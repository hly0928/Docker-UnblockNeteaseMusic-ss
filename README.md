![](https://img.shields.io/docker/cloud/build/hly0928/unblockneteasemusic-ss?color=%23429be6&style=flat-square)

## 概览

> 用于快速部署带有 UnblockNeteaseMusic 和 simple-obfs 的 Shadowsocks 服务。

本镜像包含 [UnblockNeteaseMusic](https://github.com/nondanee/UnblockNeteaseMusic), [v2ray-core](https://github.com/v2ray/v2ray-core) 和 [simple-obfs](https://github.com/shadowsocks/simple-obfs)，基于 Alpine Linux 构建。

当前版本：
- UnblockNeteaseMusic: master branch
- v2ray-core: v4.23.1
- simple-obfs: v0.0.5

*\*由于 simple-obfs 已被 deprecated，未来可能会将其移除。*

## 快速开始

```bash
docker run -d --restart unless-stopped -p 8080:8080 hly0928/unblockneteasemusic-ss
```

*(For iOS)* 安装 CA 根证书：[点此](https://raw.githubusercontent.com/hly0928/Docker-UnblockNeteaseMusic-ss/master/certs/ca.crt) 安装

SS 连接参数：

|Name|Value|
|---|---|
|Host|Server IP|
|Port|`8080`|
|Password|`UnblockNeteaseMusic`|
|Method|`aes-256-gcm`|
|Obfuscation|`http`|
|Obfs host|Optional|

## 环境变量

|Name|Default|Options|Description|
|---|---|---|---|
|PORT|`8080`|`0-65532`|容器内部监听端口，一般无需修改|
|PASSWORD|`UnblockNeteaseMusic`||连接密码|
|METHOD|`aes-256-gcm`|`aes-256-cfb`, `aes-128-cfb`, `chacha20`, `chacha20-ietf`, `aes-256-gcm`, `aes-128-gcm`, `chacha20-ietf-poly1305`|加密方式|
|OBFS|`http`|`none`, `http`, `tls`|混淆方式|
|FAILOVER|||simple-obfs [failover](https://github.com/shadowsocks/simple-obfs#coexist-with-an-actual-web-server) 选项|
|STRICT|`false`|`false`, `true`|严格模式，开启后只代理网易云流量|

例：在 `80` 端口上开启服务，密码为 `F6SVoVe5`，加密方式为 `chacha20-ietf`，不使用混淆

```bash
docker run -d \
           --restart unless-stopped \
           -p 80:8080 \
           -e PASSWORD=F6SVoVe5 \
           -e METHOD=chacha20-ietf \
           -e OBFS=none \
           hly0928/unblockneteasemusic-ss
```

## 使用自签证书

> 自签证书用于代理 HTTPS 流量，以解决部分音源匹配到却无法播放的问题。

可以直接使用本仓库提供的 [证书](https://github.com/hly0928/Docker-UnblockNeteaseMusic-ss/tree/master/certs)：[点此](https://raw.githubusercontent.com/hly0928/Docker-UnblockNeteaseMusic-ss/master/certs/ca.crt) 安装

或者参考作者 [@nondanee](https://github.com/nondanee) 给出的 [方法](https://github.com/nondanee/UnblockNeteaseMusic/issues/48#issuecomment-477870013) 签发并安装 CA 根证书，随后使用以下启动命令替换本镜像自带证书：

```bash
docker run -d \
           --restart unless-stopped \
           -p 8080:8080 \
           -v /path/to/server.crt:/certs/server.crt \
           -v /path/to/server.key:/certs/server.key \
           hly0928/unblockneteasemusic-ss
```

## 自定义 V2Ray 配置文件

可以修改默认 `/etc/v2ray/config.json` 中的 `inbounds` 部分以使用其他 V2Ray 支持的 [协议](https://www.v2ray.com/chapter_02/02_protocols.html) 连接。

Default `/etc/v2ray/config.json`:

```json
{
  "log": {
    "access": "/dev/stdout",
    "error": "/dev/stderr",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 65535,
      "protocol": "shadowsocks",
      "settings": {
        "password": "UnblockNeteaseMusic",
        "method": "aes-256-gcm",
        "network": "tcp,udp"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "http",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 65534
          }
        ]
      }
    }
  ] 
}
```

*\*如果你希望使用 Vmess 等连接方式，则应当指定环境变量 `OBFS=none` 。*

挂载自定义 `config.json`:

```bash
docker run -d \
           --restart unless-stopped \
           -p 8080:8080 \
           -e OBFS=none \
           -v /path/to/config.json:/etc/v2ray/config.json \
           hly0928/unblockneteasemusic-ss
```
