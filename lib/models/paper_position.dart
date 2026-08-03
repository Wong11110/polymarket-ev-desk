import 'market.dart';

enum PaperSide { yes, no }

class PaperPosition {
  const PaperPosition({
    required this.id,
    required this.marketId,
    required this.question,
    required this.side,
    required this.entryPrice,
    required this.stakeUsd,
    required this.shares,
    required this.openedAt,
    this.closedAt,
    this.closePrice,
  });

  final String id;
  final String marketId;
  final String question;
  final PaperSide side;
  final double entryPrice;
  final double stakeUsd;
  final double shares;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double? closePrice;

  bool get isOpen => closedAt == null;

  double markPriceFor(Market? market) {
    if (!isOpen) return closePrice ?? entryPrice;
    if (market == null) return entryPrice;
    return side == PaperSide.yes ? market.yesPrice : market.noPrice;
  }

  double pnlFor(Market? market) => (markPriceFor(market) - entryPrice) * shares;

  PaperPosition close(double price) => PaperPosition(
        id: id,
        marketId: marketId,
        question: question,
        side: side,
        entryPrice: entryPrice,
        stakeUsd: stakeUsd,
        shares: shares,
        openedAt: openedAt,
        closedAt: DateTime.now(),
        closePrice: price,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'marketId': marketId,
        'question': question,
        'side': side.name,
        'entryPrice': entryPrice,
        'stakeUsd': stakeUsd,
        'shares': shares,
        'openedAt': openedAt.toIso8601String(),
        'closedAt': closedAt?.toIso8601String(),
        'closePrice': closePrice,
      };

  factory PaperPosition.fromJson(Map<String, dynamic> json) => PaperPosition(
        id: '${json['id']}',
        marketId: '${json['marketId']}',
        question: '${json['question']}',
        side: json['side'] == PaperSide.no.name ? PaperSide.no : PaperSide.yes,
        entryPrice: _number(json['entryPrice']),
        stakeUsd: _number(json['stakeUsd']),
        shares: _number(json['shares']),
        openedAt: DateTime.tryParse('${json['openedAt']}') ?? DateTime.now(),
        closedAt: json['closedAt'] == null
            ? null
            : DateTime.tryParse('${json['closedAt']}'),
        closePrice:
            json['closePrice'] == null ? null : _number(json['closePrice']),
      );

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class PaperPortfolioSummary {
  const PaperPortfolioSummary({
    required this.startingBalance,
    required this.availableCash,
    required this.openValue,
    required this.equity,
    required this.totalPnl,
    required this.openPositions,
  });

  final double startingBalance;
  final double availableCash;
  final double openValue;
  final double equity;
  final double totalPnl;
  final int openPositions;

  factory PaperPortfolioSummary.calculate({
    required Iterable<PaperPosition> positions,
    required Map<String, Market> markets,
    required double startingBalance,
  }) {
    var availableCash = startingBalance;
    var openValue = 0.0;
    var openPositions = 0;
    for (final position in positions) {
      availableCash -= position.stakeUsd;
      if (position.isOpen) {
        openValue +=
            position.shares * position.markPriceFor(markets[position.marketId]);
        openPositions += 1;
      } else {
        availableCash += position.shares * position.markPriceFor(null);
      }
    }
    final equity = availableCash + openValue;
    return PaperPortfolioSummary(
      startingBalance: startingBalance,
      availableCash: availableCash,
      openValue: openValue,
      equity: equity,
      totalPnl: equity - startingBalance,
      openPositions: openPositions,
    );
  }
}
