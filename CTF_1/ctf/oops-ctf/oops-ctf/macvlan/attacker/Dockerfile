# Atacant per al segment L2. Kali amb l'arsenal per DHCP/DNS/ARP i AD/xarxa.
# NOTA: el build necessita internet (apt/pip), com és normal amb Kali.
FROM kalilinux/kali-rolling
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      nmap dnsutils iproute2 tcpdump \
      dsniff ettercap-text-only responder \
      isc-dhcp-server isc-dhcp-client dnsmasq \
      hydra hashcat john gobuster netexec \
      python3 python3-pip proxychains4 iputils-ping net-tools \
    && rm -rf /var/lib/apt/lists/*
# mitm6 (IPv6/DNS takeover) via pip
RUN pip3 install --no-cache-dir --break-system-packages mitm6 || true
CMD ["/bin/bash"]
