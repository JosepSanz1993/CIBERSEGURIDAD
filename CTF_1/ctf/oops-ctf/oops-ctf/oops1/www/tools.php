<?php
// Eina de "ping" vulnerable a command injection.
//   Prova:  host = 127.0.0.1; id
//   O:      host = 127.0.0.1 && cat /etc/passwd
$out = '';
if (isset($_GET['host']) && $_GET['host'] !== '') {
    $host = $_GET['host'];                 // VULNERABLE: sense sanejar
    $out = shell_exec("ping -c 1 " . $host . " 2>&1");
}
?>
<!doctype html><html lang="ca"><head><meta charset="utf-8"><title>Diagnòstic</title></head>
<body style="font-family:sans-serif;max-width:640px;margin:40px auto">
<h2>Diagnòstic de xarxa</h2>
<form method="get">
  <input name="host" placeholder="host o IP" value="<?php echo htmlspecialchars($_GET['host'] ?? ''); ?>">
  <button>Ping</button>
</form>
<pre style="background:#111;color:#0f0;padding:12px;white-space:pre-wrap"><?php echo htmlspecialchars($out); ?></pre>
<p><a href="index.php">&larr; Tornar</a></p>
</body></html>
