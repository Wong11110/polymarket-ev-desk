import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_text.dart';
import '../models/market.dart';
import '../state/app_providers.dart';
import '../widgets/metric_tile.dart';
import '../widgets/opportunity_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markets = ref.watch(marketsProvider);
    final opportunities = ref.watch(opportunitiesProvider);
    final settings = ref.watch(settingsControllerProvider);
    final text = AppText(settings.valueOrNull?.languageCode ?? 'en');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(marketsProvider);
        ref.invalidate(opportunitiesProvider);
        await ref.read(marketsProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            text.dashboardTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            text.dashboardSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                text.realtimeNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          settings.when(
            data: (value) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.sizeOf(context).width > 640 ? 4 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                MetricTile(label: text.bankroll, value: '\$${value.bankrollUsd.toStringAsFixed(0)}'),
                MetricTile(label: text.evAlert, value: '${(value.evAlertThreshold * 100).toStringAsFixed(1)}%'),
                MetricTile(label: text.kelly, value: '${(value.kellyFraction * 100).toStringAsFixed(0)}%'),
                MetricTile(label: text.maxPosition, value: '${(value.maxPositionPct * 100).toStringAsFixed(0)}%'),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('${text.settingsError}: $error'),
          ),
          const SizedBox(height: 20),
          Text(text.topOpportunities, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          opportunities.when(
            data: (items) => items.isEmpty
                ? Text(text.noEvGaps)
                : Column(
                    children: items.take(5).map((item) => OpportunityCard(opportunity: item)).toList(),
                  ),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
            error: (error, _) => Text('${text.opportunityError}: $error'),
          ),
          const SizedBox(height: 12),
          Text(text.popularMarkets, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          markets.when(
            data: (items) => Column(
              children: items.map((item) => _MarketRow(market: item, text: text)).toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text('${text.marketError}: $error'),
          ),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({required this.market, required this.text});

  final Market market;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactCurrency(symbol: r'$');
    return Card(
      child: ListTile(
        title: Text(market.question, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${market.category}  |  ${text.volume} ${currency.format(market.volumeUsd)}  |  ${text.liquidity} ${currency.format(market.liquidityUsd)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('YES ${market.yesPrice.toStringAsFixed(2)}'),
            Text('NO ${market.noPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
