# Víctima del segment L2: demana IP per DHCP (DORA real) a OOPS_4 i després
# fa servir OOPS_4 com a DNS. És el "objectiu" dels atacs de rogue DHCP / spoofing.
FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      isc-dhcp-client tcpdump iproute2 dnsutils curl ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
