CREATE DATABASE IF NOT EXISTS nexora;
USE nexora;
CREATE TABLE IF NOT EXISTS usuarios(
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(50), password VARCHAR(100), rol VARCHAR(20), email VARCHAR(100));
INSERT INTO usuarios(usuario,password,rol,email) VALUES
 ('admin','Nexora#Admin2024','admin','admin@nexora.lab'),
 ('jroca','Verano2024!','sistemas','jroca@nexora.lab'),
 ('mvidal','Rrhh2024*','rrhh','mvidal@nexora.lab'),
 ('lpena','Conta2024*','contabilidad','lpena@nexora.lab');
CREATE USER IF NOT EXISTS 'webapp'@'localhost' IDENTIFIED BY 'webapp123';
GRANT ALL ON nexora.* TO 'webapp'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'R00t-Maria!';
FLUSH PRIVILEGES;
