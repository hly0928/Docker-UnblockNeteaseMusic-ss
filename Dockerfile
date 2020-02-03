FROM alpine:latest AS builder
ARG unblockneteasemusic_version=master
RUN apk add --update curl bash git unzip gcc autoconf make libtool automake zlib-dev openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers && \
    curl -L -s https://install.direct/go.sh > go.sh && \
    bash ./go.sh && \
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
COPY --from=builder /usr/bin/v2ray/ /usr/bin/obfs-server /usr/bin/
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
