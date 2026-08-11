FROM quay.io/centos/centos:stream9

RUN dnf -y install vsftpd python3 python3-pip && dnf clean all && pip3 install aiosmtpd

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN mkdir -p /srv/ftp/uploads

# --- Servidor SMTP open-relay minimo (acepta cualquier correo) ---
RUN printf 'import asyncio, time\n\
from aiosmtpd.controller import Controller\n\
class Relay:\n\
    async def handle_RCPT(self, server, session, envelope, address, rcpt_options):\n\
        envelope.rcpt_tos.append(address)\n\
        return "250 OK"\n\
    async def handle_DATA(self, server, session, envelope):\n\
        print("Correo de", envelope.mail_from, "para", envelope.rcpt_tos, flush=True)\n\
        return "250 Message accepted for delivery"\n\
c = Controller(Relay(), hostname="0.0.0.0", port=25, ident="mail.nexora.lab ESMTP")\n\
c.start()\n\
print("SMTP open-relay escuchando en :25", flush=True)\n\
while True: time.sleep(3600)\n' > /smtp.py

# --- Arranque: SMTP en segundo plano + vsftpd en primer plano ---
RUN printf '#!/bin/sh\n\
chmod 555 /srv/ftp\n\
chmod 777 /srv/ftp/uploads\n\
python3 /smtp.py &\n\
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf -obackground=NO\n' > /start.sh && chmod +x /start.sh

EXPOSE 21 25 30000-30100
CMD ["/start.sh"]
