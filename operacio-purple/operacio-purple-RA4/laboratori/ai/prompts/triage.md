# 🤖 IA defensiva (blue team) — Triatge d'alertes i logs

> Funciona amb qualsevol assistent d'IA. És el mateix que fa automàticament el SOC
> (`soc/ai_triage.py`), però aquí ho fas tu a mà per entendre-ho.

## Per què això és "aplicació de la IA al sector" (RA4)
Un SOC rep milers d'esdeveniments. La IA ajuda a **classificar severitat**,
**mapar a MITRE ATT&CK**, **explicar en llenguatge natural** i **proposar
remediació** — tasques que abans depenien només d'un analista expert.
Millora: escala i rapidesa. Límit: falsos positius i privadesa de les dades.

---

## Recepta 1 — Triatge d'una alerta
```
Ets un analista SOC (blue team) en un laboratori educatiu.
Analitza aquesta alerta i respon amb:
- Severitat (baixa/mitjana/alta/crítica) i per què.
- Tàctica i tècnica MITRE ATT&CK.
- Explicació en 2 frases.
- Remediació concreta en 2 frases.
- És probable que sigui un fals positiu? Per què?

ALERTA / LÍNIES DE LOG:
<enganxa aquí línies de /logs/web/access.log o /logs/ssh/sshd.log>
```

## Recepta 2 — Convertir un atac observat en una regla de detecció
```
A partir d'aquestes línies de log d'un atac, escriu una expressió regular
(Python) que el detectaria, i explica quins falsos positius podria causar.

LOG:
<enganxa aquí>
```

## Recepta 3 — Resumir l'activitat del dia per a un informe
```
Resumeix aquestes alertes en 5 punts per a un informe de torn de SOC,
ordenades per risc, indicant si cal escalar alguna.

ALERTES:
<enganxa aquí el contingut de /logs/alerts.jsonl>
```

> ⚠️ **Privadesa (punt clau de la Sessió 6):** enganxar logs reals a una IA al
> núvol pot filtrar dades sensibles (IPs, usuaris, rutes internes). Al lab no passa
> res, però a l'empresa s'usaria un model **local** (Ollama) o s'anonimitzarien les dades.
