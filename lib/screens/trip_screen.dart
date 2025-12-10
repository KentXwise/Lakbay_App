import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/trip_model.dart';
import '../widgets/create_trip_modal.dart';
import 'profile_screen.dart';
import 'trip_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userNickname;

const HomeScreen({
    super.key,
    this.userNickname = 'Mga Laagan!', 
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String displayName;
  late List<Trip> trips;
  String? _selectedTripIdForDelete;

  @override
  void initState() {
    super.initState();
    displayName = widget.userNickname ?? 'Stefani';
    trips = [];
  }
  void _showCreateTripModal() {
    showDialog(
      context: context,
      builder: (context) => CreateTripModal(
        onSave: (Trip newTrip) {
          setState(() {
            trips.add(newTrip);
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Trip?',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${trip.title}"? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTrip(Trip trip) {
    setState(() {
      trips.removeWhere((t) => t.id == trip.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ "${trip.title}" deleted',
          style: GoogleFonts.poppins(),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedIndex == 1
          ? SafeArea(
              child: Column(
                children: [
                  
                  Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 35.h),
                  decoration: BoxDecoration(
                  color: AppColors.brownPrimary,
                      borderRadius: BorderRadius.circular(24.r),
                  ),
                          children: [
                            Text(
                              'Kamusta, ',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${widget.userNickname}!', 
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text('👋', style: TextStyle(fontSize: 18.sp)),
                          ],
                        ),

                        SizedBox(height: 8.h),
                        Text(
                          'Plan your next adventure',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey.shade400),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search trips by name or destination...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: trips.isEmpty
                        ? Center(
                            child: Text(
                              'No trips yet. Create one!',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(24.w),
                            itemCount: trips.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  _buildTripCard(trips[index]),
                                  if (index < trips.length - 1) SizedBox(height: 16.h),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            )
: _selectedIndex == 0
              ? const Center(
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                )
              : const ProfileScreen(),
      
      floatingActionButton: _selectedIndex == 1
    ? FloatingActionButton(
        backgroundColor: AppColors.brownPrimary,
        onPressed: _showCreateTripModal,
        child: Icon(Icons.add, color: Colors.white),
      )
    : null,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final isSelected = _selectedTripIdForDelete == trip.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)),
        );
      },
      onLongPress: () {
        setState(() {
          _selectedTripIdForDelete = trip.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.red.shade300 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150.h,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: Image.asset(
                      trip.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          trip.destination,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14.sp, color: Colors.grey.shade600),
                                SizedBox(width: 6.w),
                                Text(
                                  '${trip.startDate} - ${trip.endDate}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₱${trip.budget}',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brownPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(trip);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6A5F),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6A5F).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              if (isSelected)
                Positioned(
                  top: 8.w,
                  left: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTripIdForDelete = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade800.withOpacity(0.7),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
