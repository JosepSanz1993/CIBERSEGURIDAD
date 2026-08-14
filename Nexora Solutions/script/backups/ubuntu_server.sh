mkdir -p ~/backup-config/{dns,dhcp,firewall}

# DNS (BIND9)
sudo cp /etc/bind/named.conf.local ~/backup-config/dns/
sudo cp /etc/bind/named.conf.options ~/backup-config/dns/
sudo cp /etc/bind/db.nexora.lab ~/backup-config/dns/

# DHCP (Kea)
sudo cp /etc/kea/kea-dhcp4.conf ~/backup-config/dhcp/

# Firewall (nftables)
sudo cp /etc/nftables.conf ~/backup-config/firewall/ 2>/dev/null
sudo nft list ruleset > ~/backup-config/firewall/nftables-ruleset-actual.txt

# Netplan (red)
sudo cp /etc/netplan/*.yaml ~/backup-config/firewall/ 2>/dev/null

sudo chown -R $USER:$USER ~/backup-config
tar czf ~/backup-ubuntu.tar.gz -C ~/backup-config .
echo "Backup Ubuntu listo en ~/backup-ubuntu.tar.gz"
ls -la ~/backup-config -R