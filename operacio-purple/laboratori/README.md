# 🛡️🟥🟦 Purple Lab — Laboratori de Purple Team amb Docker

Laboratori educatiu i **aïllat** per practicar ciberseguretat ofensiva (red team)
i defensiva (blue team) alhora, amb **IA integrada** a cada fase.
Pensat per a l'assignatura **Digitalització (RA4)** del cicle **ASIX**.

> ⚖️ **Ús exclusiu dins d'aquest laboratori aïllat.** Atacar sistemes de tercers
> sense autorització per escrit és un delicte. Aquí tu ets el propietari de tot.

---

## Què hi ha dins (tot en contenidors, al teu portàtil)

| Contenidor | Rol | Adreça | Com s'hi accedeix |
|---|---|---|---|
| `attacker`  | 🟥 Red team (nmap, hydra, sqlmap, curl) | 172.30.0.10 | `docker compose exec attacker bash` |
| `web-proxy` | Nginx que registra el trànsit web | 172.30.0.15 | — |
| `dvwa`      | 🎯 Web vulnerable (seguretat ajustable) | 172.30.0.20 | http://localhost:8080 |
| `ssh-target`| 🎯 SSH amb contrasenya feble | 172.30.0.30 | `ssh -p 2222 lab@localhost` |
| `soc`       | 🟦 Blue team: detecció + IA + panell | 172.30.0.40 | http://localhost:8000 |

---

## Posada en marxa (4 passos)

```bash
# 1) Copia la configuració d'IA (per començar, deixa AI_PROVIDER=manual)
cp .env.example .env

# 2) Aixeca tot el laboratori (la primera vegada descarrega/compila; triga una estona)
docker compose up -d --build

# 3) Comprova que tot està viu i que les màquines es veuen entre elles
sh scripts/healthcheck.sh

# 4) Obre les dues finestres clau al navegador:
#    - Web víctima:  http://localhost:8080   (DVWA; login admin / password, i "Create/Reset Database")
#    - Panell SOC:   http://localhost:8000   (blue team)
```

Per entrar a la màquina atacant i llançar atacs:
```bash
docker compose exec attacker bash
# dins del contenidor ja tens nmap, hydra, sqlmap, curl, diccionaris a /wordlists ...
```

Per aturar-ho tot:
```bash
docker compose down        # atura (conserva imatges)
docker compose down -v      # atura i esborra volums/estat
```

---

## El bucle del purple team

1. 🟥 **Red** llança una tècnica des de `attacker` (p. ex. força bruta SSH).
2. 🟦 **Blue** la detecta: el SOC llegeix els logs, dispara una **alerta** i
   demana **triatge a la IA** (severitat, MITRE ATT&CK, explicació, remediació).
3. 🤝 **Purple**: enduriu la defensa (pugeu el nivell de DVWA, bloquegeu la IP…)
   i torneu a atacar per comprovar que ara es mitiga.
4. 📝 Documenteu-ho tot a l'informe final.

Les regles de detecció són a `soc/rules.yaml` (obre-les i modifica-les!).
Les receptes d'IA per fer a mà són a `ai/prompts/`.

---

## Mode d'IA (fitxer `.env`)

- `manual` (per defecte): sense claus ni internet. El SOC genera un *prompt* que
  copies a qualsevol xatbot. **Cap alumne queda bloquejat.**
- `anthropic` / `openai`: triatge automàtic amb API (cal clau).
- `ollama`: model **local** al teu ordinador (privat, ideal per parlar de privadesa).

---

## Problemes freqüents

- **DVWA dona error de BD:** entra a http://localhost:8080, login `admin`/`password`,
  i clica *Create / Reset Database*.
- **El SOC no mostra alertes:** recorda que només analitza el trànsit a partir del
  moment en què arrenca. Llança un atac i espera uns segons (refresca cada 5s).
- **`host.docker.internal` no funciona a Linux (mode ollama):** afegeix al servei
  `soc` del compose: `extra_hosts: ["host.docker.internal:host-gateway"]`.
- **Ports ocupats (8080/8000/2222):** canvia'ls al `docker-compose.yml`.
