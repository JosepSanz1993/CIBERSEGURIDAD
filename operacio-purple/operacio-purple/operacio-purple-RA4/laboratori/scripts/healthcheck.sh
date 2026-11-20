#!/bin/sh
# Comprova que el laboratori està viu i que les màquines es "veuen" entre elles.
# Ús:  sh scripts/healthcheck.sh
echo "== Contenidors en marxa =="
docker compose ps

echo
echo "== El web respon? (via proxy) =="
curl -s -o /dev/null -w "DVWA (http://localhost:8080): %{http_code}\n" http://localhost:8080 || echo "DVWA no respon"

echo
echo "== El panell del SOC respon? =="
curl -s -o /dev/null -w "SOC (http://localhost:8000): %{http_code}\n" http://localhost:8000 || echo "SOC no respon"

echo
echo "== L'atacant veu les víctimes? (ping dins la xarxa del lab) =="
docker compose exec -T attacker sh -c '
  for ip in 172.30.0.15 172.30.0.20 172.30.0.30 172.30.0.40; do
    if ping -c1 -W1 $ip >/dev/null 2>&1; then echo "  OK   $ip"; else echo "  FALLA $ip"; fi
  done'
