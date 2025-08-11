import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../../universal_api/api_key.dart';

class MissedEnquiry extends StatefulWidget {
  const MissedEnquiry({super.key});

  @override
  State<MissedEnquiry> createState() => _MissedEnquiryPageState();
}

class _MissedEnquiryPageState extends State<MissedEnquiry> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;
  int totalRecords = 0;

  final TextEditingController enquiryNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEnquiryData();
    enquiryNoController.addListener(_onEnquiryNumberChanged);
  }

  @override
  void dispose() {
    enquiryNoController.removeListener(_onEnquiryNumberChanged);
    enquiryNoController.dispose();
    super.dispose();
  }

  void _onEnquiryNumberChanged() {
    filterData();
  }

  Future<void> fetchEnquiryData() async {
    setState(() => isLoading = true);

    final String url = '$apiUrl/missedenquiry/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("missed_enquiry")) {
          final List<dynamic> enquiryList = jsonData["missed_enquiry"];

          final List<Map<String, dynamic>> processedData = enquiryList
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => {
                  'id': item['id'] ?? '',
                  'order_no': item['order_no'] ?? '',
                  'bill_total': item['bill_total'] ?? '',
                  'create_date': item['create_date'] ?? '',
                  'create_time': item['create_time'] ?? '',
                },
              )
              .toList();

          setState(() {
            tableData = processedData;
            filteredData = List.from(tableData);
            totalRecords = processedData.length;
            isLoading = false;
          });
          return;
        }

        throw Exception("Invalid API response format");
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('❌ Error fetching enquiry data: $e');
      setState(() => isLoading = false);
    }
  }

  void filterData() {
    final searchQuery = enquiryNoController.text.trim().toLowerCase();
    if (searchQuery.isEmpty) {
      setState(() {
        filteredData = List.from(tableData);
      });
    } else {
      setState(() {
        filteredData = tableData
            .where(
              (row) => (row['order_no'] ?? '').toLowerCase().contains(
                    searchQuery,
                  ),
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Subhead(
          text: "Missed Enquiry",
          weight: FontWeight.w600,
          color: const Color(0xFF1A1A1A),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Clean Header Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: enquiryNoController.text.isNotEmpty
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: enquiryNoController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      hintText: 'Search by order number',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      suffixIcon: enquiryNoController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF9CA3AF),
                                size: 18,
                              ),
                              onPressed: () {
                                enquiryNoController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Simple Stats
                Row(
                  children: [
                    Text(
                      'Total: $totalRecords records',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    if (filteredData.length != totalRecords) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Showing ${filteredData.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),

          // Table Section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                      strokeWidth: 2.5,
                    ),
                  )
                : filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48.sp,
                              color: const Color(0xFFD1D5DB),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No enquiries found',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    border: TableBorder.all(
                                      color: Colors.purple.withOpacity(0.3),
                                      width: 1,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    columnSpacing: 40,
                                    headingRowHeight: 70,
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          'No',
                                          style: GoogleFonts.outfit(
                                            textStyle: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Order No',
                                          style: GoogleFonts.outfit(
                                            textStyle: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Bill Total',
                                          style: GoogleFonts.outfit(
                                            textStyle: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Create Date',
                                          style: GoogleFonts.outfit(
                                            textStyle: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Create Time',
                                          style: GoogleFonts.outfit(
                                            textStyle: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: filteredData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      return DataRow(
                                        color: WidgetStateProperty.resolveWith<
                                            Color?>((
                                          Set<WidgetState> states,
                                        ) {
                                          return entry.key % 2 == 0
                                              ? Colors.white
                                              : Colors.grey.shade200;
                                        }),
                                        cells: [
                                          DataCell(
                                            Text(
                                              "${entry.key + 1}",
                                              style: GoogleFonts.dmSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              entry.value['order_no'] ?? '',
                                              style: GoogleFonts.dmSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              entry.value['bill_total'] ?? '0',
                                              style: GoogleFonts.dmSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              entry.value['create_date'] ?? '',
                                              style: GoogleFonts.dmSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14.2.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              entry.value['create_time'] ?? '',
                                              style: GoogleFonts.dmSans(
                                                textStyle: TextStyle(
                                                  fontSize: 14.2.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
