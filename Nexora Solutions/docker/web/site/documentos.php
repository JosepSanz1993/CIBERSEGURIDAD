<?php session_start(); if(!isset($_SESSION['user'])){header("Location: index.php");exit;}
$msg="";
if($_SERVER['REQUEST_METHOD']==='POST' && isset($_FILES['fichero'])){
  // VULNERABLE: sin validacion de tipo ni extension
  $destino = "uploads/".basename($_FILES['fichero']['name']);
  if(move_uploaded_file($_FILES['fichero']['tmp_name'],$destino)){
    $msg="Fichero subido: ".htmlspecialchars($_FILES['fichero']['name']);
  }
}
$ficheros = @scandir("uploads");
?>
<!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
<title>Documentos &middot; Nexora</title><link rel="stylesheet" href="assets/style.css"></head><body>
<div class="topbar"><span class="brand">NEXORA SOLUTIONS</span>
<span><?=$_SESSION['user']?> &middot; <a href="logout.php">Salir</a></span></div>
<div class="shell">
<nav class="side"><a href="dashboard.php">Inicio</a><a class="act" href="documentos.php">Documentos</a></nav>
<main class="main"><h2>Repositorio de documentos</h2>
<div class="up"><form method="post" enctype="multipart/form-data">
<div>Subir un documento al repositorio compartido:</div>
<input type="file" name="fichero"><br><button type="submit">Subir</button>
<?php if($msg) echo "<p style='color:#137333;margin-top:10px'>$msg</p>"; ?>
</form></div>
<table class="tbl"><tr><th>Fichero</th><th>Enlace</th></tr>
<?php foreach($ficheros as $f){ if($f=="."||$f=="..")continue;
  echo "<tr><td>$f</td><td><a href='uploads/$f'>abrir</a></td></tr>"; } ?>
</table></main></div></body></html>
