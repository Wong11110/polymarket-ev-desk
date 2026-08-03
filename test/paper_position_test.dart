import 'package:flutter_test/flutter_test.dart';
import 'package:polymarket_ev_mvp/models/market.dart';
import 'package:polymarket_ev_mvp/models/paper_position.dart';

void main() {
  final market = Market(
    id: 'market-1',
    question: 'Test market',
    category: 'Test',
    yesPrice: 0.60,
    noPrice: 0.40,
    volumeUsd: 1,
    liquidityUsd: 1,
    spread: 0.01,
    endDate: DateTime(2027),
  );

  test('marks an open YES paper position against live price', () {
    final position = PaperPosition(
      id: '1',
      marketId: 'market-1',
      question: 'Test market',
      side: PaperSide.yes,
      entryPrice: 0.50,
      stakeUsd: 50,
      shares: 100,
      openedAt: DateTime(2026),
    );

    final summary = PaperPortfolioSummary.calculate(
      positions: [position],
      markets: {'market-1': market},
      startingBalance: 1000,
    );

    expect(position.pnlFor(market), closeTo(10, 0.000001));
    expect(summary.availableCash, 950);
    expect(summary.openValue, 60);
    expect(summary.equity, 1010);
  });

  test('returns proceeds to cash after a simulated close', () {
    final position = PaperPosition(
      id: '1',
      marketId: 'market-1',
      question: 'Test market',
      side: PaperSide.no,
      entryPrice: 0.40,
      stakeUsd: 40,
      shares: 100,
      openedAt: DateTime(2026),
    ).close(0.50);

    final summary = PaperPortfolioSummary.calculate(
      positions: [position],
      markets: const {},
      startingBalance: 1000,
    );

    expect(summary.availableCash, 1010);
    expect(summary.totalPnl, 10);
  });
}
