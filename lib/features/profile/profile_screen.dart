import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_caurd_app/core/styling/app_colors.dart';

import '../../core/routing/app_routes.dart';
import '../notification/fcm_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userName = '';
  String email = '';
  String phone = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          userName = data['userName'] ?? '';
          email = data['email'] ?? user.email ?? '';
          phone = data['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          email = user.email ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 28.sp),
            SizedBox(width: 10.w),
            Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.secondaryColor, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await BackgroundPriceChecker.cancelAll();
      await _auth.signOut();
      if (mounted) {
        context.go(AppRoutes.loginScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section with gradient
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20.h,
                      bottom: 30.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryColor.withValues(alpha: 0.15),
                          Colors.black,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryColor.withValues(alpha: 0.3),
                                AppColors.secondaryColor.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : email.isNotEmpty
                                  ? email[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // Name
                        Text(
                          userName.isNotEmpty ? userName : 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          email,
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Account Info Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          'Account Info',
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Info container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.secondaryColor.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.phone_outlined,
                                'Phone',
                                phone.isNotEmpty ? phone : 'Not set',
                              ),
                              Divider(
                                color: AppColors.secondaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                height: 1,
                              ),
                              _buildInfoRow(
                                Icons.verified_outlined,
                                'Email Status',
                                _auth.currentUser?.emailVerified == true
                                    ? 'Verified ✓'
                                    : 'Not Verified',
                                valueColor:
                                    _auth.currentUser?.emailVerified == true
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // Settings Section
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.secondaryColor.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildActionRow(
                                Icons.notifications_outlined,
                                'Notification Settings',
                                onTap: () {
                                  // Future: notification settings
                                },
                              ),
                              Divider(
                                color: AppColors.secondaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                height: 1,
                              ),
                              _buildActionRow(
                                Icons.info_outline,
                                'About App',
                                onTap: () {
                                  showAboutDialog(
                                    context: context,
                                    applicationName: 'Gold Guard',
                                    applicationVersion: '1.0.0',
                                    children: [
                                      const Text(
                                        'Your trusted gold price tracker and alert system.',
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30.h),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, size: 20),
                            label: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.15,
                              ),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                side: BorderSide(
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20.sp),
          SizedBox(width: 14.w),
          Text(
            label,
            style: TextStyle(color: AppColors.secondaryColor, fontSize: 14.sp),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20.sp),
            SizedBox(width: 14.w),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColors.secondaryColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
