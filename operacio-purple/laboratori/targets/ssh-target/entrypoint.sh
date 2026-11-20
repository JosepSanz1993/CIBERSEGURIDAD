#!/bin/sh
# Prepara el directori de logs compartit i engega sshd escrivint directament
# a un fitxer (-E) perquè el blue team (SOC) pugui llegir els intents de login.
set -e

mkdir -p /logs/ssh
touch /logs/ssh/sshd.log

# Genera les claus de host si encara no existeixen
ssh-keygen -A

echo "[ssh-target] sshd escoltant al port 22. Logs -> /logs/ssh/sshd.log"
# -D: no es desconnecta (primer pla) · -e/-E: registra a fitxer en lloc de syslog
exec /usr/sbin/sshd -D -E /logs/ssh/sshd.log
