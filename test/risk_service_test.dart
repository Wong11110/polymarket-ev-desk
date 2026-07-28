import 'package:flutter_test/flutter_test.dart';
import 'package:polymarket_ev_mvp/models/risk_settings.dart';
import 'package:polymarket_ev_mvp/services/risk_service.dart';

void main() {
  test('recommends zero stake when there is no edge', () {
    const service = RiskService();
    final result = service.recommendStake(
      price: 0.55,
      fairProbability: 0.50,
      settings: RiskSettings.defaults,
    );

    expect(result.cappedStakeUsd, 0);
    expect(result.fractionalKelly, 0);
  });

  test('caps positive Kelly stake by max position rules', () {
    const service = RiskService();
    final result = service.recommendStake(
      price: 0.40,
      fairProbability: 0.55,
      settings: RiskSettings.defaults,
    );

    expect(result.cappedStakeUsd, greaterThan(0));
    expect(result.cappedStakeUsd, lessThanOrEqualTo(50));
  });
}
