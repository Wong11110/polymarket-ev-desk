# VPS 部署说明

## 当前部署设计

项目可以通过 Flutter Web 构建为静态文件，再由一个轻量 Python server 托管。server 同时提供 `/api/polymarket/events` 代理，避免浏览器直连 Polymarket API 时遇到 CORS 问题。

## 推荐 VPS 参数

- 目录：`/opt/polymarket-ev`
- 服务：`polymarket-ev.service`
- 监听：`127.0.0.1:8601`
- 外部访问：Cloudflare Tunnel public hostname

## Cloudflare Tunnel 路由

在 Cloudflare Zero Trust 的 Tunnel 配置中添加：

- Public hostname: `ev.aldacareer.online`
- Service type: `HTTP`
- Service URL: `http://127.0.0.1:8601`
- Path: 留空

这样可以避免直接暴露 VPS 端口，也不会影响同一台机器上的其他服务。

## 运维命令

```bash
systemctl status polymarket-ev.service --no-pager
curl -I http://127.0.0.1:8601/
curl -I "http://127.0.0.1:8601/api/polymarket/events?active=true&closed=false&limit=1"
```

## 安全边界

- 服务只监听 `127.0.0.1`。
- 不改动现有 `xray.service`、`cloudflared.service`、`career-agent.service`。
- 不在 VPS 或前端保存交易私钥。
- OpenAI 和交易执行应迁移到后端服务，并使用环境变量或 secret 管理。
