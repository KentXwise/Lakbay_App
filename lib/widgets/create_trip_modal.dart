import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/app_colors.dart';
import '../models/trip_model.dart';

class CreateTripModal extends StatefulWidget {
  final Function(Trip) onSave;

  const CreateTripModal({super.key, required this.onSave});

  @override
  State<CreateTripModal> createState() => _CreateTripModalState();
}

class _CreateTripModalState extends State<CreateTripModal> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController();
  final TextEditingController arrivalTimeController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedDepartureTime;
  TimeOfDay? _selectedArrivalTime;
  XFile? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    destinationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    budgetController.dispose();
    departureTimeController.dispose();
    arrivalTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        startDateController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedStartDate!.add(const Duration(days: 1)),
      firstDate: _selectedStartDate!,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
        endDateController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  Future<void> _selectDepartureTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDepartureTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDepartureTime = picked;
        departureTimeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectArrivalTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedArrivalTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedArrivalTime = picked;
        arrivalTimeController.text = picked.format(context);
      });
    }
  }

  void _clearDepartureTime() {
    setState(() {
      _selectedDepartureTime = null;
      departureTimeController.clear();
    });
  }

  void _clearArrivalTime() {
    setState(() {
      _selectedArrivalTime = null;
      arrivalTimeController.clear();
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  void _showImageOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo_library, color: AppColors.brownPrimary, size: 28.sp),
                      SizedBox(width: 16.w),
                      Text(
                        'Choose from Gallery',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: AppColors.brownPrimary, size: 28.sp),
                      SizedBox(width: 16.w),
                      Text(
                        'Take a Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createTrip() {
    if (titleController.text.isEmpty ||
        destinationController.text.isEmpty ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty ||
        budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ End date must be the same or after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Trip newTrip = Trip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text,
        destination: destinationController.text,
        startDate: startDateController.text,
        endDate: endDateController.text,
        budget: int.parse(budgetController.text),
        image: _selectedImage?.path ?? 'assets/images/default_trip.png',
        members: [],
        activitiesList: [],
        expensesList: [],
        tasksList: [],
        departureTime: departureTimeController.text.isNotEmpty ? departureTimeController.text : null,
        arrivalTime: arrivalTimeController.text.isNotEmpty ? arrivalTimeController.text : null,
      );

      widget.onSave(newTrip);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating trip: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImagePath = _selectedImage?.path;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.brownPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plan New Trip',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Image
                    Text(
                      'Trip Image',
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: _showImageOptionsBottomSheet,
                      child: Container(
                        width: double.infinity,
                        height: 180.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: currentImagePath != null ? AppColors.brownPrimary : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: currentImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(File(currentImagePath), fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 48.sp, color: AppColors.brownPrimary),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Tap to add image',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: AppColors.brownPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Trip Title
                    Text('Trip Title', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Summer Adventure',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Destination
                    Text('Destination', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: destinationController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Cebu, Philippines',
                        prefixIcon: Icon(Icons.location_on, color: AppColors.brownPrimary),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                              SizedBox(height: 10.h),
                              TextField(
                                controller: startDateController,
                                readOnly: true,
                                onTap: _selectStartDate,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.brownPrimary),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Date', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                              SizedBox(height: 10.h),
                              TextField(
                                controller: endDateController,
                                readOnly: true,
                                onTap: _selectEndDate,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.brownPrimary),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Departure & Arrival Times
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Departure Time', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                              SizedBox(height: 10.h),
                              TextField(
                                controller: departureTimeController,
                                readOnly: true,
                                onTap: _selectDepartureTime,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.access_time, color: AppColors.brownPrimary),
                                  suffixIcon: departureTimeController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: _clearDepartureTime,
                                          child: Icon(Icons.close, color: Colors.red, size: 18.sp),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Arrival Time', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                              SizedBox(height: 10.h),
                              TextField(
                                controller: arrivalTimeController,
                                readOnly: true,
                                onTap: _selectArrivalTime,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.access_time, color: AppColors.brownPrimary),
                                  suffixIcon: arrivalTimeController.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: _clearArrivalTime,
                                          child: Icon(Icons.close, color: Colors.red, size: 18.sp),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Budget
                    Text('Initial Budget (₱)', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '10000',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12.w, right: 8.w),
                          child: Text('₱', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.brownPrimary)),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 40.w),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownPrimary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'Start Adventure',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
