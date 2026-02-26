import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';

import '../../firebase_options.dart';
import '../alerts/models/alert_model.dart';
import 'background_notification_service.dart';

/// Unique task name for the periodic background price check
const String priceCheckTaskName = 'gold_price_check_task';

/// Top-level function required by workmanager — runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Initialize Firebase in the background isolate
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Get userId from input data (since FirebaseAuth.currentUser is null in background)
      String? userId = inputData?['userId'] as String?;

      // Fallback: try FirebaseAuth (works on some devices)
      if (userId == null || userId.isEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        userId = user?.uid;
      }

      if (userId == null || userId.isEmpty) {
        print('[BackgroundWorker] No user ID available, skipping.');
        return true;
      }

      // Fetch active alerts from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('price_alerts')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('isTriggered', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        print('[BackgroundWorker] No active alerts found.');
        return true;
      }

      final alerts = snapshot.docs
          .map((doc) => AlertModel.fromJson(doc.data()))
          .toList();

      // Fetch current gold prices
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // Get USD gold price
      const apiKey = 'CURZLAGEGEV1PTSGN3OS929SGN3OS';
      final response = await dio.get(
        'https://api.metals.dev/v1/latest',
        queryParameters: {'api_key': apiKey, 'currency': 'USD', 'unit': 'toz'},
      );

      if (response.statusCode != 200 || response.data == null) {
        print('[BackgroundWorker] API error.');
        return true;
      }

      final pricePerOunce =
          (response.data['metals']['gold'] as num?)?.toDouble() ?? 0.0;
      final pricePerGramUSD = pricePerOunce / 31.1035;

      // Get EGP exchange rate
      double egpRate = 49.5; // fallback
      try {
        final rateResponse = await dio.get(
          'https://open.er-api.com/v6/latest/USD',
        );
        if (rateResponse.statusCode == 200) {
          egpRate =
              (rateResponse.data['rates']['EGP'] as num?)?.toDouble() ?? 49.5;
        }
      } catch (_) {}

      final pricePerGramEGP = pricePerGramUSD * egpRate;

      // Calculate prices for each karat
      double getPrice(String karat, String currency) {
        final basePrice = currency == 'USD' ? pricePerGramUSD : pricePerGramEGP;
        switch (karat) {
          case '21K':
            return (basePrice * 21) / 24;
          case '18K':
            return (basePrice * 18) / 24;
          default:
            return basePrice;
        }
      }

      // Initialize notifications
      await BackgroundNotificationService.initialize();

      // Check each alert
      int triggeredCount = 0;
      for (var alert in alerts) {
        final currentPrice = getPrice(alert.karat, alert.currency);

        // Check based on direction
        final bool shouldTrigger = alert.direction == 'below'
            ? currentPrice <= alert.targetPrice
            : currentPrice >= alert.targetPrice;

        if (shouldTrigger) {
          // Mark alert as triggered in Firestore
          await FirebaseFirestore.instance
              .collection('price_alerts')
              .doc(alert.id)
              .update({'isTriggered': true, 'isActive': false});

          // Show notification
          final directionText = alert.direction == 'below'
              ? 'dropped to'
              : 'reached';
          await BackgroundNotificationService.showPriceAlertNotification(
            title: '🏆 Gold ${alert.karat} Alert!',
            body:
                'Gold ${alert.karat} $directionText ${currentPrice.toStringAsFixed(2)} ${alert.currency}! '
                '(Your target: ${alert.targetPrice.toStringAsFixed(2)} ${alert.currency})',
            notificationId: alert.id.hashCode,
          );

          triggeredCount++;
        }
      }

      print(
        '[BackgroundWorker] Checked ${alerts.length} alerts, '
        'triggered $triggeredCount.',
      );
      return true;
    } catch (e) {
      print('[BackgroundWorker] Error: $e');
      return true; // Return true to avoid retries on expected failures
    }
  });
}

/// Register the periodic background task
class BackgroundPriceChecker {
  /// Initialize workmanager and register the periodic task
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Register the periodic price check (runs every ~15 minutes)
  /// Pass the userId so the background isolate can access Firestore
  static Future<void> registerPeriodicTask() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return; // Don't register if no user

    await Workmanager().registerPeriodicTask(
      'gold_price_periodic_check',
      priceCheckTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
      inputData: {'userId': userId},
    );
  }

  /// Cancel all background tasks (e.g., on logout)
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }

  /// Run a one-off check immediately (useful for testing)
  static Future<void> runOnce() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await Workmanager().registerOneOffTask(
      'gold_price_one_off_check',
      priceCheckTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      inputData: {'userId': userId},
    );
  }
}
