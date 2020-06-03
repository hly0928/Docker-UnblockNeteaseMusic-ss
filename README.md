![Build Status](https://img.shields.io/docker/cloud/build/hly0928/unblockneteasemusic-ss?color=%23429be6&style=flat-square)

## 概览

> 用于快速部署带有 UnblockNeteaseMusic 和 simple-obfs 的 Shadowsocks 服务。

本镜像包含 [UnblockNeteaseMusic](https://github.com/nondanee/UnblockNeteaseMusic), [gost](https://github.com/ginuerzh/gost) 和 [simple-obfs](https://github.com/shadowsocks/simple-obfs)，基于 Alpine Linux 构建。

当前版本：
- UnblockNeteaseMusic: master branch
- gost: v2.11.1
- simple-obfs: v0.0.5

*由于 simple-obfs 已被 deprecated，未来可能会将其移除。*

## 快速开始

```bash
docker run -d --restart unless-stopped -p 8080:8080 hly0928/unblockneteasemusic-ss:gost
```

(For iOS) 安装 CA 根证书：[点此](https://raw.githubusercontent.com/hly0928/Docker-UnblockNeteaseMusic-ss/gost/certs/ca.crt) 安装，注意安装后需要到 `设置 > 通用 > 关于 > 证书信任设置` 中打开对该证书的完全信任。

SS 连接参数：

|Name|Value|
|---|---|
|Host|Server IP|
|Port|`8080`|
|Password|`UnblockNeteaseMusic`|
|Method|`chacha20-ietf-poly1305`|
|Obfuscation|`http`|
|Obfs host|Optional|

## 环境变量

|Name|Default|Options|Description|
|---|---|---|---|
|PORT|`8080`|`0-65532`|容器内部监听端口，一般无需修改|
|PASSWORD|`UnblockNeteaseMusic`||连接密码|
|METHOD|`AEAD_CHACHA20_POLY1305`|`AEAD_AES_128_GCM`, `AEAD_AES_256_GCM`, `AEAD_CHACHA20_POLY1305`|加密方式|
|OBFS|`http`|`none`, `http`, `tls`|混淆方式|
|FAILOVER|||simple-obfs [failover](https://github.com/shadowsocks/simple-obfs#coexist-with-an-actual-web-server) 选项|
|STRICT|`false`|`false`, `true`|严格模式，开启后只代理网易云流量|
|SOURCE|`qq kugou kuwo xiami`|`baidu`, `joox`, `kugou`, `kuwo`, `migu`, `qq`, `xiami`|自定义音源及搜索顺序|

例：在 `80` 端口上开启服务，密码为 `F6SVoVe5`，加密方式为 `aes-256-gcm`，不使用混淆

```bash
docker run -d \
           --restart unless-stopped \
           -p 80:8080 \
           -e PASSWORD=F6SVoVe5 \
           -e METHOD=AEAD_AES_256_GCM \
           -e OBFS=none \
           hly0928/unblockneteasemusic-ss:gost
```

## 高级设置

### 使用自签证书 (For iOS/macOS)

> 自签证书用于代理 HTTPS 流量，以解决 iOS/macOS 平台部分音源匹配到却无法播放的问题（一般显示为「网络不给力」）。

可以直接使用本仓库提供的 [证书](https://github.com/hly0928/Docker-UnblockNeteaseMusic-ss/tree/gost/certs)：iOS [点此](https://raw.githubusercontent.com/hly0928/Docker-UnblockNeteaseMusic-ss/gost/certs/ca.crt) 安装，注意安装后需要到 `设置 > 通用 > 关于 > 证书信任设置` 中打开对该证书的完全信任；macOS 需自行将证书下载并添加到 Keychain 中，随后打开完全信任。

或者参考作者 [@nondanee](https://github.com/nondanee) 给出的 [方法](https://github.com/nondanee/UnblockNeteaseMusic/issues/48#issuecomment-477870013) 自行签发并安装 CA 根证书，随后使用以下启动命令替换内置的服务器证书：

```bash
docker run -d \
           --restart unless-stopped \
           -p 8080:8080 \
           -v /path/to/server.crt:/certs/server.crt \
           -v /path/to/server.key:/certs/server.key \
           hly0928/unblockneteasemusic-ss:gost
```

### 自定义 GOST 配置文件

可以修改默认 `/etc/gost/gost.json` 中的 `ServeNodes` 部分以使用其他 gost 支持的 [协议/传输类型](https://docs.ginuerzh.xyz/gost/configuration) 连接。

Default `/etc/gost/gost.json`:

```json
{
  "Debug": false,
  "ServeNodes": [
    "ss2://AEAD_CHACHA20_POLY1305:UnblockNeteaseMusic@:65535"
  ],
  "ChainNodes": [
    "http://:65534"
  ]
}
```

*如果你希望使用其他连接方式，则应当指定环境变量 `OBFS=none`*

挂载自定义 `gost.json`:

```bash
docker run -d \
           --restart unless-stopped \
           -p 8080:8080 \
           -e OBFS=none \
           -v /path/to/gost.json:/etc/gost/gost.json \
           hly0928/unblockneteasemusic-ss:gost
```

## 许可

[The MIT License](https://github.com/hly0928/Docker-UnblockNeteaseMusic-ss/blob/gost/LICENSE)
