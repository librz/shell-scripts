#!/bin/bash

# util functions

function err() {
	echo "$1" >&2
}

# pre-requisites

echo "V2ray + tls + nginx + websocket 安装配置脚本"

echo "在运行此脚本之前，以下条件应该被满足："
echo "1. 系统是 Ubuntu 或者 Debian 并且使用 root 账号登陆"
echo "2. 系统不在 GFW 封锁范围内"
echo "3. 系统上没有安装过 certbot"
echo "4. 已经准备好域名并且 DNS 的 A 记录已经将域名指向本机的IP地址"

read -p "是否继续? (Y/N) " -r answer
if [[ $answer != "Y" ]] && [[ $answer != "y" ]]; then
	err "已退出"
	exit 1
fi

apt update

# get domain
read -p "请输入域名: " -r domain

# install curl, nginx, snapd and certbot
yes | apt install curl nginx snapd
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
if ! certbot --nginx; then
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

# find the first occurence of "managed by Certbot" and insert setting after it 
lineNumber=$(grep -in "managed by Certbot" /etc/nginx/default | awk -F':' '(NR==1){print $1}')
echo "prepare to insert nginx setting at line $lineNumber"
result=$(awk -v ln="$lineNumber" -v setting="$setting" 'NR==ln{print setting}1')
echo "$result" > /etc/nginx/default
echo "nginx setting inserted"

service nginx restart
