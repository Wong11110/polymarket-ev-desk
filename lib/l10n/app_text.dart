class AppText {
  const AppText(this.languageCode);

  final String languageCode;

  bool get zh => languageCode == 'zh';

  String pick(String en, String cn) => zh ? cn : en;

  String get appTitle => pick('Polymarket EV Desk', 'Polymarket 机会台');
  String get home => pick('Home', '首页');
  String get analysis => pick('Analysis', '分析');
  String get smartMoney => pick('Smart Money', '聪明钱');
  String get settings => pick('Settings', '设置');
  String get executionDisabled => pick('Execution disabled', '交易执行未启用');
  String get executionDisabledBody => pick(
        'This MVP is analysis-only and does not place real orders. Add backend signing, manual confirmation, slippage controls, and order-state checks before enabling trading.',
        '当前版本只做行情分析和仓位建议，不会真实下单。上线交易前需要后端签名、人工确认、滑点保护和订单状态校验。',
      );
  String get ok => pick('OK', '知道了');
  String get tradePlaceholder => pick('Trade execution disabled', '交易执行未启用');

  String get dashboardTitle => pick('Polymarket EV Desk', 'Polymarket 套利机会台');
  String get dashboardSubtitle => pick(
        'Near-real-time markets, EV Gap analysis, and Kelly-aware position sizing. Analysis only; no real orders are placed.',
        '准实时行情 + EV Gap 分析 + Kelly 仓位建议。当前只做分析，不会真实下单。',
      );
  String get realtimeNote => pick(
        'Data note: market prices are polled from the Polymarket Gamma API every 60 seconds. EV and position sizing are recalculated locally after each update. Fair probability is currently a local heuristic, not a live external AI forecast.',
        '实时性说明：市场价格每 60 秒从 Polymarket Gamma API 轮询一次；EV 和仓位建议会跟随最新价格本地重算。fair probability 目前是本地启发式估计，不是外部 AI 实时预测。',
      );
  String get bankroll => pick('Bankroll', '资金规模');
  String get evAlert => pick('EV Alert', 'EV 提醒线');
  String get kelly => pick('Kelly', 'Kelly 系数');
  String get maxPosition => pick('Max Position', '单市场上限');
  String get topOpportunities => pick('Top Opportunities', '当前机会');
  String get noEvGaps => pick('No EV gaps above your threshold yet.', '暂时没有超过阈值的 EV Gap。');
  String get popularMarkets => pick('Popular Markets', '热门市场');
  String get settingsError => pick('Settings error', '设置读取失败');
  String get opportunityError => pick('Opportunity error', '机会分析失败');
  String get marketError => pick('Market error', '行情加载失败');
  String get volume => pick('Vol', '成交');
  String get liquidity => pick('Liq', '流动性');

  String get analysisTitle => pick('EV Gap Analysis', 'EV Gap 分析');
  String get refresh => pick('Refresh', '刷新行情');
  String get analysisDescription => pick(
        'Fair probability is estimated by a local heuristic model using price, volume, liquidity, and spread. Replace it later with your own research model or an AI-backed backend.',
        '这里的 fair probability 先用本地启发式模型估计：参考市场价格、成交量、流动性和价差。正式版可以替换成自己的研究模型或后端 AI 服务。',
      );
  String get noFilteredOpportunities => pick(
        'No opportunities pass your EV and liquidity filters.',
        '当前没有通过 EV 和流动性过滤的机会。',
      );
  String get analysisError => pick('Analysis error', '分析失败');

  String get smartMoneyTitle => pick('Smart Money Tracking', '聪明钱跟踪');
  String get smartMoneyDescription => pick(
        'MVP uses mock wallet flow to demonstrate the follow-trading module. Replace it later with wallet, subgraph, CLOB, or custom indexer data.',
        'MVP 先用模拟钱包流水，展示跟单模块的结构。后续可以替换成链上钱包、CLOB 成交或自建索引服务。',
      );
  String get size => pick('Size', '金额');
  String get winRate => pick('Win Rate', '胜率');
  String get age => pick('Age', '距今');
  String get smartMoneyError => pick('Smart money error', '聪明钱数据加载失败');

  String get settingsTitle => pick('Settings', '参数设置');
  String get language => pick('Language', '语言');
  String get english => pick('English', '英文');
  String get chinese => pick('Chinese', '中文');
  String get bankrollUsd => pick('Bankroll USD', '资金规模 USD');
  String get evAlertThreshold => pick('EV Alert Threshold', 'EV 提醒阈值');
  String get kellyFraction => pick('Kelly Fraction', 'Kelly 折扣系数');
  String get maxPositionPct => pick('Max Position', '单市场最大仓位');
  String get dailyLossLimit => pick('Daily Loss Limit', '单日亏损限制');
  String get minLiquidity => pick('Min Liquidity', '最低流动性');
  String get darkMode => pick('Dark Mode', '深色模式');
  String get apiKeyPlaceholder => pick('OpenAI API Key placeholder', 'OpenAI API Key（预留）');
  String get apiKeyHelper => pick(
        'For production, proxy AI and trading keys through a backend. Do not hardcode secrets in the frontend.',
        '正式版建议通过后端代理处理 AI 和交易密钥，前端不要硬编码。',
      );
  String get saveSettings => pick('Save Settings', '保存设置');
  String get settingsSaved => pick('Settings saved', '设置已保存');

  String get fairProbability => pick('Fair', '公允概率');
  String get price => pick('Price', '价格');
  String get suggestedStake => pick('Stake', '建议仓位');
  String get risk => pick('Risk', '风险');
  String get details => pick('Details', '详情');
  String get marketDetail => pick('Opportunity Detail', '机会详情');
  String get manualAssumption => pick('Manual Fair Probability', '手动公允概率');
  String get modelEstimate => pick('Model estimate', '模型估计');
  String get impliedProbability => pick('Implied', '隐含概率');
  String get expectedRoi => pick('Expected ROI', '预期 ROI');
  String get volumeFull => pick('Volume', '成交量');
  String get liquidityFull => pick('Liquidity', '流动性');
  String get spread => pick('Spread', '价差');
  String get close => pick('Close', '关闭');
  String get detailNote => pick(
        'Adjust the fair probability to stress-test whether the opportunity still survives your risk settings.',
        '调整公允概率可以做压力测试，观察该机会在你的风控参数下是否仍然成立。',
      );
  String riskLabel(String value) {
    if (!zh) return value;
    return switch (value) {
      'low' => '低',
      'medium' => '中',
      'high' => '高',
      _ => value,
    };
  }
}
