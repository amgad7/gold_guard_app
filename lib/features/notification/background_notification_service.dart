import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the local notifications plugin
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create the notification channel for Android
    await _createNotificationChannel();

    _isInitialized = true;
  }

  /// Create a max-importance notification channel for price alerts
  static Future<void> _createNotificationChannel() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) return;

    // Delete old channel to force recreation with new settings
    await android.deleteNotificationChannel('gold_price_alerts');

    const channel = AndroidNotificationChannel(
      'gold_price_alerts',
      'Gold Price Alerts',
      description: 'Notifications when gold reaches your target price',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await android.createNotificationChannel(channel);
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // App will open automatically when notification is tapped
    // No extra navigation needed since the alerts screen is accessible from main
  }

  /// Show a price alert notification
  static Future<void> showPriceAlertNotification({
    required String title,
    required String body,
    int? notificationId,
  }) async {
    // Ensure initialized (important for background tasks)
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'gold_price_alerts',
      'Gold Price Alerts',
      channelDescription: 'Notifications when gold reaches your target price',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }
}
