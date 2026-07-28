import 'package:flutter_test/flutter_test.dart';
import 'package:polymarket_ev_mvp/l10n/app_text.dart';

void main() {
  test('localizes known mock market questions in Chinese mode', () {
    const text = AppText('zh');

    expect(
      text.marketQuestion('Will the Fed cut rates at the next FOMC meeting?'),
      '美联储会在下一次 FOMC 会议降息吗？',
    );
  });

  test('keeps market questions unchanged in English mode', () {
    const text = AppText('en');
    const question = 'Will BTC close above \$100k before year end?';

    expect(text.marketQuestion(question), question);
  });
}
