#!/bin/sh
echo "=== Contenedores ==="
docker ps -a --filter name=web --filter name=ftpsmtp --filter name=dir
echo ""
echo "=== Ultimas lineas de log ==="
for c in web ftpsmtp dir; do
  echo "--- $c ---"; docker logs --tail 3 "$c" 2>&1
done
