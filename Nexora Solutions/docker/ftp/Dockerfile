FROM quay.io/centos/centos:stream9

RUN dnf -y install vsftpd && dnf clean all

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
RUN mkdir -p /srv/ftp/uploads

RUN printf '#!/bin/sh\nchmod 555 /srv/ftp\nchmod 777 /srv/ftp/uploads\nexec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf -obackground=NO\n' > /start.sh && chmod +x /start.sh

EXPOSE 21 30000-30100
CMD ["/start.sh"]
