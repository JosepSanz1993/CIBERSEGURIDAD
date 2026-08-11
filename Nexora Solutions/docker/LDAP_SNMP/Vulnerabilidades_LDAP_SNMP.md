# Vulnerabilidades detectadas — Directorio y monitorización (AlmaLinux)

> Fichas del contenedor `dir` (10.10.30.13, seg-dmz), que presta LDAP y SNMP.

## VULN-LDAP-01 · Bind anónimo y exposición de credenciales

| Campo | Detalle |
|---|---|
| Servicio | LDAP (OpenLDAP) — 10.10.30.13:389 |
| Severidad | Crítica |
| Estándar | CWE-287 (Autenticación indebida), CWE-522 (Credenciales protegidas de forma insuficiente), CWE-256 (Contraseñas en claro) |

**Descripción.** El servicio LDAP permite consultas sin autenticación (bind anónimo) y su ACL (`access to * by * read`) autoriza la lectura de todos los atributos, incluido `userPassword`. Además, las contraseñas se almacenan en texto plano.

**Causa.** Bind anónimo habilitado + ACL excesivamente permisiva + ausencia de *hashing* de contraseñas.

**Impacto.** (1) Enumeración completa del directorio corporativo: organigrama, usuarios, correos, teléfonos y cargos, útil para el reconocimiento. (2) Robo de credenciales en claro directamente reutilizables. La cadena de impacto es notable: la usuaria `mvidal`, obtenida del LDAP, es la que protege el recurso `direccion` del servidor Samba, por lo que el compromiso del LDAP habilita un movimiento lateral hacia un recurso que estaba correctamente restringido (reutilización de credenciales).

**Explotación (evidencia).**
```bash
ldapsearch -x -H ldap://10.10.30.13 -b "dc=nexora,dc=lab" \
  "(objectClass=inetOrgPerson)" uid userPassword
```
Devuelve los usuarios y sus contraseñas sin solicitar credenciales.

**Remediación.** Deshabilitar el bind anónimo o restringir la ACL para que `userPassword` no sea legible (`by anonymous auth`); almacenar contraseñas con *hash* fuerte (SSHA); exigir autenticación para las búsquedas; cifrar el canal con LDAPS.

## VULN-SNMP-01 · Community string por defecto en SNMPv2c

| Campo | Detalle |
|---|---|
| Servicio | SNMP (net-snmp) — 10.10.30.13:161/udp |
| Severidad | Media-Alta |
| Estándar | CWE-306 (Falta de autenticación), CWE-1188 (Configuración por defecto insegura) |

**Descripción.** El agente SNMP responde a la *community string* por defecto "public" en SNMPv2c, protocolo sin cifrado ni autenticación real.

**Causa.** Uso de SNMPv2c con la community de fábrica sin modificar; la community viaja en claro por la red.

**Impacto.** Divulgación no autenticada de información del sistema: versión del SO, procesos, interfaces de red, software instalado, servicios y datos de contacto/ubicación (`syslocation`, `syscontact`). Alimenta el reconocimiento y puede revelar versiones o servicios vulnerables. Al ser de solo lectura (`rocommunity`) no permite modificaciones, pero la exposición de información es significativa.

**Explotación (evidencia).**
```bash
snmpwalk -v2c -c public 10.10.30.13
```
Vuelca la información del sistema accesible por SNMP.

**Remediación.** Cambiar o eliminar la community por defecto; migrar a SNMPv3 con autenticación y cifrado; restringir por IP de origen; deshabilitar el servicio si no se utiliza.

---

**Nota de coherencia (cadena de ataque).** Estas dos debilidades no son aisladas: el LDAP anónimo entrega credenciales que se reutilizan en el Samba (recurso `direccion`), y el SNMP aporta reconocimiento del sistema. Ambas encajan en las fases de *enumeración* y *movimiento lateral* del pentest, y refuerzan el hallazgo transversal de **gestión débil de credenciales** compartido con la base de datos MariaDB y el servidor de archivos.
