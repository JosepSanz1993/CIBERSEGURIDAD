mkdir -p ~/backup-config/{ssh,samba}

# SSH (config principal + el fichero de endurecimiento que creamos)
sudo cp /etc/ssh/sshd_config ~/backup-config/ssh/
sudo cp -r /etc/ssh/sshd_config.d/ ~/backup-config/ssh/ 2>/dev/null

# Samba (config + definición de recursos compartidos)
sudo cp /etc/samba/smb.conf ~/backup-config/samba/

# fail2ban (si lo configuraste para SSH)
sudo cp /etc/fail2ban/jail.local ~/backup-config/samba/ 2>/dev/null
sudo cp /etc/fail2ban/jail.local ~/backup-config/ssh/ 2>/dev/null

sudo chown -R $USER:$USER ~/backup-config