<?php
session_start();
require 'db.php';
$error = "";
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $u = $_POST['usuario'];
  $p = $_POST['password'];
  // VULNERABLE: concatenacion directa -> SQL Injection
  $sql = "SELECT * FROM usuarios WHERE usuario='$u' AND password='$p'";
  $res = mysqli_query($con, $sql);
  if ($res && mysqli_num_rows($res) > 0) {
    $row = mysqli_fetch_assoc($res);
    $_SESSION['user'] = $row['usuario'];
    $_SESSION['rol']  = $row['rol'];
    header("Location: dashboard.php"); exit;
  } else {
    $error = "Credenciales incorrectas";
  }
}
?>
<!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
<title>Intranet Nexora Solutions</title><link rel="stylesheet" href="assets/style.css"></head>
<body><div class="login-wrap"><div class="login-card">
<h1 class="brand">NEXORA SOLUTIONS</h1>
<div class="sub">Intranet corporativa &middot; acceso restringido</div>
<form method="post">
<label>Usuario</label><input type="text" name="usuario" autofocus>
<label>Contrasena</label><input type="password" name="password">
<button type="submit">Acceder</button>
<?php if($error) echo "<div class='error'>$error</div>"; ?>
</form></div></div></body></html>
