import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gold_caurd_app/core/styling/app_colors.dart';
import 'package:gold_caurd_app/core/widgets/spacing_widgets.dart';

import '../models/alert_model.dart';
import '../services/alert_firebase_service.dart';
import '../services/simple_alert_service.dart';
import '../../notification/background_notification_service.dart';
import '../../notification/fcm_services.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertFirebaseService _alertService = AlertFirebaseService();
  final SimpleAlertService _simpleAlertService = SimpleAlertService();

  List<AlertModel> alerts = [];
  bool isLoading = true;
  bool isChecking = false;

  String selectedKarat = '24K';
  String selectedCurrency = 'EGP';
  String selectedDirection = 'above';

  @override
  void initState() {
    super.initState();
    loadAlerts();
    checkAlertsOnOpen();
  }

  Future<void> checkAlertsOnOpen() async {
    setState(() => isChecking = true);

    try {
      final messages = await _simpleAlertService.checkAlertsOnAppOpen();

      if (messages.isNotEmpty && mounted) {
        showTriggeredAlertsDialog(messages);
      }
    } catch (e) {
      print('Error checking alerts: $e');
    } finally {
      setState(() => isChecking = false);
    }
  }

  void showTriggeredAlertsDialog(List<String> messages) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Colors.green,
                size: 32.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Price Alerts Triggered! ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages.map((msg) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: Text(
                    msg,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                loadAlerts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadAlerts() async {
    setState(() => isLoading = true);

    try {
      final data = await _alertService.getUserAlerts();
      setState(() {
        alerts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      showErrorSnackBar(e.toString());
    }
  }

  void showAddAlertDialog() {
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.notification_add, color: AppColors.primaryColor),
                  SizedBox(width: 10.w),
                  Text(
                    'Create Price Alert',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedKarat,
                        dropdownColor: Colors.grey[850],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Select Karat',
                          labelStyle: TextStyle(
                            color: AppColors.secondaryColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                        items: ['24K', '21K', '18K'].map((karat) {
                          return DropdownMenuItem(
                            value: karat,
                            child: Text(karat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedKarat = value!);
                        },
                      ),
                      HeightSpace(15),

                      DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        dropdownColor: Colors.grey[850],
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Select Currency',
                          labelStyle: TextStyle(
                            color: AppColors.secondaryColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                        items: ['USD', 'EGP'].map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(
                              currency == 'USD' ? '🇺🇸 USD' : '🇪🇬 EGP',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedCurrency = value!);
                        },
                      ),
                      HeightSpace(15),

                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Target Price per Gram',
                          labelStyle: TextStyle(
                            color: AppColors.secondaryColor,
                          ),
                          hintText: 'e.g. 4000',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter target price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      HeightSpace(15),

                      // Direction selector
                      Text(
                        'Alert when price goes:',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 13.sp,
                        ),
                      ),
                      HeightSpace(8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setDialogState(
                                () => selectedDirection = 'above',
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: selectedDirection == 'above'
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: selectedDirection == 'above'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.green,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Above',
                                        style: TextStyle(
                                          color: selectedDirection == 'above'
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setDialogState(
                                () => selectedDirection = 'below',
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: selectedDirection == 'below'
                                      ? Colors.red.withValues(alpha: 0.3)
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: selectedDirection == 'below'
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.red,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Below',
                                        style: TextStyle(
                                          color: selectedDirection == 'below'
                                              ? Colors.red
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      HeightSpace(15),

                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: Colors.green,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'You\'ll receive a notification even when the app is closed',
                                style: TextStyle(
                                  color: Colors.green[200],
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await addAlert(double.parse(priceController.text));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Create Alert'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> addAlert(double targetPrice) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final alert = AlertModel(
        userId: userId,
        targetPrice: targetPrice,
        karat: selectedKarat,
        currency: selectedCurrency,
        direction: selectedDirection,
        createdAt: DateTime.now(),
      );

      await _alertService.addAlert(alert);
      await loadAlerts();

      _showSuccessSnackBar('Alert created successfully! ');
    } catch (e) {
      showErrorSnackBar(e.toString());
    }
  }

  Future<void> toggleAlert(AlertModel alert) async {
    try {
      await _alertService.updateAlertStatus(
        alertId: alert.id!,
        isActive: !alert.isActive,
      );
      await loadAlerts();
    } catch (e) {
      showErrorSnackBar(e.toString());
    }
  }

  Future<void> deleteAlert(AlertModel alert) async {
    try {
      await _alertService.deleteAlert(alert.id!);
      await loadAlerts();
      _showSuccessSnackBar('Alert deleted');
    } catch (e) {
      showErrorSnackBar(e.toString());
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _testNotification() async {
    try {
      // 1. Send a test local notification immediately
      await BackgroundNotificationService.showPriceAlertNotification(
        title: '🔔 Test Notification',
        body:
            'Notifications are working! Background alerts will fire every ~15 minutes.',
        notificationId: 999,
      );

      _showSuccessSnackBar(
        'Test notification sent! Check your notification bar.',
      );

      // 2. Also trigger a one-off background check
      await BackgroundPriceChecker.runOnce();
    } catch (e) {
      showErrorSnackBar('Notification test failed: $e');
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Price Alerts',
          style: TextStyle(color: AppColors.primaryColor),
        ),
        centerTitle: true,
        actions: [
          if (isChecking)
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: checkAlertsOnOpen,
              icon: Icon(Icons.refresh, color: AppColors.primaryColor),
              tooltip: 'Check Alerts Now',
            ),
          IconButton(
            onPressed: _testNotification,
            icon: Icon(Icons.notifications_active, color: Colors.green),
            tooltip: 'Test Notification',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : alerts.isEmpty
          ? buildEmptyState()
          : buildAlertsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddAlertDialog,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        icon: Icon(Icons.add_alert),
        label: Text('Add Alert'),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80.sp, color: Colors.grey),
          HeightSpace(20),
          Text(
            'No Price Alerts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          HeightSpace(10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Create an alert to get notified when gold reaches your target price',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAlertsList() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return buildAlertCard(alert);
      },
    );
  }

  Widget buildAlertCard(AlertModel alert) {
    final color = alert.karat == '24K'
        ? AppColors.primaryColor
        : alert.karat == '21K'
        ? Colors.amber
        : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: alert.isActive
              ? color.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gold ${alert.karat} - ${alert.currency}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          alert.direction == 'above'
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: alert.direction == 'above'
                              ? Colors.green
                              : Colors.red,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${alert.direction == 'above' ? 'Above' : 'Below'} ${alert.targetPrice.toStringAsFixed(2)} ${alert.currency}/gram',
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: alert.isActive,
                onChanged: (value) => toggleAlert(alert),
                activeColor: color,
              ),
            ],
          ),
          if (alert.isTriggered) ...[
            HeightSpace(10),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Alert Triggered!',
                    style: TextStyle(color: Colors.green, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
          HeightSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created: ${formatDate(alert.createdAt)}',
                style: TextStyle(color: Colors.grey, fontSize: 11.sp),
              ),
              IconButton(
                onPressed: () => deleteAlert(alert),
                icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
