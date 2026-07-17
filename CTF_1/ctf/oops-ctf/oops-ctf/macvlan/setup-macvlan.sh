#!/bin/bash
# =============================================================================
#  setup-macvlan.sh  ·  Crea el segment L2 realista per a atacs DHCP/DNS/ARP
# =============================================================================
#  macvlan dóna a cada contenidor la seva pròpia MAC sobre una NIC física real,
#  de manera que broadcasts, ARP i DHCP funcionen "de veritat".
#
#  REQUISITS:
#   · NIC preferiblement CABLEJADA (Wi-Fi sol rebutjar múltiples MACs).
#   · Permisos root (ip link, promisc).
#   · No funciona bé dins de molts VPS/clouds (bloquegen mode promiscu).
# =============================================================================
set -e

# Interfície pare: autodetecta la de la ruta per defecte; pots forçar-la:
#   PARENT_IF=eth0 bash setup-macvlan.sh
PARENT_IF="${PARENT_IF:-$(ip route | awk '/default/ {print $5; exit}')}"
SUBNET="10.10.30.0/24"
GW="10.10.30.1"
NET="oops_l2"

echo "[i] Interfície pare : $PARENT_IF"
echo "[i] Subxarxa L2     : $SUBNET"

if [ -z "$PARENT_IF" ]; then
  echo "[!] No s'ha detectat cap interfície. Defineix PARENT_IF=<nom> i torna-ho a provar."
  exit 1
fi

# 1) Mode promiscu a la NIC pare (necessari per rebre trames d'altres MACs)
sudo ip link set "$PARENT_IF" promisc on && echo "[+] Promisc ON a $PARENT_IF"

# 2) Xarxa macvlan (IPAM normal per a la infraestructura estàtica)
if docker network inspect "$NET" >/dev/null 2>&1; then
  echo "[=] La xarxa $NET ja existeix"
else
  docker network create -d macvlan \
    --subnet "$SUBNET" --gateway "$GW" \
    -o parent="$PARENT_IF" "$NET" \
  && echo "[+] Xarxa macvlan $NET creada sobre $PARENT_IF"
fi

# 3) Shim a l'amfitrió perquè EL TEU HOST pugui parlar amb els contenidors
#    (per defecte macvlan aïlla host<->contenidor). Opcional però còmode.
if ! ip link show oops-shim >/dev/null 2>&1; then
  sudo ip link add oops-shim link "$PARENT_IF" type macvlan mode bridge
  sudo ip addr add 10.10.30.2/24 dev oops-shim
  sudo ip link set oops-shim up
  sudo ip route add 10.10.30.0/24 dev oops-shim 2>/dev/null || true
  echo "[+] Shim 'oops-shim' (10.10.30.2) creat: el host ja arriba al segment L2"
else
  echo "[=] Shim 'oops-shim' ja existeix"
fi

echo
echo "[✓] Segment L2 llest. Continua amb:  bash run-lab.sh"
