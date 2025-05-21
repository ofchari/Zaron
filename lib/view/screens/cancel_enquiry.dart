import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/widgets/subhead.dart';

class CancelEnquiry extends StatefulWidget {
  const CancelEnquiry({super.key});

  @override
  State<CancelEnquiry> createState() => _CancelEnquiryPageState();
}

class _CancelEnquiryPageState extends State<CancelEnquiry> {
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

    final String apiUrl =
        'https://demo.zaron.in:8181/ci4/api/cancelledenquiry/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("cancelled_enquiry")) {
          final List<dynamic> enquiryList = jsonData["cancelled_enquiry"];

          final List<Map<String, dynamic>> processedData = enquiryList
              .whereType<Map<String, dynamic>>()
              .map((item) => {
                    // 'no': (enquiryList.indexOf(item) + 1).toString(),
                    'id': item['id'] ?? '',
                    'order_no': item['order_no'] ?? '',
                    'bill_total': item['bill_total'] ?? '',
                    'create_date': item['create_date'] ?? '',
                    'create_time': item['create_time'] ?? '',
                  })
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
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
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
            .where((row) =>
                (row['order_no'] ?? '').toLowerCase().contains(searchQuery))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Subhead(
            text: "Cancelled Enquiry",
            weight: FontWeight.w500,
            color: Colors.black),
      ),
      body: Column(
        children: [
          // Enquiry No (Search)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 16),
            child: TextField(
              controller: enquiryNoController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                labelText: 'Search..',
                labelStyle: GoogleFonts.outfit(
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),

          // Total Records Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Data: $totalRecords',
              style: GoogleFonts.outfit(
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Table
          isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DataTable(
                            border: TableBorder.all(
                                color: Colors.purple, width: 0.5),
                            dataRowHeight: 60,
                            columnSpacing: 40,
                            headingRowHeight: 56,
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
                                  'ID',
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
                            rows: filteredData.asMap().entries.map((entry) {
                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    return entry.key % 2 == 0
                                        ? Colors.white
                                        : Colors.grey.shade200;
                                  },
                                ),
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
                                      entry.value['id'] ?? '',
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

                                    // Row(
                                    //   children: [
                                    //     IconButton(
                                    //       icon: const Icon(Icons.visibility,
                                    //           color: Colors.blue),
                                    //       onPressed: () {
                                    //         ScaffoldMessenger.of(context)
                                    //             .showSnackBar(
                                    //           SnackBar(
                                    //               content: Text(
                                    //                   "View details for ${entry.value['order_no']}")),
                                    //         );
                                    //       },
                                    //     ),
                                    //     IconButton(
                                    //       icon: const Icon(Icons.edit,
                                    //           color: Colors.green),
                                    //       onPressed: () {
                                    //         ScaffoldMessenger.of(context)
                                    //             .showSnackBar(
                                    //           SnackBar(
                                    //               content: Text(
                                    //                   "Edit ${entry.value['order_no']}")),
                                    //         );
                                    //       },
                                    //     ),
                                    //   ],
                                    // ),
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
        ],
      ),
    );
  }
}
