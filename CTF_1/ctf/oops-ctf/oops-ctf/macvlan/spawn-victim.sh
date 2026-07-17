#!/bin/bash
# Llança una víctima que farà DHCP real al segment L2.
# Nota: amb IPAM normal de macvlan, Docker li assigna una IP inicial; l'entrypoint
# l'allibera i força un DORA real contra OOPS_4. Pots llançar-ne diverses
# (NAME=victim2) per practicar DHCP starvation amb més "sorolls".
set -e
NET="oops_l2"
NAME="${NAME:-victim}"
HERE="$(cd "$(dirname "$0")" && pwd)"

docker build -t oops-victim:latest "$HERE/victim"
docker rm -f "$NAME" 2>/dev/null || true
docker run -dit --name "$NAME" --hostname "$NAME" \
  --network "$NET" --cap-add NET_ADMIN --cap-add NET_RAW \
  oops-victim:latest

echo "[✓] Víctima '$NAME' en marxa. Mira-la amb:  docker logs -f $NAME"
