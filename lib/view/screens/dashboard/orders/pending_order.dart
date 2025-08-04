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
import 'package:zaron/view/widgets/subhead.dart';

import '../../../universal_api/api&key.dart';

class PendingOrder extends StatefulWidget {
  const PendingOrder({super.key});

  @override
  State<PendingOrder> createState() => _PendingOrderPageState();
}

class _PendingOrderPageState extends State<PendingOrder> {
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
    print("User Input Data Fields${payload}");
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

  Future<void> fetchEnquiryData() async {
    setState(() => isLoading = true);

    final String url = '$apiUrl/pendingorder/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("pending_order")) {
          final List<dynamic> enquiryList = jsonData["pending_order"];

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
            text: "Pending Order",
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
                              // DataColumn(
                              //   label: Text(
                              //     'ID',
                              //     style: GoogleFonts.outfit(
                              //       textStyle: TextStyle(
                              //         fontSize: 16.sp,
                              //         fontWeight: FontWeight.w500,
                              //         color: Colors.black,
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
                                            color: Colors.blue, size: 20.sp),
                                        onPressed: () {
                                          final orderId =
                                              entry.value['id'] ?? '';
                                          if (orderId.isNotEmpty) {
                                            postOverView(orderId);
                                          } else {
                                            Get.snackbar(
                                              "Missing ID",
                                              "Order ID is not available for this row.",
                                              backgroundColor: Colors.orange,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
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
        ],
      ),
    );
  }
}
