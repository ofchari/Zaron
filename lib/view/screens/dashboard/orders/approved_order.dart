import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaron/view/screens/global_user/global_user.dart';

import '../../../universal_api/api_key.dart';
import '../../../widgets/text.dart';

class ApprovedOrder extends StatefulWidget {
  const ApprovedOrder({super.key});

  @override
  State<ApprovedOrder> createState() => _ApprovedOrderPageState();
}

class _ApprovedOrderPageState extends State<ApprovedOrder> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;
  int totalRecords = 0;
  int? selectedRowIndex;

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

    final String url = '$apiUrl/approvedorder/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("approved_order")) {
          final List<dynamic> enquiryList = jsonData["approved_order"];

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

  /// Overview Post method ///
  Future<void> postOverView(String id) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final payload = {
      "order_id": id,
    };
    print("User Input Data Fields$payload");
    final url = "$apiUrl/order_overview";
    final body = json.encode(payload);
    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("This is the status code${response.statusCode}");
      if (response.statusCode == 200) {
        print("this is a post Data response : ${response.body}");

// Parse the JSON response
        final responseData = json.decode(response.body);

        // Extract the overview URL
        if (responseData['overview'] != null) {
          String overviewUrl = responseData['overview'];

// Remove escape characters from the URL
          overviewUrl = overviewUrl.replaceAll(r'\/', '/');

          print("Original Overview URL: ${responseData['overview']}");
          print("Cleaned Overview URL: $overviewUrl");

// Now open the overview URL in browser
          await openOverviewInBrowser(overviewUrl);
        } else {
          print("Overview URL not found in response");
        }

        Get.snackbar(
          "Success OverView",
          "Data Added Successfully",
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      print("Error posting data: $e");
      throw Exception("Error posting data: $e");
    }
  }

  /// Call the URL to open the overview in browser ///
  Future<void> openOverviewInBrowser(String overviewUrl) async {
    try {
      print("Opening overview URL in browser: $overviewUrl");

// Create Uri object
      Uri uri = Uri.parse(overviewUrl);
      print("Parsed URI: $uri");
      print("URI scheme: ${uri.scheme}");
      print("URI host: ${uri.host}");

// Try different launch methods
      try {
// Method 1: External application
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          print("Successfully launched with externalApplication mode");
          return;
        }
      } catch (e) {
        print("External application launch failed: $e");
      }

      try {
// Method 2: Platform default
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (launched) {
          print("Successfully launched with platformDefault mode");
          return;
        }
      } catch (e) {
        print("Platform default launch failed: $e");
      }

      try {
// Method 3: In-app web view
        bool launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
        if (launched) {
          print("Successfully launched with inAppWebView mode");
          return;
        }
      } catch (e) {
        print("In-app web view launch failed: $e");
      }

// If all methods fail
      print("All launch methods failed");
      Get.snackbar(
        "Error",
        "Could not open the overview URL. All methods failed.",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      print("Error opening overview URL: $e");
      Get.snackbar(
        "Error",
        "Failed to open overview URL: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade400,
                Colors.green.shade100,
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
              text: "Approved Orders",
              weight: FontWeight.w600,
              color: Colors.black87),
        ),
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
              child: TextField(
                controller: enquiryNoController,
                decoration: InputDecoration(
                  labelText: 'Search Enquiry No',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.green),
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
                colors: [Colors.white, Colors.green[50]!],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.green,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.task_alt, color: Colors.green.shade600),
                SizedBox(width: 8.w),
                Text(
                  'Total Records: $totalRecords',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
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
              ? Expanded(child: Center(child: CircularProgressIndicator()))
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
                                  int index = entry.key;

                                  return DataRow(
                                    // Row background color logic
                                    color:
                                        WidgetStateProperty.resolveWith<Color?>(
                                      (Set<WidgetState> states) {
                                        if (selectedRowIndex == index) {
                                          return Colors.grey.shade200;
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
                                      // DataCell(
                                      //   Text(
                                      //     entry.value['id'] ?? '',
                                      //     style: GoogleFonts.dmSans(
                                      //       textStyle: TextStyle(
                                      //         fontSize: 14.sp,
                                      //         fontWeight: FontWeight.w400,
                                      //         color: Colors.black,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
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
                                      DataCell(
                                        Center(
                                          child: IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.blue,
                                                size: 20.sp),
                                            onPressed: () {
                                              final orderId =
                                                  entry.value['id'] ?? '';
                                              if (orderId.isNotEmpty) {
                                                postOverView(orderId);
                                              } else {
                                                Get.snackbar(
                                                  "Missing ID",
                                                  "Order ID is not available for this row.",
                                                  backgroundColor:
                                                      Colors.orange,
                                                  colorText: Colors.white,
                                                );
                                              }
                                            },
                                          ),
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
