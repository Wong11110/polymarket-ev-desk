import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/market.dart';

class PriceHistoryChart extends StatelessWidget {
  const PriceHistoryChart({
    super.key,
    required this.points,
    required this.languageCode,
  });

  final List<PricePoint> points;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final zh = languageCode == 'zh';
    if (points.length < 2) {
      return _ChartFrame(
        title: zh ? '近 7 日 YES 价格走势' : 'YES price, last 7 days',
        child: Center(
          child: Text(
            zh ? '暂无可用的历史价格数据' : 'No price history available',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final first = points.first.price;
    final last = points.last.price;
    final change = last - first;
    final color =
        change >= 0 ? const Color(0xFF1FC77A) : const Color(0xFFE85D75);

    return _ChartFrame(
      title: zh ? '近 7 日 YES 价格走势' : 'YES price, last 7 days',
      trailing: Text(
        '${change >= 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)} pts',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
      child: CustomPaint(
        painter: _LineChartPainter(
          points: points,
          lineColor: color,
          gridColor: Theme.of(context).colorScheme.outlineVariant,
        ),
        size: const Size(double.infinity, 132),
      ),
    );
  }
}

class _ChartFrame extends StatelessWidget {
  const _ChartFrame({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleSmall)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(height: 132, width: double.infinity, child: child),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
  });

  final List<PricePoint> points;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 4.0;
    const top = 8.0;
    const bottom = 8.0;
    final chartHeight = size.height - top - bottom;
    final values = points.map((point) => point.price).toList();
    final minValue = math.max(0, values.reduce(math.min) - 0.025).toDouble();
    final maxValue = math.min(1, values.reduce(math.max) + 0.025).toDouble();
    final range = math.max(0.05, maxValue - minValue).toDouble();

    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var index = 0; index < 4; index++) {
      final y = top + chartHeight * index / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
    }

    Offset pointAt(int index) {
      final x = left + (size.width - left) * index / (points.length - 1);
      final y =
          top + (1 - (points[index].price - minValue) / range) * chartHeight;
      return Offset(x, y);
    }

    final linePath = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var index = 1; index < points.length; index++) {
      final point = pointAt(index);
      linePath.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height - bottom)
      ..lineTo(left, size.height - bottom)
      ..close();
    canvas.drawPath(
        fillPath, Paint()..color = lineColor.withValues(alpha: 0.12));
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final last = pointAt(points.length - 1);
    canvas.drawCircle(last, 4, Paint()..color = lineColor);
    canvas.drawCircle(last, 1.7, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
