import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/success_modal.dart';
import '../widgets/failure_modal.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
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
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (nickname.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Nickname Required',
          message: 'Please choose a nickname to personalize your account.',
          onConfirm: () {},
        ),
      );
      return;
    }

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Email Required',
          message: 'Please enter a valid email address to create your account.',
          onConfirm: () {},
        ),
      );
      return;
    }

    if (password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Password Required',
          message: 'Please create a secure password for your account.',
          onConfirm: () {},
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Password Mismatch',
          message: 'The passwords you entered do not match. Please try again.',
          onConfirm: () {},
        ),
      );
      return;
    }

    if (password.length < 6) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Weak Password',
          message: 'For your security, your password must be at least 6 characters long.',
          onConfirm: () {},
        ),
      );
      return;
    }

    // Success Simulation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessModal(
        title: 'Account Created!',
        message: 'Welcome to Lakbay, $nickname! Your account is ready. Let\'s get started.',
        buttonText: 'Continue to Login',
        onConfirm: () {
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
            Text(
              'Create Account',
              style: GoogleFonts.poppins(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Start your travel adventure today',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
            ),
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
                        controller: nicknameController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        hintText: 'Your@email.com',
                        icon: Icons.email_outlined,
                        controller: emailController,
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.textGray,
                          ),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppColors.brownPrimary),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.brownPrimary,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Re-enter your password',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: AppColors.textGray,
                          ),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppColors.brownPrimary),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showConfirmPassword =
                                    !_showConfirmPassword;
                              });
                            },
                            child: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.brownPrimary,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownPrimary,
                          minimumSize: Size(double.infinity, 60.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        'Or sign up with',
                        style:
                            GoogleFonts.poppins(color: AppColors.textGray),
                      ),
                      SizedBox(height: 20.h),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: SvgPicture.asset('assets/icons/google.svg',
                            height: 24.h),
                        label: Text(
                          'Continue with Google',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 60.h),
                          side: BorderSide(color: Colors.brown.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        'By signing up, you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppColors.textGray,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                color: AppColors.brownPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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