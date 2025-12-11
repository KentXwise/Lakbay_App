import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => ContactUsScreenState();
}

class ContactUsScreenState extends State<ContactUsScreen> {
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildEmailCard(),
                SizedBox(height: 16.h),
                _buildResponseTimeCard(),
                SizedBox(height: 24.h),
                _buildContactForm(),
                SizedBox(height: 24.h),
                _buildSupportHours(),
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
      Text('Contact Us',
        style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
      SizedBox(width: 40.w),
    ]),
  );

  Widget _buildEmailCard() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.brownPrimary, AppColors.brownPrimary.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [BoxShadow(color: AppColors.brownPrimary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.mail_outline, color: Colors.white, size: 20.sp),
        SizedBox(width: 8.w),
        Text('Email',
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
      ]),
      SizedBox(height: 12.h),
      Text('support@lakbay.app',
        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
    ]),
  );

  Widget _buildResponseTimeCard() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
    child: Row(children: [
      Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6D3),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.schedule, color: AppColors.brownPrimary, size: 24.sp),
      ),
      SizedBox(width: 16.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Response Time',
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.brownPrimary)),
        SizedBox(height: 4.h),
        Text('Within 24 hours',
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade600)),
      ]),
    ]),
  );

  Widget _buildContactForm() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    padding: EdgeInsets.all(20.w),
    child: Form(
      key: formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Send us a message',
          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.brownPrimary)),
        SizedBox(height: 20.h),
        _buildFormField('Your Email', emailController, 'Enter your email address', false),
        SizedBox(height: 16.h),
        _buildFormField('Subject', subjectController, 'What do you need help with?', false),
        SizedBox(height: 16.h),
        Text('Message',
          style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.brownPrimary)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: messageController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe your issue or question in detail...',
            hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF5E6D3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.brownPrimary, width: 1.5),
            ),
            contentPadding: EdgeInsets.all(14.w),
          ),
          validator: (value) => value!.isEmpty ? 'Please enter your message' : null,
        ),
        SizedBox(height: 20.h),
        _buildSendButton(),
      ]),
    ),
  );

  Widget _buildFormField(String label, TextEditingController controller, String hint, bool isEmail) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
        style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.brownPrimary)),
      SizedBox(height: 8.h),
      TextFormField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
          filled: true,
          fillColor: const Color(0xFFF5E6D3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.brownPrimary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
        validator: (value) {
          if (value!.isEmpty) return 'This field is required';
          if (isEmail && !value.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
    ]);

  Widget _buildSendButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _sendMessage,
      icon: Icon(Icons.send, size: 18.sp),
      label: Text('Send Message',
        style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brownPrimary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 4,
      ),
    ),
  );

  Widget _buildSupportHours() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.grey.shade200, width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    padding: EdgeInsets.all(20.w),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Support Hours',
        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.brownPrimary)),
      SizedBox(height: 16.h),
      _buildHourRow('Monday - Friday', '9:00 AM - 6:00 PM'),
      SizedBox(height: 12.h),
      _buildHourRow('Saturday', '10:00 AM - 4:00 PM'),
      SizedBox(height: 12.h),
      _buildHourRow('Sunday', 'Closed', isClosedDay: true),
    ]),
  );

  Widget _buildHourRow(String day, String hours, {bool isClosedDay = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(day,
        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.brownPrimary)),
      Text(hours,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: isClosedDay ? Colors.grey.shade500 : Colors.grey.shade600,
        )),
    ],
  );

  void _sendMessage() {
    if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent successfully!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        emailController.clear();
        subjectController.clear();
        messageController.clear();
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }
}
