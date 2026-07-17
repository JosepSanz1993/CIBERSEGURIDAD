#!/bin/bash
# Neteja el laboratori L2: contenidors, shim, promisc i xarxa.
PARENT_IF="${PARENT_IF:-$(ip route | awk '/default/ {print $5; exit}')}"

docker rm -f oops4 attacker victim victim2 victim3 2>/dev/null || true
sudo ip link del oops-shim 2>/dev/null || true
docker network rm oops_l2 2>/dev/null || true
[ -n "$PARENT_IF" ] && sudo ip link set "$PARENT_IF" promisc off 2>/dev/null || true
echo "[✓] Laboratori L2 desmuntat."
