class SmartMoneySignal {
  const SmartMoneySignal({
    required this.walletLabel,
    required this.marketQuestion,
    required this.side,
    required this.amountUsd,
    required this.winRate,
    required this.timestamp,
    required this.note,
  });

  final String walletLabel;
  final String marketQuestion;
  final String side;
  final double amountUsd;
  final double winRate;
  final DateTime timestamp;
  final String note;
}
