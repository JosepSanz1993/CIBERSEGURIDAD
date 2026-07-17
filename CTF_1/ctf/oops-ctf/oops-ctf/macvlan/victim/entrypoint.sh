#!/bin/bash
# La víctima allibera la IP que li hagi posat Docker i demana una per DHCP,
# generant un intercanvi DORA real que OOPS_4 (o un rogue!) respondrà.
set -e
IF=eth0
ip addr flush dev $IF || true
echo "[victim] Demanant IP per DHCP a la xarxa..."
dhclient -v $IF || true
echo "[victim] Config resultant:"
ip -4 addr show $IF | grep inet || true
echo "[victim] DNS assignat:"; cat /etc/resolv.conf
echo "[victim] Provant resolució de oops5.oops.lab (via el DNS que m'han donat)..."
dig +short oops5.oops.lab || true
# Bucle: renova periòdicament perquè es puguin practicar atacs en calent
while true; do sleep 300; dhclient -v $IF >/dev/null 2>&1 || true; done
