#!/bin/sh
set -e

ln -sf /certs/server.crt ./server.crt
ln -sf /certs/server.key ./server.key

[ "${OBFS}" = "none" ] && export V2_PORT=${PORT} || export V2_PORT=65535
[ -f "/etc/v2ray/config.json" ] || mo /etc/v2ray/template.json > /etc/v2ray/config.json
[ -n "${FAILOVER}" ] && FAILOVER_ARG="--failover ${FAILOVER}" || FAILOVER_ARG=""
[ "${STRICT}" = "true" ] && STRICT_ARG="-s" || STRICT_ARG=""

v2ray -config=/etc/v2ray/config.json > /dev/null 2>&1 &
[ "${OBFS}" = "none" ] || eval obfs-server -s 0.0.0.0 -p ${PORT} --obfs ${OBFS} -r 127.0.0.1:65535 ${FAILOVER_ARG} > /dev/null 2>&1 &
eval node app.js -p 65534:65533 -e https://music.163.com -o ${SOURCE} ${STRICT_ARG}
