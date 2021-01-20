#!/bin/bash

echo "V2ray + tls + nginx + websocket 安装配置脚本"

echo "在运行此脚本之前，以下条件应该被满足："
echo "1. 系统是 Ubuntu 18.04 或者以上并且使用 root 账号登陆"
echo "2. 系统上没有安装过 certbot"
echo "3. 已经准备好域名并且 DNS 的 A 记录已经将域名指向本机的IP地址"

read -p "是否继续? (Y/N) " -r answer
if [[ $answer != "Y" ]] && [[ $answer != "y" ]]; then
	echo "已退出"
	exit 1
fi

# get domain
read -p "请输入域名: " -r domain

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
cat > /usr/local/etc/v2ray/config.json << "EOF"
{
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
}
EOF

service v2ray restart

# hook certbot with nginx
if ! (echo -e "Y\n$domain\n" | certbot --nginx  --register-unsafely-without-email); then
	echo "certbot 设置出现问题，安装失败"
	exit 1
fi

# nginx reverse proxy setting 
setting=$(
cat << "EOF"
location /v2 {
	proxy_redirect off;
	proxy_pass http://127.0.0.1:60000; 
	proxy_http_version 1.1;
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";
	proxy_set_header Host $http_host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
EOF
)

# find the fist occurence of "managed by Certbot" and insert setting after it 
bash <(curl -L https://raw.githubusercontent.com/librz/shell_scripts/main/flai.sh) /etc/nginx/sites-available/default "managed by Certbot"  "$setting"

service nginx restart
