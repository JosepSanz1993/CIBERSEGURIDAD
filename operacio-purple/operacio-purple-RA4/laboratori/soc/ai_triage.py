# ============================================================================
#  TRIATGE AMB IA (RA4) — El SOC envia cada alerta a una IA perquè l'analitzi:
#  severitat, tècnica MITRE, explicació en llenguatge natural i remediació.
#
#  Funciona en 4 modes (variable AI_PROVIDER al fitxer .env):
#    manual     -> (per defecte) NO fa cap crida de xarxa. Genera el prompt
#                  perquè l'enganxis a qualsevol xatbot (Claude, ChatGPT, Gemini...).
#                  Pensat perquè CAP alumne quedi bloquejat sense claus d'API.
#    openai     -> crida l'API d'OpenAI       (cal OPENAI_API_KEY)
#    anthropic  -> crida l'API d'Anthropic    (cal ANTHROPIC_API_KEY)
#    ollama     -> crida un model LOCAL amb Ollama (sense núvol, privat)
#
#  Punt de reflexió (Sessió 6): enviar logs a una IA al núvol té implicacions
#  de PRIVADESA. El mode "ollama" (local) i el mode "manual" ho eviten.
# ============================================================================
import os
import json
import requests

PROVIDER = os.environ.get("AI_PROVIDER", "manual").lower()
AI_MODEL = os.environ.get("AI_MODEL", "")
OPENAI_KEY = os.environ.get("OPENAI_API_KEY", "")
ANTHROPIC_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://host.docker.internal:11434")

TIMEOUT = 30


def build_prompt(alert):
    """Construeix el prompt de triatge. El mateix text val per a qualsevol IA."""
    return (
        "Ets un analista de seguretat (blue team) en un laboratori educatiu de purple team.\n"
        "Analitza aquesta alerta de seguretat i respon NOMÉS amb un objecte JSON amb les claus:\n"
        '  "severitat": baixa|mitjana|alta|critica,\n'
        '  "tactica_mitre": nom de la tàctica,\n'
        '  "tecnica_mitre": id i nom de la tècnica,\n'
        '  "explicacio": què està passant, màxim 2 frases, en català,\n'
        '  "remediacio": com defensar-se, màxim 2 frases, en català,\n'
        '  "fals_positiu_probable": true|false\n\n'
        "ALERTA:\n" + json.dumps(alert, ensure_ascii=False, indent=2)
    )


def triage(alert):
    """Retorna un diccionari amb el triatge de la IA (o el prompt en mode manual)."""
    prompt = build_prompt(alert)
    try:
        if PROVIDER == "openai" and OPENAI_KEY:
            return _parse(_call_openai(prompt))
        if PROVIDER == "anthropic" and ANTHROPIC_KEY:
            return _parse(_call_anthropic(prompt))
        if PROVIDER == "ollama":
            return _parse(_call_ollama(prompt))
    except Exception as e:  # si falla la xarxa/clau, no trenquem el SOC
        return {"mode": "error", "error": str(e), "prompt": prompt}
    # Mode manual (per defecte)
    return {"mode": "manual", "prompt": prompt}


def _parse(text):
    """Intenta llegir la resposta com a JSON; si no, la desa com a text pla."""
    raw = (text or "").strip()
    cleaned = raw
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        cleaned = cleaned.split("\n", 1)[-1] if "\n" in cleaned else cleaned
    try:
        start = cleaned.index("{")
        end = cleaned.rindex("}") + 1
        data = json.loads(cleaned[start:end])
        data["mode"] = "ia"
        return data
    except Exception:
        return {"mode": "text", "text": raw}


def _call_openai(prompt):
    model = AI_MODEL or "gpt-4o-mini"
    r = requests.post(
        "https://api.openai.com/v1/chat/completions",
        headers={"Authorization": f"Bearer {OPENAI_KEY}"},
        json={"model": model, "messages": [{"role": "user", "content": prompt}],
              "temperature": 0.2},
        timeout=TIMEOUT,
    )
    r.raise_for_status()
    return r.json()["choices"][0]["message"]["content"]


def _call_anthropic(prompt):
    model = AI_MODEL or "claude-3-5-haiku-latest"
    r = requests.post(
        "https://api.anthropic.com/v1/messages",
        headers={"x-api-key": ANTHROPIC_KEY, "anthropic-version": "2023-06-01"},
        json={"model": model, "max_tokens": 500,
              "messages": [{"role": "user", "content": prompt}]},
        timeout=TIMEOUT,
    )
    r.raise_for_status()
    return r.json()["content"][0]["text"]


def _call_ollama(prompt):
    model = AI_MODEL or "llama3.2"
    r = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={"model": model, "prompt": prompt, "stream": False},
        timeout=TIMEOUT,
    )
    r.raise_for_status()
    return r.json().get("response", "")
