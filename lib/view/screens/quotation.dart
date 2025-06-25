import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/screens/total_quoation_view.dart';
import 'package:zaron/view/universal_api/api&key.dart';

import '../widgets/subhead.dart';

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
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

  // Date Controllers
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      filterData(); // <<== call filter when date changes
    }
  }

  Future<void> fetchEnquiryData() async {
    setState(() => isLoading = true);

    final String Url = '$apiUrl/totalquotation/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(Url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("total_quotation")) {
          final List<dynamic> enquiryList = jsonData["total_quotation"];

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

    DateTime? fromDate;
    DateTime? toDate;

    if (fromDateController.text.isNotEmpty) {
      fromDate = DateTime.tryParse(fromDateController.text);
    }
    if (toDateController.text.isNotEmpty) {
      toDate = DateTime.tryParse(toDateController.text);
    }

    setState(() {
      filteredData = tableData.where((row) {
        final orderNo = (row['order_no'] ?? '').toLowerCase();
        final createDateStr = row['create_date'] ?? '';
        final createDate = DateTime.tryParse(createDateStr);

        final matchesSearch =
            searchQuery.isEmpty || orderNo.contains(searchQuery);
        final matchesDate = (fromDate == null ||
                createDate == null ||
                !createDate.isBefore(fromDate)) &&
            (toDate == null ||
                createDate == null ||
                !createDate.isAfter(toDate));

        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Subhead(
            text: "Total Quotation",
            weight: FontWeight.w500,
            color: Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Column(
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, fromDateController),
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.purple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.purple),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: toDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, toDateController),
                          decoration: InputDecoration(
                            labelText: 'To Date',
                            prefixIcon: const Icon(Icons.calendar_today,
                                color: Colors.purple),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.purple),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: enquiryNoController,
                    decoration: InputDecoration(
                      labelText: 'Quotation No',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.purple),
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
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.purple[50]!],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.purple,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.purple),
                SizedBox(width: 8.w),
                Text(
                  'Total Records: $totalRecords',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),

          // // Total Records Counter
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     'Total Records: $totalRecords',
          //     style: GoogleFonts.outfit(
          //       textStyle: TextStyle(
          //         fontSize: 16.sp,
          //         fontWeight: FontWeight.w600,
          //         color: Colors.black87,
          //       ),
          //     ),
          //   ),
          // ),

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
                            // child: Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: DataTable(
                            //     showCheckboxColumn: false,
                            //     border: TableBorder.all(
                            //         color: Colors.purple, width: 0.5),
                            //     dataRowHeight: 60,
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
                              DataColumn(
                                label: Text(
                                  'Action',
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
                              int rowIndex = entry.key;
                              Map<String, dynamic> row = entry.value;
                              return DataRow(
                                onSelectChanged: (selected) {
                                  setState(() {
                                    selectedRowIndex = rowIndex;
                                  });
                                },
                                color:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (selectedRowIndex == rowIndex) {
                                      return Colors.grey.shade200;
                                    }

                                    return null;

                                    // entry.key % 2 == 0
                                    //   ? Colors.white
                                    //   : Colors.grey.shade200;
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
                                      row['id'] ?? '',
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
                                      row['order_no'] ?? '',
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
                                      row['bill_total'] ?? '0',
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
                                      row['create_date'] ?? '',
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
                                      row['create_time'] ?? '',
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
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility,
                                              color: Colors.blue),
                                          onPressed: () {
                                            Get.to(() => TotalQuoationView(
                                                  id: row['id'] ?? '',
                                                ));
                                          },
                                        ),
                                        // IconButton(
                                        //   icon: const Icon(Icons.edit,
                                        //       color: Colors.green),
                                        //   onPressed: () {
                                        //     // Edit action
                                        //     ScaffoldMessenger.of(context)
                                        //         .showSnackBar(
                                        //       SnackBar(
                                        //           content: Text(
                                        //               "Edit ${row['order_no']}")),
                                        //     );
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  )
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
