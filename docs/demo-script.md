# 面试演示脚本

## 30 秒版本

这是一个 Flutter Web/PWA 做的 Polymarket EV 分析工具。我没有做真实自动下单，而是先实现市场展示、EV Gap 分析、聪明钱跟踪占位、Fractional Kelly 仓位建议和风险设置。重点是展示从产品需求到可运行 demo 的闭环，同时保留金融产品的安全边界。

## 2 分钟版本

1. 首页展示热门市场、价格、成交量、流动性和 Top Opportunities。
2. EV Gap 的公式是 `fair probability - market implied probability`，用户可以把市场价格和自己的判断拆开看。
3. Analysis 页可以点开机会详情，手动调整 fair probability，观察建议方向和仓位是否变化。
4. 仓位不是固定百分比，而是用 Fractional Kelly 计算，并被单市场上限、每日亏损限制和相关性风险截断。
5. Smart Money 页目前用 mock wallet activity，未来可以接入链上钱包、CLOB 成交或自建 indexer。
6. Settings 页支持中英文切换、风险参数调整和 OpenAI Key 预留位。
7. 部署方式优先 PWA，在 iPhone 上可以通过 Safari 添加到主屏幕，适合快速演示。

## 面试官可能追问

### 为什么不做真实下单？

因为金融交易客户端不能保存真实私钥，移动端也可能被反编译。真实下单需要后端签名、人工确认、滑点控制、订单状态校验和合规审查。MVP 先验证分析价值，不碰真实资金。

### fair probability 是怎么来的？

当前是本地启发式估计，用隐含概率、成交量、流动性和价差惩罚快速生成一个可解释 baseline。正式版会改成后端 AI research model，结合新闻、链上数据、历史成交和用户自己的假设。

### 这个项目如何体现 Vibe Coding？

我把需求拆成数据层、分析层、风控层、状态层和 UI 层，再用 AI 辅助快速生成代码、测试和部署脚本。过程中保留人工判断：例如交易执行不放客户端、API key 不硬编码、PWA 先解决 iPhone 展示。

### 下一步最重要的改进是什么？

第一是稳定真实数据源和字段映射；第二是把 AI fair probability 和解释迁到后端；第三是增加历史价格和回测，验证 EV 信号不是只在 UI 上好看。
