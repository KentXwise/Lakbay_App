import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/custom_textfield.dart';
import 'signup_screen.dart';
import '../widgets/forgot_password_modal.dart';
import 'memories_screen.dart';
import '../widgets/success_modal.dart';
import '../widgets/failure_modal.dart';

class LoginScreen extends StatefulWidget {
  final String? userNickname;

  const LoginScreen({super.key, this.userNickname});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    String userEmail = emailController.text.trim();

    if (userEmail.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Email Required',
          message: 'Please enter your email address to sign in.',
          onConfirm: () {},
        ),
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => FailureModal(
          title: 'Password Required',
          message: 'Please enter your password to continue.',
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
        title: 'Welcome Back!',
        message: 'You have successfully signed in. Let\'s plan your next adventure!',
        buttonText: 'Let\'s Go',
        onConfirm: () {
          String nickname = widget.userNickname ?? 'Traveler';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userNickname: nickname),
            ),
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
              padding: EdgeInsets.only(top: 60.h, bottom: 40.h),
              child: Column(
                children: [
                  SvgPicture.asset('assets/images/Lakbay_Logo.svg', height: 80.h),
                  SizedBox(height: 20.h),
                  Text(
                    'Lakbay',
                    style: GoogleFonts.poppins(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Plan your journey together',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Sign in to continue your travel planning',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppColors.textGray,
                        ),
                      ),
                      SizedBox(height: 30.h),
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
                          hintText: 'Enter your password',
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const ForgotPasswordModal(),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.poppins(
                              color: AppColors.brownPrimary,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownPrimary,
                          minimumSize: Size(double.infinity, 60.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    /*  SizedBox(height: 30.h),
                      Text(
                        'Or continue with',
                        style:
                            GoogleFonts.poppins(color: AppColors.textGray),
                      ),
                      SizedBox(height: 20.h),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Google Sign In
                        },
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
                      ), */
                      
                      SizedBox(height: 40.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
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