# Laboratori L2 (macvlan) — DHCP / DNS / ARP reals

Aquest segment converteix OOPS_4 en un servidor DHCP+DNS **atacable de veritat**,
amb una víctima que demana IP i un atacant Kali, tots al mateix domini de
col·lisió L2 (`10.10.30.0/24`).

## Per què macvlan (i els seus límits)

- **A favor:** cada contenidor té MAC pròpia → broadcasts, ARP i DHCP reals.
  Pots fer DHCP starvation, rogue DHCP, ARP/DNS spoofing… com al món físic.
- **Límits honestos:**
  - Necessita **NIC física en mode promiscu**; amb **Wi-Fi sol fallar** (drivers
    que rebutgen múltiples MACs). Fes-ho amb **Ethernet**.
  - Per defecte **l'amfitrió no veu els seus contenidors macvlan** → per això
    `setup-macvlan.sh` crea un *shim* (`oops-shim`, 10.10.30.2).
  - macvlan **no admet `--internal`** ni segmentació fàcil multi-VLAN. Aquí fem
    **un sol segment L2** (que és el que necessites per als atacs de capa 2).
  - Molts **VPS/cloud bloquegen** el mode promiscu: fes-ho en maquinari propi.
  - El DHCP **no encaixa bé amb Compose** (cal null-IPAM + `dhclient`), per això
    aquí fem servir **scripts**.

## Posada en marxa

```bash
cd macvlan
bash setup-macvlan.sh        # crea xarxa L2 + promisc + shim   (root)
bash run-lab.sh              # OOPS_4 (DHCP+DNS) + atacant Kali
bash spawn-victim.sh         # una víctima que fa DHCP real
docker exec -it attacker bash   # la teva consola d'atac
# ... quan acabis:
bash teardown.sh
```

Comprova que tot "respira":
```bash
docker logs -f oops4         # veuràs els DHCPDISCOVER/OFFER/REQUEST/ACK
docker logs -f victim        # veuràs la IP i el DNS que li han donat
```

---

## Objectius i pistes (spoilers plegats)

### 🎯 O1 — Transferència de zona (AXFR)
Descobreix tota la xarxa interna a partir del DNS mal configurat.
<details><summary>Pista 1</summary>El servei de DNS d'OOPS_4 permet una operació que hauria d'estar restringida a servidors secundaris.</details>
<details><summary>Pista 2</summary><code>dig axfr oops.lab @10.10.30.14</code> — fixa't en els registres A i TXT.</details>

### 🎯 O2 — Observa i entén el DHCP
Captura l'intercanvi DORA i identifica quин servidor mana.
<details><summary>Pista 1</summary>Des de l'atacant: <code>tcpdump -i eth0 -n port 67 or port 68</code> mentre llances una víctima.</details>
<details><summary>Pista 2</summary>Quin valor porta l'opció 6 (DNS) a l'OFFER? Aquí és on tot el trànsit de noms queda a mans d'OOPS_4… o de qui respongui primer.</details>

### 🎯 O3 — DHCP starvation
Esgota el pool d'OOPS_4 perquè no pugui servir més leases.
<details><summary>Pista 1</summary>El pool és petit a propòsit (10.10.30.100–200). Inunda'l amb sol·licituds amb MACs falses.</details>
<details><summary>Pista 2</summary>A Kali: <code>ettercap</code> o eines de <code>dsniff</code>; també pots scriptar <code>dhclient</code> amb múltiples <code>--client-id</code>. Observa a <code>docker logs oops4</code> com s'esgoten les adreces.</details>

### 🎯 O4 — Rogue DHCP + presa de control del DNS
Sigues tu qui respongui el DHCP i imposa el teu DNS a la víctima.
<details><summary>Pista 1</summary>L'atacant ja porta <code>dnsmasq</code> i <code>isc-dhcp-server</code>. Munta el teu propi DHCP anunciant <code>option 6</code> = la teva IP (10.10.30.10).</details>
<details><summary>Pista 2</summary>Combina'l amb O3: si el servidor legítim està esgotat, el teu respondrà primer. Després resol <code>oops.lab</code> amb els teus propis registres i redirigeix la víctima on vulguis.</details>

### 🎯 O5 — ARP/DNS spoofing (man-in-the-middle)
Intercepta el trànsit de la víctima sense tocar el DHCP.
<details><summary>Pista 1</summary><code>ettercap -T -i eth0 -M arp /10.10.30.100// /10.10.30.14//</code> per posar-te al mig.</details>
<details><summary>Pista 2</summary>Amb <code>dnsspoof</code> (dsniff) o el plugin de DNS d'ettercap pots forjar respostes per a <code>oops.lab</code> i enviar la víctima a la teva màquina.</details>

### 🎯 O6 (opcional) — Pont cap a la resta del CTF
Enllaça aquest segment L2 amb el laboratori principal (bridge) per fer moviment
lateral "complet".
<details><summary>Pista</summary>Pots connectar també OOPS_5 a <code>oops_l2</code> (<code>docker network connect oops_l2 oops5</code>) i practicar el salt un cop hagis compromès el segment. La credencial reutilitzada segueix sent la d'OOPS_4 → OOPS_5.</details>

---

## Neteja i seguretat

- `bash teardown.sh` esborra contenidors, shim, xarxa i treu el promisc.
- **Mai** connectis aquest segment a la teva LAN real: un rogue DHCP es menjaria
  la teva xarxa domèstica. Fes-ho en una NIC dedicada o en un host aïllat.
