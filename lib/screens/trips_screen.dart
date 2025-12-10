import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/trip_model.dart';
import 'trip_detail_screen.dart';
import '../widgets/edit_trip_modal.dart';
import '../screens/budget_screen.dart'; 
import '../screens/members_screen.dart'; 
import '../screens/tasks_screen.dart'; 

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _selectedFilter = 'All';
  TextEditingController _searchController = TextEditingController();
  List<Trip> allTrips = [];

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    allTrips = [
      Trip(
        id: '1',
        title: 'El Nido Paradise',
        destination: 'Palawan, Philippines',
        startDate: 'Jan 10',
        endDate: 'Jan 15',
        budget: 25000,
        image: 'assets/images/el_nido.jpg',
        activities: [],
      ),
      Trip(
        id: '2',
        title: 'Mountain Adventure',
        destination: 'Cordillera, Philippines',
        startDate: 'Feb 20',
        endDate: 'Feb 25',
        budget: 15000,
        image: 'assets/images/mountain.jpg',
        activities: [],
      ),
      Trip(
        id: '3',
        title: 'Beach Getaway',
        destination: 'Siargao, Philippines',
        startDate: 'Mar 01',
        endDate: 'Mar 05',
        budget: 35000,
        image: 'assets/images/beach.jpg',
        activities: [],
      ),
    ];
  }

  // Determine trip status based on dates (for UI display)
  String getTripStatus(Trip trip) {
    // You can customize this logic based on your needs
    // For now, returning static values - modify as needed
    if (trip.id == '3') return 'Ongoing';
    return 'Completed';
  }

  List<Trip> get filteredTrips {
    List<Trip> filtered = allTrips;

    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((trip) =>
              getTripStatus(trip)
                  .toLowerCase()
                  .contains(_selectedFilter.toLowerCase()) ||
              _selectedFilter.toLowerCase() == 'done' &&
                  getTripStatus(trip).toLowerCase() == 'completed')
          .toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((trip) =>
              trip.title.toLowerCase().contains(query) ||
              trip.destination.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  // Calculate total budget spent (sample data)
  int getTotalSpent(Trip trip) {
    if (getTripStatus(trip) == 'Ongoing') {
      return (trip.budget * 0.158).toInt(); // 15.8% spent
    }
    return 0; // Completed trips show 0% spent
  }

  void _showCreateTripModal() {
    showDialog(
      context: context,
      builder: (context) => CreateTripModal(
        onSave: (Trip newTrip) {
          setState(() {
            allTrips.add(newTrip);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget =
        allTrips.fold<int>(0, (sum, trip) => sum + trip.budget);
    final totalSpent =
        filteredTrips.fold<int>(0, (sum, trip) => sum + getTotalSpent(trip));
    final ongoingCount = allTrips
        .where((trip) => getTripStatus(trip).toLowerCase() == 'ongoing')
        .length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Trips',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${allTrips.length} adventures • $ongoingCount ongoing',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Open trip options menu
                        },
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Budget Cards Row
                  Row(
                    children: [
                      // Total Budget Card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Budget',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '₱${totalBudget.toString()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Total Spent Card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Spent',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '₱${totalSpent.toString()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search trips...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab('All'),
                    SizedBox(width: 10.w),
                    _buildFilterTab('Ongoing'),
                    SizedBox(width: 10.w),
                    _buildFilterTab('Done'),
                  ],
                ),
              ),
            ),

            // Trips List
            Expanded(
              child: filteredTrips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.luggage_outlined,
                            size: 64.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No trips found',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Start planning your first adventure!',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      itemCount: filteredTrips.length,
                      itemBuilder: (context, index) {
                        final trip = filteredTrips[index];
                        return _buildTripCard(trip);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brownPrimary,
        onPressed: _showCreateTripModal,
        child: Icon(Icons.add, color: Colors.white, size: 28.sp),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brownPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final tripStatus = getTripStatus(trip);
    final budgetSpent = getTotalSpent(trip);
    final remaining = trip.budget - budgetSpent;
    final percentage =
        budgetSpent == 0 ? 0.0 : budgetSpent.toDouble() / trip.budget;

    // Color based on status
    Color statusColor = Colors.grey.shade600;
    Color cardBgColor = Colors.grey.shade400;

    if (tripStatus == 'Completed') {
      statusColor = Colors.teal.shade600;
      cardBgColor = Colors.grey.shade400;
    } else if (tripStatus == 'Ongoing') {
      statusColor = Colors.orange.shade600;
      cardBgColor = Colors.teal.shade400;
    }

    return GestureDetector(
      onTap: () {
        // ✅ NAVIGATE TO TRIP DETAIL SCREEN
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip Image with Status Badge
              Stack(
                children: [
                  Container(
                    height: 160.h,
                    width: double.infinity,
                    color: cardBgColor,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.w,
                    left: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        tripStatus,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Trip Details
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            trip.destination,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${trip.startDate}-${trip.endDate}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Budget Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.wallet_outlined,
                              size: 14.sp,
                              color: AppColors.brownPrimary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Budget',
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 6.h,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 0.8
                              ? Colors.red.shade500
                              : AppColors.brownPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Budget Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱${budgetSpent.toString()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'of ₱${remaining.toString()} remaining',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
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
      ),
    );
  }
}
