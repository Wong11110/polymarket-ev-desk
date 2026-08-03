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
  String get executionDisabled => pick('Execution disabled', '交易执行未启用');
  String get executionDisabledBody => pick(
        'This app is analysis-only and does not place real orders. A production execution path needs backend signing, manual confirmation, slippage limits, and order-state checks.',
        '当前版本只做行情分析和仓位建议，不会真实下单。正式交易还需要后端签名、人工确认、滑点保护和订单状态校验。',
      );
  String get tradePlaceholder => pick('Trade execution disabled', '交易执行未启用');

  String get dashboardTitle => pick('Polymarket EV Desk', 'Polymarket 机会雷达');
  String get evAlert => pick('EV Alert', 'EV 提醒线');
  String get topOpportunities => pick('Top Opportunities', '优先关注机会');
  String get refresh => pick('Refresh', '刷新行情');
  String get marketError => pick('Market load failed', '行情加载失败');
  String get opportunityError => pick('Opportunity analysis failed', '机会分析失败');
  String get volume => pick('Vol', '成交量');
  String get liquidity => pick('Liq', '流动性');
  String get originalTitle => pick('Original', '原始标题');

  String get analysisTitle => pick('EV Gap Analysis', 'EV Gap 分析');
  String get analysisDescription => pick(
        'Fair probability currently uses a local heuristic based on price, volume, liquidity, and spread. Replace it with your own research model or an AI-backed backend when ready.',
        '公允概率目前由本地启发式模型估算，综合了价格、成交量、流动性和价差。后续可替换为自己的研究模型或后端 AI 服务。',
      );
  String get noFilteredOpportunities => pick(
        'No opportunities pass your EV and liquidity filters.',
        '当前没有通过 EV 与流动性筛选的机会。',
      );
  String get analysisError => pick('Analysis failed', '分析失败');

  String get smartMoneyTitle => pick('Smart Money Tracking', '聪明钱跟踪');
  String get smartMoneyDescription => pick(
        'This module currently uses demonstrative wallet activity. It is structured so a wallet indexer, CLOB trades, or on-chain data source can replace the mock feed.',
        '当前模块先展示模拟钱包活动；数据层已预留，可替换为钱包索引、CLOB 成交或链上数据源。',
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
  String get apiKeyPlaceholder =>
      pick('OpenAI API Key (optional)', 'OpenAI API Key（预留）');
  String get apiKeyHelper => pick(
        'Do not put production AI or trading secrets in the frontend. Use a backend proxy for sensitive operations.',
        '不要把生产环境的 AI 或交易密钥放在前端。涉及敏感操作时请通过后端代理。',
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
        'Adjust fair probability to check whether an idea remains viable under your risk settings.',
        '可以调整公允概率，检查机会在当前风控参数下是否仍然成立。',
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
          RegExp(entry.key, caseSensitive: false), entry.value);
    }
    return result;
  }
}

const _marketQuestionZh = <String, String>{
  'will the fed cut rates at the next fomc meeting?': '美联储会在下一次 FOMC 会议降息吗？',
  'will btc close above \$100k before year end?': 'BTC 会在年底前收于 10 万美元上方吗？',
  'will candidate a win the national election?': '候选人 A 会赢得全国大选吗？',
  'will a frontier ai lab release a new flagship model in q3?':
      '前沿 AI 实验室会在第三季度发布新旗舰模型吗？',
  'will team usa win the 2026 world cup?': '美国队会赢得 2026 年世界杯吗？',
};

const _categoryZh = <String, String>{
  'macro': '宏观',
  'crypto': '加密',
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
