#!/bin/sh
set -e

ln -sf /certs/server.crt ./server.crt
ln -sf /certs/server.key ./server.key

[ "${OBFS}" = "none" ] && export GOST_PORT=${PORT} || export GOST_PORT=65535
[ -f "/etc/gost/gost.json" ] || mo /etc/gost/template.json > /etc/gost/gost.json
[ -n "${FAILOVER}" ] && FAILOVER_ARG="--failover ${FAILOVER}" || FAILOVER_ARG=""
[ "${STRICT}" = "true" ] && STRICT_ARG="-s" || STRICT_ARG=""

gost -C /etc/gost/gost.json > /dev/null 2>&1 &
[ "${OBFS}" = "none" ] || eval obfs-server -s 0.0.0.0 -p ${PORT} --obfs ${OBFS} -r 127.0.0.1:65535 ${FAILOVER_ARG} > /dev/null 2>&1 &
eval node app.js -p 65534:65533 -e https://music.163.com -o ${SOURCE} ${STRICT_ARG}
