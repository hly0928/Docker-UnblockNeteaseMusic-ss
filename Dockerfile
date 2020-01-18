FROM alpine:latest AS builder
ARG v2ray_version=v4.22.1
ARG unblockneteasemusic_version=master
RUN apk add --update wget git unzip gcc autoconf make libtool automake zlib-dev openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers && \
    mkdir /v2ray && \
    cd /v2ray && \
    wget -q -O v2ray.zip https://github.com/v2ray/v2ray-core/releases/download/${v2ray_version}/v2ray-linux-64.zip && \
    unzip v2ray.zip && \
    mkdir /simple-obfs && \
    cd /simple-obfs && \
    git clone https://github.com/shadowsocks/simple-obfs.git . && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --prefix=/usr --disable-documentation && \
    make install && \
    mkdir /UnblockNeteaseMusic && \
    cd /UnblockNeteaseMusic && \
    git clone https://github.com/nondanee/UnblockNeteaseMusic.git . && \
    git checkout ${unblockneteasemusic_version}

FROM alpine:latest
LABEL maintainer="hly0928 <i@hly0928.com>"
COPY --from=builder /v2ray/v2ray /v2ray/v2ctl /v2ray/geoip.dat /v2ray/geosite.dat /usr/bin/obfs-server /usr/bin/
COPY --from=builder /UnblockNeteaseMusic .
COPY certs/server.crt certs/server.key /certs/
COPY entrypoint.sh /usr/bin/
ENV port=8080
ENV obfs=http
ENV strict=false
RUN apk add --no-cache libev nodejs && \
    rm -f server.crt server.key && \
    mkdir -p /etc/v2ray/
EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
