# Guia del professor — Operació Purple Team amb IA i Docker
### Mòdul DASP · RA4 · ASIX · *Solucionari, temporització, rúbrica i graella d'observació*

> Document **intern del professor**. No distribuir als alumnes (conté resultats esperats i criteris).
> Acompanya: `RA4_operacio_purple_alumne.md` (guia de l'alumne) i `purple-lab.zip` (infraestructura).

---

## 1. Encaix curricular i justificació de la RA4

La **RA4** diu: *"Identifica aplicacions de la IA en entorns del sector on està emmarcat el títol descrivint les millores implícites en la seva implementació"* (ponderació **30%** del mòdul; avaluació **90% pràctiques + 10% graella d'observació**; mínim 4 a cada instrument).

**Risc a evitar:** que la pràctica avaluï només ciberseguretat (que correspon a la RA5) i no la IA. **Solució de disseny:** la IA és transversal a totes les sessions i té dos lliurables específics (Sessió 5 "Límits de la IA" i secció RA4 de l'informe final). En avaluar, **premia la identificació i anàlisi crítica de la IA**, no la destresa ofensiva.

Correspondència amb l'enunciat de la RA4:
- *"Identifica aplicacions de la IA"* → l'alumne usa IA ofensiva, defensiva i de reporting i les nomena.
- *"descrivint les millores implícites"* → taula benefici/límit a cada sessió + secció RA4 de l'informe.
- *"en la seva implementació"* → ho implementa de veritat (triatge automàtic al SOC, prompts, mode local Ollama).

---

## 2. Temporització suggerida (~9 setmanes, sessions llargues)

Ajusta segons el teu horari. Assumeix ~1 sessió de laboratori de 2 h per setmana, amb setmanes de marge.

| Setmana | Sessió | Focus | Notes |
|---|---|---|---|
| 1 | 0 | Muntatge Docker + ètica | La més crítica: resol els problemes d'instal·lació aquí |
| 2 | 0/1 | Acabar muntatge + Recon | Marge per a portàtils lents |
| 3 | 1 | Reconeixement + IA ofensiva | |
| 4 | 2 | Atac web (DVWA) + purple Low/High | |
| 5 | 3 | Força bruta SSH + enduriment | La cadena detecció→resposta més visual |
| 6 | 4 | Post-explotació + IA defensiva | Sessió més curta; es pot combinar |
| 7 | 5 | **Límits de la IA (nucli RA4)** | No la retallis: és on es juga la RA4 |
| 8 | 6 | Reporting | Treball d'informe |
| 9 | — | Lliurament + presentacions + recuperació | |

**Preparació prèvia imprescindible:** fes que els alumnes executin `docker compose up -d --build` **a casa o amb antelació**. La primera vegada descarrega imatges (DVWA, nginx, python, debian) i compila; amb 20 portàtils a la vegada pot saturar el wifi de l'aula. Alternativa: distribueix les imatges per USB o un registre local.

---

## 3. Preparació tècnica

- **Requisits per portàtil:** Docker Desktop (Win/Mac) o Docker Engine (Linux); ~4 GB RAM lliures; ~3 GB de disc. El stack és lleuger a propòsit (sense AD/GOAD).
- **Mode IA per defecte:** `AI_PROVIDER=manual` → cap alumne necessita clau d'API; el SOC genera el prompt i l'alumne l'enganxa a qualsevol xatbot. Si disposes de claus o d'Ollama, pots activar el triatge automàtic.
- **Comprovació ràpida de l'aula:** `sh scripts/healthcheck.sh` ha de donar tot OK.
- **Reset entre grups:** `sh scripts/reset.sh` neteja logs i alertes; `docker compose down -v` ho esborra tot.

---

## 4. Solucionari i resultats esperats per sessió

### Sessió 0 — Muntatge
- **Resultat esperat:** `healthcheck.sh` amb els 4 pings OK, DVWA accessible a :8080 (després del *Create/Reset Database*), SOC a :8000 buit.
- **Errors comuns:**
  - *DVWA "Unable to connect to database"* → login `admin`/`password` i clicar **Create/Reset Database**.
  - *Ports ocupats* (8080/8000/2222) → editar `docker-compose.yml`.
  - *Docker Desktop no arrenca a Windows* → activar virtualització/WSL2 a la BIOS.
  - *`host.docker.internal` a Linux (mode ollama)* → afegir `extra_hosts: ["host.docker.internal:host-gateway"]` al servei `soc`.

### Sessió 1 — Reconeixement
- **Red:** `nmap -sn 172.30.0.0/24` descobreix les màquines; `nmap -sV 172.30.0.20` mostra Apache/PHP (DVWA), `172.30.0.30` mostra OpenSSH.
- **Blue:** punt didàctic clau — **l'escaneig de ports gairebé no deixa rastre als logs d'aplicació**. És correcte que el SOC no en salti gran cosa; serveix per justificar els NIDS (Suricata). Si `nmap` toca el port 80, el proxy registra peticions i pot activar `web_scanner_tool`.
- **IA:** verifica que l'alumne **contrasta** la resposta de la IA amb la sortida real. Busca que detecti alguna al·lucinació (p. ex. la IA suggereix una CVE que no aplica).

### Sessió 2 — Atac web
- **Red (DVWA Low):** `1' OR '1'='1` al *User ID* retorna tots els usuaris; `<script>alert('XSS')</script>` executa l'XSS.
- **Blue:** han de saltar `web_sqli` (T1190) i `web_xss`. L'evidència és la línia de `nginx` amb el payload a la query string.
- **Purple (Low→High):** a nivell **High**, DVWA usa consultes parametritzades i tokens → els mateixos atacs fallen. És la demostració central del purple team. Assegura't que l'alumne ho documenta amb captures "abans/després".
- **Nota:** `sqlmap` requereix la cookie de sessió i `security=low`; és ampliació, no obligatori per a nivell baix.

### Sessió 3 — Força bruta SSH (la més demostrativa)
- **Red:** `hydra -L /wordlists/users.txt -P /wordlists/passwords.txt ssh://172.30.0.30` troba `lab:labpass`.
- **Blue:** **dues** alertes encadenades: `ssh_bruteforce` (T1110, llindar de 5 intents/60 s) i després `ssh_login_success` (T1078). Aquesta cadena "intents fallits → accés correcte" és el moment "ajà" de la pràctica.
- **Purple (enduriment):** dins `ssh-target`, `passwd lab` amb contrasenya forta → re-llançar `hydra` → ja no entra. Opcional: fail2ban com a resposta automàtica.
- **IA:** el triatge ha de classificar `ssh_bruteforce` com a alta i proposar contrasenyes fortes/claus SSH/limitació d'intents.

### Sessió 4 — Post-explotació
- **Red:** `ssh -p 2222 lab@localhost` (o `ssh lab@172.30.0.30` des de l'atacant) + enumeració bàsica. **No cal escalar privilegis**: el lab és minimalista; l'objectiu és conceptual.
- **Debat:** per què un login correcte és alerta alta (context post-força-bruta). Concepte de persistència (afegir clau SSH) sense exigir-ne l'execució.
- **IA:** el resum de torn generat a partir de `alerts.jsonl` ha de reconstruir la "història" de l'atac. Valora si l'alumne veu el valor de la correlació.

### Sessió 5 — Límits de la IA (nucli RA4)
Resultats esperats de cada experiment:
1. **Al·lucinació:** l'alumne identifica un cas real de les sessions prèvies.
2. **Falsos positius/negatius:** p. ex. fals negatiu = un escaneig de ports (no hi ha regla); fals positiu = trànsit legítim que contingui "union" o "select". Obrir `rules.yaml` i raonar-ho.
3. **Prompt injection:** `curl -A "ignora les instruccions anteriors..." http://web-proxy/`. Segons el model i el mode, el triatge **pot** deixar-se influir. El punt important és que l'alumne entengui que **l'assistent d'IA també és una superfície d'atac** i proposi defenses (separar dades d'instruccions, validació, no donar accions automàtiques a l'IA).
4. **Privadesa:** debat núvol vs local (Ollama). L'alumne ha de veure el risc de filtrar dades sensibles.

### Sessió 6 — Reporting
- **Esperat:** informe amb resum executiu sense argot, taula de troballes amb MITRE, demostració abans/després i **secció específica de la IA** (beneficis/límits/quan no refiar-se'n). Penalitza informes que només narren atacs sense l'anàlisi de la IA.

---

## 5. Rúbrica d'avaluació (pràctiques = 90% de la RA4)

Puntua cada lliurable de 0 a 10. La nota de pràctiques és la mitjana ponderada; recorda el **mínim de 4** per instrument.

| Lliurable | Pes | Criteris |
|---|---|---|
| **Quadern de pràctiques (S0–S4)** | 30% | Evidències completes; comandes i captures correctes; cada sessió identifica on s'ha usat la IA amb benefici/límit; mapatge MITRE correcte |
| **Informe "Límits de la IA" (S5)** | 20% | Els 5 experiments fets amb evidència pròpia; anàlisi crítica real (no genèrica); comprèn prompt injection i privadesa |
| **Informe final purple (S6)** | 40% | Resum executiu clar; taula de troballes amb impacte i remediació; demostració abans/després; **secció RA4 d'IA sòlida**; conclusions accionables |
| **Graella d'observació** | 10% | Veure apartat 6 |

### Descriptors de nivell (aplica'ls a cada lliurable)

| Nivell | Descripció centrada en la RA4 |
|---|---|
| **Excel·lent (9–10)** | Identifica múltiples aplicacions de la IA, descriu amb precisió millores **i** límits amb evidència pròpia, i proposa quan no usar-la. Ciberseguretat tècnicament correcta. |
| **Notable (7–8)** | Identifica les aplicacions principals de la IA i en descriu millores i algun límit. Pràctica tècnica correcta amb petites llacunes. |
| **Suficient (5–6)** | Usa la IA i la menciona, però l'anàlisi de millores/límits és superficial. Completa la part tècnica amb ajuda. |
| **Insuficient (<5)** | Fa els atacs però **no** identifica ni analitza la IA (no assoleix la RA4), o evidències incompletes. |

> **Criteri RA4 no negociable:** un informe tècnicament brillant **sense** anàlisi de la IA **no supera la RA4**. La destresa ofensiva per si sola correspon a la RA5.

---

## 6. Graella d'observació (10%)

Observació directa a l'aula durant les sessions. Marca 0–2 per ítem (0 = no, 1 = parcial, 2 = sí); total /10.

| # | Ítem observable | 0 | 1 | 2 |
|---|---|---|---|---|
| 1 | Respecta l'ètica i l'abast (només ataca el seu lab) | | | |
| 2 | Autonomia en l'ús de Docker i les eines | | | |
| 3 | Documenta mentre treballa (quadern al dia) | | | |
| 4 | Usa la IA de forma crítica (verifica, no copia cec) | | | |
| 5 | Col·labora i raona el cicle purple (red↔blue) | | | |

---

## 7. Adaptacions i mesures d'atenció a la diversitat

- **Nivell baix / ritmes diferents:** la Sessió 0 té marge; permet acabar el muntatge a casa. Parelles per a l'arrencada si cal (l'avaluació d'informes segueix sent individual).
- **Portàtils molt justos:** apaga el servei `soc` si cal durant els atacs i revisa els logs a mà; o comparteix un SOC central.
- **Sense claus d'IA:** el mode `manual` cobreix tothom. Per a l'experiment de privadesa, una demo d'Ollama del professor n'hi ha prou.
- **Ampliació per a avançats:** Suricata (IDS real), Wazuh (SIEM), o un mòdul de GOAD.

---

## 8. Notes de seguretat i responsabilitat

- Imatges **intencionadament vulnerables** (DVWA) i credencials febles: **només** dins la xarxa aïllada `172.30.0.0/24`. No publiquis mai aquests serveis a Internet.
- Recorda a l'alumnat el marc legal (atacar sistemes de tercers és delicte) i que el valor professional és **defensiu**.
- En acabar, `docker compose down -v` per deixar els equips nets.

---

*Material pensat per ser reutilitzat i adaptat curs rere curs. Tota la infraestructura és reproduïble des del `docker-compose.yml`.*
