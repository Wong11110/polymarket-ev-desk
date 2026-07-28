import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_text.dart';
import '../models/risk_settings.dart';
import '../state/app_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _bankroll;
  late final TextEditingController _apiKey;

  @override
  void initState() {
    super.initState();
    _bankroll = TextEditingController();
    _apiKey = TextEditingController();
  }

  @override
  void dispose() {
    _bankroll.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return settingsAsync.when(
      data: (settings) {
        final text = AppText(settings.languageCode);
        if (_bankroll.text.isEmpty) {
          _bankroll.text = settings.bankrollUsd.toStringAsFixed(0);
        }
        if (_apiKey.text.isEmpty) _apiKey.text = settings.openAiApiKey;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              text.settingsTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${text.language} / Language',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'en', label: Text(text.english)),
                          ButtonSegment(value: 'zh', label: Text(text.chinese)),
                        ],
                        selected: {settings.languageCode},
                        onSelectionChanged: (values) {
                          _update(settings.copyWith(languageCode: values.first));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bankroll,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bankroll USD',
                prefixText: r'$ ',
                border: OutlineInputBorder(),
              ).copyWith(labelText: text.bankrollUsd),
              onSubmitted: (_) => _save(settings),
            ),
            const SizedBox(height: 16),
            _SliderTile(
              title: text.evAlertThreshold,
              value: settings.evAlertThreshold,
              min: 0.01,
              max: 0.2,
              label: '${(settings.evAlertThreshold * 100).toStringAsFixed(1)}%',
              onChanged: (value) => _update(settings.copyWith(evAlertThreshold: value)),
            ),
            _SliderTile(
              title: text.kellyFraction,
              value: settings.kellyFraction,
              min: 0.05,
              max: 1,
              label: '${(settings.kellyFraction * 100).toStringAsFixed(0)}%',
              onChanged: (value) => _update(settings.copyWith(kellyFraction: value)),
            ),
            _SliderTile(
              title: text.maxPositionPct,
              value: settings.maxPositionPct,
              min: 0.01,
              max: 0.25,
              label: '${(settings.maxPositionPct * 100).toStringAsFixed(0)}%',
              onChanged: (value) => _update(settings.copyWith(maxPositionPct: value)),
            ),
            _SliderTile(
              title: text.dailyLossLimit,
              value: settings.dailyLossLimitPct,
              min: 0.02,
              max: 0.3,
              label: '${(settings.dailyLossLimitPct * 100).toStringAsFixed(0)}%',
              onChanged: (value) => _update(settings.copyWith(dailyLossLimitPct: value)),
            ),
            _SliderTile(
              title: text.minLiquidity,
              value: settings.minLiquidityUsd,
              min: 500,
              max: 100000,
              divisions: 199,
              label: '\$${settings.minLiquidityUsd.toStringAsFixed(0)}',
              onChanged: (value) => _update(settings.copyWith(minLiquidityUsd: value)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(text.darkMode),
              value: settings.darkMode,
              onChanged: (value) => _update(settings.copyWith(darkMode: value)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKey,
              obscureText: true,
              decoration: InputDecoration(
                labelText: text.apiKeyPlaceholder,
                helperText: text.apiKeyHelper,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(settings),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _save(settings),
              icon: const Icon(Icons.save),
              label: Text(text.saveSettings),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Settings error: $error')),
    );
  }

  Future<void> _save(RiskSettings settings) async {
    final parsedBankroll = double.tryParse(_bankroll.text.trim()) ?? settings.bankrollUsd;
    await _update(
      settings.copyWith(
        bankrollUsd: parsedBankroll,
        openAiApiKey: _apiKey.text.trim(),
      ),
    );
    if (mounted) {
      final text = AppText(settings.languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text.settingsSaved)),
      );
    }
  }

  Future<void> _update(RiskSettings settings) async {
    await ref.read(settingsControllerProvider.notifier).saveSettings(settings);
    ref.invalidate(opportunitiesProvider);
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
    this.divisions,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title)),
                Text(label, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            Slider(
              value: value.clamp(min, max).toDouble(),
              min: min,
              max: max,
              divisions: divisions ?? 100,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
