#!/bin/bash
set -e

# Fixa la contrasenya de root al hash cruixible (password real: "dragon")
sed -i 's|^root:[^:]*:|root:$5$R00tS4lt$Lzq8t3vvtPkOABDf4CDvJU/BgzbMUE.FnDLekEXAXT/:|' /etc/shadow

mkdir -p /data/db
# Arrenca mongod temporalment i carrega el seed (mongosh ve amb mongodb-org-shell;
# si no l'has instal·lat, instal·la 'mongodb-mongosh' o carrega el seed manualment)
mongod --bind_ip 0.0.0.0 --fork --logpath /var/log/mongod.log
sleep 3
if command -v mongosh >/dev/null 2>&1; then
    mongosh --quiet /opt/mongo-init.js || true
else
    echo "[!] mongosh no instal·lat: carrega /opt/mongo-init.js manualment" >&2
fi
mongod --shutdown || true
sleep 2

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/oops3.conf
