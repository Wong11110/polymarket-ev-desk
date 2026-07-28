import 'dart:convert';

class Market {
  const Market({
    required this.id,
    required this.question,
    required this.category,
    required this.yesPrice,
    required this.noPrice,
    required this.volumeUsd,
    required this.liquidityUsd,
    required this.spread,
    required this.endDate,
    this.description,
  });

  final String id;
  final String question;
  final String category;
  final double yesPrice;
  final double noPrice;
  final double volumeUsd;
  final double liquidityUsd;
  final double spread;
  final DateTime endDate;
  final String? description;

  double get impliedYesProbability => yesPrice.clamp(0, 1).toDouble();
  double get impliedNoProbability => noPrice.clamp(0, 1).toDouble();
  bool get isBinaryArbCandidate => yesPrice + noPrice < 0.99;

  factory Market.fromGammaJson(Map<String, dynamic> json) {
    final markets = json['markets'];
    final firstMarket = markets is List && markets.isNotEmpty
        ? Map<String, dynamic>.from(markets.first as Map)
        : json;

    final outcomes = _decodeList(firstMarket['outcomes']);
    final prices = _decodeList(firstMarket['outcomePrices']);
    final yesIndex = outcomes.indexWhere(
      (value) => value.toString().toLowerCase() == 'yes',
    );
    final noIndex = outcomes.indexWhere(
      (value) => value.toString().toLowerCase() == 'no',
    );

    final yesPrice = _asDouble(
      yesIndex >= 0 && yesIndex < prices.length ? prices[yesIndex] : null,
      fallback: _asDouble(firstMarket['bestAsk'], fallback: 0.5),
    );
    final noPrice = _asDouble(
      noIndex >= 0 && noIndex < prices.length ? prices[noIndex] : null,
      fallback: (1 - yesPrice).clamp(0, 1).toDouble(),
    );

    return Market(
      id: '${firstMarket['id'] ?? json['id'] ?? json['slug']}',
      question: '${firstMarket['question'] ?? json['title'] ?? json['question'] ?? '未命名市场'}',
      category: '${firstMarket['category'] ?? json['category'] ?? _tagCategory(json) ?? '综合'}',
      yesPrice: yesPrice,
      noPrice: noPrice,
      volumeUsd: _asDouble(firstMarket['volume'] ?? json['volume']),
      liquidityUsd: _asDouble(firstMarket['liquidity'] ?? json['liquidity']),
      spread: _asDouble(
        firstMarket['spread'],
        fallback: (_asDouble(firstMarket['bestAsk'] ?? firstMarket['ask']) -
                _asDouble(firstMarket['bestBid'] ?? firstMarket['bid']))
            .abs(),
      ),
      endDate: DateTime.tryParse('${json['endDate'] ?? firstMarket['endDate'] ?? ''}') ??
          DateTime.now().add(const Duration(days: 30)),
      description: json['description']?.toString(),
    );
  }

  factory Market.fromGammaEventMarket({
    required Map<String, dynamic> event,
    required Map<String, dynamic> market,
  }) {
    final merged = <String, dynamic>{
      ...event,
      'markets': [market],
    };
    return Market.fromGammaJson(merged);
  }

  static List<dynamic> _decodeList(dynamic value) {
    if (value is List) return value;
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded;
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static String? _tagCategory(Map<String, dynamic> json) {
    final tags = json['tags'];
    if (tags is! List || tags.isEmpty) return null;
    for (final tag in tags) {
      if (tag is Map<String, dynamic>) return tag['label']?.toString();
    }
    return null;
  }
}
