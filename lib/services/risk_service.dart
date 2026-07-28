import 'dart:math';

import '../models/risk_settings.dart';

class PositionRecommendation {
  const PositionRecommendation({
    required this.rawKelly,
    required this.fractionalKelly,
    required this.cappedStakeUsd,
    required this.maxStakeUsd,
    required this.warning,
  });

  final double rawKelly;
  final double fractionalKelly;
  final double cappedStakeUsd;
  final double maxStakeUsd;
  final String warning;
}

class RiskService {
  const RiskService();

  PositionRecommendation recommendStake({
    required double price,
    required double fairProbability,
    required RiskSettings settings,
    double correlationPenalty = 0,
  }) {
    final zh = settings.languageCode == 'zh';
    if (price <= 0 || price >= 1 || fairProbability <= price) {
      return PositionRecommendation(
        rawKelly: 0,
        fractionalKelly: 0,
        cappedStakeUsd: 0,
        maxStakeUsd: settings.bankrollUsd * settings.maxPositionPct,
        warning: zh
            ? '价格和概率校验后没有正向优势。'
            : 'No positive edge after price and probability checks.',
      );
    }

    final b = (1 / price) - 1;
    final q = 1 - fairProbability;
    final rawKelly = ((b * fairProbability) - q) / b;
    final adjustedKelly =
        max(0.0, rawKelly * settings.kellyFraction * (1 - correlationPenalty));
    final maxStake = settings.bankrollUsd * settings.maxPositionPct;
    final dailyLossCap = settings.bankrollUsd * settings.dailyLossLimitPct;
    final stake = min(settings.bankrollUsd * adjustedKelly, min(maxStake, dailyLossCap));

    final warning = correlationPenalty > 0.2
        ? zh
            ? '已加入相关性惩罚，相似主题市场需要降低总敞口。'
            : 'Correlation penalty applied. Reduce exposure across similar markets.'
        : stake >= maxStake
            ? zh
                ? '仓位已被单市场风险上限截断。'
                : 'Position capped by max single-market risk.'
            : zh
                ? '仓位在当前风控参数范围内。'
                : 'Within configured risk limits.';

    return PositionRecommendation(
      rawKelly: rawKelly.clamp(0, 1).toDouble(),
      fractionalKelly: adjustedKelly.clamp(0, 1).toDouble(),
      cappedStakeUsd: stake,
      maxStakeUsd: maxStake,
      warning: warning,
    );
  }
}
