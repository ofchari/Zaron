import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/widgets/text.dart';

import '../../../universal_api/api_key.dart';

class MissedEnquiry extends StatefulWidget {
  const MissedEnquiry({super.key});

  @override
  State<MissedEnquiry> createState() => _MissedEnquiryPageState();
}

class _MissedEnquiryPageState extends State<MissedEnquiry> {
  int? selectedRowIndex;
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
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade300,
                Colors.orange.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: MyText(
              text: "Missed Enquiry",
              weight: FontWeight.w600,
              color: Colors.black87),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: enquiryNoController,
                  decoration: InputDecoration(
                    labelText: 'Search Enquiry No',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
              ),
            ),
            // Total Records Counter
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.orange[50]!],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.orange,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Colors.orange.shade400),
                  SizedBox(width: 8.w),
                  Text(
                    'Total Records: $totalRecords',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  // if (filteredData.length != totalRecords) ...[
                  //   Spacer(),
                  //   Container(
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  //     decoration: BoxDecoration(
                  //       color: Colors.purple.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(20.r),
                  //       border:
                  //           Border.all(color: Colors.purple.withOpacity(0.3)),
                  //     ),
                  //     child: Text(
                  //       'Showing: ${filteredData.length}',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 13.sp,
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.purple,
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),
            // Table
            isLoading
                ? Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.purple,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : filteredData.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'No records found',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
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
                                    color: Colors.orange.withOpacity(0.3),
                                    width: 1,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  columnSpacing: 40,
                                  headingRowHeight: 70,
                                  columns: [
                                    DataColumn(
                                        label: Text('No',
                                            style: GoogleFonts.outfit(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500))),
                                    DataColumn(
                                        label: Text('Order No',
                                            style: GoogleFonts.outfit(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500))),
                                    DataColumn(
                                        label: Text('Bill Total',
                                            style: GoogleFonts.outfit(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500))),
                                    DataColumn(
                                        label: Text('Create Date',
                                            style: GoogleFonts.outfit(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500))),
                                    DataColumn(
                                        label: Text('Create Time',
                                            style: GoogleFonts.outfit(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500))),
                                  ],
                                  rows:
                                      filteredData.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var row = entry.value;

                                    return DataRow(
                                      // Row background color logic
                                      color: WidgetStateProperty.resolveWith<
                                          Color?>(
                                        (Set<WidgetState> states) {
                                          if (selectedRowIndex == index) {
                                            return Colors.orange.shade50;
                                          }
                                          return null;
                                        },
                                      ),
                                      // Row tap logic
                                      onSelectChanged: (_) {
                                        setState(() {
                                          if (selectedRowIndex == index) {
                                            selectedRowIndex =
                                                null; // Deselect if already selected
                                          } else {
                                            selectedRowIndex =
                                                index; // Select new row
                                          }
                                        });
                                      },
                                      cells: [
                                        DataCell(Text("${index + 1}",
                                            style: GoogleFonts.dmSans(
                                                fontSize: 14.sp))),
                                        DataCell(Text(row['order_no'] ?? '',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 14.sp))),
                                        DataCell(Text(row['bill_total'] ?? '0',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 14.sp))),
                                        DataCell(Text(row['create_date'] ?? '',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 14.2.sp))),
                                        DataCell(Text(row['create_time'] ?? '',
                                            style: GoogleFonts.dmSans(
                                                fontSize: 14.2.sp))),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
