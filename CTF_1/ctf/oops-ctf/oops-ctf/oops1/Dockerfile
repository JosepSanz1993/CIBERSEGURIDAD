# OOPS_1 — nginx + PHP + MySQL + SSH
# Vulnerabilitats didàctiques:
#   1) SQLi (MySQL) al formulari de login  (concatenació de cadenes)
#   2) Command injection a tools.php  (shell_exec sense sanejar)
#   3) "Backdoor" estil PHP 8.1.0-dev (capçalera User-Agentt) — REPRODUÏT
#      de forma educativa, no és el binari real tainted.
#   4) Taula d'usuaris amb contrasenyes caducades seguint PATRÓ -> crunch+hydra
#   5) Privesc: enigma en .php (ASCII decimal) que defineix el pattern matching
#      de Java i revela el secret per a `su`.
# SSH amb contrasenya FORTA (no vulnerable) — l'entrada ha de ser per la web.
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      nginx php-fpm php-mysqli mariadb-server openssh-server \
      supervisor iputils-ping ca-certificates procps sudo \
    && rm -rf /var/lib/apt/lists/*

# --- Usuari amb contrasenya FORTA per SSH (objectiu: no cruixir-la) ---
RUN useradd -m -s /bin/bash webadmin \
    && echo 'webadmin:9x!Qz#Vr72$Lm4&Tp0@wKd1' | chpasswd \
    && mkdir -p /var/run/sshd

# --- Usuari "local" el secret del qual s'obté resolent l'enigma ---
# Privesc: oopsuser pot executar `find` com root sense contrasenya (GTFOBins):
#   sudo find . -exec /bin/sh \; -quit
RUN useradd -m -s /bin/bash oopsuser \
    && echo 'oopsuser:Cr4ckM3_L4b#2024' | chpasswd \
    && echo 'oopsuser ALL=(root) NOPASSWD: /usr/bin/find' > /etc/sudoers.d/oopsuser \
    && chmod 440 /etc/sudoers.d/oopsuser

COPY www/            /var/www/html/
COPY challenge/      /var/www/html/internal/
COPY sql/init.sql    /docker-entrypoint-initdb.d/init.sql
COPY nginx.conf      /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/oops1.conf
COPY entrypoint.sh   /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Flags
RUN mkdir -p /root && echo 'FLAG{oops1_root_pattern_matching_solved}' > /root/flag.txt \
    && echo 'FLAG{oops1_web_user_foothold}' > /home/oopsuser/user_flag.txt

EXPOSE 80 22
ENTRYPOINT ["/entrypoint.sh"]
