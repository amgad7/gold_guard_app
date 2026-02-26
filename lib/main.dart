import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routing/router_generation_config.dart';
import 'core/styling/theme_data.dart';
import 'features/notification/background_notification_service.dart';
import 'features/notification/fcm_services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize local notifications
  await BackgroundNotificationService.initialize();
  await BackgroundNotificationService.requestPermission();

  // Initialize background price checker (task registration happens after login)
  await BackgroundPriceChecker.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: RouterGenerationConfig.goRouter,
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
        );
      },
    );
  }
}
