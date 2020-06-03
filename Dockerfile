FROM alpine:latest AS builder
# Define gost version
ARG GOST_VERSION=2.11.1
# Define UnblockNeteaseMusic version
ARG UNBLOCKNETEASEMUSIC_VERSION=master
# Install dependencies
RUN apk update && \
    apk add git wget gzip gcc autoconf make libtool automake zlib-dev openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers
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
# Download gost
RUN cd /root && \
    wget -q -O gost.gz https://github.com/ginuerzh/gost/releases/download/v${GOST_VERSION}/gost-linux-amd64-${GOST_VERSION}.gz && \
    gzip -d gost.gz && \
    chmod +x gost
# Download UnblockNeteaseMusic
RUN git clone https://github.com/nondanee/UnblockNeteaseMusic.git /UnblockNeteaseMusic && \
    cd /UnblockNeteaseMusic && \
    git checkout ${UNBLOCKNETEASEMUSIC_VERSION}

FROM alpine:latest
LABEL maintainer="hly0928 <i@hly0928.com>"
COPY --from=builder /usr/local/bin/obfs-server /usr/local/bin/
COPY --from=builder /root/mo /usr/local/bin/
COPY --from=builder /root/gost /usr/local/bin/
COPY --from=builder /UnblockNeteaseMusic .
COPY entrypoint.sh /usr/local/bin/
COPY certs/server.crt certs/server.key /certs/
COPY template.json /etc/gost/template.json
ENV PORT=8080 \
    PASSWORD=UnblockNeteaseMusic \
    METHOD=AEAD_CHACHA20_POLY1305 \
    OBFS=http \
    STRICT=false \
    SOURCE="qq kugou kuwo xiami"
RUN apk add --no-cache bash libev nodejs && \
    rm -f server.crt server.key
EXPOSE 8080
ENTRYPOINT ["entrypoint.sh"]
