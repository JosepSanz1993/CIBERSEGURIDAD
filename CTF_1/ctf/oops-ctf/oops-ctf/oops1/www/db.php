<?php
// Connexió a MySQL. Credencials "hardcoded" (mala pràctica didàctica).
function db() {
    $c = @mysqli_connect('127.0.0.1', 'webapp', 'webapp', 'webapp');
    if (!$c) { die('DB error: ' . mysqli_connect_error()); }
    return $c;
}
