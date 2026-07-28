import 'market.dart';

enum TradeSide { yes, no }

enum RiskLevel { low, medium, high }

class Opportunity {
  const Opportunity({
    required this.market,
    required this.side,
    required this.fairProbability,
    required this.impliedProbability,
    required this.evGap,
    required this.confidence,
    required this.riskLevel,
    required this.reason,
    required this.suggestedStakeUsd,
    required this.kellyFraction,
  });

  final Market market;
  final TradeSide side;
  final double fairProbability;
  final double impliedProbability;
  final double evGap;
  final double confidence;
  final RiskLevel riskLevel;
  final String reason;
  final double suggestedStakeUsd;
  final double kellyFraction;

  double get price => side == TradeSide.yes ? market.yesPrice : market.noPrice;
  double get expectedRoi => price <= 0 ? 0 : evGap / price;
}
