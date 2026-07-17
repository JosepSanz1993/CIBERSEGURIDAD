#!/bin/bash
# Crea les dues xarxes compartides que fan servir TOTES les màquines.
# Executa'l UN COP abans d'aixecar cap màquina.
set -e

create() {
  if docker network inspect "$1" >/dev/null 2>&1; then
    echo "[=] La xarxa $1 ja existeix"
  else
    docker network create "${@:2}" "$1" && echo "[+] Creada $1"
  fi
}

# DMZ: exposada a l'atacant (Kali/Parrot s'hi connecta)
create oops_dmz --subnet 10.10.10.0/24

# Interna: sense sortida (--internal) -> força el pivot per oops4
create oops_internal --internal --subnet 10.10.20.0/24

echo "Fet. Ara pots fer: cd oopsN && docker compose up -d --build"
