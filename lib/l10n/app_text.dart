class AppText {
  const AppText(this.languageCode);

  final String languageCode;
  bool get zh => languageCode == 'zh';
  String pick(String en, String cn) => zh ? cn : en;

  String get appTitle => pick('Polymarket EV Desk', 'Polymarket 机会雷达');
  String get home => pick('Home', '首页');
  String get analysis => pick('Analysis', '分析');
  String get smartMoney => pick('Smart Money', '聪明钱');
  String get settings => pick('Settings', '设置');
  String get ok => pick('OK', '知道了');
  String get executionDisabled =>
      pick('Real execution is not connected', '尚未连接真实交易');
  String get executionDisabledBody => pick(
        'This workspace can analyse live public market data and estimate fills. Real orders require wallet signing, a protected server-side credential flow, and explicit user confirmation.',
        '当前工作台可分析公开实时行情并预估成交。真实订单需要钱包签名、受保护的服务端凭据流程以及用户明确确认。',
      );
  String get tradePlaceholder => pick('Execution status', '交易状态');

  String get dashboardTitle => pick('Polymarket EV Desk', 'Polymarket 机会雷达');
  String get evAlert => pick('EV Alert', 'EV 提醒线');
  String get topOpportunities => pick('Top Opportunities', '优先关注机会');
  String get refresh => pick('Refresh', '刷新');
  String get marketError => pick('Market load failed', '行情加载失败');
  String get opportunityError => pick('Opportunity analysis failed', '机会分析失败');
  String get volume => pick('Vol', '成交额');
  String get liquidity => pick('Liq', '流动性');
  String get originalTitle => pick('Original', '原始标题');

  String get analysisTitle => pick('EV Gap Analysis', 'EV Gap 分析');
  String get analysisDescription => pick(
        'Fair probability is a local heuristic based on price, volume, liquidity, and spread. Validate every idea with independent research before risking capital.',
        '公平概率目前由价格、成交额、流动性和价差构成的本地启发式模型估算。任何真实资金决策前，都应完成独立研究和盘口核验。',
      );
  String get noFilteredOpportunities => pick(
        'No opportunities pass your EV and liquidity filters.',
        '当前没有通过 EV 与流动性筛选的机会。',
      );
  String get analysisError => pick('Analysis failed', '分析失败');

  String get smartMoneyTitle => pick('Smart Money Tracking', '聪明钱跟踪');
  String get smartMoneyDescription => pick(
        'This module currently shows demonstrative wallet activity. Its repository boundary is ready for an indexer or verified trade feed.',
        '当前模块展示的是演示钱包活动；数据层已经预留，可替换为索引服务或已验证的成交数据源。',
      );
  String get size => pick('Size', '金额');
  String get winRate => pick('Win Rate', '胜率');
  String get age => pick('Age', '时间');
  String get smartMoneyError => pick('Smart money load failed', '聪明钱数据加载失败');

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
  String get apiKeyPlaceholder => pick(
        'OpenAI API Key (reserved, not enabled)',
        'OpenAI API Key（预留，尚未启用）',
      );
  String get apiKeyHelper => pick(
        'This MVP does not send this key anywhere. Do not put production AI keys or trading credentials in the frontend.',
        '当前版本不会发送此密钥。请勿把生产 AI 密钥或交易凭据放在前端。',
      );
  String get saveSettings => pick('Save Settings', '保存设置');
  String get settingsSaved => pick('Settings saved', '设置已保存');

  String get fairProbability => pick('Fair', '公平概率');
  String get price => pick('Price', '价格');
  String get suggestedStake => pick('Stake', '建议仓位');
  String get risk => pick('Risk', '风险');
  String get details => pick('Details', '详情');
  String get marketDetail => pick('Opportunity Detail', '机会详情');
  String get manualAssumption => pick('Manual Fair Probability', '手动公平概率');
  String get modelEstimate => pick('Model estimate', '模型估计');
  String get impliedProbability => pick('Implied', '隐含概率');
  String get expectedRoi => pick('Expected ROI', '预期 ROI');
  String get volumeFull => pick('Volume', '成交额');
  String get liquidityFull => pick('Liquidity', '流动性');
  String get spread => pick('Spread', '价差');
  String get close => pick('Close', '关闭');
  String get detailNote => pick(
        'Change your fair probability assumption to test whether the idea still fits your risk settings.',
        '调整公平概率假设，检查机会在当前风控参数下是否依然成立。',
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

  String marketQuestion(String value) {
    if (!zh) return value;
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return _marketQuestionZh[normalized.toLowerCase()] ??
        _translateCommonTerms(normalized);
  }

  String marketCategory(String value) {
    if (!zh) return value;
    return _categoryZh[value.trim().toLowerCase()] ?? value;
  }

  String _translateCommonTerms(String value) {
    var result = value;
    for (final entry in _commonTerms.entries) {
      result = result.replaceAll(
        RegExp(entry.key, caseSensitive: false),
        entry.value,
      );
    }
    return result;
  }
}

const _marketQuestionZh = <String, String>{
  'will the fed cut rates at the next fomc meeting?': '美联储会在下一次 FOMC 会议降息吗？',
  'will btc close above \$100k before year end?': 'BTC 会在年底前收于 10 万美元上方吗？',
  'will candidate a win the national election?': '候选人 A 会赢得全国大选吗？',
  'will a frontier ai lab release a new flagship model in q3?':
      '前沿 AI 实验室会在第三季度发布新的旗舰模型吗？',
  'will team usa win the 2026 world cup?': '美国队会赢得 2026 年世界杯吗？',
};

const _categoryZh = <String, String>{
  'macro': '宏观',
  'crypto': '加密资产',
  'politics': '政治',
  'technology': '科技',
  'sports': '体育',
  'economics': '经济',
  'business': '商业',
  'elections': '选举',
  'culture': '文化',
};

const _commonTerms = <String, String>{
  r'\bwill\b': '是否',
  r'\bfed\b': '美联储',
  r'\brates\b': '利率',
  r'\bbitcoin\b': '比特币',
  r'\bethereum\b': '以太坊',
  r'\belection\b': '选举',
  r'\bai\b': 'AI',
  r'\bmodel\b': '模型',
  r'\brelease\b': '发布',
  r'\babove\b': '高于',
  r'\bbelow\b': '低于',
  r'\bbefore\b': '之前',
  r'\bafter\b': '之后',
  r'\bwin\b': '获胜',
  r'\bclose\b': '收盘',
  r'\byear end\b': '年底',
};
