#!/bin/sh
set -e

if [ ! -f "/etc/v2ray/config.json" ]; then
  if [ "${OBFS}" = "none" ]; then
    export V2_PORT=${PORT}
  else
    export V2_PORT=65535
  fi
  mo /etc/v2ray/template.json > /etc/v2ray/config.json
fi

v2ray -config=/etc/v2ray/config.json > /dev/null 2>&1 &

if [ "${OBFS}" != "none" ]; then
  if [ -n "${FAILOVER}" ]; then
    obfs-server -s 0.0.0.0 -p ${PORT} --obfs ${OBFS} -r 127.0.0.1:65535 --failover ${FAILOVER} > /dev/null 2>&1 &
  else
    obfs-server -s 0.0.0.0 -p ${PORT} --obfs ${OBFS} -r 127.0.0.1:65535 > /dev/null 2>&1 &
  fi
fi

ln -sf /certs/server.crt ./server.crt
ln -sf /certs/server.key ./server.key

if [ "${STRICT}" = "true" ]; then
  node app.js -p 65534:65533 -e https://music.163.com -o qq kuwo kugou migu -s
else
  node app.js -p 65534:65533 -e https://music.163.com -o qq kuwo kugou migu
fi
