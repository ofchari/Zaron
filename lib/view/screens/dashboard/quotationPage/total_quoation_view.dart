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
import 'package:zaron/view/screens/global_user/global_user.dart';
import '../../../universal_api/api&key.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/subhead.dart';
import '../../../widgets/text.dart';

class TotalQuoationView extends StatefulWidget {
  const TotalQuoationView({super.key, required this.id});

  final String id;

  @override
  State<TotalQuoationView> createState() => _TotalQuoationViewState();
}

class _TotalQuoationViewState extends State<TotalQuoationView> {
  final remarkController = TextEditingController();
  int? selectedCategoryId;
  Map<String, int?> selectedIndices = {};
  late double height;
  late double width;

  List<Map<String, dynamic>> categories = [];
  String categoryName = '';
  Map<String, List<String>> categoryLabels = {};
  Map<String, List<Map<String, dynamic>>> categoryData = {};
  List<Map<String, dynamic>> data = [];
  Map<String, dynamic> uomOptions = {};

  bool isLoading = true;
  Map<String, dynamic> additionalInfo = {};
  Map<String, dynamic> additionalValues = {};

  @override
  void initState() {
    super.initState();
    print(widget.id);
    fetchTableData();
  }

  Future<void> fetchTableData() async {
    String url = '$apiUrl/quotation_rowlabels/${widget.id}';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final categoriesData =
              List<Map<String, dynamic>>.from(jsonData['categories']);

          if (categoriesData.isNotEmpty) {
            setState(() {
              categories = categoriesData;
// Store labels and data for each category
              for (var category in categories) {
                final categoryId = category['category_id'].toString();
                categoryLabels[categoryId] =
                    List<String>.from(category['labels'] ?? []);
                categoryData[categoryId] =
                    List<Map<String, dynamic>>.from(category['data'] ?? []);

// Initialize UOM options from all categories
                for (var item in category['data'] ?? []) {
                  if (item['UOM'] is Map && item['UOM']['options'] is Map) {
                    uomOptions.addAll(
                        Map<String, String>.from(item['UOM']['options']));
                  }
                }
              }
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          throw Exception("API returned failure status");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching table data: $e");
      throw Exception("Error fetching table data: $e");
    }
  }

  Future<void> fetchAdditionalInfo(String itemId) async {
    final response =
        await http.get(Uri.parse("$apiUrl/quotation_add_info/$itemId"));

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
                    controller: remarkController,
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
                                  style: GoogleFonts.outfit(
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
      "remarks": remarkController.text,
      ...additionalValues,
    };
    print("User Input Data Fields${payload}");

    final url = "$apiUrl/quotation_storeaddinfo";
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
  Future<void> postCreateQuotation() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final headers = {"Content-Type": "application/json"};
    final payload = {
      "customer_id": UserSession().userId,
      "order_id": widget.id,
    };
    print("User Input Data Fields${payload}");

    final url = "https://demo.zaron.in:8181/ci3app/api/createquotation";
    final body = json.encode(payload);

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("This is the status code${response.statusCode}");
      if (response.statusCode == 200) {
        print("this is a post Data response : ${response.body}");
        Get.snackbar(
          "Success Create Quotation",
          "Data Added Successfully",
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
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
      "customer_id": UserSession().userId,
      "order_id": widget.id,
    };
    print("User Input Data Fields${payload}");
    final url = "$apiUrl/quotation_overview";
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
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  /// Inside your _TotalEnquiryViewState class
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
                    radius: BorderRadius.circular(15))),
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

    final response = await http.get(
      Uri.parse('$apiUrl/enquirydelete/$itemId'),
    );

    if (response.statusCode == 200) {
      final index = data.indexWhere((row) => row['id'] == itemId);
      if (index != -1) {
        setState(() {
          data.removeAt(index);
        });
        print(data);
        print(itemId);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item deleted successfully.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete the item.")),
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

                  print("🔻 Sending POST data to $apiUrl/grouping");
                  print("Payload: $payload");

                  final response = await http.post(
                    Uri.parse("$apiUrl/grouping"),
                    headers: {"Content-Type": "application/json"},
                    body: json.encode(payload),
                  );

                  print("✅ Response status: ${response.statusCode}");
                  print("✅ Response body: ${response.body}");

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
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade200,
                  Colors.deepPurple,
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
            width: width * 0.4, // Give more width to title
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: MyText(
                text: "Total Quotation View",
                weight: FontWeight.w600,
                color: Colors.white),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                postOverView();
              },
              child: Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white, size: 30),
            ),
            Container(
              width: width * 0.17.w,
              height: height * 0.04.h,
              margin: EdgeInsets.only(right: 15, top: 8, bottom: 8),
              child: GestureDetector(
                  onTap: () {
                    postCreateQuotation();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                        MyText(
                            text: "Create",
                            weight: FontWeight.w500,
                            color: Colors.white)
                      ],
                    ),
                  )),
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Gap(5),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: categories.map((category) {
                            final categoryId =
                                category['category_id'].toString();
                            final labels = categoryLabels[categoryId] ?? [];
                            final data = categoryData[categoryId] ?? [];

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    category['category_name'] ?? '',
                                    style: GoogleFonts.outfit(
                                      textStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    notificationPredicate: (notification) =>
                                        notification.depth == 1,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        columnSpacing: 40,
                                        headingRowHeight: 70,
                                        columns: labels
                                            .map((label) => DataColumn(
                                                  label: MyText(
                                                    text: label,
                                                    weight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ))
                                            .toList(),
                                        rows: data.asMap().entries.map((entry) {
                                          int rowIndex = entry.key;
                                          Map<String, dynamic> row =
                                              entry.value;
                                          return DataRow(
                                            color: MaterialStateProperty
                                                .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                                if (selectedCategoryId ==
                                                        int.parse(categoryId) &&
                                                    selectedIndices[
                                                            categoryId] ==
                                                        rowIndex) {
                                                  return Colors.grey.shade200;
                                                }
                                                return null;
                                              },
                                            ),
                                            onSelectChanged: (selected) {
                                              setState(() {
                                                if (selectedCategoryId ==
                                                        int.parse(categoryId) &&
                                                    selectedIndices[
                                                            categoryId] ==
                                                        rowIndex) {
// Deselect if the same row is tapped
                                                  selectedCategoryId = null;
                                                  selectedIndices[categoryId] =
                                                      null;
                                                } else {
// Select the new row
                                                  selectedCategoryId =
                                                      int.parse(categoryId);
                                                  selectedIndices[categoryId] =
                                                      rowIndex;
                                                }
                                              });
                                            },
                                            cells: labels.map((label) {
                                              var value = row[label];

                                              if (label == "UOM" &&
                                                  value is Map) {
                                                String selectedValue =
                                                    value['value'];
                                                return DataCell(
                                                  DropdownButton<String>(
                                                    style: GoogleFonts.outfit(
                                                      textStyle: TextStyle(
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    value: selectedValue,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        row[label]['value'] =
                                                            newValue!;
                                                      });
                                                    },
                                                    items: uomOptions.entries
                                                        .map(
                                                          (entry) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                            value: entry.key,
                                                            child: Text(
                                                                entry.value),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                );
                                              } else if (label == "Nos" ||
                                                  label == "Profile" ||
                                                  label == "Sq.Mtr") {
                                                return DataCell(
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextFormField(
                                                      initialValue:
                                                          value.toString(),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (newVal) {
                                                        setState(() {
                                                          row[label] = newVal;
                                                        });
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else if (label == "Action") {
                                                return DataCell(
                                                  Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.groups,
                                                            color: Colors.blue),
                                                        onPressed: () {
                                                          final itemId =
                                                              row['id'];
                                                          if (itemId != null) {
                                                            openGroupDialog(
                                                                itemId);
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          final itemId =
                                                              row['id'];
                                                          if (itemId != null) {
                                                            deleteItem(itemId);
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.settings,
                                                            color:
                                                                Colors.green),
                                                        onPressed: () {
                                                          final itemId =
                                                              row['id'];
                                                          if (itemId != null) {
                                                            openAdditionalDrawer(
                                                                itemId);
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return DataCell(MyText(
                                                  text: value.toString(),
                                                  weight: FontWeight.w500,
                                                  color: Colors.black,
                                                ));
                                              }
                                            }).toList(),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
// Gap(10),
// Divider(height: 30, thickness: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
