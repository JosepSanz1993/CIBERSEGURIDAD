<h1 align="center">🎯 OOPS-CTF</h1>

<p align="center">
  <b>Un laboratori Capture The Flag autocontingut, amb Docker, per aprendre red team de xarxa i Active Directory des de zero.</b><br>
  5 màquines vulnerables · pivoting i moviment lateral · segment L2 real (DHCP/DNS/ARP) · guia i solucionari.
</p>

<p align="center">
  <img alt="Docker" src="https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white">
  <img alt="Nivell" src="https://img.shields.io/badge/Nivell-Principiant→Intermedi-brightgreen">
  <img alt="Llengua" src="https://img.shields.io/badge/Idioma-Català-red">
  <img alt="Ús" src="https://img.shields.io/badge/Ús-Només%20laboratori%20aïllat-critical">
</p>



> ## ⚠️ Avís ètic i legal (llegeix-lo)
> Aquest projecte conté màquines **intencionadament vulnerables**, com
> [VulnHub](https://www.vulnhub.com/), [GOAD](https://github.com/Orange-Cyberdefense/GOAD)
> o Metasploitable. Existeix **únicament amb finalitats educatives**.
>
> - Fes-lo servir **exclusivament al teu laboratori aïllat i propi**.
> - **Mai** l'exposis a internet ni a la teva xarxa domèstica.
> - **Mai** apliquis aquestes tècniques contra sistemes de tercers sense
>   **autorització per escrit**. El que separa un professional d'un delicte no és
>   el coneixement tècnic: és l'**autorització** i l'**abast**.
>
> L'autor no es fa responsable de l'ús indegut d'aquest material.

---

## 🧭 Què és

OOPS-CTF munta, amb un parell d'ordres, un entorn complet per practicar el cicle
d'una operació ofensiva real: **reconeixement → accés inicial → escalada de
privilegis → pivoting → moviment lateral → compromís total**, mapejable al marc
[MITRE ATT&CK](https://attack.mitre.org/).

Pensat per a qui comença: cada màquina té objectius clars, **pistes escalonades**
(perquè no t'encallis) i un **solucionari** complet quan vulguis comparar.

## ✨ Característiques

- **5 màquines Docker**, cadascuna amb el seu `Dockerfile` i `docker-compose.yml`.
- **Segmentació de xarxa realista**: DMZ (`10.10.10.0/24`) + xarxa interna
  aïllada (`10.10.20.0/24`) que **obliga a fer pivot**.
- **Vulnerabilitats variades i didàctiques**: SQLi, command injection, backdoor
  estil PHP 8.1.0-dev, NoSQLi a MongoDB, RCE a PostgreSQL (`COPY FROM PROGRAM`),
  hashos amb salt, xifratge AES, males configuracions de `sudo`, reutilització
  de credencials…
- **Laboratori de capa 2 (macvlan)** on els atacs de **DHCP/DNS/ARP** són reals.
- **Documentació completa**: guia de jugador amb pistes i solucionari pas a pas,
  amb notes de **remediació** a cada màquina.

## 🗺️ Arquitectura

```
Kali/Parrot  →  DMZ 10.10.10.0/24  →  [oops4 · pont]  →  interna 10.10.20.0/24
                oops1 .11 (web)                          oops2 .12 (postgres)
                oops3 .13 (web+mongo)                    oops5 .15 (crown jewel)
                oops4 .14 (dns/dhcp) ──────────────────  oops4 .14
```

## 🚀 Inici ràpid

```bash
git clone https://github.com/<usuari>/oops-ctf.git
cd oops-ctf
bash setup-networks.sh     # crea les xarxes compartides (un sol cop)
make up                    # aixeca les 5 màquines

# consola d'atac
docker run -it --rm --network oops_dmz kalilinux/kali-rolling bash
```

Segment L2 (DHCP/DNS/ARP reals):
```bash
cd macvlan && bash setup-macvlan.sh && bash run-lab.sh && bash spawn-victim.sh
```

## 📂 Estructura

```
oops-ctf/
├── README.md              · aquesta portada
├── GUIA.md                · guia de jugador (objectius + pistes)
├── SOLUCIONARI.md         · walkthrough complet (spoilers)
├── setup-networks.sh      · crea les xarxes compartides
├── Makefile               · up / down / build de tot
├── oops1 … oops5/         · una carpeta per màquina (Dockerfile + compose)
└── macvlan/               · laboratori de capa 2 (DHCP/DNS/ARP)
```

## 📚 Documentació

| Document | Per a què |
|----------|-----------|
| [`GUIA.md`](GUIA.md) | Posada en marxa, objectius i **pistes** (sense spoilers directes). |
| [`SOLUCIONARI.md`](SOLUCIONARI.md) | Solució **completa** pas a pas + remediació. |
| [`macvlan/README-macvlan.md`](macvlan/README-macvlan.md) | Atacs de capa 2 i els seus límits. |

## 🎓 Ruta d'aprenentatge

Recon → **OOPS_1** (web → enigma → root) → **OOPS_3** (mongo + cracking) →
**OOPS_4** (AXFR + pivot) → **OOPS_2** (RCE PostgreSQL) → **OOPS_5** (moviment
lateral → compromís total) → **extra:** segment L2 macvlan.

## 🤝 Contribucions

Els *issues* i *pull requests* són benvinguts: noves màquines, vulnerabilitats,
traduccions o millores de la documentació.

## 📄 Llicència

Codi sota llicència **MIT** (afegeix un fitxer `LICENSE`). El material educatiu
es comparteix per a ús **responsable** en entorns controlats.

---

<p align="center"><i>Construït per aprendre. Documenta cada pas: en surt el teu primer writeup de portfoli.</i></p>
