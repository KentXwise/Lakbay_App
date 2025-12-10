import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../core/app_colors.dart';
import 'profile_screen.dart';
import 'trip_detail_screen.dart';
import '../models/trip_model.dart';
import '../widgets/create_trip_modal.dart';

class HomeScreen extends StatefulWidget {
  final String userNickname;

  const HomeScreen({
    super.key,
    required this.userNickname,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();

  // Mock memory data
  List<Map<String, dynamic>> memories = [
    {'id': 1, 'image': 'assets/images/photo1.jpg', 'title': 'Beach Trip', 'description': 'Amazing beach day', 'imageFile': null},
    {'id': 2, 'image': 'assets/images/photo2.jpg', 'title': 'Mountain View', 'description': 'Peak of adventure', 'imageFile': null},
    {'id': 3, 'image': 'assets/images/photo3.jpg', 'title': 'City Lights', 'description': 'Night in the city', 'imageFile': null},
  ];

  // Trips data - now using Trip model
  List<Trip> trips = [
    Trip(
      id: '1',
      title: 'Dagat',
      destination: 'Davao',
      startDate: '12/22/2025',
      endDate: '12/24/2025',
      budget: 5000,
      image: 'assets/images/photo1.jpg',
      members: [],
      activitiesList: [],
      expensesList: [],
      tasksList: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildTripsTab(),
            ProfileScreen(userNickname: widget.userNickname),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: AppColors.brownPrimary,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Memories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 1 ? _buildCreateTripFAB() : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FLOATING ACTION BUTTON - Create Trip
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCreateTripFAB() {
    return GestureDetector(
      onTap: _showCreateTripModal,
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.brownPrimary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.brownPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MEMORIES TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHomeTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.brownPrimary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 35.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Lakbay, ',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'Hi, ${widget.userNickname}!',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '₱6k',
                      'Spent',
                      Icons.wallet_giftcard,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      '${memories.length}',
                      'Memories',
                      Icons.photo_library_outlined,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      '${trips.length}',
                      'Trips',
                      Icons.card_travel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 32.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Memories',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: _buildMasonryGallery(),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TRIPS TAB
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTripsTab() {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.brownPrimary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 35.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Kamusta, ',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: '${widget.userNickname}!',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Plan your next adventure',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 24.h),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search trips by name or destination...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Trips List
        Expanded(
          child: trips.isEmpty
              ? _buildEmptyTripsState()
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        ...trips.map((trip) => _buildTripCard(trip)).toList(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMPTY TRIPS STATE
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildEmptyTripsState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_travel,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'No trips yet',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Create your first trip to get started',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  _showCreateTripModal();
                },
                icon: const Icon(Icons.add),
                label: Text(
                  'Create Trip',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brownPrimary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // TRIP CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTripCard(Trip trip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: trip),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Container(
                height: 160.h,
                color: Colors.grey.shade200,
                child: Image.asset(
                  trip.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40.sp,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    trip.destination,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Date and Budget Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14.sp,
                            color: Colors.grey.shade400,
                          ),
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
                      // Budget
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CREATE TRIP MODAL - Using CreateTripModal widget
  // ═══════════════════════════════════════════════════════════════════
  void _showCreateTripModal() {
    showDialog(
      context: context,
      builder: (context) => CreateTripModal(
        onSave: (Trip newTrip) {
          setState(() {
            trips.add(newTrip);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Trip created!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // FORM FIELD WIDGET
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: AppColors.brownPrimary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MASONRY GALLERY (Memories)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMasonryGallery() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              if (memories.isNotEmpty)
                _buildMemoryCard(memories[0], height: 220.h),
              SizedBox(height: 16.h),
              if (memories.length > 2)
                _buildMemoryCard(memories[2], height: 220.h),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            children: [
              if (memories.length > 1)
                _buildMemoryCard(memories[1], height: 180.h),
              SizedBox(height: 16.h),
              _buildAddPhotoCard(),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // MEMORY CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMemoryCard(Map<String, dynamic> memory, {required double height}) {
    return GestureDetector(
      onLongPress: () {
        _showMemoryActionSheet(memory);
      },
      onTap: () {
        _viewMemory(memory);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              memory['imageFile'] != null
                  ? Image.file(
                      memory['imageFile'],
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      memory['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Image not found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          memory['title'] ?? 'Memory',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.touch_app,
                        color: Colors.white70,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ADD PHOTO CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: () {
        _showPhotoActionSheet();
      },
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6D3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD4A574),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showPhotoActionSheet();
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: Container(
                        width: 56.w,
                        height: 56.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A574)
                                  .withOpacity(value * 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add,
                          color: const Color(0xFFD4A574),
                          size: 32.sp,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                Text(
                  'Add New Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Post your memories',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFFD4A574),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STAT CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 16.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFD4A574),
            size: 28.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.brownPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Memory Functions (View, Edit, Delete, etc.)
  // ═══════════════════════════════════════════════════════════════════
  void _viewMemory(Map<String, dynamic> memory) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.black,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: memory['imageFile'] != null
                        ? Image.file(
                            memory['imageFile'],
                            fit: BoxFit.cover,
                            height: 300.h,
                            width: double.infinity,
                          )
                        : Image.asset(
                            memory['image'],
                            fit: BoxFit.cover,
                            height: 300.h,
                            width: double.infinity,
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory['title'] ?? 'Memory',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          memory['description'] ?? 'No description',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _editMemory(memory);
                                },
                                icon: const Icon(Icons.edit),
                                label: Text(
                                  'Edit',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brownPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownPrimary,
                                  ),
                                ),
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
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.close,
                    color: AppColors.brownPrimary,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editMemory(Map<String, dynamic> memory) {
    final titleController = TextEditingController(text: memory['title']);
    final descriptionController = TextEditingController(text: memory['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Memory',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.brownPrimary,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                memory['title'] = titleController.text;
                memory['description'] = descriptionController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Memory updated',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownPrimary,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        _showNewMemoryForm(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _showNewMemoryForm(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNewMemoryForm(File imageFile) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Memory',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  imageFile,
                  height: 150.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Memory Title',
                  hintText: 'e.g., Beach Day',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add details about this memory...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.brownPrimary,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  memories.add({
                    'id': memories.length + 1,
                    'image': 'assets/images/photo1.jpg',
                    'title': titleController.text,
                    'description': descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : 'No description',
                    'imageFile': imageFile,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Memory saved!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter a title',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownPrimary,
            ),
            child: Text(
              'Save Memory',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _replaceImage(Map<String, dynamic> memory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Replace Image',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        content: Text(
          'Choose a new image for this memory',
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
            child: Text(
              'Take Photo',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.brownPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: Text(
              'Choose from Gallery',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.brownPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoryActionSheet(Map<String, dynamic> memory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: AppColors.brownPrimary,
                  size: 24.sp,
                ),
                title: Text(
                  'View Memory',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewMemory(memory);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: AppColors.brownPrimary,
                  size: 24.sp,
                ),
                title: Text(
                  'Edit Memory',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editMemory(memory);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: AppColors.brownPrimary,
                  size: 24.sp,
                ),
                title: Text(
                  'Replace Image',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _replaceImage(memory);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 24.sp,
                ),
                title: Text(
                  'Delete Memory',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(memory);
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> memory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Memory?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${memory['title']}"? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                memories.removeWhere((m) => m['id'] == memory['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Memory deleted',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: AppColors.brownPrimary,
                  size: 24.sp,
                ),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: AppColors.brownPrimary,
                  size: 24.sp,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
