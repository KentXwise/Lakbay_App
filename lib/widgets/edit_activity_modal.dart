import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/activity_model.dart';

class EditActivityModal extends StatefulWidget {
  final Activity? activity;
  final Function(Activity) onSave;
  final String tripId;
  final int existingActivitiesCount;
  final List<String>? availableDays;
  final List<Activity>? existingActivities;
  final String? tripStartDate;
  final String? tripEndDate;

  const EditActivityModal({
    super.key,
    this.activity,
    required this.onSave,
    required this.tripId,
    this.existingActivitiesCount = 0,
    this.availableDays,
    this.existingActivities,
    this.tripStartDate,
    this.tripEndDate,
  });

  @override
  State<EditActivityModal> createState() => _EditActivityModalState();
}

class _EditActivityModalState extends State<EditActivityModal> {
  late TextEditingController nameController;
  late TextEditingController timeController;
  late TextEditingController locationController;
  late TextEditingController costController;

  late String selectedPeriod;
  late String selectedDay;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.activity?.name ?? '');
    timeController = TextEditingController(text: widget.activity?.time ?? '');
    locationController =
        TextEditingController(text: widget.activity?.location ?? '');
    costController =
        TextEditingController(text: widget.activity?.cost.toString() ?? '');

    if (widget.activity != null) {
      selectedDay = widget.activity?.day ?? 'Day 1';
      String timeText = widget.activity?.time ?? '';
      selectedPeriod =
          (timeText.contains('PM') || timeText.contains('pm')) ? 'PM' : 'AM';
    } else {
      selectedDay = 'Day 1';
      selectedPeriod = 'AM';
    }

    selectedDate = null;
  }

  @override
  void dispose() {
    nameController.dispose();
    timeController.dispose();
    locationController.dispose();
    costController.dispose();
    super.dispose();
  }

  List<MapEntry<String, DateTime>> _generateDateRangeOptions() {
    List<MapEntry<String, DateTime>> dateOptions = [];
    try {
      if (widget.tripStartDate == null || widget.tripEndDate == null) {
        return dateOptions;
      }

      final startParts = widget.tripStartDate!.split('/');
      final endParts = widget.tripEndDate!.split('/');

      final startDate = DateTime(
        int.parse(startParts[2]),
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      final endDate = DateTime(
        int.parse(endParts[2]),
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      DateTime current = startDate;
      int dayNumber = 1;

      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        String displayText =
            'Day $dayNumber • ${current.month}/${current.day}/${current.year}';
        dateOptions.add(MapEntry(displayText, current));
        current = current.add(const Duration(days: 1));
        dayNumber++;
      }
    } catch (e) {
      debugPrint('Error generating date range: $e');
    }
    return dateOptions;
  }

  Future<void> _selectDate() async {
    try {
      if (widget.tripStartDate == null || widget.tripEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip dates not set')),
        );
        return;
      }

      final startParts = widget.tripStartDate!.split('/');
      final endParts = widget.tripEndDate!.split('/');

      final startDate = DateTime(
        int.parse(startParts[2]),
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      final endDate = DateTime(
        int.parse(endParts[2]),
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? startDate,
        firstDate: startDate,
        lastDate: endDate,
      );

      if (picked != null) {
        setState(() {
          selectedDate = picked;
          final difference = picked.difference(startDate).inDays;
          int dayNumber = difference + 1;
          selectedDay = 'Day $dayNumber';
        });
      }
    } catch (e) {
      debugPrint('Error selecting date: $e');
    }
  }

  bool _isTimeConflict(String day, String time, String period) {
    if (widget.existingActivities == null) return false;

    String fullTime = '$time $period';

    for (var activity in widget.existingActivities!) {
      if (widget.activity != null && activity.id == widget.activity!.id) {
        continue;
      }

      if (activity.day == day && activity.time == fullTime) {
        return true;
      }
    }
    return false;
  }

  void _saveActivity() {
    if (nameController.text.isEmpty ||
        timeController.text.isEmpty ||
        locationController.text.isEmpty ||
        costController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_isTimeConflict(selectedDay, timeController.text, selectedPeriod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Time conflict! An activity already exists at '
            '$selectedDay ${timeController.text} $selectedPeriod',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final int cost = int.parse(costController.text);
      final String fullTime = '${timeController.text} $selectedPeriod';

      final activity = Activity(
        id: widget.activity?.id ?? DateTime.now().toString(),
        name: nameController.text,
        day: selectedDay,
        time: fullTime,
        location: locationController.text,
        cost: cost,
      );

      widget.onSave(activity);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid cost format')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.activity != null;

    List<String> daysList = widget.availableDays ?? [];
    if (daysList.isEmpty) {
      daysList = ['Day 1'];
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 0.85.sh,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
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
                      isEditMode ? 'Edit Activity' : 'Add Activity',
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

              // Form Content
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Selector (Calendar Button)
                    Text(
                      'Select Day',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate != null
                                  ? '$selectedDay • ${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                                  : 'Select date',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: selectedDate != null
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade400,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.brownPrimary,
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Activity Name
                    Text(
                      'Activity Name',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Island Hopping Tour',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.brownPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Time and Period Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: timeController,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  hintText: '00:00',
                                  hintStyle:
                                      GoogleFonts.poppins(color: Colors.grey.shade400),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.brownPrimary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Period',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButton(
                                  value: selectedPeriod,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.brownPrimary,
                                    ),
                                  ),
                                  items: ['AM', 'PM'].map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 16.w),
                                        child: Text(
                                          value,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedPeriod = newValue ?? 'AM';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Location
                    Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        hintText: 'Mactan Island',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.brownPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Cost
                    Text(
                      'Cost (₱)',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '2500',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.brownPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brownPrimary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          isEditMode ? 'Update Activity' : 'Add Activity',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
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
