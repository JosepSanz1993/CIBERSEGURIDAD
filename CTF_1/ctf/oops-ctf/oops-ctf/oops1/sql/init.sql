-- Base de dades de la webapp d'OOPS_1
CREATE DATABASE IF NOT EXISTS webapp;
USE webapp;

CREATE TABLE users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(64) NOT NULL,
    password      VARCHAR(128) NOT NULL,   -- text pla a propòsit (mala pràctica didàctica)
    password_expired TINYINT DEFAULT 1,
    role          VARCHAR(32) DEFAULT 'user'
);

-- Les contrasenyes "caducades" segueixen un PATRÓ conegut:
--   <Estació><Any>!   ->  ex.  Spring2024!  Winter2023!  Autumn2025!
-- Amb això l'atacant construeix un diccionari amb crunch/regla i el passa a
-- hydra contra el login (o contra ssh de 'oopsuser' si prova reutilització).
--
--   crunch 11 11 -t ,%%%%2024! -o pat.txt   (aprox; cal afinar la màscara)
--   o millor, una llista curta d'estacions x anys:
--     for s in Spring Summer Autumn Winter; do for y in 2021 2022 2023 2024 2025; do
--       echo "${s}${y}!"; done; done > pat.txt
--   hydra -L users.txt -P pat.txt <IP> http-post-form "..."
INSERT INTO users (username, password, role) VALUES
  ('admin',   'Winter2024!', 'admin'),
  ('jsmith',  'Summer2023!', 'user'),
  ('mgarcia', 'Autumn2022!', 'user'),
  ('rlopez',  'Spring2025!', 'user'),
  ('svc_web', 'Summer2021!', 'service');

-- Pista dins la pròpia BD cap a l'enigma de privesc
CREATE TABLE notes (id INT PRIMARY KEY AUTO_INCREMENT, note TEXT);
INSERT INTO notes (note) VALUES
  ('TODO: mou /var/www/html/internal/patternmatch.php fora del webroot!'),
  ('Recorda: el secret local es genera amb el mateix "pattern matching" de Java.');

-- Usuari de BD que fa servir la webapp (privilegis amplis a propòsit)
CREATE USER IF NOT EXISTS 'webapp'@'localhost' IDENTIFIED BY 'webapp';
GRANT ALL PRIVILEGES ON webapp.* TO 'webapp'@'localhost';
FLUSH PRIVILEGES;
