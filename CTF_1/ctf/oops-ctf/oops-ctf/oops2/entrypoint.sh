#!/bin/bash
set -e
PGBIN=$(ls -d /usr/lib/postgresql/*/bin | head -1)
PGDATA=/var/lib/postgresql/data
mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA"

if [ ! -f "$PGDATA/PG_VERSION" ]; then
    su postgres -c "$PGBIN/initdb -D $PGDATA" >/dev/null
    # Exposa PostgreSQL a la xarxa interna i permet auth per contrasenya
    echo "listen_addresses='*'" >> "$PGDATA/postgresql.conf"
    echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"

    su postgres -c "$PGBIN/pg_ctl -D $PGDATA -w start"
    su postgres -c "psql -f /opt/init.sql"
    # Insereix la clau SSH privada generada al build
    KEY=$(sed 's/'"'"'/'"''"'/g' /tmp/dbuser_key)
    su postgres -c "psql -d intranet -c \"INSERT INTO ssh_keys(owner,private_key) VALUES ('dbuser', \$\$${KEY}\$\$);\""
    su postgres -c "$PGBIN/pg_ctl -D $PGDATA -w stop"
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/oops2.conf
