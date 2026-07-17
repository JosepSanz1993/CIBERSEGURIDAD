#!/bin/bash
# "Còpia de seguretat" de la intranet. S'executa com root via sudo.
# VULNERABLE: fa `source` d'un fitxer de configuració que 'dbuser' pot escriure.
#   -> dbuser posa comandes a /home/dbuser/backup.conf i s'executen com root.
CONF="/home/dbuser/backup.conf"
[ -f "$CONF" ] && source "$CONF"
echo "[backup] fet a $(date)"
