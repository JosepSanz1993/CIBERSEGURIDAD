#!/bin/bash
# Config de red - Kali (atacante) - Nexora lab
# interna=eth0 (10.10.99.50)  NAT=eth1 (temporal)
# La interna es la interfaz SIN la IPv6 fd17:... de la NAT (normalmente eth0)
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (sudo)"; exit 1; }
INT_IF="eth0"

# Conexion interna sobre eth0
nmcli con add type ethernet ifname "$INT_IF" con-name interna 2>/dev/null || true
nmcli con mod interna ipv4.method manual \
  ipv4.addresses 10.10.99.50/24 \
  ipv4.dns 10.10.99.1 \
  ipv4.never-default yes \
  ipv4.routes "10.10.0.0/16 10.10.99.1"
nmcli con up interna

# Limpia restos en la conexion NAT (que Internet salga por ella)
nmcli con mod "Wired connection 1" ipv4.gateway "" ipv4.routes "" ipv4.method auto 2>/dev/null || true
nmcli con up "Wired connection 1" 2>/dev/null || true

echo "[OK] Kali configurado."
ip -br a
