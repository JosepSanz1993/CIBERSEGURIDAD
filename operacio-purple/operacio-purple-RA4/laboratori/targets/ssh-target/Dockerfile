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

# Permetem autenticació per contrasenya (necessari per a la pràctica de força bruta)
RUN sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
