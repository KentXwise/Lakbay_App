import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});

  @override
  State<NotifScreen> createState() => NotifScreenState();
}

class NotifScreenState extends State<NotifScreen> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Notification Channels',
                  style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.brownPrimary)),
                SizedBox(height: 24.h),
                _buildNotificationOption(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts on your device',
                  value: pushNotifications,
                  onChanged: (val) => setState(() => pushNotifications = val),
                ),
                SizedBox(height: 20.h),
                _buildNotificationOption(
                  icon: Icons.mail_outline,
                  title: 'Email Notifications',
                  subtitle: 'Get updates via email',
                  value: emailNotifications,
                  onChanged: (val) => setState(() => emailNotifications = val),
                ),
                SizedBox(height: 20.h),
                _buildNotificationOption(
                  icon: Icons.sms_outlined,
                  title: 'SMS Notifications',
                  subtitle: 'Receive text messages',
                  value: smsNotifications,
                  onChanged: (val) => setState(() => smsNotifications = val),
                ),
                SizedBox(height: 48.h),
                _buildSaveButton(),
                SizedBox(height: 20.h),
              ]),
            ),
          ),
        ),
      ]),
    ),
  );

  Widget _buildHeader() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.brownPrimary,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24.r),
        bottomRight: Radius.circular(24.r),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(Icons.close, color: Colors.white, size: 24.sp),
        ),
      ),
      Text('Notifications',
        style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
      SizedBox(width: 40.w),
    ]),
  );

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Row(children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6D3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.brownPrimary, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.brownPrimary)),
              SizedBox(height: 6.h),
              Text(subtitle,
                style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
      SizedBox(width: 12.w),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.brownPrimary,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    ]),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _savePreferences,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownPrimary,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        elevation: 4,
      ),
      child: Text('Save Preferences',
        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
    ),
  );

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preferences saved!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
  }
}
