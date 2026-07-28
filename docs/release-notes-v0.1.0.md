# Release v0.1.0

## 版本定位

Polymarket EV Desk v0.1.0 是一个面试演示级 MVP，重点展示预测市场分析产品的完整闭环：市场数据、EV Gap、仓位建议、设置持久化、PWA 演示和部署脚本。

## 包含内容

- Flutter Web/PWA release build
- Polymarket Gamma API proxy server
- mock fallback data
- README 和产品截图
- 需求分析与用户研究 demo
- 面试演示脚本

## 已知限制

- 不包含 Android APK，因为当前 Windows 环境尚未安装 Android SDK。
- 不包含 iOS IPA，因为 iOS 构建和签名需要 macOS + Xcode。
- 不做真实交易下单。
- fair probability 当前是本地启发式估计，不是生产级 AI 预测。

## 体验方式

1. 解压 `polymarket_ev_desk_web_demo.zip`。
2. 将 `web/` 目录部署到 HTTPS 静态托管。
3. 如果需要实时 Polymarket 数据，使用 `deploy_server.py` 启动同源代理。
4. iPhone Safari 打开 HTTPS URL 后选择“添加到主屏幕”。
