import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_text.dart';
import '../state/app_providers.dart';
import '../widgets/market_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/opportunity_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketsAsync = ref.watch(marketsProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
    final filteredOpportunities = ref.watch(filteredOpportunitiesProvider);
    final settings = ref.watch(settingsControllerProvider);
    final watchlist = ref.watch(watchlistProvider).valueOrNull ?? const <String>{};
    final languageCode = settings.valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final zh = languageCode == 'zh';
    final markets = marketsAsync.valueOrNull ?? const [];
    final topMarkets = filteredOpportunities.map((item) => item.market).toList();
    final updatedAt = DateFormat('HH:mm:ss').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(marketsProvider);
        ref.invalidate(opportunitiesProvider);
        await ref.read(marketsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.dashboardTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      zh
                          ? '热门预测市场、EV Gap、流动性和仓位建议'
                          : 'Markets, EV gaps, liquidity, and Kelly sizing',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: text.refresh,
                onPressed: () {
                  ref.invalidate(marketsProvider);
                  ref.invalidate(opportunitiesProvider);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DataBanner(
            isLoading: marketsAsync.isLoading || opportunitiesAsync.isLoading,
            updatedAt: updatedAt,
            zh: zh,
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.sizeOf(context).width > 720 ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.95,
            children: [
              MetricTile(
                label: zh ? '市场数' : 'Markets',
                value: '${markets.length}',
              ),
              MetricTile(
                label: zh ? '机会数' : 'Signals',
                value: '${filteredOpportunities.length}',
              ),
              MetricTile(
                label: zh ? '关注' : 'Watchlist',
                value: '${watchlist.length}',
              ),
              settings.when(
                data: (value) => MetricTile(
                  label: text.evAlert,
                  value: '${(value.evAlertThreshold * 100).toStringAsFixed(1)}%',
                ),
                loading: () => const MetricTile(label: 'EV', value: '...'),
                error: (_, __) => const MetricTile(label: 'EV', value: '--'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FilterPanel(zh: zh),
          const SizedBox(height: 18),
          Text(
            text.topOpportunities,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          opportunitiesAsync.when(
            data: (_) => filteredOpportunities.isEmpty
                ? _EmptyState(
                    title: zh ? '暂无满足条件的机会' : 'No matching signals',
                    body: zh
                        ? '可以降低 EV 阈值、切换分类，或关闭“只看关注”。'
                        : 'Try lowering the EV threshold, changing category, or disabling watchlist-only.',
                  )
                : Column(
                    children: filteredOpportunities
                        .take(6)
                        .map((item) => OpportunityCard(opportunity: item))
                        .toList(),
                  ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Text('${text.opportunityError}: $error'),
          ),
          const SizedBox(height: 14),
          Text(
            zh ? '市场雷达' : 'Market Radar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          marketsAsync.when(
            data: (_) {
              final marketIds = <String>{};
              final uniqueMarkets = [
                for (final market in topMarkets)
                  if (marketIds.add(market.id)) market,
              ];
              if (uniqueMarkets.isEmpty) {
                return _EmptyState(
                  title: zh ? '筛选后没有市场' : 'No markets after filters',
                  body: zh ? '请调整搜索关键词或分类。' : 'Adjust search or category.',
                );
              }
              return Column(
                children: uniqueMarkets
                    .take(12)
                    .map((market) => MarketCard(market: market))
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('${text.marketError}: $error'),
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  const _FilterPanel({required this.zh});

  final bool zh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(marketFilterProvider);
    final categories = ref.watch(marketCategoriesProvider);
    final controller = ref.read(marketFilterProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: zh ? '搜索市场、主题或关键词' : 'Search markets, topics, keywords',
                isDense: true,
              ),
              onChanged: controller.setQuery,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: categories.contains(filter.category)
                        ? filter.category
                        : 'All',
                    decoration: InputDecoration(
                      labelText: zh ? '分类' : 'Category',
                      isDense: true,
                    ),
                    items: [
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category == 'All'
                              ? (zh ? '全部' : 'All')
                              : category),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setCategory(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<MarketSortMode>(
                    initialValue: filter.sortMode,
                    decoration: InputDecoration(
                      labelText: zh ? '排序' : 'Sort',
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: MarketSortMode.evGap,
                        child: Text(zh ? 'EV Gap' : 'EV Gap'),
                      ),
                      DropdownMenuItem(
                        value: MarketSortMode.volume,
                        child: Text(zh ? '成交量' : 'Volume'),
                      ),
                      DropdownMenuItem(
                        value: MarketSortMode.liquidity,
                        child: Text(zh ? '流动性' : 'Liquidity'),
                      ),
                      DropdownMenuItem(
                        value: MarketSortMode.spread,
                        child: Text(zh ? '低价差' : 'Tight spread'),
                      ),
                      DropdownMenuItem(
                        value: MarketSortMode.endingSoon,
                        child: Text(zh ? '临近结束' : 'Ending soon'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.setSortMode(value);
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: filter.watchlistOnly,
              onChanged: controller.setWatchlistOnly,
              title: Text(zh ? '只看我的关注' : 'Watchlist only'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataBanner extends StatelessWidget {
  const _DataBanner({
    required this.isLoading,
    required this.updatedAt,
    required this.zh,
  });

  final bool isLoading;
  final String updatedAt;
  final bool zh;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(isLoading ? Icons.sync : Icons.cloud_done_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                zh
                    ? 'Gamma API 准实时轮询；EV、流动性和仓位在本地重算。更新时间 $updatedAt'
                    : 'Gamma API polling; EV, liquidity and sizing are recalculated locally. Updated $updatedAt',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      ),
    );
  }
}
