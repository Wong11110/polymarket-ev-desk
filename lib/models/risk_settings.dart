class RiskSettings {
  const RiskSettings({
    required this.bankrollUsd,
    required this.maxPositionPct,
    required this.dailyLossLimitPct,
    required this.kellyFraction,
    required this.evAlertThreshold,
    required this.minLiquidityUsd,
    required this.openAiApiKey,
    required this.darkMode,
    required this.languageCode,
  });

  final double bankrollUsd;
  final double maxPositionPct;
  final double dailyLossLimitPct;
  final double kellyFraction;
  final double evAlertThreshold;
  final double minLiquidityUsd;
  final String openAiApiKey;
  final bool darkMode;
  final String languageCode;

  static const defaults = RiskSettings(
    bankrollUsd: 1000,
    maxPositionPct: 0.05,
    dailyLossLimitPct: 0.08,
    kellyFraction: 0.25,
    evAlertThreshold: 0.04,
    minLiquidityUsd: 2500,
    openAiApiKey: '',
    darkMode: true,
    languageCode: 'en',
  );

  RiskSettings copyWith({
    double? bankrollUsd,
    double? maxPositionPct,
    double? dailyLossLimitPct,
    double? kellyFraction,
    double? evAlertThreshold,
    double? minLiquidityUsd,
    String? openAiApiKey,
    bool? darkMode,
    String? languageCode,
  }) {
    return RiskSettings(
      bankrollUsd: bankrollUsd ?? this.bankrollUsd,
      maxPositionPct: maxPositionPct ?? this.maxPositionPct,
      dailyLossLimitPct: dailyLossLimitPct ?? this.dailyLossLimitPct,
      kellyFraction: kellyFraction ?? this.kellyFraction,
      evAlertThreshold: evAlertThreshold ?? this.evAlertThreshold,
      minLiquidityUsd: minLiquidityUsd ?? this.minLiquidityUsd,
      openAiApiKey: openAiApiKey ?? this.openAiApiKey,
      darkMode: darkMode ?? this.darkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
