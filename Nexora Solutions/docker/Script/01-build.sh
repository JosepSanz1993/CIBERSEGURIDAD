#!/bin/sh
# Construye las tres imagenes de la DMZ. Requiere NAT activa (Internet).
BASE="$(cd "$(dirname "$0")/.." && pwd)"
echo "[*] Construyendo web-image..."
docker build -t web-image "$BASE/web" || exit 1
echo "[*] Construyendo ftp-image..."
docker build -t ftp-image "$BASE/ftp" || exit 1
echo "[*] Construyendo dir-image..."
docker build -t dir-image "$BASE/dir" || exit 1
echo "[OK] Imagenes construidas:"
docker images | grep -E "web-image|ftp-image|dir-image"
