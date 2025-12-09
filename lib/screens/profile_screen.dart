import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../widgets/logout_confirmation_modal.dart';
import 'login_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ✅ NEW METHOD: Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LogoutConfirmationModal(
        onConfirm: () => _handleLogout(context),
        onCancel: () {
          print('Logout cancelled');
        },
      ),
    );
  }

  // ✅ NEW METHOD: Handle logout logic
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Clear user session here (Firebase, SharedPreferences, etc.)
      // Example:
      // await FirebaseAuth.instance.signOut();
      // await SharedPreferences.getInstance().then((prefs) => prefs.clear());

      if (context.mounted) {
        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: AppColors.brownPrimary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Colors.amber.shade300,
                          child: Icon(Icons.person,
                              size: 28.sp, color: Colors.white),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google User',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.mail,
                                    size: 16.sp, color: Colors.white70),
                                SizedBox(width: 6.w),
                                Text(
                                  'user@gmail.com',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                children: [
                  Text(
                    'Account Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildSettingCard(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                  ),
                  _buildSettingCard(
                    icon: Icons.lock_outline,
                    title: 'Privacy & Security',
                    subtitle: 'Manage your privacy settings',
                  ),
                  _buildSettingCard(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Configure notification preferences',
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Support',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildSettingCard(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get support and find answers',
                  ),
                  _buildSettingCard(
                    icon: Icons.email_outlined,
                    title: 'Contact Us',
                    subtitle: 'support@lakbay.app',
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmation(context), // ✅ CHANGED
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brownPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Text(
                      'Lakbay v1.0.0 • Made with ❤ by the Student of DNSC BSIT 3A',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.brown.shade50,
          child: Icon(icon, color: AppColors.brownPrimary),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        onTap: () {
          // TODO: navigate to specific setting page
        },
      ),
    );
  }
}
