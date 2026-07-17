-- Base de dades de la intranet d'OOPS_2
CREATE DATABASE intranet;
\c intranet

-- Rol amb privilegis EXCESSIUS (mala pràctica) -> permet COPY FROM PROGRAM (RCE)
CREATE ROLE intranet WITH LOGIN SUPERUSER PASSWORD 'intranet';

CREATE TABLE credentials (
    username  TEXT,
    salt      TEXT,
    sha256    TEXT   -- sha256(salt || password), cal cruixir amb hashcat mode 1420? no:
                     -- format aquí és sha256(salt.password) concatenat -> vegeu README
);
INSERT INTO credentials (username, salt, sha256) VALUES
  ('alice','S4lt_alice','51a9d004583ca786def2266e761c89f64a23627ffc922dd69ca3cc4c8eebef10'),
  ('bob','S4lt_bob','f86a9bc4f6e233fb9cb03cce52d9086446bad8ae1a0a87f95bd2ea8fc8e779b0'),
  ('carol','S4lt_carol','c317b3d4b1a33df42480d5139278e4c36d51199fed503a9d47de8d70827e2e2a'),
  ('dave','S4lt_dave','a43982019e103baf9df8b2e08c053659651bfb0366a0757520b8b2fc66a90b90');

-- Dades de client XIFRADES amb AES-256-CBC (openssl, -pbkdf2). La clau és a
-- /opt/secure/aes.key i s'obté via RCE (COPY FROM PROGRAM). Desxifrar:
--   echo '<blob>' | openssl enc -d -aes-256-cbc -pbkdf2 -a -pass pass:<clau>
CREATE TABLE secure_data (label TEXT, ciphertext TEXT);
INSERT INTO secure_data (label, ciphertext) VALUES
  ('customer_record',
   'U2FsdGVkX1+yqm6zxlj8DuU9Z705cUVPXfxZlFVFuyoOKozgqUFhBbsU0IVZRrcJCNzfF5RUVYclQK6U1trePN/WBQ17p3hbUJbp+/AVs8+NCvn88oGxCTehYVkklf8UK7t5/vmxCE5vN2fEssmpPA==');

-- La clau SSH privada de 'dbuser' es guarda aquí (mala pràctica) i l'insereix
-- l'entrypoint en temps d'arrencada (ho fa perquè la clau es genera al build).
CREATE TABLE ssh_keys (owner TEXT, private_key TEXT);
