import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_caurd_app/core/styling/app_colors.dart';
import 'package:gold_caurd_app/core/widgets/custom_text_field.dart';
import 'package:gold_caurd_app/core/widgets/spacing_widgets.dart';
import 'package:gold_caurd_app/firebase/firebase_function.dart';

import '../../core/routing/app_routes.dart';
import '../../core/widgets/primay_button_widget.dart';
import '../notification/fcm_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: emailController.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_reset,
                color: AppColors.primaryColor,
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Reset Password',
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: resetEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty) return;

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset link sent to $email'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HeightSpace(80),

                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.security,
                      size: 50.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  HeightSpace(30),

                  Text(
                    "GOLD GUARD",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 38.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  HeightSpace(10),
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  HeightSpace(50),

                  CustomTextField(
                    controller: emailController,
                    hintText: "Email or Phone Number",
                    width: double.infinity,
                    height: 74.h,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or phone';
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Icon(
                        Icons.person_outline,
                        size: 24.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  HeightSpace(20),

                  CustomTextField(
                    controller: passwordController,
                    hintText: "Password",
                    width: double.infinity,
                    height: 74.h,
                    isPassword: !isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Icon(
                        Icons.lock_outline,
                        size: 24.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  HeightSpace(15),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  HeightSpace(30),
                  // Login Button
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffD4AF37),
                          ),
                        )
                      : PrimayButtonWidget(
                          buttonText: "Login",
                          onPress: () {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              FirebaseFunction.login(
                                email: emailController.text,
                                password: passwordController.text,
                                onSuccess: () async {
                                  // Register background task with userId
                                  await BackgroundPriceChecker.registerPeriodicTask();
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                    context.go(AppRoutes.mainScreen);
                                  }
                                },
                                onError: (error) {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: Text(error),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                  HeightSpace(40),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.secondaryColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.secondaryColor.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  HeightSpace(30),

                  InkWell(
                    onTap: () {
                      GoRouter.of(context).pushNamed(AppRoutes.registerScreen);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Register Now",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  HeightSpace(30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
