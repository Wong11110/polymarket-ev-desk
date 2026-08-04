import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:polymarket_ev_mvp/main.dart';
import 'package:polymarket_ev_mvp/repositories/polymarket_repository.dart';
import 'package:polymarket_ev_mvp/state/app_providers.dart';

void main() {
  testWidgets('mobile shell exposes the core navigation flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketsProvider.overrideWith(
            (ref) => Stream.value(PolymarketRepository.mockMarkets),
          ),
          opportunitiesProvider.overrideWith((ref) async => const []),
        ],
        child: const PolymarketEvApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('Smart Money'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
