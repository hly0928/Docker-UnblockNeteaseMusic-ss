FROM alpine:latest AS builder
# Define UnblockNeteaseMusic version
ARG UNBLOCKNETEASEMUSIC_VERSION=master
# Install build dependencies
RUN apk update && \
    apk add curl git gcc autoconf make libtool automake zlib-dev openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers
# Build simple-obfs
RUN git clone https://github.com/shadowsocks/simple-obfs.git /simple-obfs && \
    cd /simple-obfs && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --disable-documentation && \
    make install
# Download mo
RUN curl -fsSL https://git.io/get-mo -o mo && \
    chmod +x mo && \
    mv mo /usr/local/bin/
# Download UnblockNeteaseMusic
RUN git clone https://github.com/nondanee/UnblockNeteaseMusic.git /UnblockNeteaseMusic && \
    cd /UnblockNeteaseMusic && \
    git checkout ${UNBLOCKNETEASEMUSIC_VERSION}

FROM v2fly/v2fly-core AS v2fly-core

FROM alpine:latest
LABEL maintainer="hly0928 <i@hly0928.com>"
COPY --from=builder /usr/local/bin/obfs-server /usr/local/bin/mo /usr/local/bin/
COPY --from=builder /UnblockNeteaseMusic .
COPY --from=v2fly-core /usr/bin/v2ray/ /usr/local/bin/
COPY certs/server.crt certs/server.key /certs/
COPY template.json /etc/v2ray/template.json
COPY entrypoint.sh /usr/local/bin/
ENV PORT=8080
ENV PASSWORD=UnblockNeteaseMusic
ENV METHOD=aes-256-gcm
ENV OBFS=http
ENV STRICT=false
RUN apk add --no-cache bash libev nodejs && \
    rm -f server.crt server.key
EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
