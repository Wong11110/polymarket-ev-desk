import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_text.dart';
import '../state/app_providers.dart';

class SmartMoneyPage extends ConsumerWidget {
  const SmartMoneyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signals = ref.watch(smartMoneyProvider);
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final currency = NumberFormat.compactCurrency(symbol: r'$');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          text.smartMoneyTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          text.smartMoneyDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        signals.when(
          data: (items) => Column(
            children: [
              for (final signal in items)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                signal.walletLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Chip(label: Text(signal.side)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(text.marketQuestion(signal.marketQuestion)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _SignalStat(
                                text.size, currency.format(signal.amountUsd)),
                            _SignalStat(text.winRate,
                                '${(signal.winRate * 100).toStringAsFixed(0)}%'),
                            _SignalStat(text.age, _age(signal.timestamp)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          signal.note,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('${text.smartMoneyError}: $error'),
        ),
      ],
    );
  }

  static String _age(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _SignalStat extends StatelessWidget {
  const _SignalStat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label $value'),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}
