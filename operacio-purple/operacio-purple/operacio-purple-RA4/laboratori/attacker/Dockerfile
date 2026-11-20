# Caixa d'eines de l'atacant (red team), lleugera i cross-platform.
# Prou per a tota la pràctica sense haver de descarregar una Kali sencera.
# (Si vols l'arsenal complet: canvia la primera línia per  FROM kalilinux/kali-rolling
#  i substitueix l'apt-get per  apt-get install -y kali-linux-headless )
FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# Eines bàsiques de la pràctica: si alguna d'aquestes falla, el build s'ha d'aturar.
RUN apt-get update && apt-get install -y --no-install-recommends \
        nmap \
        hydra \
        curl \
        wget \
        netcat-openbsd \
        iputils-ping \
        dnsutils \
        openssh-client \
        python3 \
        python3-requests \
        ca-certificates \
        less \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

# Eines d'AMPLIACIÓ (sqlmap, nikto). Són opcionals a la pràctica i alguns antivirus o
# filtres de xarxa (p. ex. el de l'institut) en bloquegen la descàrrega. Si passa, el
# build continua i només mostra un avís; les pots instal·lar més tard des d'una altra xarxa.
# nikto és a la secció "non-free" de Debian: l'afegim a les fonts que ja porta la imatge.
RUN if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
        sed -i -E '/^Components:/{/non-free/!s/$/ contrib non-free/}' /etc/apt/sources.list.d/debian.sources; \
    else \
        sed -i -E '/^deb /{/non-free/!s/$/ contrib non-free/}' /etc/apt/sources.list; \
    fi \
    && apt-get update \
    && for p in sqlmap nikto; do \
        apt-get install -y --no-install-recommends "$p" \
          || echo "AVÍS: no s'ha pogut instal·lar $p (descàrrega bloquejada?). El laboratori funciona igualment."; \
    done \
    && rm -rf /var/lib/apt/lists/*

# Diccionaris petits per a la força bruta (els generem aquí perquè no depenguem de xarxa)
RUN mkdir -p /wordlists \
    && printf '%s\n' admin administrator root lab test user guest support operator backup \
        > /wordlists/users.txt \
    && printf '%s\n' password 123456 password123 admin admin123 root toor lab labpass \
        qwerty letmein changeme welcome Password1 12345678 iloveyou \
        > /wordlists/passwords.txt

WORKDIR /loot
CMD ["sleep", "infinity"]
