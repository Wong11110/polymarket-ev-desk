import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_text.dart';
import '../models/market.dart';
import '../models/order_book.dart';
import '../models/paper_position.dart';
import '../state/app_providers.dart';
import 'price_history_chart.dart';

class MarketCard extends ConsumerWidget {
  const MarketCard({super.key, required this.market, this.compact = false});

  final Market market;
  final bool compact;

  void _openPaperTrade(BuildContext context, PaperSide side) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaperTradeSheet(market: market, initialSide: side),
    );
  }

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
                      onTap: () => _openPaperTrade(context, PaperSide.yes),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PriceBox(
                      label: 'NO',
                      value: market.noPrice,
                      color: Colors.lightBlueAccent,
                      onTap: () => _openPaperTrade(context, PaperSide.no),
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
      builder: (_) =>
          _PaperTradeSheet(market: market, initialSide: PaperSide.yes),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final currency = NumberFormat.compactCurrency(symbol: r'$');
    final history = ref.watch(marketPriceHistoryProvider(market));
    final orderBooks = ref.watch(marketOrderBooksProvider(market));

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
              orderBooks.when(
                data: (books) => _BookDepthPanel(
                  yes: books.yes,
                  no: books.no,
                  zh: languageCode == 'zh',
                ),
                loading: () => const SizedBox(
                  height: 72,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _BookDepthPanel(
                  yes: null,
                  no: null,
                  zh: languageCode == 'zh',
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
  const _PaperTradeSheet({required this.market, required this.initialSide});
  final Market market;
  final PaperSide initialSide;

  @override
  ConsumerState<_PaperTradeSheet> createState() => _PaperTradeSheetState();
}

class _PaperTradeSheetState extends ConsumerState<_PaperTradeSheet> {
  final _stakeController = TextEditingController(text: '25');
  late PaperSide _side;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide;
    _stakeController.addListener(_refreshQuote);
  }

  void _refreshQuote() => setState(() {});

  @override
  void dispose() {
    _stakeController.removeListener(_refreshQuote);
    _stakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final zh = languageCode == 'zh';
    final summary = ref.watch(paperPortfolioSummaryProvider);
    final orderBooks = ref.watch(marketOrderBooksProvider(widget.market));
    final price =
        _side == PaperSide.yes ? widget.market.yesPrice : widget.market.noPrice;
    final stake = double.tryParse(_stakeController.text.trim()) ?? 0;
    final orderBook =
        orderBooks.valueOrNull?.forOutcome(_side == PaperSide.yes);
    final estimate = orderBook?.estimateBuy(stake);

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
            const SizedBox(height: 10),
            _ExecutionQuote(
              estimate: estimate,
              isLoading: orderBooks.isLoading,
              zh: zh,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (stake <= 0 || stake > summary.availableCash) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(zh
                          ? '请输入不超过可用虚拟资金的金额。'
                          : 'Enter an amount within available virtual cash.'),
                    ));
                    return;
                  }
                  if (estimate != null && !estimate.isFullyFillable) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(zh
                          ? '当前订单簿深度不足，无法按该金额模拟完整成交。'
                          : 'Current order-book depth cannot fully fill this amount.'),
                    ));
                    return;
                  }
                  await ref.read(paperPortfolioProvider.notifier).open(
                        market: widget.market,
                        side: _side,
                        stakeUsd: stake,
                        entryPrice: estimate?.averagePrice,
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

class _BookDepthPanel extends StatelessWidget {
  const _BookDepthPanel(
      {required this.yes, required this.no, required this.zh});

  final OrderBook? yes;
  final OrderBook? no;
  final bool zh;

  @override
  Widget build(BuildContext context) {
    if (yes == null && no == null) {
      return _BookFallback(zh: zh);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.layers_outlined, size: 19),
            const SizedBox(width: 8),
            Text(zh ? '实时订单簿' : 'Live order book',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _BookStat(label: 'YES', book: yes, zh: zh)),
            const SizedBox(width: 10),
            Expanded(child: _BookStat(label: 'NO', book: no, zh: zh)),
          ]),
          const SizedBox(height: 8),
          Text(
            zh
                ? '买入预估会按卖盘逐档计算，盘口不足时会明确提示，避免把展示价格当作可成交价格。'
                : 'Buy estimates walk the ask book level by level and flag insufficient depth instead of treating display price as executable.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ]),
      ),
    );
  }
}

class _BookStat extends StatelessWidget {
  const _BookStat({required this.label, required this.book, required this.zh});
  final String label;
  final OrderBook? book;
  final bool zh;

  @override
  Widget build(BuildContext context) {
    if (book == null || book!.bestAsk == null || book!.bestBid == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text('$label  ${zh ? '暂无盘口' : 'No book'}'),
        ),
      );
    }
    final spread = book!.spread ?? 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text('${zh ? '买一' : 'Bid'} ${book!.bestBid!.toStringAsFixed(3)}'),
          Text('${zh ? '卖一' : 'Ask'} ${book!.bestAsk!.toStringAsFixed(3)}'),
          Text('${zh ? '价差' : 'Spread'} ${spread.toStringAsFixed(3)}',
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}

class _BookFallback extends StatelessWidget {
  const _BookFallback({required this.zh});
  final bool zh;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(zh
              ? '该市场暂时没有可用订单簿。'
              : 'No usable order book is available for this market.'),
        ),
      );
}

class _ExecutionQuote extends StatelessWidget {
  const _ExecutionQuote(
      {required this.estimate, required this.isLoading, required this.zh});
  final ExecutionEstimate? estimate;
  final bool isLoading;
  final bool zh;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const LinearProgressIndicator();
    if (estimate == null || estimate!.requestedUsd <= 0) {
      return Text(
        zh
            ? '正在获取订单簿，输入金额后可查看预估成交与滑点。'
            : 'Fetching order book. Enter an amount to preview fill and slippage.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final value = estimate!;
    final priceText = value.averagePrice == null
        ? '--'
        : value.averagePrice!.toStringAsFixed(4);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(spacing: 12, runSpacing: 6, children: [
          Text('${zh ? '预估均价' : 'Est. avg'} $priceText'),
          Text(
              '${zh ? '份数' : 'Shares'} ${value.filledShares.toStringAsFixed(2)}'),
          Text(
              '${zh ? '滑点' : 'Impact'} ${(value.priceImpact * 100).toStringAsFixed(2)}%'),
          Text('${zh ? '档位' : 'Levels'} ${value.levelsUsed}'),
          Text(
            value.isFullyFillable
                ? (zh ? '盘口可覆盖' : 'Depth available')
                : (zh ? '盘口深度不足' : 'Insufficient depth'),
            style: TextStyle(
                color: value.isFullyFillable
                    ? Colors.greenAccent
                    : Colors.orangeAccent),
          ),
        ]),
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
      {required this.label,
      required this.value,
      required this.color,
      required this.onTap});

  final String label;
  final double value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
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
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
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
