import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/trip_model.dart';

class TripReceiptScreen extends StatelessWidget {
  final Trip trip;

  const TripReceiptScreen({
    super.key,
    required this.trip,
  });

  // Calculate total spent from expenses
  double _calculateTotalSpent() {
    double total = 0;
    for (var expense in trip.expenses) {
      total += expense.cost;
    }
    return total;
  }

  // Calculate remaining budget
  double _calculateRemaining() {
    return (trip.budget - _calculateTotalSpent()).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = _calculateTotalSpent();
    double remaining = _calculateRemaining();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: AppColors.brownPrimary),
        ),
        title: Text(
          'Trip Receipt',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.brownPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: AppColors.brownPrimary),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Receipt Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.brownPrimary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.home,
                            color: const Color(0xFFD4A574),
                            size: 40.sp,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'LAKBAY',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Travel Receipt',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip Information
                          _buildSectionTitle('Trip Information'),
                          SizedBox(height: 16.h),
                          _buildInfoRow('Trip Name:', trip.title),
                          SizedBox(height: 12.h),
                          _buildInfoRow('Destination:', trip.destination),
                          SizedBox(height: 12.h),
                          _buildInfoRow(
                            'Dates:',
                            '${trip.startDate} - ${trip.endDate}',
                          ),
                          SizedBox(height: 12.h),
                          _buildInfoRow('Budget:', '₱${trip.budget.toStringAsFixed(0)}'),
                          SizedBox(height: 24.h),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: 24.h),

                          // Travel Group
                          if (trip.members.isNotEmpty) ...[
                            _buildSectionTitle('Travel Group'),
                            SizedBox(height: 16.h),
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: trip.members
                                  .map((member) => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Text(
                                          member.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 24.h),
                            Divider(color: Colors.grey.shade300),
                            SizedBox(height: 24.h),
                          ],

                          // Itinerary/Activities
                          if (trip.activities.isNotEmpty) ...[
                            _buildSectionTitle(
                              'Itinerary (${trip.activities.length} activities)',
                            ),
                            SizedBox(height: 16.h),
                            ..._buildActivitiesList(),
                            SizedBox(height: 24.h),
                            Divider(color: Colors.grey.shade300),
                            SizedBox(height: 24.h),
                          ],

                          // Expenses
                          if (trip.expenses.isNotEmpty) ...[
                            _buildSectionTitle('Expenses'),
                            SizedBox(height: 16.h),
                            ..._buildExpensesList(),
                            SizedBox(height: 24.h),
                            Divider(color: Colors.grey.shade300),
                            SizedBox(height: 24.h),
                          ],

                          // Summary
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Spent',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₱${totalSpent.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brownPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Remaining',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₱${remaining.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD4A574),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Footer
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  '"Ang bawat lakbay ay puno ng alaala"',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Generated by Lakbay • ${DateTime.now().toString().split(' ')[0]}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.brownPrimary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.brownPrimary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActivitiesList() {
    final activities = trip.activities;
    return activities
        .asMap()
        .entries
        .map((entry) {
          final activity = entry.value;
          final isLast = entry.key == activities.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      activity.name ?? 'Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '₱${activity.cost ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4A574),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${activity.day ?? 'Day 1'} • ${activity.time ?? '09:00 AM'}',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              if (!isLast) SizedBox(height: 12.h),
            ],
          );
        })
        .toList();
  }

  List<Widget> _buildExpensesList() {
    final expenses = trip.expenses;
    return expenses
        .asMap()
        .entries
        .map((entry) {
          final expense = entry.value;
          final isLast = entry.key == expenses.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        expense.category,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₱${expense.cost.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4A574),
                    ),
                  ),
                ],
              ),
              if (!isLast) SizedBox(height: 12.h),
            ],
          );
        })
        .toList();
  }
}
