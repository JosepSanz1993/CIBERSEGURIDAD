# Víctima SSH: servei real amb un usuari de contrasenya feble.
# Els intents d'autenticació es desen a /logs/ssh/sshd.log perquè el SOC els vegi.
FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

# Usuari víctima amb contrasenya DÈBIL a propòsit (només per al laboratori aïllat)
RUN useradd -m -s /bin/bash lab \
    && echo 'lab:labpass' | chpasswd

# Configuració de sshd per a la pràctica (fitxer propi a sshd_config.d, que té prioritat):
#  - PasswordAuthentication yes : necessari per a la força bruta
#  - PerSourcePenalties no      : OpenSSH >= 9.8 (Debian stable actual) castiga i BLOQUEJA
#                                 les IPs amb molts logins fallits; hydra deixaria de funcionar
#  - MaxStartups                : accepta més connexions simultànies (hydra en fa diverses)
RUN { \
        echo 'PasswordAuthentication yes'; \
        echo 'KbdInteractiveAuthentication no'; \
        echo 'PermitRootLogin no'; \
        echo 'MaxStartups 100:30:200'; \
        if dpkg --compare-versions "$(dpkg-query -W -f='${Version}' openssh-server)" ge 1:9.8; then \
            echo 'PerSourcePenalties no'; \
        fi; \
    } > /etc/ssh/sshd_config.d/00-lab.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
