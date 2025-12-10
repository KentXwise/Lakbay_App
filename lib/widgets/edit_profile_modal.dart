// ============================================
// UPDATED EDIT_PROFILE_MODAL.DART - WITH DATA RETURN
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/app_colors.dart';

class EditProfileModal extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Function(File?) onProfileImageChanged;
  final Map<String, String> initialData;

  const EditProfileModal({
    super.key,
    required this.onSave,
    required this.onProfileImageChanged,
    required this.initialData,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  late TextEditingController birthdateController;
  late TextEditingController bioController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  late File? _profileImage;
  late final ImagePicker _imagePicker;
  late bool _showCurrentPassword;
  late bool _showNewPassword;
  late bool _showConfirmPassword;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    fullNameController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );
    emailController = TextEditingController(
      text: widget.initialData['email'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.initialData['phone'] ?? '',
    );
    locationController = TextEditingController(
      text: widget.initialData['location'] ?? '',
    );
    birthdateController = TextEditingController(
      text: widget.initialData['birthdate'] ?? '',
    );
    bioController = TextEditingController(
      text: widget.initialData['bio'] ?? '',
    );
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    _profileImage = null;
    _imagePicker = ImagePicker();
    _showCurrentPassword = false;
    _showNewPassword = false;
    _showConfirmPassword = false;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    birthdateController.dispose();
    bioController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        widget.onProfileImageChanged(_profileImage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _handleSave() {
    if (fullNameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Create a map with updated data
    Map<String, String> updatedData = {
      'name': fullNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'location': locationController.text,
      'birthdate': birthdateController.text,
      'bio': bioController.text,
    };

    Navigator.pop(context);
    widget.onSave(updatedData); // Pass data back

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: AppColors.brownPrimary,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: AppColors.brownPrimary,
                width: 1.5,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.brownPrimary,
                  size: 18.sp,
                ),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.brownPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _handleSave,
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.brownPrimary.withOpacity(0.2),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.amber.shade100,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50.sp,
                                      color: Colors.amber.shade800,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.brownPrimary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Personal Information Section
                    Text(
                      'Personal Information',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _buildFormField(
                      label: 'Full Name',
                      controller: fullNameController,
                      hintText: 'e.g., John Doe',
                    ),
                    SizedBox(height: 14.h),
                    _buildFormField(
                      label: 'Email Address',
                      controller: emailController,
                      hintText: 'e.g., john@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 14.h),
                    _buildFormField(
                      label: 'Phone Number',
                      controller: phoneController,
                      hintText: 'e.g., +63 917 123 4567',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 14.h),
                    _buildFormField(
                      label: 'Location',
                      controller: locationController,
                      hintText: 'e.g., Panabo, Philippines',
                    ),
                    SizedBox(height: 14.h),
                    _buildFormField(
                      label: 'Birthdate',
                      controller: birthdateController,
                      hintText: 'Select your birthdate',
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          birthdateController.text =
                              '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                        }
                      },
                    ),
                    SizedBox(height: 14.h),
                    _buildFormField(
                      label: 'Bio',
                      controller: bioController,
                      hintText: 'Tell us about yourself...',
                      maxLines: 4,
                      maxLength: 150,
                    ),
                    SizedBox(height: 28.h),

                    // Security Section
                    Text(
                      'Security',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18.sp,
                            color: Colors.amber.shade700,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Leave fields empty to keep current password',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _buildPasswordField(
                      label: 'Current Password',
                      controller: currentPasswordController,
                      hintText: 'Enter your current password',
                      showPassword: _showCurrentPassword,
                      onToggle: () {
                        setState(() {
                          _showCurrentPassword = !_showCurrentPassword;
                        });
                      },
                    ),
                    SizedBox(height: 14.h),
                    _buildPasswordField(
                      label: 'New Password',
                      controller: newPasswordController,
                      hintText: 'Enter your new password',
                      showPassword: _showNewPassword,
                      onToggle: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                    ),
                    SizedBox(height: 14.h),
                    _buildPasswordField(
                      label: 'Confirm New Password',
                      controller: confirmPasswordController,
                      hintText: 'Confirm your new password',
                      showPassword: _showConfirmPassword,
                      onToggle: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
