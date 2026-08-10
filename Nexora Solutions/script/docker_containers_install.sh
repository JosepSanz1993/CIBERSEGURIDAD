#Create network
docker network create -d macvlan --subnet=10.10.30.0/24 --gateway=10.10.30.1 -o parent=eth0 dmznet
docker network ls

#Create volumen
docker volume create Dropbox

# Fedora - servicios web y base de datos (.11)
docker run -d --name web --network dmznet --ip 10.10.30.11 -v dropbox:/var/www/html/uploads fedora sleep infinity

# CentOS Stream - FTP y SMTP (.12)  [mismo volumen: buzon FTP]
docker run -d --name ftpsmtp --network dmznet --ip 10.10.30.12 -v dropbox:/srv/ftp/uploads quay.io/centos/centos:stream9 sleep infinity

# AlmaLinux - LDAP y SNMP (.13)
docker run -d --name dir --network dmznet --ip 10.10.30.13 almalinux:9 sleep infinity

#Check status
docker ps          

