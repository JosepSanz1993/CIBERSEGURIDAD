# Scripts de configuracion de red - Laboratorio Nexora

Un script por maquina. Ejecutar como root en cada VM tras instalar el sistema.
Reflejan el plan de direccionamiento y los ajustes reales del laboratorio.

| Script | Maquina | Segmento | IP | Sistema de red |
|--------|---------|----------|----|----|
| red-01-firewall-ubuntu.sh | Ubuntu Server (firewall) | los tres + NAT | .99.1/.20.1/.30.1 | netplan |
| red-02-rocky.sh | Rocky Linux | interna + NAT | 10.10.20.10 | nmcli |
| red-03-docker-alpine.sh | Alpine (host Docker) | dmz + NAT | 10.10.30.10 | /etc/network/interfaces |
| red-04-kali.sh | Kali (atacante) | atacante + NAT | 10.10.99.50 | nmcli |
| red-05-rhel-siem.sh | RHEL 9 (SIEM) | interna + NAT | 10.10.20.20 | nmcli |

## Uso
    chmod +x red-0X-*.sh
    sudo ./red-0X-<maquina>.sh      # (en Alpine: ./red-03-docker-alpine.sh como root)

## Criterio de diseno comun
- IP estatica en la interfaz interna de cada segmento.
- DNS apuntando al firewall (BIND: 10.10.X.1).
- `never-default`: la interfaz del laboratorio NO es la ruta por defecto de Internet;
  Internet sale por la NAT temporal (que se retira al aislar el laboratorio).
- Ruta `10.10.0.0/16` via el firewall: permite alcanzar el resto de segmentos.
- Alpine incluye el modo promiscuo persistente (necesario para macvlan) via post-up.

## Avisos
- Verifica los nombres de interfaz/conexion antes de ejecutar:
    - Debian/RHEL:  ip -br a   /   nmcli con show
    - Alpine:       ip a
- La NAT es un andamio temporal; retirala en VirtualBox al terminar cada maquina:
    VBoxManage modifyvm "<vm>" --nicX none
- Requisito VirtualBox para macvlan: modo promiscuo allow-all en la NIC de la DMZ
  del host Alpine y del firewall (se aplica con VBoxManage modifyvm --nicpromiscX allow-all).
