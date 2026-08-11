#!/bin/sh
# Crea la red macvlan de la DMZ y el volumen compartido (idempotente).
docker network inspect dmznet >/dev/null 2>&1 || \
  docker network create -d macvlan \
    --subnet=10.10.30.0/24 --gateway=10.10.30.1 \
    -o parent=eth0 dmznet
docker volume inspect dropbox >/dev/null 2>&1 || docker volume create dropbox
echo "[OK] Red macvlan 'dmznet' y volumen 'dropbox' listos."
