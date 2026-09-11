# Nexora Solutions — Proyecto Final de Ciberseguridad

Proyecto de laboratorio de **pentesting / Red Team** sobre una infraestructura simulada
(firewall Ubuntu, Rocky Linux, contenedores Alpine/Docker, DMZ, SIEM en RHEL, servicios
FTP, SMTP, LDAP, SNMP, SMB y web). Incluye scripts de despliegue, hardening y documentación.

> ⚠️ **Aviso:** Todo el contenido es exclusivamente educativo y para entornos autorizados.

## 🎥 Vídeo de la presentación

[Ver presentación en YouTube/Drive](PON_AQUÍ_TU_ENLACE)

_(El vídeo no se incluye en el repositorio por su tamaño — más de 300 MB.)_

## 📁 Estructura

- `docker/` — Dockerfiles y scripts de los servicios vulnerables (web, FTP, LDAP/SNMP, SMTP).
- `script/` — Scripts de red, backups y despliegue.
- `img/` — Diagramas de topología, hardening y movimiento lateral.
- `ProyectoFinal.pdf` / `.docx` — Documentación completa del proyecto.
- `NexoraSolutions.pptx` — Diapositivas de la presentación.

## 🚀 Despliegue rápido

```bash
cd docker/Script
./01-build.sh
./02-red.sh
./03-up.sh
```

## 🔒 Nota sobre credenciales

Las credenciales que aparecen en la documentación son de un **laboratorio aislado**.
No se incluyen claves privadas ni contraseñas reales en este repositorio.
