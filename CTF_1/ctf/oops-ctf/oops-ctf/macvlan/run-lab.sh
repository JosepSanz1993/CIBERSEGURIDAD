#!/bin/bash
# Aixeca la infraestructura L2: OOPS_4 (servidor DHCP+DNS) i l'atacant (Kali).
# Requereix haver executat abans:  bash setup-macvlan.sh
set -e
NET="oops_l2"
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Construint imatge d'OOPS_4..."
docker build -t oops4:latest "$HERE/../oops4"

echo "[*] Arrencant OOPS_4 (10.10.30.14) amb DHCP+DNS reals..."
docker rm -f oops4 2>/dev/null || true
docker run -d --name oops4 --hostname oops4 \
  --network "$NET" --ip 10.10.30.14 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  -v "$HERE/oops4-dnsmasq.conf:/etc/dnsmasq.d/oops.conf:ro" \
  oops4:latest

echo "[*] Construint imatge de l'atacant (Kali + eines L2)... (triga la 1a vegada)"
docker build -t oops-attacker:latest "$HERE/attacker"

echo "[*] Arrencant l'atacant (10.10.30.10)..."
docker rm -f attacker 2>/dev/null || true
docker run -dit --name attacker --hostname attacker \
  --network "$NET" --ip 10.10.30.10 \
  --cap-add NET_ADMIN --cap-add NET_RAW \
  oops-attacker:latest

echo
echo "[✓] Infra L2 en marxa."
echo "    · Entra a l'atacant:   docker exec -it attacker bash"
echo "    · Llança una víctima:  bash spawn-victim.sh"
echo "    · Logs DHCP d'oops4:   docker logs -f oops4"
