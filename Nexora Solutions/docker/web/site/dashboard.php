<?php session_start(); if(!isset($_SESSION['user'])){header("Location: index.php");exit;} ?>
<!DOCTYPE html><html lang="es"><head><meta charset="utf-8">
<title>Panel &middot; Nexora</title><link rel="stylesheet" href="assets/style.css"></head><body>
<div class="topbar"><span class="brand">NEXORA SOLUTIONS</span>
<span><?=$_SESSION['user']?> (<?=$_SESSION['rol']?>) &middot; <a href="logout.php">Salir</a></span></div>
<div class="shell">
<nav class="side">
<a class="act" href="dashboard.php">Inicio</a>
<a href="documentos.php">Documentos</a>
<a href="#">Recursos Humanos</a><a href="#">Contabilidad</a>
<a href="#">Sistemas</a><a href="#">Direccion</a>
</nav>
<main class="main"><h2>Bienvenido, <?=$_SESSION['user']?></h2>
<div class="cards">
<div class="card"><h3>Recursos Humanos</h3><p>Nominas, contratos y personal.</p></div>
<div class="card"><h3>Contabilidad</h3><p>Facturacion y presupuestos.</p></div>
<div class="card"><h3>Sistemas</h3><p>Inventario e infraestructura TI.</p></div>
<div class="card"><h3>Direccion</h3><p>Planificacion estrategica.</p></div>
<div class="card"><h3>Documentos</h3><p>Repositorio compartido de la empresa.</p></div>
</div></main></div></body></html>
