import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../widgets/custom_textfield.dart';
import 'signup_screen.dart';
import '../widgets/forgot_password_modal.dart';
import 'memories_screen.dart';
import '../widgets/success_modal.dart';
import '../widgets/failure_modal.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String? userNickname;

  const LoginScreen({super.key, this.userNickname});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _showPassword = false;
  bool _isLoading = false;

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

  Future<void> _handleLogin() async {
    String userEmail = emailController.text.trim();
    String password = passwordController.text.trim();

    if (userEmail.isEmpty) {
      _showError('Email Required', 'Please enter your email address to sign in.');
      return;
    }

    if (password.isEmpty) {
      _showError('Password Required', 'Please enter your password to continue.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(userEmail, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessModal(
          title: 'Welcome Back!',
          message: 'You have successfully signed in.',
          buttonText: "Let's Go",
          onConfirm: () {
            String nickname = widget.userNickname ?? userEmail.split('@')[0];
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(userNickname: nickname),
              ),
              (route) => false,
            );
          },
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      
      String title = 'Login Failed';
      String message = 'An unknown error occurred.';

      if (e.code == 'user-not-found') {
        title = 'User Not Found';
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        title = 'Wrong Credentials';
        message = 'Invalid email or password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      }

      _showError(title, message);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error', e.toString());
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => FailureModal(
        title: title,
        message: message,
        onConfirm: () {},
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
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownPrimary,
                          minimumSize: Size(double.infinity, 60.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: _isLoading 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
<<<<<<< Updated upstream
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
                      
=======
                      // Removed Google Sign In buttons here
>>>>>>> Stashed changes
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