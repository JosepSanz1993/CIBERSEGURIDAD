<?php
require 'db.php';
$msg = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $u = $_POST['username'] ?? '';
    $p = $_POST['password'] ?? '';
    $conn = db();
    // VULNERABLE: concatenació directa -> SQL injection
    //   Prova:  username = admin' -- -
    //   O:      username = ' OR '1'='1' -- -
    $q = "SELECT id, username, role FROM users WHERE username='$u' AND password='$p'";
    $r = mysqli_query($conn, $q);
    if ($r && ($row = mysqli_fetch_assoc($r))) {
        $msg = "Benvingut, {$row['username']} (rol: {$row['role']}). "
             . "Consell: revisa /internal/ i tools.php.";
    } else {
        $msg = 'Credencials incorrectes. (SQL error: ' . mysqli_error($conn) . ')';
    }
}
?>
<!doctype html><html lang="ca"><head><meta charset="utf-8"><title>Login</title></head>
<body style="font-family:sans-serif;max-width:520px;margin:40px auto">
<h2>Iniciar sessió</h2>
<form method="post">
  <p>Usuari: <input name="username"></p>
  <p>Contrasenya: <input name="password" type="password"></p>
  <button type="submit">Entrar</button>
</form>
<p style="color:#a00"><?php echo htmlspecialchars($msg); ?></p>
<p><a href="index.php">&larr; Tornar</a></p>
</body></html>
