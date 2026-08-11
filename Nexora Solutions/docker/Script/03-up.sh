#!/bin/sh
# Levanta (o recrea) los tres contenedores de la DMZ con su IP y politica de reinicio.
docker rm -f web ftpsmtp dir 2>/dev/null

docker run -d --name web --network dmznet --ip 10.10.30.11 \
  --restart unless-stopped -v dropbox:/var/www/html/uploads web-image

docker run -d --name ftpsmtp --network dmznet --ip 10.10.30.12 \
  --restart unless-stopped -v dropbox:/srv/ftp/uploads ftp-image

docker run -d --name dir --network dmznet --ip 10.10.30.13 \
  --restart unless-stopped dir-image

echo "[OK] Contenedores levantados:"
docker ps
