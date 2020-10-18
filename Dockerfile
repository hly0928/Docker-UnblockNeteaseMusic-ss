FROM alpine:latest AS builder
# Define V2Ray version
ARG V2RAY_VERSION=4.31.1
# Define UnblockNeteaseMusic version
ARG UNBLOCKNETEASEMUSIC_VERSION=master
# Install dependencies
RUN apk update && \
    apk add git wget unzip gcc autoconf make libtool automake zlib-dev openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers
# Build simple-obfs
RUN git clone https://github.com/shadowsocks/simple-obfs.git /simple-obfs && \
    cd /simple-obfs && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure --disable-documentation && \
    make install
# Download mo
RUN cd /root && \
    wget -q -O mo https://git.io/get-mo && \
    chmod +x mo
# Download V2Ray
RUN cd /root && \
    wget -q -O v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/v2ray-linux-64.zip && \
    unzip v2ray.zip
# Download UnblockNeteaseMusic
RUN git clone https://github.com/nondanee/UnblockNeteaseMusic.git /UnblockNeteaseMusic && \
    cd /UnblockNeteaseMusic && \
    git checkout ${UNBLOCKNETEASEMUSIC_VERSION}

FROM alpine:latest
LABEL maintainer="hly0928 <i@hly0928.com>"
COPY --from=builder /usr/local/bin/obfs-server /usr/local/bin/
COPY --from=builder /root/mo /usr/local/bin/
COPY --from=builder /root/v2ray /root/v2ctl /root/geoip.dat /root/geosite.dat /usr/local/bin/
COPY --from=builder /UnblockNeteaseMusic .
COPY entrypoint.sh /usr/local/bin/
COPY certs/server.crt certs/server.key /certs/
COPY template.json /etc/v2ray/template.json
ENV PORT=8080 \
    PASSWORD=UnblockNeteaseMusic \
    METHOD=aes-256-gcm \
    OBFS=http \
    STRICT=false \
    SOURCE="qq kugou kuwo xiami"
RUN apk add --no-cache bash libev nodejs && \
    rm -f server.crt server.key
EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
