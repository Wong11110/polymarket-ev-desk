import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_text.dart';
import '../models/market.dart';
import '../models/paper_position.dart';
import '../state/app_providers.dart';
import 'price_history_chart.dart';

class MarketCard extends ConsumerWidget {
  const MarketCard({super.key, required this.market, this.compact = false});

  final Market market;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final watchlist =
        ref.watch(watchlistProvider).valueOrNull ?? const <String>{};
    final isSaved = watchlist.contains(market.id);
    final currency = NumberFormat.compactCurrency(symbol: r'$');
    final date = DateFormat.MMMd().format(market.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => MarketDetailSheet(market: market),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarketIcon(market: market),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text.marketQuestion(market.question),
                          maxLines: compact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _Tag(text.marketCategory(market.category)),
                            if (market.isBinaryArbCandidate)
                              _Tag(languageCode == 'zh' ? '价差观察' : 'Arb watch'),
                            if (market.isEndingSoon)
                              _Tag(languageCode == 'zh'
                                  ? '临近结束'
                                  : 'Ending soon'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isSaved
                        ? (languageCode == 'zh' ? '取消关注' : 'Remove watch')
                        : (languageCode == 'zh' ? '加入关注' : 'Add watch'),
                    onPressed: () =>
                        ref.read(watchlistProvider.notifier).toggle(market.id),
                    icon: Icon(isSaved ? Icons.star : Icons.star_border),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PriceBox(
                      label: 'YES',
                      value: market.yesPrice,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PriceBox(
                      label: 'NO',
                      value: market.noPrice,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Metric(
                      label: text.volume,
                      value: currency.format(market.volumeUsd)),
                  _Metric(
                      label: text.liquidity,
                      value: currency.format(market.liquidityUsd)),
                  _Metric(
                      label: text.spread,
                      value: market.spread.toStringAsFixed(3)),
                  _Metric(
                      label: languageCode == 'zh' ? '结束' : 'Ends', value: date),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _LiquidityBar(score: market.liquidityScore)),
                  IconButton(
                    tooltip: languageCode == 'zh'
                        ? '打开 Polymarket'
                        : 'Open Polymarket',
                    onPressed: () => launchUrl(
                      Uri.parse(market.polymarketUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketDetailSheet extends ConsumerWidget {
  const MarketDetailSheet({super.key, required this.market});

  final Market market;

  void _openPaperTrade(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaperTradeSheet(market: market),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final currency = NumberFormat.compactCurrency(symbol: r'$');
    final history = ref.watch(marketPriceHistoryProvider(market));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageCode == 'zh' ? '市场详情' : 'Market Detail',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(text.marketQuestion(market.question),
                  style: Theme.of(context).textTheme.titleMedium),
              if (languageCode == 'zh') ...[
                const SizedBox(height: 6),
                Text(
                  '${text.originalTitle}: ${market.question}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Metric(
                      label: 'YES', value: market.yesPrice.toStringAsFixed(3)),
                  _Metric(
                      label: 'NO', value: market.noPrice.toStringAsFixed(3)),
                  _Metric(
                      label: 'YES+NO',
                      value: market.noVigSum.toStringAsFixed(3)),
                  _Metric(
                      label: text.volumeFull,
                      value: currency.format(market.volumeUsd)),
                  _Metric(
                      label: text.liquidityFull,
                      value: currency.format(market.liquidityUsd)),
                  _Metric(
                      label: text.spread,
                      value: market.spread.toStringAsFixed(3)),
                  if (market.bestBid != null)
                    _Metric(
                        label: 'Best bid',
                        value: market.bestBid!.toStringAsFixed(3)),
                  if (market.bestAsk != null)
                    _Metric(
                        label: 'Best ask',
                        value: market.bestAsk!.toStringAsFixed(3)),
                ],
              ),
              const SizedBox(height: 14),
              history.when(
                data: (points) => PriceHistoryChart(
                  points: points,
                  languageCode: languageCode,
                ),
                loading: () => const SizedBox(
                  height: 156,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => PriceHistoryChart(
                  points: const [],
                  languageCode: languageCode,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                languageCode == 'zh'
                    ? '执行提示：真实套利还需要核验订单簿深度、手续费、滑点、成交概率与资金成本。此应用默认只做机会发现和风控提示，不会自动下单。'
                    : 'Execution note: real arbitrage needs order-book depth, fees, slippage, fill probability, and withdrawal/bridge cost checks. This app is discovery and risk analysis only.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openPaperTrade(context),
                  icon: const Icon(Icons.add_chart_outlined),
                  label: Text(languageCode == 'zh' ? '创建模拟仓位' : 'Paper trade'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(market.polymarketUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(languageCode == 'zh' ? '打开原市场' : 'Open market'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperTradeSheet extends ConsumerStatefulWidget {
  const _PaperTradeSheet({required this.market});
  final Market market;

  @override
  ConsumerState<_PaperTradeSheet> createState() => _PaperTradeSheetState();
}

class _PaperTradeSheetState extends ConsumerState<_PaperTradeSheet> {
  final _stakeController = TextEditingController(text: '25');
  PaperSide _side = PaperSide.yes;

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final zh = languageCode == 'zh';
    final summary = ref.watch(paperPortfolioSummaryProvider);
    final price =
        _side == PaperSide.yes ? widget.market.yesPrice : widget.market.noPrice;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zh ? '创建模拟仓位' : 'Create paper position',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(widget.market.question,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 14),
            SegmentedButton<PaperSide>(
              segments: const [
                ButtonSegment(value: PaperSide.yes, label: Text('YES')),
                ButtonSegment(value: PaperSide.no, label: Text('NO')),
              ],
              selected: {_side},
              onSelectionChanged: (selection) =>
                  setState(() => _side = selection.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _stakeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: zh ? '模拟金额（USD）' : 'Paper stake (USD)',
                helperText:
                    '${zh ? '当前价格' : 'Current price'} ${price.toStringAsFixed(3)}  |  ${zh ? '可用虚拟资金' : 'Available virtual cash'} \$${summary.availableCash.toStringAsFixed(2)}',
                prefixText: r'$',
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final stake =
                      double.tryParse(_stakeController.text.trim()) ?? 0;
                  if (stake <= 0 || stake > summary.availableCash) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(zh
                          ? '请输入不超过可用虚拟资金的金额。'
                          : 'Enter an amount within available virtual cash.'),
                    ));
                    return;
                  }
                  await ref.read(paperPortfolioProvider.notifier).open(
                        market: widget.market,
                        side: _side,
                        stakeUsd: stake,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(zh ? '确认模拟建仓' : 'Confirm paper trade'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketIcon extends StatelessWidget {
  const _MarketIcon({required this.market});

  final Market market;

  @override
  Widget build(BuildContext context) {
    final imageUrl = market.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: imageUrl == null || imageUrl.isEmpty
            ? const Icon(Icons.query_stats)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.query_stats),
              ),
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox(
      {required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        color: color.withValues(alpha: 0.12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            Text(value.toStringAsFixed(2),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text('$label $value'),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(value, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

class _LiquidityBar extends StatelessWidget {
  const _LiquidityBar({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: score.clamp(0, 1).toDouble(),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
