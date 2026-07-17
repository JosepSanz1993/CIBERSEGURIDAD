// Seed de MongoDB per OOPS_3 (s'executa via mongosh a l'entrypoint)
db = db.getSiblingDB('oops');

db.users.insertMany([
  { username: 'admin',  password: 'M0ng0Adm1n!' },
  { username: 'editor', password: 'letmein2024' }
]);

// Document sensible xifrat amb AES-256-CBC (clau filtrada a /backup: Sup3rMongoKey_2024)
db.secure_docs.insertMany([
  { label: 'vip_contract',
    ciphertext: 'U2FsdGVkX1+hWEhBl7MgAJVmSWeUC20IN77XQEyQ3y1d2LnxBf6rsqVFZMIQADWMSjWeZaRL0EjOZ6XrJZEcpUFRUcfhF1vfBqFZaZ80UNtXNEdGnWwDDdEE3fVQYrIi' }
]);

// Hash de root en format sha256crypt -> cruixir amb hashcat -m 7400 o john
db.system_secrets.insertOne({
  note: 'root shadow line',
  hash: '$5$R00tS4lt$Lzq8t3vvtPkOABDf4CDvJU/BgzbMUE.FnDLekEXAXT/'
});
