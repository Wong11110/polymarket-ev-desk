# Polymarket EV Desk Web/PWA Demo

## 快速体验

这个包是 Flutter Web/PWA 构建产物，适合部署到 HTTPS 静态站点后在 iPhone Safari 中演示。

推荐方式：

1. 解压 `polymarket_ev_desk_web_demo.zip`。
2. 将 `web/` 目录上传到 Cloudflare Pages、Vercel、Netlify、Nginx 或任意 HTTPS 静态托管。
3. 用 Safari 打开线上地址。
4. 点击分享按钮，选择“添加到主屏幕”。

## 本地预览

如果只是本地查看，可以在项目根目录运行：

```powershell
C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe run tool/static_server.dart build/web 8080
```

然后访问：

```text
http://localhost:8080
```

## 数据说明

Web 环境通过同源 `/api/polymarket/events` 代理请求 Polymarket Gamma API。如果托管平台不支持代理，项目会自动回退到 mock 数据，保证 demo 页面可用。

## 安全说明

当前版本只做分析，不做真实下单，不保存真实交易私钥，不构成投资建议。
