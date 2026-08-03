import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/market.dart';
import '../models/paper_position.dart';
import '../state/app_providers.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final zh = languageCode == 'zh';
    final positionsAsync = ref.watch(paperPortfolioProvider);
    final summary = ref.watch(paperPortfolioSummaryProvider);
    final markets = ref.watch(marketsProvider).valueOrNull ?? const <Market>[];
    final marketById = {for (final market in markets) market.id: market};
    final currency = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return positionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Portfolio error: $error')),
      data: (positions) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(zh ? '模拟组合' : 'Paper Portfolio',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            zh
                ? '使用实时市场价格盯市。本页不会连接钱包，也不会执行真实订单。'
                : 'Marked to live market prices. No wallet is connected and no real orders are placed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          _PortfolioSummary(summary: summary, currency: currency, zh: zh),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(zh ? '持仓与历史' : 'Positions & history',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              IconButton(
                tooltip: zh ? '清空模拟记录' : 'Reset paper trades',
                onPressed: positions.isEmpty
                    ? null
                    : () => _confirmReset(context, ref, zh),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (positions.isEmpty)
            _EmptyPortfolio(zh: zh)
          else
            ...positions.reversed.map(
              (position) => _PositionTile(
                position: position,
                market: marketById[position.marketId],
                currency: currency,
                zh: zh,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(
      BuildContext context, WidgetRef ref, bool zh) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zh ? '清空模拟组合？' : 'Reset paper portfolio?'),
        content: Text(zh
            ? '这会删除本设备上的全部模拟持仓和历史记录。'
            : 'This removes all paper positions and trade history on this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(zh ? '取消' : 'Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(zh ? '清空' : 'Reset')),
        ],
      ),
    );
    if (shouldReset == true) {
      await ref.read(paperPortfolioProvider.notifier).reset();
    }
  }
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary(
      {required this.summary, required this.currency, required this.zh});
  final PaperPortfolioSummary summary;
  final NumberFormat currency;
  final bool zh;

  @override
  Widget build(BuildContext context) {
    final pnlColor =
        summary.totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(zh ? '虚拟资金余额' : 'Virtual equity',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(currency.format(summary.equity),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Wrap(spacing: 18, runSpacing: 12, children: [
            _SummaryValue(
                label: zh ? '累计盈亏' : 'Total P&L',
                value:
                    '${summary.totalPnl >= 0 ? '+' : ''}${currency.format(summary.totalPnl)}',
                color: pnlColor),
            _SummaryValue(
                label: zh ? '可用资金' : 'Available cash',
                value: currency.format(summary.availableCash)),
            _SummaryValue(
                label: zh ? '持仓市值' : 'Open value',
                value: currency.format(summary.openValue)),
            _SummaryValue(
                label: zh ? '在持仓数' : 'Open positions',
                value: '${summary.openPositions}'),
          ]),
        ]),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.w800)),
          ]);
}

class _PositionTile extends ConsumerWidget {
  const _PositionTile(
      {required this.position,
      required this.market,
      required this.currency,
      required this.zh});
  final PaperPosition position;
  final Market? market;
  final NumberFormat currency;
  final bool zh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mark = position.markPriceFor(market);
    final pnl = position.pnlFor(market);
    final active = position.isOpen;
    final side = position.side == PaperSide.yes ? 'YES' : 'NO';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Text(position.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Text(active ? (zh ? '模拟持仓' : 'Open') : (zh ? '已平仓' : 'Closed'),
                style: Theme.of(context).textTheme.labelMedium),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 8, children: [
            Text('$side  ${position.shares.toStringAsFixed(2)}'),
            Text(
                '${zh ? '开仓' : 'Entry'} ${position.entryPrice.toStringAsFixed(3)}'),
            Text('${zh ? '现价' : 'Mark'} ${mark.toStringAsFixed(3)}'),
            Text('${pnl >= 0 ? '+' : ''}${currency.format(pnl)}',
                style: TextStyle(
                    color: pnl >= 0 ? Colors.greenAccent : Colors.redAccent)),
          ]),
          if (active) ...[
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => ref
                      .read(paperPortfolioProvider.notifier)
                      .close(position.id, mark),
                  icon: const Icon(Icons.close),
                  label: Text(zh ? '按当前价模拟平仓' : 'Close at mark'),
                )),
          ],
        ]),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio({required this.zh});
  final bool zh;
  @override
  Widget build(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(zh
            ? '从任一市场详情中选择 YES 或 NO，并创建模拟仓位。'
            : 'Open a market detail, choose YES or NO, and create a paper position.'),
      ));
}
