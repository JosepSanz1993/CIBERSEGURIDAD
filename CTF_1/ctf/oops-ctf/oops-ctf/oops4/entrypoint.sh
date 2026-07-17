#!/bin/bash
set -e
# Assegura que named carrega la zona local
grep -q 'named.conf.local' /etc/bind/named.conf || true
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/oops4.conf
