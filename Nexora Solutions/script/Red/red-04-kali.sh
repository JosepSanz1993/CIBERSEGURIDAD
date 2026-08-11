#!/bin/bash
# Config de red - Kali (atacante) - Nexora lab
# interna=eth0 (10.10.99.50)  NAT=eth1 (temporal)
# La interna es la interfaz SIN la IPv6 fd17:... de la NAT (normalmente eth0)
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (sudo)"; exit 1; }

INT_IF="eth0"            # interfaz interna (segmento atacante)
DNS_LAB="10.10.99.1"     # DNS del laboratorio (BIND del firewall).
                         # Si por .99.1 no resuelve, cambia a 10.10.20.1

# --- Conexion interna sobre eth0 ---
nmcli con add type ethernet ifname "$INT_IF" con-name interna 2>/dev/null || true
nmcli con mod interna ipv4.method manual \
  ipv4.addresses 10.10.99.50/24 \
  ipv4.dns "$DNS_LAB" \
  ipv4.dns-priority 10 \
  ipv4.dns-search nexora.lab \
  ipv4.never-default yes \
  ipv4.routes "10.10.0.0/16 10.10.99.1"
nmcli con up interna

# --- NAT: solo Internet, sin ser DNS ni ruta por defecto del laboratorio ---
# dns-priority alto (200) para que su DNS quede por detras del DNS del lab
nmcli con mod "Wired connection 1" ipv4.gateway "" ipv4.routes "" \
  ipv4.method auto ipv4.dns-priority 200 2>/dev/null || true
nmcli con up "Wired connection 1" 2>/dev/null || true

echo "[OK] Kali configurado."
echo "--- Interfaces ---"; ip -br a
echo "--- Prueba de DNS ---"
nslookup web.nexora.lab 2>/dev/null | grep -A1 Name || echo "  (revisa el DNS: prueba dig @10.10.20.1 web.nexora.lab)"