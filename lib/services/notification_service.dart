import 'package:flutter/foundation.dart';

import '../models/opportunity.dart';
import '../models/risk_settings.dart';

class NotificationService {
  Future<void> initialize() async {
    debugPrint('通知服务已初始化：当前为占位模式。');
  }

  Future<void> notifyForOpportunity(
    Opportunity opportunity,
    RiskSettings settings,
  ) async {
    if (opportunity.evGap < settings.evAlertThreshold) return;
    debugPrint(
      '机会提醒：${opportunity.market.question} '
      '${opportunity.side.name.toUpperCase()} '
      'EV ${(opportunity.evGap * 100).toStringAsFixed(1)}%',
    );
  }
}
