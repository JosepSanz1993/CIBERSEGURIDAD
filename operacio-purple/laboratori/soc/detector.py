# ============================================================================
#  MOTOR DE DETECCIÓ del blue team.
#  Vigila els fitxers de log de les víctimes, aplica les regles de rules.yaml
#  i, quan hi ha coincidència, crea una ALERTA (amb triatge d'IA) a
#  /logs/alerts.jsonl. El panell web (dashboard.py) mostra aquestes alertes.
# ============================================================================
import os
import re
import json
import time
import threading
from datetime import datetime, timezone

import yaml

import ai_triage

LOGS_DIR = "/logs"
ALERTS_FILE = os.path.join(LOGS_DIR, "alerts.jsonl")
RULES_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rules.yaml")

# Estat intern per a les regles de llindar: {regla: {clau_ip: [marques_de_temps]}}
_threshold_state = {}


def _now_iso():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def load_rules():
    with open(RULES_FILE, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    rules = []
    for name, cfg in data.items():
        cfg = dict(cfg)
        cfg["name"] = name
        cfg["_regex"] = re.compile(cfg["pattern"])
        rules.append(cfg)
    return rules


def _write_alert(alert):
    os.makedirs(LOGS_DIR, exist_ok=True)
    with open(ALERTS_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(alert, ensure_ascii=False) + "\n")


def _make_alert(rule, line, src_ip, count=None):
    alert = {
        "id": str(int(time.time() * 1000)),
        "ts": _now_iso(),
        "rule": rule["name"],
        "description": rule.get("description", ""),
        "severity": rule.get("severity", "mitjana"),
        "mitre": rule.get("mitre", ""),
        "src_ip": src_ip or "",
        "count": count,
        "evidence": line.strip()[:500],
    }
    # Triatge amb IA (RA4). En mode "manual" només genera el prompt, sense xarxa.
    alert["ai"] = ai_triage.triage(alert)
    _write_alert(alert)
    print(f"[ALERTA] {alert['rule']} ({alert['severity']}) src={alert['src_ip']}", flush=True)
    return alert


def _handle_line(rule, line):
    m = rule["_regex"].search(line)
    if not m:
        return
    groups = m.groupdict()
    src_ip = groups.get("ip")

    if rule.get("type", "match") == "threshold":
        key = src_ip or "global"
        window = int(rule.get("window_seconds", 60))
        threshold = int(rule.get("threshold", 5))
        state = _threshold_state.setdefault(rule["name"], {})
        marks = state.setdefault(key, [])
        now = time.time()
        marks.append(now)
        # descarta les marques fora de la finestra temporal
        marks = [t for t in marks if now - t <= window]
        state[key] = marks
        if len(marks) >= threshold:
            state[key] = []  # reinicia: una sola alerta per ràfega
            _make_alert(rule, line, src_ip, count=threshold)
    else:
        _make_alert(rule, line, src_ip)


def tail_loop(rules):
    """Segueix (tail -f) tots els fitxers de log i avalua cada línia nova."""
    sources = {}
    for r in rules:
        sources.setdefault(r["source"], []).append(r)

    offsets = {}
    print(f"[SOC] Motor de detecció actiu. Vigilant: {list(sources.keys())}", flush=True)
    while True:
        for src, src_rules in sources.items():
            try:
                if not os.path.exists(src):
                    continue
                size = os.path.getsize(src)
                if src not in offsets:
                    # Primer cop que veiem el fitxer: comencem pel final.
                    # Només analitzem el que passi A PARTIR d'ara.
                    offsets[src] = size
                    continue
                if size < offsets[src]:   # el fitxer s'ha truncat/rotat
                    offsets[src] = 0
                if size > offsets[src]:
                    with open(src, "r", errors="ignore") as f:
                        f.seek(offsets[src])
                        for line in f:
                            for r in src_rules:
                                _handle_line(r, line)
                        offsets[src] = f.tell()
            except Exception as e:
                print(f"[SOC] error llegint {src}: {e}", flush=True)
        time.sleep(2)


def start_background():
    """Engega el motor de detecció en un fil en segon pla."""
    rules = load_rules()
    t = threading.Thread(target=tail_loop, args=(rules,), daemon=True)
    t.start()
    return t


if __name__ == "__main__":
    # Permet executar el detector tot sol per depurar: python detector.py
    start_background()
    while True:
        time.sleep(3600)
