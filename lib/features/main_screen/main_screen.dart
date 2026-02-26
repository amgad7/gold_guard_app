import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gold_caurd_app/core/styling/app_colors.dart';

import '../gold_chart_screen/views/gold_chart_screen.dart';
import '../home/views/home_screen.dart';
import '../alerts/views/alerts_screen.dart';
import '../profile/profile_screen.dart';
import '../calculator/gold_calculator_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const GoldChartScreen(),
    const GoldCalculatorScreen(),
    const AlertsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: AppColors.secondaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.secondaryColor.withValues(alpha: 0.5),
          currentIndex: currentIndex,
          elevation: 0,
          selectedFontSize: 11.sp,
          unselectedFontSize: 9.sp,
          iconSize: 24.sp,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Icon(
                  currentIndex == 0 ? Icons.home : Icons.home_outlined,
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Icon(
                  currentIndex == 1
                      ? Icons.show_chart
                      : Icons.show_chart_outlined,
                ),
              ),
              label: "Chart",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Icon(
                  currentIndex == 2
                      ? Icons.calculate
                      : Icons.calculate_outlined,
                ),
              ),
              label: "Calculator",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Icon(
                  currentIndex == 3
                      ? Icons.notifications_active
                      : Icons.notifications_outlined,
                ),
              ),
              label: "Alerts",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: Icon(
                  currentIndex == 4 ? Icons.person : Icons.person_outline,
                ),
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
