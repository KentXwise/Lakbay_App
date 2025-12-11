import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../core/app_colors.dart';
import '../widgets/logout_confirmation_modal.dart';
import '../widgets/edit_profile_modal.dart';
import 'login_screen.dart';
import 'memories_screen.dart';
import 'notif_screen.dart';
import 'contact_us_screen.dart';


class ProfileScreen extends StatefulWidget {
  final String? userNickname;


  const ProfileScreen({super.key, this.userNickname});


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  // Profile Data
  late String userName;
  late String userEmail;
  late String userPhone;
  late String userLocation;
  late String userBirthdate;
  late String userBio;
  File? _profileImage;


  @override
  void initState() {
    super.initState();
    // Initialize with default values
    userName = widget.userNickname ?? 'Google User';
    userEmail = 'user@gmail.com';
    userPhone = '+63 917 123 4567';
    userLocation = 'Panabo, Philippines';
    userBirthdate = 'MM/DD/YYYY';
    userBio = 'Add a bio to let others know about you!';
  }


  void _showEditProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => EditProfileModal(
        initialData: {
          'name': userName,
          'email': userEmail,
          'phone': userPhone,
          'location': userLocation,
          'birthdate': userBirthdate,
          'bio': userBio,
        },
        onSave: (Map<String, String> updatedData) {
          setState(() {
            userName = updatedData['name'] ?? userName;
            userEmail = updatedData['email'] ?? userEmail;
            userPhone = updatedData['phone'] ?? userPhone;
            userLocation = updatedData['location'] ?? userLocation;
            userBirthdate = updatedData['birthdate'] ?? userBirthdate;
            userBio = updatedData['bio'] ?? userBio;
          });
        },
        onProfileImageChanged: (File? image) {
          setState(() {
            _profileImage = image;
          });
        },
      ),
    );
  }


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


  Future<void> _handleLogout(BuildContext context) async {
    try {
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Profile Info
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
                    onTap: () {
                      // Navigate back to home_screen.dart instead of pop
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            userNickname: widget.userNickname ?? 'User',
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
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
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(Icons.person,
                                  size: 28.sp, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(Icons.mail,
                                      size: 16.sp, color: Colors.white70),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      userEmail,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


            // Settings List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                children: [
                  // Profile Details Section
                  Text(
                    'Your Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 12.h),


                  // Profile Details Card
                  Container(
                    padding: EdgeInsets.all(16.w),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Phone', userPhone, Icons.phone),
                        Divider(height: 16.h, color: Colors.grey.shade200),
                        _buildDetailRow(
                            'Location', userLocation, Icons.location_on),
                        Divider(height: 16.h, color: Colors.grey.shade200),
                        _buildDetailRow('Birthdate', userBirthdate, Icons.cake),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),


                  // Bio Section
                  Text(
                    'Bio',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      userBio,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.blue.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),


                  // Account Settings Section
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
                    onTap: () => _showEditProfileModal(context),
                  ),
                //  _buildSettingCard(
                //   icon: Icons.lock_outline,
                //    title: 'Privacy & Security',
                //    subtitle: 'Manage your privacy settings',
                //    onTap: () {
                      // TODO: Navigate to privacy settings
                //    },
                //  ),
                  _buildSettingCard(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Configure notification preferences',
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),
                  SizedBox(height: 24.h),


                  // Support Section
                  Text(
                    'Support',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                //  SizedBox(height: 12.h),
                //  _buildSettingCard(
                //    icon: Icons.help_outline,
                //    title: 'Help Center',
                //    subtitle: 'Get support and find answers',
                //    onTap: () {
                      // TODO: Navigate to help center
                //    },
                //  ),
                  _buildSettingCard(
                    icon: Icons.email_outlined,
                    title: 'Contact Us',
                    subtitle: 'support@lakbay.app',
                    onTap: () {
                      // TODO: Navigate to contact us
                    },
                  ),
                  SizedBox(height: 24.h),


                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmation(context),
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


                  // Version Info
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


  // Helper widget to display profile details
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.brownPrimary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
        onTap: onTap,
      ),
    );
  }
}
