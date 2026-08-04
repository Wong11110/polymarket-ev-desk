class OrderLevel {
  const OrderLevel({required this.price, required this.size});

  final double price;
  final double size;

  factory OrderLevel.fromJson(Map<String, dynamic> json) => OrderLevel(
        price: _number(json['price']),
        size: _number(json['size']),
      );

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class OrderBook {
  const OrderBook({
    required this.tokenId,
    required this.bids,
    required this.asks,
    required this.tickSize,
    required this.minOrderSize,
    required this.updatedAt,
  });

  final String tokenId;
  final List<OrderLevel> bids;
  final List<OrderLevel> asks;
  final double tickSize;
  final double minOrderSize;
  final DateTime updatedAt;

  double? get bestBid => bids.isEmpty ? null : bids.first.price;
  double? get bestAsk => asks.isEmpty ? null : asks.first.price;
  double? get spread =>
      bestBid == null || bestAsk == null ? null : bestAsk! - bestBid!;

  factory OrderBook.fromJson(Map<String, dynamic> json) {
    final bids = _levels(json['bids'])
      ..sort((a, b) => b.price.compareTo(a.price));
    final asks = _levels(json['asks'])
      ..sort((a, b) => a.price.compareTo(b.price));
    final rawTimestamp = json['timestamp'];
    final millis = rawTimestamp is num
        ? rawTimestamp.toInt()
        : int.tryParse('$rawTimestamp') ??
            DateTime.now().millisecondsSinceEpoch;
    return OrderBook(
      tokenId: '${json['asset_id'] ?? json['token_id'] ?? ''}',
      bids: bids,
      asks: asks,
      tickSize: _number(json['tick_size']),
      minOrderSize: _number(json['min_order_size']),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal(),
    );
  }

  ExecutionEstimate estimateBuy(double requestedUsd) {
    if (requestedUsd <= 0 || asks.isEmpty) {
      return ExecutionEstimate.empty(requestedUsd);
    }
    var remainingUsd = requestedUsd;
    var totalCost = 0.0;
    var shares = 0.0;
    var levelsUsed = 0;

    for (final level in asks) {
      if (remainingUsd <= 0 || level.price <= 0 || level.size <= 0) break;
      final affordableShares = remainingUsd / level.price;
      final takeShares =
          affordableShares < level.size ? affordableShares : level.size;
      final cost = takeShares * level.price;
      shares += takeShares;
      totalCost += cost;
      remainingUsd -= cost;
      levelsUsed += 1;
    }

    final filled = requestedUsd - remainingUsd;
    return ExecutionEstimate(
      requestedUsd: requestedUsd,
      filledUsd: filled,
      filledShares: shares,
      averagePrice: shares == 0 ? null : totalCost / shares,
      bestAsk: bestAsk,
      levelsUsed: levelsUsed,
      isFullyFillable: remainingUsd <= 0.0001,
    );
  }

  static List<OrderLevel> _levels(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => OrderLevel.fromJson(Map<String, dynamic>.from(item)))
        .where((level) => level.price > 0 && level.size > 0)
        .toList();
  }

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}

class ExecutionEstimate {
  const ExecutionEstimate({
    required this.requestedUsd,
    required this.filledUsd,
    required this.filledShares,
    required this.averagePrice,
    required this.bestAsk,
    required this.levelsUsed,
    required this.isFullyFillable,
  });

  final double requestedUsd;
  final double filledUsd;
  final double filledShares;
  final double? averagePrice;
  final double? bestAsk;
  final int levelsUsed;
  final bool isFullyFillable;

  double get priceImpact =>
      averagePrice == null || bestAsk == null ? 0 : averagePrice! - bestAsk!;
  double get fillRatio => requestedUsd == 0 ? 0 : filledUsd / requestedUsd;

  factory ExecutionEstimate.empty(double requestedUsd) => ExecutionEstimate(
        requestedUsd: requestedUsd,
        filledUsd: 0,
        filledShares: 0,
        averagePrice: null,
        bestAsk: null,
        levelsUsed: 0,
        isFullyFillable: false,
      );
}

class MarketOrderBooks {
  const MarketOrderBooks({this.yes, this.no});
  final OrderBook? yes;
  final OrderBook? no;
  OrderBook? forOutcome(bool yesOutcome) => yesOutcome ? yes : no;
}
