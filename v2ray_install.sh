#!/bin/bash

# V2ray + tls + nginx + websocket 的安装和设置

echo "在运行此脚本之前，以下条件应该被满足："
echo "1. 系统是 Ubuntu 18.04 或者以上"
echo "2. 系统上没有安装过 certbot"
echo "3. 已经准备好域名并且 DNS 的 A 记录已经将域名指向本机的IP地址"

echo -n "是否继续? (Y/N) "
read answer
if [[ $answer != "Y" ]] && [[ $answer != "y" ]]; then
	exit 1
fi

# get domain
echo -n "Please input your domain: "
read domain

# install curl, nginx, snapd and certbot
yes Y | apt install curl nginx snapd
snap install --classic certbot
if [[ ! -f /usr/bin/certbot ]]; then
				ln -s /snap/bin/certbot /usr/bin/certbot
fi

# run scripts from https://github.com/v2fly/fhs-install-v2ray to install v2ray core and geo file
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) 
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh) 

# write v2ray config 
config='{
  "inbounds": [{
    "port": 60000, 
    "protocol": "vmess",
    "settings": {
      "clients": [{ "id": "4cce13cd-770e-4b5b-8013-c16b6e62bbcc" }]
    },
		"streamSettings": {
			"network": "ws",
			"wsSettings": {
				"path": "/v2"
			}
		}
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}'
echo $config > /usr/local/etc/v2ray/config.json
service v2ray restart

# hook certbot with nginx
echo -e "Y\n$doamin\n" | certbot --nginx  -register-unsafely-without-email
if [[ $? -ne 0 ]]; then
	echo "certbot 设置出现问题，安装失败"
	exit 1
fi

# insert reverse proxy setting to nginx config
setting='\nlocation /v2 {\n    proxy_redirect off;\n    proxy_pass http://127.0.0.1:60000; \n    proxy_http_version 1.1;\n    proxy_set_header Upgrade $http_upgrade;\n    proxy_set_header Connection "upgrade";\n    proxy_set_header Host $http_host;\n    proxy_set_header X-Real-IP $remote_addr;\n    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n  }\n'
# find the fist occurence of "managed by Certbot" ans insert setting after it 
bash <(curl -L https://raw.githubusercontent.com/librz/shell_scripts/main/flai.sh) /etc/nginx/sites-available "managed by Certbot"  "$setting"

service nginx restart
