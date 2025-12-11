import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  // --- PDF GENERATION LOGIC ---
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();

    // Load Fonts
    final fontRegular = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsSemiBold();
    final fontItalic = await PdfGoogleFonts.poppinsItalic();

    // Load Logo (Ensure this asset exists in your pubspec.yaml)
    final logoImage = await rootBundle.load('assets/images/Lakbay_Logo.png');
    final imageBytes = logoImage.buffer.asUint8List();

    // Calculations
    final totalSpent = _calculateTotalSpent();
    final remaining = _calculateRemaining();
    final perPersonShare = _calculatePerPersonShare();
    final brownColor = PdfColor.fromInt(0xFF5B2708); // AppColors.brownPrimary
    final lightBrownColor = PdfColor.fromInt(0xFFF5E6D3);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
            italic: fontItalic,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColor.fromInt(0xFFF5F5F5)), // Grey background
          ),
        ),
        header: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            color: brownColor,
            borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(10)),
          ),
          padding: const pw.EdgeInsets.symmetric(vertical: 20),
          width: double.infinity,
          child: pw.Column(
            children: [
              pw.Image(pw.MemoryImage(imageBytes), width: 50, height: 50),
              pw.SizedBox(height: 10),
              pw.Text(
                'LAKBAY',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              pw.Text(
                'Travel Receipt',
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.vertical(bottom: pw.Radius.circular(10)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Trip Info
                _buildPdfSectionTitle('Trip Information', brownColor),
                pw.SizedBox(height: 10),
                _buildPdfInfoRow('Trip Name:', trip.title, brownColor),
                _buildPdfInfoRow('Destination:', trip.destination, brownColor),
                _buildPdfInfoRow('Dates:', '${trip.startDate} - ${trip.endDate}', brownColor),
                _buildPdfInfoRow('Budget:', 'P${trip.budget.toStringAsFixed(0)}', brownColor),
                pw.SizedBox(height: 20),
                pw.Divider(),

                // Members
                if (trip.members.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildPdfSectionTitle('Travel Group', brownColor),
                  pw.SizedBox(height: 10),
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: trip.members.map((m) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFEEEEEE),
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(
                          m.fullName, // Use fullName
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                        ),
                      );
                    }).toList(),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                ],

                // Expenses
                if (trip.expenses.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildPdfSectionTitle('Expenses', brownColor),
                  pw.SizedBox(height: 10),
                  ...trip.expenses.map((e) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(e.description, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                                pw.Text(e.category, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                              ],
                            ),
                            pw.Text('P${e.cost.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFD4A574))),
                          ],
                        ),
                      )),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                ],

                // Per Person Share
                if (trip.members.isNotEmpty && trip.expenses.isNotEmpty) ...[
                   pw.SizedBox(height: 20),
                   pw.Container(
                     padding: const pw.EdgeInsets.all(12),
                     decoration: pw.BoxDecoration(
                       color: lightBrownColor,
                       borderRadius: pw.BorderRadius.circular(8),
                     ),
                     child: pw.Row(
                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                       children: [
                         pw.Text('Fair Split (${trip.members.length} members)', style: pw.TextStyle(color: brownColor, fontWeight: pw.FontWeight.bold)),
                         pw.Text('P${perPersonShare.toStringAsFixed(2)} / person', style: pw.TextStyle(color: brownColor, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                       ],
                     ),
                   ),
                   pw.SizedBox(height: 20),
                ],

                // Summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: brownColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Spent', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                          pw.Text('P${totalSpent.toStringAsFixed(0)}', style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                       pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Remaining', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                          pw.Text('P${remaining.toStringAsFixed(0)}', style: pw.TextStyle(color: PdfColor.fromInt(0xFFD4A574), fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Center(
          child: pw.Column(
            children: [
              pw.SizedBox(height: 20),
              pw.Text('"Ang bawat lakbay ay puno ng alaala"', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: PdfColors.grey600)),
              pw.Text('Generated by Lakbay', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  pw.Widget _buildPdfSectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- ACTIONS ---

  // Print functionality
  Future<void> _printReceipt() async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _generatePdf(format),
        name: 'Lakbay_Receipt_${trip.title}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Download PDF functionality
  Future<void> _downloadPDF() async {
    try {
      final pdfBytes = await _generatePdf(PdfPageFormat.a4);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Lakbay_Receipt_${trip.title}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
            onPressed: _downloadPDF, // Share/Download is usually the same action in mobile
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
                          // Lakbay Logo
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
                                          member.fullName, // Updated to use fullName
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
                      member.fullName, // Updated to use fullName
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