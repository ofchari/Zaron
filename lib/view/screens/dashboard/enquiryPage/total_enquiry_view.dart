import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaron/view/universal_api/api_key.dart';
import 'package:zaron/view/widgets/buttons.dart';
import 'package:zaron/view/widgets/text.dart';

import '../../../getx/summary_screen.dart';
import '../../../widgets/subhead.dart';
import '../../global_user/global_user.dart';
import '../quotationPage/quotation.dart';

class TotalEnquiryView extends StatefulWidget {
  const TotalEnquiryView({super.key, required this.id});

  final String id;

  @override
  State<TotalEnquiryView> createState() => _TotalEnquiryViewState();
}

class _TotalEnquiryViewState extends State<TotalEnquiryView> {
  // Map<String, int?> selectedRowIndices = {};
  //
  // String categoryName = '';
  // final remarkController = TextEditingController();
  // List<Map<String, dynamic>> allDataTables = [];
  Map<String, int?> selectedRowIndices = {};
  Map<String, TextEditingController> remarkControllers = {}; // Add this line
  String categoryName = '';
  List<Map<String, dynamic>> allDataTables = [];
  late double height;
  late double width;

  List<String> labels = [];
  List<Map<String, dynamic>> data = [];
  Map<String, dynamic> uomOptions = {};

  Map<String, dynamic> billingOptions = {};

  bool isLoading = true;
  Map<String, dynamic> additionalInfo = {};
  Map<String, dynamic> additionalValues = {};

  bool _isSnackBarVisible = false;

  @override
  void initState() {
    super.initState();
    fetchTableData();
    print(widget.id);
  }

  Future<void> fetchTableData() async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/rowlabels/${widget.id}'));

      if (response.statusCode == 200) {
        print("total amt check ${response.body}");
        final jsonData = json.decode(response.body);
        final categories = jsonData['categories'];

        debugPrint("thisss r ${response.body}");

        setState(() {
          isLoading = false;
          allDataTables = categories.map<Map<String, dynamic>>((category) {
            return {
              'categoryName': category['category_name'],
              'labels': List<String>.from(category['labels']),
              'data': List<Map<String, dynamic>>.from(category['data']),
            };
          }).toList();

// Set categoryName to first category's name if available
          if (allDataTables.isNotEmpty) {
            categoryName = allDataTables[0]['categoryName'] ?? '';
          } else {
            categoryName = '';
          }
        });
      } else {
        setState(() {
          isLoading = false;
          categoryName = '';
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        categoryName = '';
      });
      print('Error fetching table data: $e');
    }
  }

  Future<void> fetchAdditionalInfo(String itemId) async {
    final response = await http.get(Uri.parse("$apiUrl/add_info/$itemId"));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      try {
        setState(() {
          additionalInfo = jsonData['data'] ?? {};
          additionalValues = {};
          for (var key in additionalInfo.keys) {
            final entry = additionalInfo[key];
            if (entry is Map && entry.containsKey('value')) {
              additionalValues[key] = entry['value'];
            }
          }
        });
      } catch (e) {
        print('Error parsing additional info: $e');
      }
    } else {
      print('Failed to load additional info: ${response.statusCode}');
    }
  }

  void openAdditionalDrawer(String itemId) async {
    // Create a new controller for this specific item if it doesn't exist
    remarkControllers.putIfAbsent(itemId, () => TextEditingController());
    await fetchAdditionalInfo(itemId);

    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Subhead(
                    text: "Additional Information",
                    weight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkControllers[itemId]!,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Remarks",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: additionalInfo.length,
                      itemBuilder: (context, index) {
                        final entry = additionalInfo.entries.elementAt(index);
                        final key = entry.key;
                        final value = entry.value;

                        if (value is! Map || !value.containsKey('options')) {
                          return const SizedBox.shrink();
                        }

                        final options =
                            Map<String, String>.from(value['options']);
                        final selectedValue = additionalValues[key];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: key,
                                weight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: options.containsKey(selectedValue)
                                    ? selectedValue
                                    : null,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                hint: Text(
                                  "Select option",
                                  style: GoogleFonts.figtree(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    additionalValues[key] = newValue!;
                                  });
                                },
                                items: options.entries.map((entry) {
                                  return DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: MyText(
                                      text: entry.value,
                                      weight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      postAdditionalInfo(itemId);
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Buttons(
                        text: "Save",
                        weight: FontWeight.w500,
                        color: Colors.blue,
                        height: height / 20.5,
                        width: width / 4,
                        radius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> postAdditionalInfo(String itemId) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> payload = {
      "id": itemId,
      "remarks": remarkControllers[itemId]?.text ?? '',
      ...additionalValues,
    };
    print("User Input Data Fields$payload");

    final url = "$apiUrl/storeaddinfo";
    final body = json.encode(payload);

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("This is the status code${response.statusCode}");
      if (response.statusCode == 200) {
        print("this is a post Data response : ${response.body}");
        Get.snackbar(
          "Success",
          "Data Added Successfully",
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  /// Create Quotation Post Method ///
  Future<void> postCreateQuotation(BuildContext context) async {
    final headers = {"Content-Type": "application/json"};
    final payload = {
      "customer_id": UserSession().userId,
      "order_id": widget.id,
    };
    print("User Input Data Fields $payload");

    final url = "$apiUrl/createquotation";
    final body = json.encode(payload);

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("This is the status code ${response.statusCode}");

      if (response.statusCode == 200) {
        print("This is a post Data response: ${response.body}");
        Get.to(QuotationPage());

        if (_isSnackBarVisible) return;

        _isSnackBarVisible = true;
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                content: Text("Create Quotation Successfully"),
                duration: Duration(seconds: 2),
              ),
            )
            .closed
            .then((_) {
          _isSnackBarVisible = false;
        });

        // Or if you prefer Get.snackbar:
        // Get.snackbar("Success", "Quotation created successfully", ...);
      }
    } catch (e) {
      print("Error: $e");
      // Handle error snackbar or dialog if needed
    }
  }

  /// Overview Post method ///
  Future<void> postOverView() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final payload = {
      // "customer_id": UserSession().userId,
      "order_id": widget.id,
    };
    print("User Input Data Fields$payload");
    final url = "$apiUrl/enquiry_overview";
    final body = json.encode(payload);
    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("This is the status code${response.statusCode}");
      if (response.statusCode == 200) {
        print(response.body);
        print(response.statusCode);
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
  void dispose() {
    // Dispose all controllers
    remarkControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

// Inside your _TotalEnquiryViewState class

  Future<void> deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text(
            "Are you sure you want to delete this item?",
            style: GoogleFonts.outfit(
                textStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: Buttons(
                text: "No",
                weight: FontWeight.w500,
                color: Colors.green,
                height: height / 18.5,
                width: width / 4.2,
                radius: BorderRadius.circular(15),
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: Buttons(
                    text: "Yes",
                    weight: FontWeight.w500,
                    color: Colors.red,
                    height: height / 18.5,
                    width: width / 4.2,
                    radius: BorderRadius.circular(15))),
          ],
        );
      },
    );

    if (confirm != true) return;

    final response = await http.delete(
      Uri.parse('$apiUrl/enquirydelete/$itemId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Remove the item from all data tables
        for (var table in allDataTables) {
          List<Map<String, dynamic>> tableData = table['data'];
          tableData.removeWhere((row) => row['id'] == itemId);
        }

        // Remove any tables that are now empty
        allDataTables.removeWhere((table) => table['data'].isEmpty);
      });
      print(data);
      print(itemId);

      Get.snackbar("Item deleted from Enquiry", "deleted successfully",
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to delete the item.")),
      );
    }
  }

  /// Group Post logic in Show dialog //
  void openGroupDialog(String itemId) {
    final TextEditingController countController = TextEditingController();
    final BuildContext rootContext =
        context; // Capture it from the parent widget

    showDialog(
      context: rootContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Grouping",
              style: GoogleFonts.outfit(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          content: TextFormField(
            controller: countController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Count",
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Buttons(
                    text: "Cancel",
                    weight: FontWeight.w500,
                    color: Colors.grey,
                    height: height / 18.5,
                    width: width / 4.2,
                    radius: BorderRadius.circular(15))),
            GestureDetector(
                onTap: () async {
                  final count = countController.text.trim();

                  if (count.isEmpty) {
                    Navigator.of(context).pop(); // close first
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                        const SnackBar(content: Text("Please enter a count.")));
                    return;
                  }

                  Navigator.of(context).pop(); // Close dialog

                  final Map<String, dynamic> payload = {
                    "id": itemId,
                    "count": int.parse(count),
                  };

                  print("Sending POST data to $apiUrl/grouping");
                  print("Payload: $payload");

                  final response = await http.post(
                    Uri.parse("$apiUrl/grouping"),
                    headers: {"Content-Type": "application/json"},
                    body: json.encode(payload),
                  );

                  print("Response status: ${response.statusCode}");
                  print("Response body: ${response.body}");

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Group posted successfully."),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text("Failed to post group."),
                      ),
                    );
                  }
                },
                child: Buttons(
                    text: "Save",
                    weight: FontWeight.w500,
                    color: Colors.blue,
                    height: height / 18.5,
                    width: width / 4.2,
                    radius: BorderRadius.circular(15))),
          ],
        );
      },
    );
  }

// Add this variable at the top of your class
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if (width <= 450) {
        return _smallBuildLayout();
      } else {
        return const Center(
            child: Text("Please make sure your device is in portrait view"));
      }
    });
  }

  Widget _smallBuildLayout() {
    return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade200,
                  Colors.blue,
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
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: MyText(
                text: "Total Enquiry View",
                weight: FontWeight.w600,
                color: Colors.white),
          ),
          actions: [
            // Language icon in a rounded glassmorphic container
            GestureDetector(
              onTap: () {
                postOverView();
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Gap(8),
            // Add icon in a rounded glassmorphic container
            GestureDetector(
              onTap: () {
                postCreateQuotation(context);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            Gap(8),
            // Summary icon in a rounded glassmorphic container with adjusted color for contrast
            GestureDetector(
              onTap: () {
                Get.to(SummaryScreen());
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                // Remove default padding to fit perfectly in container
                constraints: BoxConstraints(),
                child: Icon(
                  Icons.note_alt_sharp,
                  color: Colors
                      .white, // Changed to white for consistency and better contrast
                  size: 20,
                ),
              ),
            ),
            Gap(10),
          ],
        ),
        body: isLoading
            ? SafeArea(child: const Center(child: CircularProgressIndicator()))
            : allDataTables.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200.w,
                          height: 200.h,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/No data-pana.png"))),
                        ),
                        Gap(10),
                        Text(
                          "No Data Found",
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Gap(15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isGridView = !isGridView;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isGridView
                                      ? Colors.blue.shade300.withOpacity(0.5)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.grid_view,
                                  color: isGridView
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  size: 24,
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: !isGridView
                                      ? Colors.blue.shade300.withOpacity(0.5)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.view_list,
                                  color: !isGridView
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: allDataTables.map((table) {
                                  List<String> labels =
                                      List<String>.from(table['labels']);
                                  List<Map<String, dynamic>> data =
                                      List<Map<String, dynamic>>.from(
                                          table['data']);
                                  String categoryName = table['categoryName'];

                                  // Get UOM/Billing options from first row if available
                                  Map<String, dynamic> uomOptions = {};
                                  Map<String, dynamic> billingOptions = {};

                                  if (data.isNotEmpty &&
                                      data[0]['UOM'] is Map) {
                                    uomOptions = Map<String, dynamic>.from(
                                        data[0]['UOM']['options']);
                                  }
                                  if (data.isNotEmpty &&
                                      data[0]['Billing Option'] is Map) {
                                    billingOptions = Map<String, dynamic>.from(
                                        data[0]['Billing Option']['options']);
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            categoryName.isNotEmpty
                                                ? categoryName
                                                : 'No Category',
                                            style: GoogleFonts.outfit(
                                              textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Gap(10),
                                      // Conditional rendering based on isGridView
                                      isGridView
                                          ? _buildGridView(
                                              data,
                                              labels,
                                              categoryName,
                                              uomOptions,
                                              billingOptions)
                                          : _buildTableView(
                                              data,
                                              labels,
                                              categoryName,
                                              uomOptions,
                                              billingOptions),
                                      Gap(35)
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ));
  }

// Original table view method
  Widget _buildTableView(
      List<Map<String, dynamic>> data,
      List<String> labels,
      String categoryName,
      Map<String, dynamic> uomOptions,
      Map<String, dynamic> billingOptions) {
    return Scrollbar(
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
              color: Colors.blue.withOpacity(0.3),
              width: 1,
              borderRadius: BorderRadius.circular(12),
            ),
            columnSpacing: 40,
            headingRowHeight: 70,
            columns: labels
                .map((label) => DataColumn(
                      label: MyText(
                        text: label,
                        weight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ))
                .toList(),
            rows: data.asMap().entries.map((entry) {
              int rowIndex = entry.key;
              Map<String, dynamic> row = entry.value;
              return DataRow(
                onSelectChanged: (selected) {
                  setState(() {
                    if (selectedRowIndices[categoryName] == rowIndex) {
                      selectedRowIndices.remove(categoryName);
                    } else {
                      selectedRowIndices[categoryName] = rowIndex;
                    }
                  });
                },
                color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> state) {
                  if (selectedRowIndices[categoryName] == rowIndex) {
                    return Colors.grey.shade200;
                  }
                  return null;
                }),
                cells: labels.map((label) {
                  return _buildDataCell(label, row, uomOptions, billingOptions);
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

// New grid view method
  Widget _buildGridView(
      List<Map<String, dynamic>> data,
      List<String> labels,
      String categoryName,
      Map<String, dynamic> uomOptions,
      Map<String, dynamic> billingOptions) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> row = data[index];
          bool isSelected = selectedRowIndices[categoryName] == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (selectedRowIndices[categoryName] == index) {
                  selectedRowIndices.remove(categoryName);
                } else {
                  selectedRowIndices[categoryName] = index;
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action buttons at the top
                    if (labels.contains("Action"))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.groups,
                                color: Colors.blue, size: 20),
                            onPressed: () {
                              final itemId = row['id'];
                              if (itemId != null) {
                                openGroupDialog(itemId);
                              }
                            },
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              final itemId = row['id'];
                              if (itemId != null) {
                                deleteItem(itemId);
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.settings,
                                color: Colors.green, size: 20),
                            onPressed: () {
                              final itemId = row['id'];
                              if (itemId != null) {
                                openAdditionalDrawer(itemId);
                              }
                            },
                          ),
                        ],
                      ),
                    Gap(8),
                    // Other fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: labels
                              .where((label) => label != "Action")
                              .map((label) {
                            var value = row[label];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Gap(4),
                                  _buildEnhancedGridField(
                                      label, row, uomOptions, billingOptions),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

// Helper method to build data cells (same logic as before)
  DataCell _buildDataCell(String label, Map<String, dynamic> row,
      Map<String, dynamic> uomOptions, Map<String, dynamic> billingOptions) {
    var value = row[label];

    if (label == "UOM" && value is Map) {
      String selectedValue = value['value'];
      return DataCell(
        DropdownButton<String>(
          value: selectedValue,
          style: GoogleFonts.outfit(
            textStyle: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          onChanged: (newValue) {
            setState(() {
              row[label]['value'] = newValue!;
            });
          },
          items: uomOptions.entries
              .map((entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ))
              .toList(),
        ),
      );
    } else if (label == "Billing Option" && value is Map) {
      String selectedValue = value['value'];
      return DataCell(
        DropdownButton<String>(
          value: billingOptions.containsKey(selectedValue)
              ? selectedValue
              : billingOptions.keys.first,
          style: GoogleFonts.outfit(
            textStyle: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          onChanged: (newValue) {
            setState(() {
              row[label]['value'] = newValue!;
            });
          },
          items: billingOptions.entries
              .map((entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ))
              .toList(),
        ),
      );
    } else if (label == "profile" || label == "Nos") {
      return DataCell(
        SizedBox(
          width: 80,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            onChanged: (newVal) {
              setState(() {
                row[label] = newVal;
              });
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      );
    } else if (label == "Action") {
      return DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.groups, color: Colors.blue),
              onPressed: () {
                final itemId = row['id'];
                if (itemId != null) {
                  openGroupDialog(itemId);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                final itemId = row['id'];
                if (itemId != null) {
                  deleteItem(itemId);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.green),
              onPressed: () {
                final itemId = row['id'];
                if (itemId != null) {
                  openAdditionalDrawer(itemId);
                }
              },
            ),
          ],
        ),
      );
    } else {
      return DataCell(
        MyText(
          text: value.toString(),
          weight: FontWeight.w400,
          color: Colors.black,
        ),
      );
    }
  }

// Enhanced grid field builder with modern styling
  Widget _buildEnhancedGridField(String label, Map<String, dynamic> row,
      Map<String, dynamic> uomOptions, Map<String, dynamic> billingOptions) {
    var value = row[label];

    // Create a consistent field container
    Widget fieldWidget;
    Color labelColor = _getLabelColor(label);

    if (label == "UOM" && value is Map) {
      String selectedValue = value['value'];
      fieldWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          underline: SizedBox(),
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.blue.shade600, size: 16),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade800,
          ),
          onChanged: (newValue) {
            setState(() {
              row[label]['value'] = newValue!;
            });
          },
          items: uomOptions.entries
              .map((entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, style: TextStyle(fontSize: 11)),
                  ))
              .toList(),
        ),
      );
    } else if (label == "Billing Option" && value is Map) {
      String selectedValue = value['value'];
      fieldWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.purple.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: billingOptions.containsKey(selectedValue)
              ? selectedValue
              : billingOptions.keys.first,
          isExpanded: true,
          underline: SizedBox(),
          icon: Icon(Icons.keyboard_arrow_down,
              color: Colors.purple.shade600, size: 16),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.purple.shade800,
          ),
          onChanged: (newValue) {
            setState(() {
              row[label]['value'] = newValue!;
            });
          },
          items: billingOptions.entries
              .map((entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, style: TextStyle(fontSize: 11)),
                  ))
              .toList(),
        ),
      );
    } else if (label == "profile" || label == "Nos") {
      fieldWidget = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
          onChanged: (newVal) {
            setState(() {
              row[label] = newVal;
            });
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon:
                Icon(Icons.edit, color: Colors.green.shade400, size: 14),
          ),
        ),
      );
    } else {
      fieldWidget = Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          value.toString(),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: labelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: labelColor.withOpacity(0.4), width: 1),
              ),
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        Gap(4),
        fieldWidget,
      ],
    );
  }

// Helper method to assign colors to different field types
  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'uom':
        return Colors.blue.shade700;
      case 'billing option':
        return Colors.purple.shade700;
      case 'profile':
      case 'nos':
        return Colors.green.shade700;
      case 'id':
        return Colors.orange.shade700;
      case 'name':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}
