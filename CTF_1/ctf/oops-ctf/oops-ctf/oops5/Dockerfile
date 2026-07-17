# OOPS_5 — CROWN JEWEL (només a internal_net)
# Objectiu final: assolir-hi accés DESPRÉS del moviment lateral.
#   · Descobreixes que existeix via AXFR a OOPS_4 (oops5.oops.lab -> 10.10.20.15).
#   · Obtens la credencial reutilitzada a /opt/net/inventory.txt d'OOPS_4.
#   · Com que oops5 NO és a la DMZ, cal PIVOTAR per oops4 (SSH -L / chisel / socks).
#   · Entres per SSH amb l'admin i reculls la flag final ("domini compromès").
# Privesc final trivial: l'usuari 'siteadmin' està a sudoers NOPASSWD (representa
# el "Domain Admin" del CTF) -> root -> flag arrel.
FROM debian:12-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      openssh-server sudo procps \
    && rm -rf /var/lib/apt/lists/*

# Credencial que es reutilitza des d'OOPS_4 (moviment lateral)
RUN useradd -m -s /bin/bash siteadmin \
    && echo 'siteadmin:L4t3r4l_M0v3_2024' | chpasswd \
    && echo 'siteadmin ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/siteadmin \
    && chmod 440 /etc/sudoers.d/siteadmin

RUN echo 'FLAG{oops5_CROWN_JEWEL_full_compromise}' > /root/flag.txt \
    && echo 'FLAG{oops5_lateral_movement_success}' > /home/siteadmin/user_flag.txt \
    && mkdir -p /var/run/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
