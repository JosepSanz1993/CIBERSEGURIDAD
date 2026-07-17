# OOPS_2 — PostgreSQL (intranet) + SSH
# Vulnerabilitats didàctiques:
#   1) PostgreSQL "COPY ... FROM PROGRAM" (CVE-2019-9193): RCE com a usuari postgres
#      si tens un rol superuser o pg_execute_server_program. Aquí el rol 'intranet'
#      té privilegis excessius (mala pràctica) per permetre l'explotació.
#   2) Dades sensibles xifrades (AES-256-CBC) + hashos amb salt (sha256(salt+pass)).
#      Objectiu: desxifrar (la clau AES s'obté via RCE al filesystem) i cruixir els hashos.
#   3) Privesc: sudo mal configurat -> l'usuari 'dbuser' pot executar un script
#      editable / un binari GTFOBins com root.
#   4) SSH SENSE contrasenya (només clau). La clau privada està guardada a la BD.
FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      postgresql postgresql-contrib openssh-server sudo openssl procps \
      ca-certificates supervisor \
    && rm -rf /var/lib/apt/lists/*

# Usuari 'dbuser' que entra per SSH amb CLAU (sense password login)
RUN useradd -m -s /bin/bash dbuser \
    && mkdir -p /home/dbuser/.ssh && chmod 700 /home/dbuser/.ssh

# Genera un parell de claus i col·loca la pública; la privada anirà a la BD.
RUN ssh-keygen -t ed25519 -N '' -f /tmp/dbuser_key -C dbuser@oops2 \
    && cp /tmp/dbuser_key.pub /home/dbuser/.ssh/authorized_keys \
    && chmod 600 /home/dbuser/.ssh/authorized_keys \
    && chown -R dbuser:dbuser /home/dbuser/.ssh

# --- Privesc via sudo: dbuser pot executar /opt/backup.sh com root (i és editable) ---
COPY sudo/backup.sh /opt/backup.sh
RUN chmod 755 /opt/backup.sh && chown root:root /opt/backup.sh \
    && echo 'dbuser ALL=(root) NOPASSWD: /opt/backup.sh' > /etc/sudoers.d/dbuser \
    && chmod 440 /etc/sudoers.d/dbuser
# Nota: /opt/backup.sh fa `source` d'un fitxer que dbuser SÍ pot escriure -> RCE root.

# Secret AES i flags
RUN mkdir -p /opt/secure \
    && echo 'S3cr3t_AES_K3y_do_not_share' > /opt/secure/aes.key \
    && chmod 644 /opt/secure/aes.key \
    && echo '# La clau la pot llegir el servei (mala practica) -> RCE la filtra' > /opt/secure/README \
    && echo 'FLAG{oops2_root_via_sudo_backup}' > /root/flag.txt \
    && echo 'FLAG{oops2_user_foothold_via_pg}' > /home/dbuser/user_flag.txt

COPY sql/init.sql /opt/init.sql
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/oops2.conf
RUN chmod +x /entrypoint.sh && mkdir -p /var/run/sshd

EXPOSE 5432 22
ENTRYPOINT ["/entrypoint.sh"]
