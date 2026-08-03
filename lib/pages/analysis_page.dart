import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_text.dart';
import '../state/app_providers.dart';
import '../widgets/opportunity_card.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunities = ref.watch(opportunitiesProvider);
    final filtered = ref.watch(filteredOpportunitiesProvider);
    final filter = ref.watch(marketFilterProvider);
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final zh = languageCode == 'zh';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(text.analysisTitle,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              tooltip: text.refresh,
              onPressed: () async {
                ref.invalidate(marketsProvider);
                ref.invalidate(opportunitiesProvider);
                await ref.read(marketsProvider.future);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          zh
              ? '按 EV Gap、流动性、价差与临近结束时间筛选。真实执行前仍需要检查订单簿深度、费用和成交概率。'
              : text.analysisDescription,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                  label: Text(zh
                      ? '结果 ${filtered.length}'
                      : '${filtered.length} results'),
                ),
                FilterChip(
                  selected: filter.watchlistOnly,
                  onSelected:
                      ref.read(marketFilterProvider.notifier).setWatchlistOnly,
                  label: Text(zh ? '只看关注' : 'Watchlist'),
                ),
                for (final sort in MarketSortMode.values)
                  ChoiceChip(
                    selected: filter.sortMode == sort,
                    onSelected: (_) => ref
                        .read(marketFilterProvider.notifier)
                        .setSortMode(sort),
                    label: Text(_sortLabel(sort, zh)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        opportunities.when(
          data: (_) => filtered.isEmpty
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(zh
                        ? '当前没有符合条件的机会。可在设置页下调 EV 阈值或最低流动性。'
                        : text.noFilteredOpportunities),
                  ),
                )
              : Column(children: [
                  for (final opportunity in filtered)
                    OpportunityCard(opportunity: opportunity)
                ]),
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator())),
          error: (error, _) => Text('${text.analysisError}: $error'),
        ),
      ],
    );
  }
}

String _sortLabel(MarketSortMode sort, bool zh) {
  return switch (sort) {
    MarketSortMode.evGap => 'EV',
    MarketSortMode.volume => zh ? '成交' : 'Vol',
    MarketSortMode.liquidity => zh ? '流动性' : 'Liq',
    MarketSortMode.spread => zh ? '价差' : 'Spread',
    MarketSortMode.endingSoon => zh ? '结束' : 'End',
  };
}
