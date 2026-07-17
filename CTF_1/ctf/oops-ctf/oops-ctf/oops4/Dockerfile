# OOPS_4 — DNS (BIND9) + DHCP (dnsmasq) + SSH  ·  PASSAREL·LA (dual-homed)
# Vulnerabilitats didàctiques:
#   1) BIND9 amb `allow-transfer { any; }` -> transferència de zona AXFR oberta.
#      L'atacant fa `dig axfr oops.lab @10.10.10.14` i descobreix TOTA la xarxa
#      interna, inclosa oops5.oops.lab (10.10.20.15) i un registre TXT amb pista.
#   2) DHCP: dnsmasq serveix leases a internal_net i injecta com a DNS l'oops4
#      (escenari de "rogue DHCP" / DNS forçat). Vegeu la NOTA sobre L2 al README.
#   3) SSH amb credencials febles -> foothold. Als fitxers de config hi ha la
#      contrasenya reutilitzable a OOPS_5 (moviment lateral).
#   4) És l'ÚNICA màquina a les dues xarxes -> cal pivotar per aquí cap a oops5.
FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      bind9 bind9utils dnsmasq openssh-server iproute2 procps supervisor \
    && rm -rf /var/lib/apt/lists/*

# Foothold: usuari amb contrasenya feble (cruixible)
RUN useradd -m -s /bin/bash netadmin \
    && echo 'netadmin:autumn' | chpasswd

# Config que filtra la credencial reutilitzable a OOPS_5
RUN mkdir -p /opt/net \
    && printf '# Inventari intern\n# oops5 (10.10.20.15) admin ssh pass: L4t3r4l_M0v3_2024\n' \
       > /opt/net/inventory.txt \
    && chmod 644 /opt/net/inventory.txt \
    && echo 'FLAG{oops4_pivot_gateway}' > /home/netadmin/user_flag.txt

COPY named.conf.local /etc/bind/named.conf.local
COPY db.oops.lab      /etc/bind/db.oops.lab
COPY dnsmasq.conf     /etc/dnsmasq.d/oops.conf
COPY entrypoint.sh    /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/oops4.conf
RUN chmod +x /entrypoint.sh && mkdir -p /var/run/sshd

EXPOSE 53/udp 53/tcp 67/udp 22
ENTRYPOINT ["/entrypoint.sh"]
