import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../core/app_colors.dart';
import 'profile_screen.dart';
import 'trip_detail_screen.dart';
import '../models/trip_model.dart';
import '../widgets/create_trip_modal.dart';
import '../services/database_service.dart';

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
  
  // Database Service
  late DatabaseService _dbService;
  
  // Memory list (For now local, could be moved to Firebase later)
  List<Map<String, dynamic>> memories = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _dbService = DatabaseService(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildTripsTab(), // Modified to use StreamBuilder
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

  Widget _buildHomeTab() {
    // Note: To implement real calculation from Firestore, we would need to 
    // fetch all trips first. For this simplified version, we calculate based on local view
    // or you can create a FutureBuilder to sum up totals from DB.
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
              // Stats cards are static for now, connect to Stream if needed
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '--k', 
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
                      '--', 
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
          child: memories.isEmpty
              ? _buildEmptyMemoriesState()
              : SingleChildScrollView(
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

  Widget _buildEmptyMemoriesState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.photo_camera_back,
                  size: 56.sp,
                  color: AppColors.brownPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'No Memories Yet',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Start capturing and sharing your travel moments',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Tap to add your first photo',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 40.h),
              GestureDetector(
                onTap: _showPhotoActionSheet,
                child: Container(
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: AppColors.brownPrimary,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brownPrimary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  // --- TRIPS TAB WITH STREAM BUILDER ---
  Widget _buildTripsTab() {
    return StreamBuilder<List<Trip>>(
      stream: _dbService.tripsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final trips = snapshot.data ?? [];

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
      },
    );
  }

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
                onPressed: _showCreateTripModal,
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

  Widget _buildTripCard(Trip trip) {
    bool isLocalImage = !trip.image.startsWith('assets/');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: trip),
          ),
        );
      },
      onLongPress: () {
        _showTripDeleteConfirmation(trip);
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
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Container(
                height: 160.h,
                color: Colors.grey.shade200,
                child: isLocalImage 
                    ? Image.file(
                        File(trip.image),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => 
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : Image.asset(
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
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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

  void _showTripDeleteConfirmation(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Trip?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${trip.title}"? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.deleteTrip(trip.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Trip deleted',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
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

  void _showCreateTripModal() {
    showDialog(
      context: context,
      builder: (context) => CreateTripModal(
        onSave: (Trip newTrip) async {
          // Handle Image Persistence before saving to DB
          String finalImagePath = newTrip.image;
          
          if (!newTrip.image.startsWith('assets/')) {
            final file = File(newTrip.image);
            if (await file.exists()) {
              // Save to app documents via service
              finalImagePath = await _dbService.saveImageLocally(file);
            }
          }

          // Create final trip with persistent path
          Trip finalTrip = Trip(
            id: newTrip.id,
            title: newTrip.title,
            destination: newTrip.destination,
            startDate: newTrip.startDate,
            endDate: newTrip.endDate,
            budget: newTrip.budget,
            image: finalImagePath,
            members: newTrip.members,
            activitiesList: newTrip.activities,
            expensesList: newTrip.expenses,
            tasksList: newTrip.tasks,
            departureTime: newTrip.departureTime,
            arrivalTime: newTrip.arrivalTime,
          );

          await _dbService.updateTrip(finalTrip);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Trip created!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  // --- STAT CARD ---
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

  // --- MASONRY GALLERY (MEMORIES) ---
  Widget _buildMasonryGallery() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              if (memories.isNotEmpty)
                _buildMemoryCard(memories[0], height: 220.h),
              if (memories.length > 1) SizedBox(height: 16.h),
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
              if (memories.isNotEmpty) SizedBox(height: 16.h),
              _buildAddPhotoCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryCard(Map<String, dynamic> memory,
      {required double height}) {
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
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory['title'] ?? 'Memory',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to view • Long press to edit',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
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

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _showPhotoActionSheet,
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
            onTap: _showPhotoActionSheet,
            borderRadius: BorderRadius.circular(16.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween(begin: 0.0, end: 1.0),
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

  void _viewMemory(Map<String, dynamic> memory) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.w),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
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
                  Padding(
                    padding: EdgeInsets.all(20.w),
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
                        SizedBox(height: 12.h),
                        Text(
                          memory['description'] ?? 'No description',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '(Tap outside to close)',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  void _editMemory(Map<String, dynamic> memory) {
    final titleController = TextEditingController(text: memory['title']);
    final descriptionController =
        TextEditingController(text: memory['description']);
    File? newImageFile = memory['imageFile'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                GestureDetector(
                  onTap: () {
                    _showImageReplaceOptions(
                      memory,
                      (File newImage) {
                        setState(() {
                          newImageFile = newImage;
                        });
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          height: 150.h,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: newImageFile != null
                              ? Image.file(
                                  newImageFile!,
                                  fit: BoxFit.cover,
                                )
                              : (memory['imageFile'] != null
                                  ? Image.file(
                                      memory['imageFile'],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      memory['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 40.sp,
                                            color: Colors.grey.shade400,
                                          ),
                                        );
                                      },
                                    )),
                        ),
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
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Tap to replace image',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Memory title',
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
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  memory['title'] = titleController.text;
                  memory['description'] = descriptionController.text;
                  if (newImageFile != null) {
                    memory['imageFile'] = newImageFile;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Memory updated!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
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
      ),
    );
  }

  void _showImageReplaceOptions(
    Map<String, dynamic> memory,
    Function(File) onImageSelected,
  ) {
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
                  _pickImageForReplacement(onImageSelected);
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
                  _pickImageFromGalleryForReplacement(onImageSelected);
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
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

  Future<void> _pickImageForReplacement(Function(File) onImageSelected) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        onImageSelected(File(image.path));
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

  Future<void> _pickImageFromGalleryForReplacement(
      Function(File) onImageSelected) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        onImageSelected(File(image.path));
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  memories.add({
                    'id': DateTime.now().millisecondsSinceEpoch,
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
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