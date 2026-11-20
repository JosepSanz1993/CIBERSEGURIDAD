#!/bin/sh
# Neteja els logs i les alertes per començar un exercici de zero
# (NO esborra els contenidors; per a això fes "docker compose down -v").
echo "Netejant logs i alertes..."
rm -f ../logs/web/access.log ../logs/web/error.log ../logs/ssh/sshd.log ../logs/alerts.jsonl 2>/dev/null
rm -f logs/web/access.log logs/web/error.log logs/ssh/sshd.log logs/alerts.jsonl 2>/dev/null
echo "Fet. Reinicia els serveis si cal:  docker compose restart web-proxy ssh-target soc"
