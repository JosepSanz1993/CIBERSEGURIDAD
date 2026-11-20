# 🤖 IA ofensiva (red team) — Copilot de reconeixement

> Aquestes receptes funcionen amb **qualsevol** assistent d'IA (Claude, ChatGPT,
> Gemini, Copilot, o un model local amb Ollama). No cal cap clau d'API.
> Ús dins del laboratori aïllat i amb finalitat educativa.

## Per què això és "aplicació de la IA al sector" (RA4)
Un analista pot trigar molt a llegir i prioritzar la sortida d'un escaneig.
Una IA la resumeix, prioritza el que és explotable i proposa els passos següents
en segons. Aquí veus la **millora implícita** (velocitat, priorització) i també
els **límits** (pot inventar-se serveis o versions: has de verificar sempre).

---

## Recepta 1 — Resumir i prioritzar un escaneig Nmap
Enganxa la sortida de `nmap -sV` i demana:

```
Ets un assistent de pentesting en un laboratori educatiu i aïllat.
A partir d'aquesta sortida de Nmap, dona'm:
1) Una taula de serveis oberts (port, servei, versió).
2) Els 3 vectors d'atac més probables, ordenats per facilitat d'explotació.
3) Per a cada vector, quina eina del lab faria servir (nmap, hydra, sqlmap, curl).
4) AVÍS: marca què NO pots confirmar només amb l'escaneig i hauria de verificar.

SORTIDA NMAP:
<enganxa-la-aquí>
```

## Recepta 2 — Explicar un servei desconegut
```
Explica'm en 3 frases què és el servei <X> versió <Y>, per a què s'usa
i quins riscos de seguretat típics té. Indica si la versió és antiga.
```

## Recepta 3 — Generar un diccionari de contrasenyes contextual
```
Genera 15 contrasenyes febles probables per a un servidor de pràctiques
d'un institut anomenat "lab". Només per a un laboratori aïllat educatiu.
```

> ⚠️ **Verifica sempre.** La IA pot "al·lucinar" ports, versions o vulnerabilitats
> que no existeixen. La IA proposa hipòtesis; tu les confirmes amb les eines.
