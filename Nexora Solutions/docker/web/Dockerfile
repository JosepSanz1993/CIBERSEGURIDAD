FROM fedora:41

RUN dnf -y install httpd php php-fpm php-mysqlnd mariadb-server mariadb && dnf clean all

COPY site/ /var/www/html/
COPY init.sql /root/init.sql
RUN mkdir -p /var/www/html/uploads && chown -R apache:apache /var/www/html

RUN printf '#!/bin/sh\n\
mkdir -p /run/httpd /run/php-fpm\n\
if [ ! -d /var/lib/mysql/mysql ]; then mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1; fi\n\
chown -R mysql:mysql /var/lib/mysql\n\
mariadbd-safe --datadir=/var/lib/mysql &\n\
for i in $(seq 1 30); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done\n\
mysql < /root/init.sql\n\
php-fpm -D\n\
exec httpd -DFOREGROUND\n' > /start.sh && chmod +x /start.sh

EXPOSE 80 443
CMD ["/start.sh"]
