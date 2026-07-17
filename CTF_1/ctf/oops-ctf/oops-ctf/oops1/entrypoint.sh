#!/bin/bash
set -e

# Inicialitza el datadir de MariaDB si cal
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1
fi

# Arrenca MariaDB temporalment per carregar el seed
mariadbd --user=mysql &
MPID=$!
for i in $(seq 1 30); do
    mariadb -e "SELECT 1" >/dev/null 2>&1 && break
    sleep 1
done
mariadb < /docker-entrypoint-initdb.d/init.sql || true
mysqladmin shutdown 2>/dev/null || kill $MPID 2>/dev/null || true
sleep 2

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/oops1.conf
