import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/widgets/subhead.dart';

class TotalEnquiry extends StatefulWidget {
  const TotalEnquiry({super.key});

  @override
  State<TotalEnquiry> createState() => _TotalEnquiryState();
}

class _TotalEnquiryState extends State<TotalEnquiry> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;
  int totalRecords = 0;

  // Controllers for date range
  final TextEditingController fromDateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  final TextEditingController toDateController = TextEditingController(
    text: DateTime.now().toString().split(' ')[0],
  );
  final TextEditingController enquiryNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPortalActivity();

    // Add listener to enquiryNoController to filter data automatically
    enquiryNoController.addListener(_onEnquiryNumberChanged);
  }

  @override
  void dispose() {
    // Remove listener when disposing
    enquiryNoController.removeListener(_onEnquiryNumberChanged);
    fromDateController.dispose();
    toDateController.dispose();
    enquiryNoController.dispose();
    super.dispose();
  }

  void _onEnquiryNumberChanged() {
    // Debounce could be added here for better performance
    fetchPortalActivity();
  }

  Future<void> fetchPortalActivity() async {
    setState(() => isLoading = true);

    final String fromDate = fromDateController.text;
    final String toDate = toDateController.text;
    final String enquiryNo = enquiryNoController.text;

    final String apiUrl =
        'https://demo.zaron.in:8181/index.php/order/fetch_data_table?page=1&size=100&search=${enquiryNo}&tablename=orders&order_base=121&from_date=$fromDate&to_date=$toDate';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("PortalActivity")) {
          final List<dynamic> activityData = jsonData["PortalActivity"] as List;
          final int count =
              jsonData["totalCount"] as int? ?? activityData.length;

          final List<Map<String, dynamic>> processedData = activityData
              .whereType<Map<String, dynamic>>()
              .map((item) => {
                    'no': item['no']?.toString() ?? '',
                    'id': item['id']?.toString() ?? '',
                    'order_no': item['order_no']?.toString() ?? '',
                    'name': item['name']?.toString() ?? '',
                    'phone': item['phone']?.toString() ?? '',
                    'totalamount': item['totalamount']?.toString() ?? '0',
                    'enquiry_date': item['enquiry_date']?.toString() ?? '',
                  })
              .toList();

          setState(() {
            tableData = processedData;
            filteredData = List.from(tableData);
            totalRecords = count;
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
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
        // Trigger data fetch when date changes
        fetchPortalActivity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown,
        title: Subhead(
            text: "Total Enquiry",
            weight: FontWeight.w500,
            color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              // await _downloadExcelFile(filteredData);
            },
            icon: const Icon(Icons.download, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters in single row with better spacing
          Container(
            padding: const EdgeInsets.all(
                16), // Increased padding for better spacing
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // From Date
                  SizedBox(
                    height: size.height * 0.06,
                    width: size.width * 0.40,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: fromDateController,
                        // enabled: false,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "From Date",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          suffixIcon: InkWell(
                              onTap: () =>
                                  _selectDate(context, fromDateController),
                              child: Icon(Icons.calendar_today, size: 18)),
                        ),
                      ),
                    ),
                  ),
                  Gap(8),

                  // To Date
                  SizedBox(
                    height: size.height * 0.06,
                    width: size.width * 0.40,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        readOnly: true,
                        controller: toDateController,
                        // enabled: false,
                        decoration: InputDecoration(
                          labelText: "To Date",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          suffixIcon: InkWell(
                              onTap: () =>
                                  _selectDate(context, toDateController),
                              child: Icon(Icons.calendar_today, size: 18)),
                        ),
                      ),
                    ),
                  ),
                  Gap(8),

                  // Enquiry No (with auto-filter)
                  SizedBox(
                    height: size.height * 0.06,
                    width: size.width * 0.40,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: TextField(
                        controller: enquiryNoController,
                        decoration: InputDecoration(
                          labelText: "Enquiry No",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          suffixIcon: Icon(Icons.search, size: 25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total Records Counter
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16), // Increased padding
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Records: $totalRecords',
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
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          dataRowHeight: 60,
                          // Increased for better readability
                          columnSpacing: 22,
                          // Increased spacing
                          headingRowHeight: 56,
                          // Increased header height
                          columns: [
                            DataColumn(
                              label: Text(
                                '#',
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
                                'Enquiry No',
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
                                'Total',
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
                                'Enquiry Date (Created)',
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
                                    entry.value['no'] ?? '',
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
                                    entry.value['order_no'] ?? '',
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
                                    entry.value['totalamount'] ?? '0',
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
                                    entry.value['enquiry_date'] ?? '',
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
                                          // View details action
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "View details for ${entry.value['order_no']}")),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.green),
                                        onPressed: () {
                                          // Edit action
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Edit ${entry.value['order_no']}")),
                                          );
                                        },
                                      ),
                                    ],
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
        ],
      ),
    );
  }
}
