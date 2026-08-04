import 'package:flutter_test/flutter_test.dart';
import 'package:polymarket_ev_mvp/models/order_book.dart';

void main() {
  final book = OrderBook.fromJson({
    'asset_id': 'token',
    'timestamp': '1700000000000',
    'tick_size': '0.01',
    'min_order_size': '1',
    'bids': [
      {'price': '0.48', 'size': '10'},
      {'price': '0.50', 'size': '5'},
    ],
    'asks': [
      {'price': '0.55', 'size': '10'},
      {'price': '0.50', 'size': '5'},
    ],
  });

  test('sorts book levels into best bid and ask order', () {
    expect(book.bestBid, 0.50);
    expect(book.bestAsk, 0.50);
  });

  test('estimates a buy across multiple ask levels', () {
    final estimate = book.estimateBuy(8);
    expect(estimate.isFullyFillable, isTrue);
    expect(estimate.filledShares, closeTo(15, 0.001));
    expect(estimate.averagePrice, closeTo(0.5333, 0.001));
    expect(estimate.levelsUsed, 2);
  });
}
