import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../home/services/gold_api_service.dart';
import '../services/alert_firebase_service.dart';

class SimpleAlertService {
  final AlertFirebaseService _alertService = AlertFirebaseService();
  final GoldApiService _apiService = GoldApiService();

  Future<List<String>> checkAlertsOnAppOpen() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return [];

      final alerts = await _alertService.getActiveAlerts();
      if (alerts.isEmpty) return [];

      final priceUSD = await _apiService.getGoldPrice('USD');
      final priceEGP = await _apiService.getGoldPrice('EGP');

      List<String> triggeredMessages = [];

      for (var alert in alerts) {
        final currentModel = alert.currency == 'USD' ? priceUSD : priceEGP;

        double currentPrice;
        switch (alert.karat) {
          case '21K':
            currentPrice = currentModel.price21k ?? 0;
            break;
          case '18K':
            currentPrice = currentModel.price18k ?? 0;
            break;
          default:
            currentPrice = currentModel.priceGram24k ?? 0;
        }

        // Check based on direction
        bool isTriggered = false;
        if (alert.direction == 'below') {
          isTriggered = currentPrice <= alert.targetPrice;
        } else {
          isTriggered = currentPrice >= alert.targetPrice;
        }

        if (isTriggered) {
          await _alertService.markAlertAsTriggered(alert.id!);

          final directionText = alert.direction == 'below'
              ? 'dropped to'
              : 'reached';
          triggeredMessages.add(
            '📢 Alert: Gold ${alert.karat} $directionText ${currentPrice.toStringAsFixed(2)} ${alert.currency}! (Target: ${alert.targetPrice} ${alert.currency})',
          );
        }
      }

      return triggeredMessages;
    } catch (e) {
      print('Error checking alerts: $e');
      return [];
    }
  }

  Stream<List<String>> watchPriceAlerts() async* {
    while (true) {
      await Future.delayed(Duration(minutes: 5));

      final messages = await checkAlertsOnAppOpen();
      if (messages.isNotEmpty) {
        yield messages;
      }
    }
  }
}
