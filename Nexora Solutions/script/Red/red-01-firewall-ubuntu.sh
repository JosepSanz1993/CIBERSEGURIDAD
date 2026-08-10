#!/bin/bash
# Config de red - Ubuntu Server (Firewall / Router) - Nexora lab
# Interfaces: enp0s3=atacante  enp0s8=interna  enp0s9=dmz  enp0s10=NAT(temporal)
# Verifica los nombres reales con: ip -br a
set -e
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root (sudo)"; exit 1; }

cat > /etc/netplan/01-lab.yaml <<'YAML'
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:                 # net-atacante
      dhcp4: no
      addresses: [10.10.99.1/24]
    enp0s8:                 # net-interna
      dhcp4: no
      addresses: [10.10.20.1/24]
    enp0s9:                 # net-dmz
      dhcp4: no
      addresses: [10.10.30.1/24]
    enp0s10:                # NAT temporal (Internet para instalar)
      dhcp4: yes
YAML
chmod 600 /etc/netplan/01-lab.yaml
netplan apply

# Reenvio de paquetes (el firewall enruta entre segmentos)
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-lab-router.conf
sysctl --system >/dev/null

echo "[OK] Firewall Ubuntu configurado."
ip -br a | grep 10.10
