import '../models/market.dart';
import '../models/opportunity.dart';
import '../models/risk_settings.dart';
import 'risk_service.dart';

class AiAnalysisService {
  AiAnalysisService({RiskService riskService = const RiskService()})
      : _riskService = riskService;

  final RiskService _riskService;

  List<Opportunity> analyzeMarkets({
    required List<Market> markets,
    required RiskSettings settings,
    Map<String, double> fairProbabilities = const {},
  }) {
    final opportunities = <Opportunity>[];

    for (final market in markets) {
      final fairYes =
          fairProbabilities[market.id] ?? estimateFairProbability(market);
      final fairNo = 1 - fairYes;

      opportunities.addAll([
        _buildOpportunity(
          market: market,
          side: TradeSide.yes,
          fairProbability: fairYes,
          impliedProbability: market.impliedYesProbability,
          settings: settings,
        ),
        _buildOpportunity(
          market: market,
          side: TradeSide.no,
          fairProbability: fairNo,
          impliedProbability: market.impliedNoProbability,
          settings: settings,
        ),
      ]);
    }

    return opportunities
        .where((item) =>
            item.evGap >= settings.evAlertThreshold &&
            item.market.liquidityUsd >= settings.minLiquidityUsd)
        .toList()
      ..sort((a, b) {
        final byEv = b.evGap.compareTo(a.evGap);
        return byEv != 0
            ? byEv
            : b.market.liquidityUsd.compareTo(a.market.liquidityUsd);
      });
  }

  double estimateFairProbability(Market market) {
    final liquiditySignal =
        (market.liquidityUsd / 100000).clamp(0, 0.08).toDouble();
    final volumeSignal = (market.volumeUsd / 1000000).clamp(0, 0.05).toDouble();
    final spreadPenalty = market.spread.clamp(0, 0.08).toDouble();
    final base = market.impliedYesProbability;
    return (base + liquiditySignal + volumeSignal - spreadPenalty)
        .clamp(0.03, 0.97)
        .toDouble();
  }

  Opportunity evaluateOpportunity({
    required Market market,
    required TradeSide side,
    required double fairProbability,
    required RiskSettings settings,
  }) {
    return _buildOpportunity(
      market: market,
      side: side,
      fairProbability: fairProbability,
      impliedProbability: side == TradeSide.yes
          ? market.impliedYesProbability
          : market.impliedNoProbability,
      settings: settings,
    );
  }

  Opportunity _buildOpportunity({
    required Market market,
    required TradeSide side,
    required double fairProbability,
    required double impliedProbability,
    required RiskSettings settings,
  }) {
    final price = side == TradeSide.yes ? market.yesPrice : market.noPrice;
    final evGap = fairProbability - impliedProbability;
    final correlationPenalty =
        market.category.toLowerCase().contains('politic') ? 0.15 : 0.05;
    final position = _riskService.recommendStake(
      price: price,
      fairProbability: fairProbability,
      settings: settings,
      correlationPenalty: correlationPenalty,
    );

    return Opportunity(
      market: market,
      side: side,
      fairProbability: fairProbability,
      impliedProbability: impliedProbability,
      evGap: evGap,
      confidence: _confidenceFor(market, evGap),
      riskLevel: _riskFor(market, evGap),
      reason: explain(
        market: market,
        side: side,
        evGap: evGap,
        position: position,
        languageCode: settings.languageCode,
      ),
      suggestedStakeUsd: position.cappedStakeUsd,
      kellyFraction: position.fractionalKelly,
    );
  }

  String explain({
    required Market market,
    required TradeSide side,
    required double evGap,
    required PositionRecommendation position,
    required String languageCode,
  }) {
    final sideText = side == TradeSide.yes ? 'YES' : 'NO';
    final zh = languageCode == 'zh';
    final liquidityNote = market.liquidityUsd >= 10000
        ? zh
            ? '当前流动性足够支撑 MVP 级别仓位估算'
            : 'liquidity is acceptable for MVP sizing'
        : zh
            ? '当前流动性偏薄，真实交易只能使用限价单'
            : 'liquidity is thin; use limit orders only';

    if (zh) {
      return '买入 $sideText 的 EV Gap 为 ${(evGap * 100).toStringAsFixed(1)}%；'
          '$liquidityNote。${position.warning}';
    }
    return '$sideText shows a ${(evGap * 100).toStringAsFixed(1)}% EV gap; '
        '$liquidityNote. ${position.warning}';
  }

  double _confidenceFor(Market market, double evGap) {
    final liquidityScore =
        (market.liquidityUsd / 50000).clamp(0, 0.35).toDouble();
    final evScore = (evGap / 0.15).clamp(0, 0.45).toDouble();
    final spreadScore = (0.2 - market.spread).clamp(0, 0.2).toDouble();
    return (liquidityScore + evScore + spreadScore)
        .clamp(0.05, 0.95)
        .toDouble();
  }

  RiskLevel _riskFor(Market market, double evGap) {
    if (market.liquidityUsd < 5000 || market.spread > 0.08) {
      return RiskLevel.high;
    }
    if (evGap > 0.08 && market.liquidityUsd > 25000) return RiskLevel.low;
    return RiskLevel.medium;
  }
}
