import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/trip_model.dart';

class TripReceiptScreen extends StatefulWidget {
  final Trip trip;

  const TripReceiptScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripReceiptScreen> createState() => _TripReceiptScreenState();
}

class _TripReceiptScreenState extends State<TripReceiptScreen> {
  late Trip trip;
  bool _showSplitView = false;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
  }

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

  // Calculate per-person share
  double _calculatePerPersonShare() {
    if (trip.members.isEmpty) return 0;
    return _calculateTotalSpent() / trip.members.length;
  }

  // Print functionality
  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing receipt...'),
        backgroundColor: AppColors.brownPrimary,
      ),
    );
    // TODO: Implement actual print functionality
    // You can use: https://pub.dev/packages/printing
  }

  // Download PDF functionality
  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading receipt as PDF...'),
        backgroundColor: AppColors.brownPrimary,
      ),
    );
    // TODO: Implement actual PDF generation
    // You can use: https://pub.dev/packages/pdf and https://pub.dev/packages/printing
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = _calculateTotalSpent();
    double remaining = _calculateRemaining();
    double perPersonShare = _calculatePerPersonShare();

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
                    // Header - Brown Background with Logo
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.brownPrimary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Column(
                        children: [
                          // Lakbay Logo from assets
                          Image.asset(
                            'assets/images/Lakbay_Logo.png',
                            height: 60.h,
                            width: 60.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'LAKBAY',
                            style: GoogleFonts.poppins(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Travel Receipt',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
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
                          Divider(color: Colors.grey.shade300, thickness: 1),
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
                                          horizontal: 16.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Text(
                                          member.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            SizedBox(height: 24.h),
                            Divider(color: Colors.grey.shade300, thickness: 1),
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
                            Divider(color: Colors.grey.shade300, thickness: 1),
                            SizedBox(height: 24.h),
                          ],

                          // Expenses
                          if (trip.expenses.isNotEmpty) ...[
                            _buildSectionTitle('Expenses'),
                            SizedBox(height: 16.h),
                            ..._buildExpensesList(),
                            SizedBox(height: 24.h),
                            Divider(color: Colors.grey.shade300, thickness: 1),
                            SizedBox(height: 24.h),
                          ],

                          // Per-Person Split Section (with toggle)
                          if (trip.expenses.isNotEmpty && trip.members.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle('Per-Person Split'),
                                Container(
                                  decoration: BoxDecoration(
                                    color: _showSplitView
                                        ? AppColors.brownPrimary
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showSplitView = !_showSplitView;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      child: Text(
                                        _showSplitView ? 'Hide' : 'Show',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _showSplitView
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            if (_showSplitView) ...[
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5E6D3).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFFD4A574),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fair Split Among ${trip.members.length} Members',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brownPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    ..._buildPerPersonShareList(perPersonShare),
                                    SizedBox(height: 16.h),
                                    Divider(
                                      color: AppColors.brownPrimary
                                          .withOpacity(0.2),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Each person pays',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            color: AppColors.brownPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '₱${perPersonShare.toStringAsFixed(2)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
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
                              Divider(color: Colors.grey.shade300, thickness: 1),
                              SizedBox(height: 24.h),
                            ],
                          ],

                          // Summary - Brown Background Section
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppColors.brownPrimary,
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
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '₱${totalSpent.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
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
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '₱${remaining.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28.sp,
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
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Generated by Lakbay • ${DateFormat('MM/dd/yyyy').format(DateTime.now())}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w400,
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

              // Action Buttons - Print & Download
              Row(
                children: [
                  // Print Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _printReceipt,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.brownPrimary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.print,
                              color: AppColors.brownPrimary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Print',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brownPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Download PDF Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _downloadPDF,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.brownPrimary,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brownPrimary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Download PDF',
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
                  ),
                ],
              ),
              SizedBox(height: 32.h),
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
            fontSize: 13.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name ?? 'Activity',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${activity.day ?? 'Day 1'} • ${activity.time ?? '09:00 AM'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '₱${activity.cost ?? 0}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4A574),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                SizedBox(height: 12.h),
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 12.h),
              ],
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
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        expense.category,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₱${expense.cost.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4A574),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                SizedBox(height: 12.h),
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 12.h),
              ],
            ],
          );
        })
        .toList();
  }

  List<Widget> _buildPerPersonShareList(double perPersonShare) {
    return trip.members
        .asMap()
        .entries
        .map((entry) {
          final member = entry.value;
          final index = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brownPrimary,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      member.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.brownPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₱${perPersonShare.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownPrimary,
                  ),
                ),
              ],
            ),
          );
        })
        .toList();
  }
}
