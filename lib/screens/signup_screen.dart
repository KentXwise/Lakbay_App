// ============================================
// UPDATED SIGNUP_SCREEN.DART - CAPTURE NICKNAME
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/success_modal.dart';
import 'login_screen.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen> {
  // ✅ NEW: TextEditingControllers for form inputs
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F5F5),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // ✅ NEW: Dispose controllers
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ NEW METHOD: Validate and create account
  void _handleSignUp() {
    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your nickname')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Show success modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessModal(
        title: 'Account Created!',
        message: 'Welcome $nickname! Your account has been successfully created.',
        buttonText: 'Continue to Login',
        onConfirm: () {
          // ✅ Navigate to LoginScreen and pass nickname
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(userNickname: nickname),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 40.h, bottom: 20.h),
              child: SvgPicture.asset('assets/images/Lakbay_Logo.svg',
                  height: 90.h, color: Colors.white.withOpacity(0.9)),
            ),
            Text('Create Account',
                style: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('Start your travel adventure today',
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white70)),

            SizedBox(height: 30.h),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                padding: EdgeInsets.all(30.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextField(
                        hintText: 'Nickname',
                        icon: Icons.person_outline,
                        controller: nicknameController, // ✅ ADDED
                      ),
                      CustomTextField(
                        hintText: 'Your@email.com',
                        icon: Icons.email_outlined,
                        controller: emailController, // ✅ ADDED
                      ),
                      CustomTextField(
                        hintText: 'Create a strong password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: passwordController, // ✅ ADDED
                      ),
                      CustomTextField(
                        hintText: 'Re-enter your password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: confirmPasswordController, // ✅ ADDED
                      ),

                      SizedBox(height: 30.h),
                      ElevatedButton(
                        onPressed: _handleSignUp, // ✅ CHANGED
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownPrimary,
                          minimumSize: Size(double.infinity, 60.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r)),
                        ),
                        child: Text('Create Account',
                            style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),

                      SizedBox(height: 30.h),
                      Text('Or sign up with',
                          style: GoogleFonts.poppins(color: AppColors.textGray)),

                      SizedBox(height: 20.h),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: SvgPicture.asset('assets/icons/google.svg',
                            height: 24.h),
                        label: Text('Continue with Google',
                            style: GoogleFonts.poppins(
                                fontSize: 16.sp, color: Colors.black87)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 60.h),
                          side: BorderSide(color: Colors.brown.shade200),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r)),
                        ),
                      ),

                      SizedBox(height: 30.h),
                      Text(
                        'By signing up, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 12.sp, color: AppColors.textGray),
                      ),

                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                              style: GoogleFonts.poppins(color: Colors.black87)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text('Sign In',
                                style: GoogleFonts.poppins(
                                    color: AppColors.brownPrimary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
