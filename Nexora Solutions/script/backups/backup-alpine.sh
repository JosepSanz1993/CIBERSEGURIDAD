#!/bin/sh
# ============================================================
# Backup de configuracion - Host Docker Alpine (Nexora lab)
# Respalda: config del host + configs reales de los 3 contenedores
# Ejecutar como root en el host Alpine.
# ============================================================
set -e
DEST=~/backup-config
rm -rf "$DEST"
mkdir -p "$DEST/host" "$DEST/web" "$DEST/ftpsmtp" "$DEST/dir"

echo "[*] Respaldando configuracion del host Alpine..."
cp /etc/network/interfaces          "$DEST/host/"          2>/dev/null || true
cp /etc/local.d/promisc.start       "$DEST/host/"          2>/dev/null || true
cp /etc/apk/repositories            "$DEST/host/"          2>/dev/null || true
# Inventario de contenedores, red macvlan y volumenes (para documentar el estado)
docker ps -a           > "$DEST/host/docker-ps.txt"        2>/dev/null || true
docker images          > "$DEST/host/docker-images.txt"    2>/dev/null || true
docker network inspect dmznet > "$DEST/host/dmznet.json"   2>/dev/null || true
docker volume ls       > "$DEST/host/docker-volumes.txt"   2>/dev/null || true

echo "[*] Extrayendo config del contenedor web (Apache/TLS/intranet/BD)..."
docker cp web:/etc/httpd/conf.d/ssl.conf  "$DEST/web/"           2>/dev/null || true
docker cp web:/root/init.sql              "$DEST/web/"           2>/dev/null || true
docker cp web:/var/www/html               "$DEST/web/intranet"   2>/dev/null || true

echo "[*] Extrayendo config del contenedor ftpsmtp (FTP + SMTP)..."
docker cp ftpsmtp:/etc/vsftpd/vsftpd.conf "$DEST/ftpsmtp/"       2>/dev/null || true
docker cp ftpsmtp:/smtp.py                "$DEST/ftpsmtp/"       2>/dev/null || true

echo "[*] Extrayendo config del contenedor dir (LDAP + SNMP)..."
docker cp dir:/opt/symas/etc/openldap/slapd.conf "$DEST/dir/"    2>/dev/null || true
docker cp dir:/root/datos.ldif                    "$DEST/dir/"   2>/dev/null || true
docker cp dir:/etc/snmp/snmpd.conf                "$DEST/dir/"   2>/dev/null || true

echo "[*] Comprimiendo (cpio+gzip, sin depender de tar)..."
cd "$DEST"
find . -type f | cpio -o 2>/dev/null | gzip > ~/backup-alpine.cpio.gz

echo ""
echo "[OK] Backup completo en ~/backup-alpine.cpio.gz"
echo "     Contenido:"
find "$DEST" -type f | sed "s|$DEST|  |"
