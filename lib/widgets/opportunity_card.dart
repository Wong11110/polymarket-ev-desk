import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_text.dart';
import '../models/opportunity.dart';
import '../state/app_providers.dart';

class OpportunityCard extends ConsumerWidget {
  const OpportunityCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode =
        ref.watch(settingsControllerProvider).valueOrNull?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final sideColor =
        opportunity.side == TradeSide.yes ? Colors.greenAccent : Colors.lightBlueAccent;
    final currency = NumberFormat.compactCurrency(symbol: r'$');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => OpportunityDetailSheet(opportunity: opportunity),
        ),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    opportunity.market.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(opportunity.side.name.toUpperCase()),
                  backgroundColor: sideColor.withValues(alpha: 0.16),
                  side: BorderSide(color: sideColor.withValues(alpha: 0.45)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Pill('EV Gap', '${(opportunity.evGap * 100).toStringAsFixed(1)}%'),
                _Pill(text.fairProbability, '${(opportunity.fairProbability * 100).toStringAsFixed(1)}%'),
                _Pill(text.price, opportunity.price.toStringAsFixed(2)),
                _Pill(text.suggestedStake, currency.format(opportunity.suggestedStakeUsd)),
                _Pill('Kelly', '${(opportunity.kellyFraction * 100).toStringAsFixed(1)}%'),
                _Pill(text.risk, text.riskLabel(opportunity.riskLevel.name)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              opportunity.reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => OpportunityDetailSheet(opportunity: opportunity),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(text.details),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

}

class OpportunityDetailSheet extends ConsumerStatefulWidget {
  const OpportunityDetailSheet({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  ConsumerState<OpportunityDetailSheet> createState() => _OpportunityDetailSheetState();
}

class _OpportunityDetailSheetState extends ConsumerState<OpportunityDetailSheet> {
  late double _fairProbability;

  @override
  void initState() {
    super.initState();
    _fairProbability = widget.opportunity.fairProbability;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final languageCode = settings?.languageCode ?? 'en';
    final text = AppText(languageCode);
    final service = ref.watch(aiAnalysisServiceProvider);
    final currency = NumberFormat.compactCurrency(symbol: r'$');
    final updated = settings == null
        ? widget.opportunity
        : service.evaluateOpportunity(
            market: widget.opportunity.market,
            side: widget.opportunity.side,
            fairProbability: _fairProbability,
            settings: settings,
          );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text.marketDetail,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.opportunity.market.question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pill('Side', updated.side.name.toUpperCase()),
                  _Pill(text.price, updated.price.toStringAsFixed(3)),
                  _Pill('EV Gap', '${(updated.evGap * 100).toStringAsFixed(1)}%'),
                  _Pill(text.expectedRoi, '${(updated.expectedRoi * 100).toStringAsFixed(1)}%'),
                  _Pill(text.suggestedStake, currency.format(updated.suggestedStakeUsd)),
                  _Pill(text.risk, text.riskLabel(updated.riskLevel.name)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      text.manualAssumption,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text('${(_fairProbability * 100).toStringAsFixed(1)}%'),
                ],
              ),
              Slider(
                value: _fairProbability.clamp(0.01, 0.99).toDouble(),
                min: 0.01,
                max: 0.99,
                divisions: 98,
                onChanged: (value) => setState(() => _fairProbability = value),
              ),
              Text(
                text.detailNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pill(
                    text.impliedProbability,
                    '${(updated.impliedProbability * 100).toStringAsFixed(1)}%',
                  ),
                  _Pill(
                    text.modelEstimate,
                    '${(widget.opportunity.fairProbability * 100).toStringAsFixed(1)}%',
                  ),
                  _Pill(
                    text.volumeFull,
                    currency.format(widget.opportunity.market.volumeUsd),
                  ),
                  _Pill(
                    text.liquidityFull,
                    currency.format(widget.opportunity.market.liquidityUsd),
                  ),
                  _Pill(
                    text.spread,
                    widget.opportunity.market.spread.toStringAsFixed(3),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(updated.reason),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(text.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.value);

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label ', style: Theme.of(context).textTheme.labelSmall),
            Text(value, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
