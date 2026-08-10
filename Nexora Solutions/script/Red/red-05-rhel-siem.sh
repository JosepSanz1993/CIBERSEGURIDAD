#!/bin/bash
# Config de red - RHEL 9 (SIEM Wazuh, segmento interno) - Nexora lab
# interna=enp0s3 (10.10.20.20)  NAT=enp0s8 (temporal)
# Verifica los nombres de conexion con: nmcli con show
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (sudo)"; exit 1; }
INT_CON="enp0s3"
NAT_CON="enp0s8"

nmcli con mod "$INT_CON" ipv4.method manual \
  ipv4.addresses 10.10.20.20/24 \
  ipv4.dns 10.10.20.1 \
  ipv4.never-default yes \
  ipv4.routes "10.10.0.0/16 10.10.20.1"
nmcli con up "$INT_CON"

nmcli con mod "$NAT_CON" ipv4.method auto 2>/dev/null || true
nmcli con up "$NAT_CON" 2>/dev/null || true

echo "[OK] RHEL SIEM configurado."
ip -br a
