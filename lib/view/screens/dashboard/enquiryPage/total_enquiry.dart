import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/dashboard/enquiryPage/total_enquiry_view.dart';
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/universal_api/api&key.dart';

import '../../../widgets/text.dart';

class TotalEnquiryPage extends StatefulWidget {
  const TotalEnquiryPage({super.key});

  @override
  State<TotalEnquiryPage> createState() => _TotalEnquiryPageState();
}

class _TotalEnquiryPageState extends State<TotalEnquiryPage> {
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

  void _onEnquiryNumberChanged() {
    filterData();
  }

  Future<void> fetchEnquiryData() async {
    setState(() => isLoading = true);

    final String url = '$apiUrl/totalenquiry/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(response.body);
        print(response.statusCode);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("total_enquiry")) {
          final List<dynamic> enquiryList = jsonData["total_enquiry"];

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
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade200,
                Colors.purple.shade100,
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
              text: "Total Enquiry",
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: fromDateController,
                            readOnly: true,
                            onTap: () =>
                                _selectDate(context, fromDateController),
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
                        labelText: 'Search Enquiry No',
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
            // Total Records Counter
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
            // Table
            isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: // Add this in your StatefulWidget class
                          SingleChildScrollView(
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
                                DataColumn(
                                    label: Text('Action',
                                        style: GoogleFonts.outfit(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500))),
                              ],
                              rows: filteredData.asMap().entries.map((entry) {
                                int index = entry.key;
                                var row = entry.value;

                                return DataRow(
                                  // Row background color logic
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      if (selectedRowIndex == index) {
                                        return Colors.grey.shade300;
                                      }
                                      return null;
                                    },
                                  ), // Row tap logic
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
                                    // DataCell(Text(row['id'] ?? '',
                                    //     style: GoogleFonts.dmSans(
                                    //         fontSize: 14.sp))),
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
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility,
                                              color: Colors.blue),
                                          onPressed: () {
                                            Get.to(() => TotalEnquiryView(
                                                id: row['id'] ?? ''));
                                          },
                                        ),
                                      ],
                                    )),
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
