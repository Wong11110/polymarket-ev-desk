import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/opportunity.dart';
import '../models/risk_settings.dart';

class NotificationService {
  static const _channelId = 'opportunity_alerts';
  static const _channelName = 'Opportunity alerts';
  static const _channelDescription =
      'Alerts for markets that pass the selected EV threshold.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidAllowed = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosAllowed = await ios?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    return androidAllowed ?? iosAllowed ?? true;
  }

  Future<void> notifyForOpportunity(
    Opportunity opportunity,
    RiskSettings settings,
  ) async {
    if (opportunity.evGap < settings.evAlertThreshold) return;
    await initialize();

    final market = opportunity.market;
    final title = '${opportunity.side.name.toUpperCase()} EV alert';
    final body = '${market.question}\nEV '
        '${(opportunity.evGap * 100).toStringAsFixed(1)}% | price '
        '${(opportunity.impliedProbability * 100).toStringAsFixed(1)}%';
    await _plugin.show(
      market.id.hashCode & 0x7fffffff,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      payload: market.id,
    );
  }
}
