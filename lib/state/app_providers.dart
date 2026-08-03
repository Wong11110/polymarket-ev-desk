import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/market.dart';
import '../models/opportunity.dart';
import '../models/risk_settings.dart';
import '../models/smart_money_signal.dart';
import '../repositories/polymarket_repository.dart';
import '../services/ai_analysis_service.dart';
import '../services/notification_service.dart';

final polymarketRepositoryProvider = Provider<PolymarketRepository>((ref) {
  return PolymarketRepository();
});

final aiAnalysisServiceProvider = Provider<AiAnalysisService>((ref) {
  return AiAnalysisService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

enum MarketSortMode { evGap, volume, liquidity, spread, endingSoon }

class MarketFilterState {
  const MarketFilterState({
    this.query = '',
    this.category = 'All',
    this.sortMode = MarketSortMode.evGap,
    this.watchlistOnly = false,
  });

  final String query;
  final String category;
  final MarketSortMode sortMode;
  final bool watchlistOnly;

  MarketFilterState copyWith({
    String? query,
    String? category,
    MarketSortMode? sortMode,
    bool? watchlistOnly,
  }) {
    return MarketFilterState(
      query: query ?? this.query,
      category: category ?? this.category,
      sortMode: sortMode ?? this.sortMode,
      watchlistOnly: watchlistOnly ?? this.watchlistOnly,
    );
  }
}

final marketFilterProvider =
    NotifierProvider<MarketFilterController, MarketFilterState>(
  MarketFilterController.new,
);

class MarketFilterController extends Notifier<MarketFilterState> {
  @override
  MarketFilterState build() => const MarketFilterState();

  void setQuery(String value) => state = state.copyWith(query: value);
  void setCategory(String value) => state = state.copyWith(category: value);
  void setSortMode(MarketSortMode value) =>
      state = state.copyWith(sortMode: value);
  void setWatchlistOnly(bool value) =>
      state = state.copyWith(watchlistOnly: value);
}

final watchlistProvider =
    AsyncNotifierProvider<WatchlistController, Set<String>>(
  WatchlistController.new,
);

class WatchlistController extends AsyncNotifier<Set<String>> {
  static const _key = 'watchlistMarketIds';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<void> toggle(String marketId) async {
    final current = {...(state.valueOrNull ?? const <String>{})};
    if (current.contains(marketId)) {
      current.remove(marketId);
    } else {
      current.add(marketId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, current.toList()..sort());
    state = AsyncData(current);
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, RiskSettings>(
        SettingsController.new);

class SettingsController extends AsyncNotifier<RiskSettings> {
  static const _bankroll = 'bankrollUsd';
  static const _maxPosition = 'maxPositionPct';
  static const _dailyLoss = 'dailyLossLimitPct';
  static const _kelly = 'kellyFraction';
  static const _evThreshold = 'evAlertThreshold';
  static const _minLiquidity = 'minLiquidityUsd';
  static const _apiKey = 'openAiApiKey';
  static const _darkMode = 'darkMode';
  static const _languageCode = 'languageCode';
  static const _secureStorage = FlutterSecureStorage();

  @override
  Future<RiskSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final storedApiKey = await _readApiKey();
    return RiskSettings(
      bankrollUsd:
          prefs.getDouble(_bankroll) ?? RiskSettings.defaults.bankrollUsd,
      maxPositionPct:
          prefs.getDouble(_maxPosition) ?? RiskSettings.defaults.maxPositionPct,
      dailyLossLimitPct: prefs.getDouble(_dailyLoss) ??
          RiskSettings.defaults.dailyLossLimitPct,
      kellyFraction:
          prefs.getDouble(_kelly) ?? RiskSettings.defaults.kellyFraction,
      evAlertThreshold: prefs.getDouble(_evThreshold) ??
          RiskSettings.defaults.evAlertThreshold,
      minLiquidityUsd: prefs.getDouble(_minLiquidity) ??
          RiskSettings.defaults.minLiquidityUsd,
      openAiApiKey: storedApiKey,
      darkMode: prefs.getBool(_darkMode) ?? RiskSettings.defaults.darkMode,
      languageCode:
          prefs.getString(_languageCode) ?? RiskSettings.defaults.languageCode,
    );
  }

  Future<void> saveSettings(RiskSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bankroll, settings.bankrollUsd);
    await prefs.setDouble(_maxPosition, settings.maxPositionPct);
    await prefs.setDouble(_dailyLoss, settings.dailyLossLimitPct);
    await prefs.setDouble(_kelly, settings.kellyFraction);
    await prefs.setDouble(_evThreshold, settings.evAlertThreshold);
    await prefs.setDouble(_minLiquidity, settings.minLiquidityUsd);
    await _writeApiKey(settings.openAiApiKey);
    await prefs.setBool(_darkMode, settings.darkMode);
    await prefs.setString(_languageCode, settings.languageCode);
    state = AsyncData(settings);
  }

  Future<String> _readApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKey) ??
          RiskSettings.defaults.openAiApiKey;
    } catch (_) {
      return RiskSettings.defaults.openAiApiKey;
    }
  }

  Future<void> _writeApiKey(String value) async {
    try {
      if (value.isEmpty) {
        await _secureStorage.delete(key: _apiKey);
      } else {
        await _secureStorage.write(key: _apiKey, value: value);
      }
    } catch (_) {
      // Web preview over plain HTTP may not support secure storage.
    }
  }
}

final marketsProvider = StreamProvider.autoDispose<List<Market>>((ref) async* {
  final repository = ref.watch(polymarketRepositoryProvider);
  while (true) {
    yield await repository.fetchPopularMarkets();
    await Future<void>.delayed(const Duration(seconds: 60));
  }
});

final marketCategoriesProvider = Provider<List<String>>((ref) {
  final markets = ref.watch(marketsProvider).valueOrNull ?? const <Market>[];
  return [
    'All',
    ...{for (final market in markets) market.category}
  ];
});

final filteredMarketsProvider = Provider<List<Market>>((ref) {
  final markets = ref.watch(marketsProvider).valueOrNull ?? const <Market>[];
  final filter = ref.watch(marketFilterProvider);
  final watchlist =
      ref.watch(watchlistProvider).valueOrNull ?? const <String>{};
  final query = filter.query.trim().toLowerCase();
  final filtered = markets.where((market) {
    if (filter.watchlistOnly && !watchlist.contains(market.id)) {
      return false;
    }
    if (filter.category != 'All' && market.category != filter.category) {
      return false;
    }
    if (query.isEmpty) {
      return true;
    }
    return market.question.toLowerCase().contains(query) ||
        market.category.toLowerCase().contains(query);
  }).toList();

  filtered.sort((a, b) {
    return switch (filter.sortMode) {
      MarketSortMode.evGap => b.volumeUsd.compareTo(a.volumeUsd),
      MarketSortMode.volume => b.volumeUsd.compareTo(a.volumeUsd),
      MarketSortMode.liquidity => b.liquidityUsd.compareTo(a.liquidityUsd),
      MarketSortMode.spread => a.spread.compareTo(b.spread),
      MarketSortMode.endingSoon => a.endDate.compareTo(b.endDate),
    };
  });
  return filtered;
});

final marketPriceHistoryProvider =
    FutureProvider.autoDispose.family<List<PricePoint>, Market>((ref, market) {
  return ref.watch(polymarketRepositoryProvider).fetchPriceHistory(market);
});

final smartMoneyProvider = FutureProvider<List<SmartMoneySignal>>((ref) async {
  final repository = ref.watch(polymarketRepositoryProvider);
  return repository.fetchSmartMoneySignals();
});

final opportunitiesProvider = FutureProvider<List<Opportunity>>((ref) async {
  final markets = ref.watch(marketsProvider).valueOrNull ?? const <Market>[];
  final settings = await ref.watch(settingsControllerProvider.future);
  final service = ref.watch(aiAnalysisServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final opportunities =
      service.analyzeMarkets(markets: markets, settings: settings);

  for (final opportunity in opportunities.take(3)) {
    await notificationService.notifyForOpportunity(opportunity, settings);
  }

  return opportunities;
});

final filteredOpportunitiesProvider = Provider<List<Opportunity>>((ref) {
  final opportunities =
      ref.watch(opportunitiesProvider).valueOrNull ?? const <Opportunity>[];
  final filter = ref.watch(marketFilterProvider);
  final watchlist =
      ref.watch(watchlistProvider).valueOrNull ?? const <String>{};
  final query = filter.query.trim().toLowerCase();

  final filtered = opportunities.where((item) {
    final market = item.market;
    if (filter.watchlistOnly && !watchlist.contains(market.id)) {
      return false;
    }
    if (filter.category != 'All' && market.category != filter.category) {
      return false;
    }
    if (query.isEmpty) return true;
    return market.question.toLowerCase().contains(query) ||
        market.category.toLowerCase().contains(query);
  }).toList();

  filtered.sort((a, b) {
    return switch (filter.sortMode) {
      MarketSortMode.evGap => b.evGap.compareTo(a.evGap),
      MarketSortMode.volume => b.market.volumeUsd.compareTo(a.market.volumeUsd),
      MarketSortMode.liquidity =>
        b.market.liquidityUsd.compareTo(a.market.liquidityUsd),
      MarketSortMode.spread => a.market.spread.compareTo(b.market.spread),
      MarketSortMode.endingSoon => a.market.endDate.compareTo(b.market.endDate),
    };
  });
  return filtered;
});
