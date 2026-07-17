# OOPS_3 — App web (Flask :8080) + MongoDB + SSH
# Vulnerabilitats didàctiques:
#   1) MongoDB SENSE autenticació (bind 0.0.0.0) -> lectura directa de col·leccions.
#   2) Directoris "ocults" descobribles amb gobuster (/backup, /api/debug).
#   3) NoSQL injection al login ({"$ne": null}) -> bypass.
#   4) Dades sensibles xifrades a Mongo; la clau es filtra a /backup.
#   5) Privesc: hash del root en format sha256crypt ($5$salt$...) -> hashcat/john.
FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-flask python3-pymongo openssh-server sudo \
      gnupg curl ca-certificates procps supervisor \
    && rm -rf /var/lib/apt/lists/*

# MongoDB Community (repo oficial). Si la teva arquitectura no és amd64, canvia'l.
RUN curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main" \
       > /etc/apt/sources.list.d/mongodb.list \
    && apt-get update && apt-get install -y mongodb-org-server \
    && rm -rf /var/lib/apt/lists/*

# appuser reutilitza la contrasenya de l'usuari 'editor' de MongoDB
# (reutilització de credencials): Mongo -> editor:letmein2024 -> ssh appuser
RUN useradd -m -s /bin/bash appuser \
    && echo 'appuser:letmein2024' | chpasswd \
    && echo 'FLAG{oops3_user_via_mongo_nosqli}' > /home/appuser/user_flag.txt \
    && echo 'FLAG{oops3_root_cracked_sha256crypt}' > /root/flag.txt

# Contrasenya root cruixible (patró de diccionari): "dragon" -> sha256crypt
#   generat amb: openssl passwd -5 -salt R00tS4lt dragon
RUN echo 'root:$5$R00tS4lt$Qk3...PLACEHOLDER...' >/dev/null # (valor real a entrypoint)

COPY app/ /opt/app/
COPY mongo-init.js /opt/mongo-init.js
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/oops3.conf
RUN chmod +x /entrypoint.sh && mkdir -p /var/run/sshd /data/db

EXPOSE 8080 27017 22
ENTRYPOINT ["/entrypoint.sh"]
