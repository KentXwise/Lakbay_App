import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../core/app_colors.dart';
import '../models/trip_model.dart';
import '../models/activity_model.dart';
import '../widgets/edit_trip_modal.dart';
import '../widgets/edit_activity_modal.dart';
import '../screens/budget_screen.dart';
import '../screens/members_screen.dart';
import '../models/member_model.dart';
import '../screens/tasks_screen.dart';
import '../models/task_model.dart';
import '../screens/trip_receipt_screen.dart';
import '../services/database_service.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late String selectedTab;
  late List<Activity> activities;
  late Trip currentTrip;
  late DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    selectedTab = 'Itinerary';
    currentTrip = widget.trip;
    // Map dynamic activities to strongly typed Activity objects
    activities = currentTrip.activities.map((e) => e as Activity).toList();
    
    // Initialize DB Service
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(user.uid);
    }
  }

  // Helper to save trip changes to Firestore
  void _saveTripChanges(Trip updatedTrip) async {
    setState(() {
      currentTrip = updatedTrip;
      // Sync local activities list
      activities = updatedTrip.activities.map((e) => e as Activity).toList();
    });
    await _dbService.updateTrip(updatedTrip);
  }

  void _showTripReceipt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripReceiptScreen(trip: currentTrip),
      ),
    );
  }

  int _calculateTripDays() {
    try {
      final startParts = currentTrip.startDate.split('/');
      final endParts = currentTrip.endDate.split('/');
      
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
      
      final difference = endDate.difference(startDate).inDays;
      return difference + 1;
    } catch (e) {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLocalImage = !currentTrip.image.startsWith('assets/');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200.h,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: isLocalImage
                      ? Image.file(
                          File(currentTrip.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Center(child: Icon(Icons.broken_image)),
                        )
                      : Image.asset(
                          currentTrip.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Icon(Icons.arrow_back,
                          color: Colors.white, size: 20.sp),
                    ),
                  ),
                ),
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: GestureDetector(
                    onTap: () => _editTripDetails(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Icon(Icons.settings,
                          color: Colors.white, size: 20.sp),
                    ),
                  ),
                ),
                Positioned(
                  top: 16.h,
                  right: 60.w,
                  child: GestureDetector(
                    onTap: () => _showTripReceipt(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Icon(Icons.receipt, color: Colors.white, size: 20.sp),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTrip.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16.sp, color: Colors.grey.shade600),
                      SizedBox(width: 6.w),
                      Text(
                        currentTrip.destination,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16.sp, color: Colors.grey.shade600),
                      SizedBox(width: 6.w),
                      Text(
                        '${currentTrip.startDate} - ${currentTrip.endDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (currentTrip.departureTime != null && currentTrip.departureTime!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          color: Colors.grey.shade600,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Depart: ${currentTrip.departureTime}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (currentTrip.arrivalTime != null && currentTrip.arrivalTime!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.flight_land,
                          color: Colors.grey.shade600,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Arrive: ${currentTrip.arrivalTime}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  _buildTab('Itinerary'),
                  _buildTab('Budget'),
                  _buildTab('Members'),
                  _buildTab('Task'),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: selectedTab == 'Itinerary'
                  ? _buildItineraryContent()
                  : selectedTab == 'Budget'
                      ? _buildBudgetContent()
                      : selectedTab == 'Members'
                          ? _buildMembersContent()
                          : _buildTaskContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String tabName) {
    bool isSelected = selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tabName),
        child: Column(
          children: [
            Text(
              tabName,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.brownPrimary : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            if (isSelected)
              Container(
                height: 3.h,
                color: AppColors.brownPrimary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView(
        children: [
          Text(
            'Daily Schedule',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          ..._buildActivitiesByDay(),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => _addActivity(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownPrimary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  'Add Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  List<Widget> _buildActivitiesByDay() {
    List<Widget> widgets = [];

    if (activities.isEmpty) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Center(
            child: Text(
              'No activities yet. Add one to get started!',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      );
    } else {
      final groupedByDay = <String, List<Activity>>{};
      for (var activity in activities) {
        if (!groupedByDay.containsKey(activity.day)) {
          groupedByDay[activity.day] = [];
        }
        groupedByDay[activity.day]!.add(activity);
      }

      final sortedDays = groupedByDay.keys.toList()
        ..sort((a, b) {
          final aNum = int.tryParse(a.replaceAll(RegExp(r'\D'), '')) ?? 0;
          final bNum = int.tryParse(b.replaceAll(RegExp(r'\D'), '')) ?? 0;
          return aNum.compareTo(bNum);
        });

      for (var day in sortedDays) {
        final dayActivities = groupedByDay[day]!;

        dayActivities.sort((a, b) {
          final timeA = _parseTime(a.time);
          final timeB = _parseTime(b.time);
          return timeA.compareTo(timeB);
        });

        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
            child: Text(
              day,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        );

        for (var activity in dayActivities) {
          widgets.add(_buildActivityCard(activity));
          widgets.add(SizedBox(height: 12.h));
        }
      }
    }

    return widgets;
  }

  int _parseTime(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1] : 'AM';

      final timeSplit = timePart.split(':');
      int hour = int.parse(timeSplit[0]);
      int minute = int.parse(timeSplit.length > 1 ? timeSplit[1] : '0');

      if (period == 'AM') {
        if (hour == 12) hour = 0;
      } else {
        if (hour != 12) hour += 12;
      }

      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildActivityCard(Activity activity) {
    return GestureDetector(
      onLongPress: () => _showActivityOptions(activity),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brownPrimary,
                  ),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.brownPrimary,
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        activity.time,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    activity.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12.sp, color: Colors.grey.shade600),
                      SizedBox(width: 4.w),
                      Text(
                        activity.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              '₱ ${activity.cost}',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.brownPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetContent() {
    return BudgetScreen(
      trip: currentTrip,
      onTripUpdated: _saveTripChanges,
    );
  }

  Widget _buildMembersContent() {
    return MembersScreen(
      trip: currentTrip,
      onTripUpdated: _saveTripChanges,
    );
  }

  Widget _buildTaskContent() {
    return TasksScreen(
      trip: currentTrip,
      onTripUpdated: _saveTripChanges,
    );
  }

  void _addActivity() {
    int tripDays = _calculateTripDays();
    
    List<String> daysList = [];
    for (int i = 1; i <= tripDays; i++) {
      daysList.add('Day $i');
    }
    
    showDialog(
      context: context,
      builder: (context) => EditActivityModal(
        activity: null,
        tripId: currentTrip.title,
        onSave: (Activity newActivity) {
          setState(() {
            currentTrip.activities.add(newActivity);
            // Sync local list for display
            activities.add(newActivity);
          });
          _dbService.updateTrip(currentTrip);
        },
        existingActivitiesCount: activities.length,
        availableDays: daysList,
        existingActivities: activities.cast<Activity>(),
        tripStartDate: currentTrip.startDate,
        tripEndDate: currentTrip.endDate,
      ),
    );
  }

  void _showActivityOptions(Activity activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.brownPrimary),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editActivity(activity);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteActivity(activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editActivity(Activity activity) {
    int tripDays = _calculateTripDays();
    
    List<String> daysList = [];
    for (int i = 1; i <= tripDays; i++) {
      daysList.add('Day $i');
    }
    
    showDialog(
      context: context,
      builder: (context) => EditActivityModal(
        activity: activity,
        tripId: currentTrip.title,
        onSave: (Activity updatedActivity) {
          setState(() {
            final index = currentTrip.activities.indexWhere((a) => a.id == activity.id);
            if (index != -1) {
              currentTrip.activities[index] = updatedActivity;
              // Sync local
              activities = currentTrip.activities.map((e) => e as Activity).toList();
            }
          });
          _dbService.updateTrip(currentTrip);
        },
        availableDays: daysList,
        existingActivities: activities.cast<Activity>(),
        tripStartDate: currentTrip.startDate,
        tripEndDate: currentTrip.endDate,
      ),
    );
  }

  void _deleteActivity(Activity activity) {
    setState(() {
      currentTrip.activities.removeWhere((a) => a.id == activity.id);
      activities.removeWhere((a) => a.id == activity.id);
    });
    _dbService.updateTrip(currentTrip);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity deleted')),
    );
  }

  void _editTripDetails() {
    showDialog(
      context: context,
      builder: (context) => EditTripModal(
        trip: currentTrip,
        onSave: (Trip updatedTrip) {
          List<String> changedFields = [];
          
          if (updatedTrip.title != currentTrip.title) {
            changedFields.add('Title');
          }
          if (updatedTrip.destination != currentTrip.destination) {
            changedFields.add('Destination');
          }
          if (updatedTrip.startDate != currentTrip.startDate) {
            changedFields.add('Start Date');
          }
          if (updatedTrip.endDate != currentTrip.endDate) {
            changedFields.add('End Date');
          }
          if (updatedTrip.budget != currentTrip.budget) {
            changedFields.add('Budget');
          }
          
          _saveTripChanges(updatedTrip); // Calls setState and saves to DB
          
          String notificationMessage;
          if (changedFields.isEmpty) {
            notificationMessage = '✓ No changes made';
          } else if (changedFields.length == 1) {
            notificationMessage = '✓ ${changedFields[0]} updated';
          } else if (changedFields.length <= 3) {
            notificationMessage = '✓ ${changedFields.join(', ')} updated';
          } else {
            notificationMessage = '✓ Trip updated (${changedFields.length} fields)';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notificationMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}