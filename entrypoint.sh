#!/bin/sh
set -e

if [ ! -f "/etc/v2ray/config.json" ]; then
  cat > /etc/v2ray/config.json << EOF
{ "log": { "access": "/dev/stdout", "error": "/dev/stderr", "loglevel": "warning" },
  "inbounds": [{ "port": 65535, "protocol": "shadowsocks", "settings": { "password": "UnblockNeteaseMusic", "method": "aes-256-gcm", "network": "tcp,udp" }}],
  "outbounds": [{ "protocol": "http", "settings": { "servers": [{ "address": "127.0.0.1", "port": 65534 }]}}] }
EOF

  if [ -n "${password}" ]; then
    sed -i "s/UnblockNeteaseMusic/${password}/" /etc/v2ray/config.json
  fi

  if [ -n "${method}" ]; then
    sed -i "s/aes-256-gcm/${method}/" /etc/v2ray/config.json
  fi

  if [ "${obfs}" = "none" ]; then
    sed -i "s/65535/${port}/" /etc/v2ray/config.json
  fi
fi

v2ray -config=/etc/v2ray/config.json > /dev/null 2>&1 &

if [ "${obfs}" != "none" ]; then
  if [ -n "${failover}" ]; then
    obfs-server -s 0.0.0.0 -p ${port} --obfs ${obfs} -r 127.0.0.1:65535 --failover ${failover} > /dev/null 2>&1 &
  else
    obfs-server -s 0.0.0.0 -p ${port} --obfs ${obfs} -r 127.0.0.1:65535 > /dev/null 2>&1 &
  fi
fi

ln -sf /certs/server.crt ./server.crt
ln -sf /certs/server.key ./server.key

if [ "${strict}" = "true" ]; then
  node app.js -p 65534:65533 -e https://music.163.com -s
else
  node app.js -p 65534:65533 -e https://music.163.com
fi
