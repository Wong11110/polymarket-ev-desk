import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/market.dart';
import '../models/smart_money_signal.dart';

class PolymarketRepository {
  PolymarketRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Market>> fetchPopularMarkets() async {
    final uri = _popularMarketsUri();

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return mockMarkets;
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return mockMarkets;

      final markets = decoded.whereType<Map<String, dynamic>>().expand((event) {
        final nestedMarkets = event['markets'];
        if (nestedMarkets is List && nestedMarkets.isNotEmpty) {
          return nestedMarkets.whereType<Map<String, dynamic>>().map((market) =>
              Market.fromGammaEventMarket(event: event, market: market));
        }
        return [Market.fromGammaJson(event)];
      }).where((market) {
        return market.yesPrice > 0 &&
            market.noPrice > 0 &&
            market.yesPrice < 1 &&
            market.noPrice < 1 &&
            market.liquidityUsd > 0;
      }).toList();

      return markets.isEmpty ? mockMarkets : markets;
    } catch (_) {
      return mockMarkets;
    }
  }

  Uri _popularMarketsUri() {
    const query =
        'active=true&closed=false&limit=50&order=volume&ascending=false';
    if (kIsWeb) {
      return Uri.parse('/api/polymarket/events?$query');
    }
    return Uri.parse('https://gamma-api.polymarket.com/events?$query');
  }

  Future<List<SmartMoneySignal>> fetchSmartMoneySignals() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return mockSmartMoneySignals;
  }

  static final mockMarkets = <Market>[
    Market(
      id: 'mvp-fed-cut',
      question: 'Will the Fed cut rates at the next FOMC meeting?',
      category: 'Macro',
      yesPrice: 0.42,
      noPrice: 0.59,
      volumeUsd: 2850000,
      liquidityUsd: 185000,
      spread: 0.018,
      endDate: DateTime(2026, 9, 18),
      description: 'Mock binary rates market.',
    ),
    Market(
      id: 'mvp-btc-100k',
      question: 'Will BTC close above \$100k before year end?',
      category: 'Crypto',
      yesPrice: 0.31,
      noPrice: 0.71,
      volumeUsd: 1280000,
      liquidityUsd: 72000,
      spread: 0.026,
      endDate: DateTime(2026, 12, 31),
    ),
    Market(
      id: 'mvp-election',
      question: 'Will Candidate A win the national election?',
      category: 'Politics',
      yesPrice: 0.53,
      noPrice: 0.50,
      volumeUsd: 9200000,
      liquidityUsd: 310000,
      spread: 0.014,
      endDate: DateTime(2026, 11, 4),
    ),
    Market(
      id: 'mvp-ai-release',
      question: 'Will a frontier AI lab release a new flagship model in Q3?',
      category: 'Technology',
      yesPrice: 0.47,
      noPrice: 0.55,
      volumeUsd: 640000,
      liquidityUsd: 42000,
      spread: 0.031,
      endDate: DateTime(2026, 9, 30),
    ),
    Market(
      id: 'mvp-world-cup',
      question: 'Will Team USA win the 2026 World Cup?',
      category: 'Sports',
      yesPrice: 0.12,
      noPrice: 0.89,
      volumeUsd: 3900000,
      liquidityUsd: 260000,
      spread: 0.011,
      endDate: DateTime(2026, 7, 19),
      slug: 'will-team-usa-win-the-2026-world-cup',
    ),
    Market(
      id: 'mvp-eth-etf',
      question: 'Will ETH close above \$8,000 before 2027?',
      category: 'Crypto',
      yesPrice: 0.27,
      noPrice: 0.75,
      volumeUsd: 2100000,
      liquidityUsd: 135000,
      spread: 0.019,
      endDate: DateTime(2026, 12, 31),
      slug: 'will-eth-close-above-8000-before-2027',
    ),
    Market(
      id: 'mvp-ai-agent',
      question: 'Will an AI agent complete a Fortune 500 workflow autonomously in 2026?',
      category: 'Technology',
      yesPrice: 0.36,
      noPrice: 0.66,
      volumeUsd: 870000,
      liquidityUsd: 64000,
      spread: 0.024,
      endDate: DateTime(2026, 12, 31),
      slug: 'will-an-ai-agent-complete-a-fortune-500-workflow-autonomously-in-2026',
    ),
  ];

  static final mockSmartMoneySignals = <SmartMoneySignal>[
    SmartMoneySignal(
      walletLabel: 'AlphaDesk 07',
      marketQuestion: 'Will the Fed cut rates at the next FOMC meeting?',
      side: 'YES',
      amountUsd: 42000,
      winRate: 0.64,
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      note: 'Accumulated through several limit orders near 0.40-0.42.',
    ),
    SmartMoneySignal(
      walletLabel: 'Macro Whale',
      marketQuestion: 'Will Candidate A win the national election?',
      side: 'NO',
      amountUsd: 115000,
      winRate: 0.58,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      note: 'Large hedge after poll-driven price move.',
    ),
    SmartMoneySignal(
      walletLabel: 'Crypto EV Bot',
      marketQuestion: 'Will BTC close above \$100k before year end?',
      side: 'YES',
      amountUsd: 18500,
      winRate: 0.61,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      note: 'Momentum wallet added exposure after spot breakout.',
    ),
  ];
}
