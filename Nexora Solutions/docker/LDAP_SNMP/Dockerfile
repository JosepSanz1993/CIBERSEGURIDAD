FROM almalinux:9

# Repositorio oficial de Symas OpenLDAP 2.6 para RHEL9
RUN dnf -y install wget && \
    wget -q https://repo.symas.com/configs/SOLDAP/rhel9/release26.repo \
      -O /etc/yum.repos.d/soldap-release26.repo

RUN dnf -y install symas-openldap-clients symas-openldap-servers net-snmp net-snmp-utils \
    && dnf clean all

COPY slapd.conf /opt/symas/etc/openldap/slapd.conf
COPY datos.ldif /root/datos.ldif

# Inicializacion del LDAP en build:
#  - slaptest -u : valida config sin abrir la BD (que aun no existe)
#  - slapadd -f slapd.conf : carga los datos leyendo la config clasica
RUN mkdir -p /opt/symas/etc/openldap/slapd.d /var/lib/ldap \
 && /opt/symas/sbin/slaptest -f /opt/symas/etc/openldap/slapd.conf -F /opt/symas/etc/openldap/slapd.d -u \
 && /opt/symas/sbin/slapadd -f /opt/symas/etc/openldap/slapd.conf -l /root/datos.ldif \
 && (chown -R ldap:ldap /opt/symas/etc/openldap/slapd.d /var/lib/ldap 2>/dev/null || true)

# SNMP DEBIL: community "public" en v2c
RUN printf 'rocommunity public\n\
syslocation "CPD Nexora - Planta 1"\n\
syscontact admin@nexora.lab\n\
sysname dir.nexora.lab\n\
agentAddress udp:161\n' > /etc/snmp/snmpd.conf

# Arranque: slapd (binario real en /opt/symas/lib/slapd, config clasica -f) + snmpd
RUN printf '#!/bin/sh\n\
/opt/symas/lib/slapd -h "ldap:/// ldapi:///" -f /opt/symas/etc/openldap/slapd.conf\n\
sleep 1\n\
echo "LDAP y SNMP arrancados"\n\
exec snmpd -f -Lo\n' > /start.sh && chmod +x /start.sh

EXPOSE 389 161/udp
CMD ["/start.sh"]
