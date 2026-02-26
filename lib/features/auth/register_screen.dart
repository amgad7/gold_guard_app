import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_caurd_app/core/styling/app_colors.dart';
import 'package:gold_caurd_app/core/widgets/custom_text_field.dart';
import 'package:gold_caurd_app/core/widgets/spacing_widgets.dart';
import 'package:gold_caurd_app/firebase/firebase_function.dart';
import '../../core/routing/app_routes.dart';
import '../../core/widgets/primay_button_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                  HeightSpace(8),
                  Text(
                    "Create Your Account",
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  HeightSpace(40),

                  CustomTextField(
                    controller: nameController,
                    hintText: "Full Name",
                    width: double.infinity,
                    height: 74.h,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
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
                    controller: emailController,
                    hintText: "Email Address",
                    width: double.infinity,
                    height: 74.h,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Icon(
                        Icons.email_outlined,
                        size: 24.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  HeightSpace(20),
                  CustomTextField(
                    controller: phoneController,
                    hintText: "Phone Number",
                    width: double.infinity,
                    height: 74.h,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length < 11) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Icon(
                        Icons.phone_outlined,
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
                  HeightSpace(20),
                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    width: double.infinity,
                    height: 74.h,
                    isPassword: !isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
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
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  HeightSpace(40),
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffD4AF37),
                          ),
                        )
                      : PrimayButtonWidget(
                          buttonText: "Register",
                          onPress: () {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              FirebaseFunction.createUserAccount(
                                email: emailController.text,
                                password: passwordController.text,
                                userName: nameController.text,
                                phone: phoneController.text,
                                onSuccess: () {
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
                  HeightSpace(30),
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
                  HeightSpace(25),
                  InkWell(
                    onTap: () {
                      GoRouter.of(context).pop();
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Login Now",
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
