#!/bin/sh
# Config de red - Alpine (host Docker, DMZ) - Nexora lab
# eth0=dmz (10.10.30.10, parent de macvlan, con promiscuo)  eth1=NAT(temporal)
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root"; exit 1; }

cat > /etc/network/interfaces <<'IFACE'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.10.30.10
    netmask 255.255.255.0
    post-up ip link set eth0 promisc on
    post-up ip route add 10.10.0.0/16 via 10.10.30.1 2>/dev/null || true

auto eth1
iface eth1 inet dhcp
IFACE

rc-service networking restart
echo "[OK] Alpine host Docker configurado (promiscuo persistente incluido)."
ip a | grep -E "^[0-9]|inet "
