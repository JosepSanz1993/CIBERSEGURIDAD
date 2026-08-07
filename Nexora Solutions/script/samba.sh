#!/bin/bash
# Estructura SMB realista - Nexora Solutions (LABORATORIO - datos ficticios)
BASE=/srv/samba

sudo mkdir -p $BASE/comun/plantillas $BASE/rrhh/{nominas,contratos} \
  $BASE/contabilidad/facturas $BASE/sistemas/{scripts,configuracion,claves} \
  $BASE/direccion $BASE/intercambio

# --- comun (público) ---
echo "Servidor de archivos de Nexora Solutions." | sudo tee $BASE/comun/avisos.txt
echo "Plantilla de informe corporativo." | sudo tee $BASE/comun/plantillas/informe.txt

# --- rrhh (datos personales, expuesto por error) ---
sudo tee $BASE/rrhh/personal.csv >/dev/null <<'EOF'
nombre,dni,puesto,salario_bruto,iban
Josep Roca,12345678A,Administrador de sistemas,38000,ES76 2100 0000 0000 0000 0001
Marta Vidal,23456789B,Directora de RRHH,52000,ES76 2100 0000 0000 0000 0002
Luis Peña,34567890C,Contable,31000,ES76 2100 0000 0000 0000 0003
EOF
echo "Contrato indefinido - Josep Roca - CONFIDENCIAL" | sudo tee $BASE/rrhh/contratos/contrato_jroca.txt
echo "Recibo de nomina - noviembre 2024" | sudo tee $BASE/rrhh/nominas/nomina_2024_11.txt

# --- contabilidad (sensible) ---
sudo tee $BASE/contabilidad/cuentas_bancarias.txt >/dev/null <<'EOF'
Cuenta principal: ES76 2100 0000 0000 0000 9999
Banca online: usuario nexora_fin / clave Tesoreria#2024
EOF
echo "Presupuesto 2025 (borrador)" | sudo tee $BASE/contabilidad/presupuesto_2025.txt
echo "Factura F-2024-0187" | sudo tee $BASE/contabilidad/facturas/F-2024-0187.txt

# --- sistemas (LA JOYA) ---
sudo tee $BASE/sistemas/credenciales_servicios.txt >/dev/null <<'EOF'
# Inventario de credenciales de servicio - NO DIFUNDIR
FTP   (ftp.nexora.lab) : svc_ftp     / Ftp#Nexora2024
MySQL (web.nexora.lab) : root        / R00t-Maria!
SIEM  (siem.nexora.lab): wazuh-admin / W@zuhAdmin2024
Equipo core            : admin       / Cisco123!
EOF
sudo tee $BASE/sistemas/scripts/backup_diario.sh >/dev/null <<'EOF'
#!/bin/bash
# Backup diario (contraseña en claro - mala practica a proposito)
SMBUSER="svc_backup"; SMBPASS="Verano2024!"
mount -t cifs //10.10.20.10/backups /mnt/nas -o user=$SMBUSER,pass=$SMBPASS
EOF
sudo tee $BASE/sistemas/claves/id_rsa >/dev/null <<'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
clave-privada-de-laboratorio-ficticia-sin-valor-real
-----END OPENSSH PRIVATE KEY-----
EOF
echo "copia de smb.conf" | sudo tee $BASE/sistemas/configuracion/smb.conf.bak

# --- direccion (correctamente restringido) ---
echo "Plan estrategico 2025 - solo direccion" | sudo tee $BASE/direccion/estrategia_2025.txt

# --- intercambio (buzon de escritura anonima) ---
echo "Deposita aqui los ficheros para el equipo." | sudo tee $BASE/intercambio/LEEME.txt

# --- Propiedad, permisos y contexto SELinux ---
sudo chown -R nobody:nobody $BASE
sudo find $BASE -type d -exec chmod 775 {} \;
sudo find $BASE -type f -exec chmod 664 {} \;
sudo chcon -R -t samba_share_t $BASE
echo "Estructura creada en $BASE"