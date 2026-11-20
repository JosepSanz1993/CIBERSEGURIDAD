# ============================================================================
#  PANELL WEB del blue team (SOC).  http://localhost:8000
#  Mostra les alertes (amb el triatge d'IA), estadístiques i els logs en viu.
#  En arrencar, engega també el motor de detecció (detector.py) en segon pla.
# ============================================================================
import os
import json

from flask import Flask, render_template, jsonify

import detector

ALERTS_FILE = "/logs/alerts.jsonl"
app = Flask(__name__)


def read_alerts(limit=100):
    if not os.path.exists(ALERTS_FILE):
        return []
    alerts = []
    with open(ALERTS_FILE, "r", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                alerts.append(json.loads(line))
            except json.JSONDecodeError:
                pass
    return list(reversed(alerts))[:limit]


def tail(path, n=25):
    if not os.path.exists(path):
        return []
    with open(path, "r", errors="ignore") as f:
        return [l.rstrip() for l in f.readlines()[-n:]]


@app.route("/")
def index():
    alerts = read_alerts()
    stats = {"alta": 0, "critica": 0, "mitjana": 0, "baixa": 0}
    for a in alerts:
        sev = a.get("severity", "mitjana")
        stats[sev] = stats.get(sev, 0) + 1
    return render_template(
        "index.html",
        alerts=alerts,
        stats=stats,
        total=len(alerts),
        web=tail("/logs/web/access.log"),
        ssh=tail("/logs/ssh/sshd.log"),
        provider=os.environ.get("AI_PROVIDER", "manual"),
    )


@app.route("/api/alerts")
def api_alerts():
    return jsonify(read_alerts())


if __name__ == "__main__":
    detector.start_background()
    app.run(host="0.0.0.0", port=8000)
