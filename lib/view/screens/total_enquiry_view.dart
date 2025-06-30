import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/buttons.dart';
import 'package:zaron/view/widgets/text.dart';

import '../widgets/subhead.dart';

class TotalEnquiryView extends StatefulWidget {
  const TotalEnquiryView({super.key, required this.id});

  final String id;

  @override
  State<TotalEnquiryView> createState() => _TotalEnquiryViewState();
}

class _TotalEnquiryViewState extends State<TotalEnquiryView> {
  Map<String, int?> selectedRowIndices = {};

  String categoryName = '';
  final remarkController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    fetchTableData();
  }

  Future<void> fetchTableData() async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/rowlabels/${widget.id}'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final categories = jsonData['categories'];

        print(response.body);

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
      "remarks": remarkController.text,
      ...additionalValues,
    };
    print("User Input Data Fields${payload}");

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

  @override
  void dispose() {
    remarkController.dispose();
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Item deleted successfully.")),
      );
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: Subhead(
              text: "Total Enquiry View",
              weight: FontWeight.w500,
              color: Colors.black),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
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
                                      Scrollbar(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.all(16.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: DataTable(
                                              showCheckboxColumn: false,
                                              border: TableBorder.all(
                                                color: Colors.purple
                                                    .withOpacity(0.3),
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
                                                          weight:
                                                              FontWeight.w600,
                                                          color: Colors.black,
                                                        ),
                                                      ))
                                                  .toList(),
                                              rows: data
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                int rowIndex = entry.key;
                                                Map<String, dynamic> row =
                                                    entry.value;
                                                return DataRow(
                                                  onSelectChanged: (selected) {
                                                    setState(() {
                                                      if (selected!) {
                                                        selectedRowIndices[
                                                                categoryName] =
                                                            rowIndex;
                                                      } else {
                                                        selectedRowIndices
                                                            .remove(
                                                                categoryName);
                                                      }
                                                    });
                                                  },
                                                  color: MaterialStateProperty
                                                      .resolveWith<Color?>(
                                                          (Set<MaterialState>
                                                              state) {
                                                    if (selectedRowIndices[
                                                            categoryName] ==
                                                        rowIndex) {
                                                      return Colors
                                                          .grey.shade200;
                                                    }
                                                    return null;
                                                  }),
                                                  cells: labels.map((label) {
                                                    var value = row[label];

                                                    if (label == "UOM" &&
                                                        value is Map) {
                                                      String selectedValue =
                                                          value['value'];
                                                      return DataCell(
                                                        DropdownButton<String>(
                                                          value: selectedValue,
                                                          style: GoogleFonts
                                                              .outfit(
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 14.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              row[label][
                                                                      'value'] =
                                                                  newValue!;
                                                            });
                                                          },
                                                          items: uomOptions
                                                              .entries
                                                              .map((entry) =>
                                                                  DropdownMenuItem<
                                                                      String>(
                                                                    value: entry
                                                                        .key,
                                                                    child: Text(
                                                                        entry
                                                                            .value),
                                                                  ))
                                                              .toList(),
                                                        ),
                                                      );
                                                    } else if (label ==
                                                            "Billing Option" &&
                                                        value is Map) {
                                                      String selectedValue =
                                                          value['value'];
                                                      return DataCell(
                                                        DropdownButton<String>(
                                                          value: billingOptions
                                                                  .containsKey(
                                                                      selectedValue)
                                                              ? selectedValue
                                                              : billingOptions
                                                                  .keys.first,
                                                          style: GoogleFonts
                                                              .outfit(
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 14.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          onChanged:
                                                              (newValue) {
                                                            setState(() {
                                                              row[label][
                                                                      'value'] =
                                                                  newValue!;
                                                            });
                                                          },
                                                          items: billingOptions
                                                              .entries
                                                              .map((entry) =>
                                                                  DropdownMenuItem<
                                                                      String>(
                                                                    value: entry
                                                                        .key,
                                                                    child: Text(
                                                                        entry
                                                                            .value),
                                                                  ))
                                                              .toList(),
                                                        ),
                                                      );
                                                    } else if (label ==
                                                            "Length" ||
                                                        label == "Nos") {
                                                      return DataCell(
                                                        SizedBox(
                                                          width: 80,
                                                          child: TextFormField(
                                                            initialValue: value
                                                                .toString(),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onChanged:
                                                                (newVal) {
                                                              setState(() {
                                                                row[label] =
                                                                    newVal;
                                                              });
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else if (label ==
                                                        "Action") {
                                                      return DataCell(
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.groups,
                                                                  color: Colors
                                                                      .blue),
                                                              onPressed: () {
                                                                final itemId =
                                                                    row['id'];
                                                                if (itemId !=
                                                                    null) {
                                                                  openGroupDialog(
                                                                      itemId);
                                                                }
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red),
                                                              onPressed: () {
                                                                final itemId =
                                                                    row['id'];
                                                                if (itemId !=
                                                                    null) {
                                                                  deleteItem(
                                                                      itemId);
                                                                }
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                  Icons
                                                                      .settings,
                                                                  color: Colors
                                                                      .green),
                                                              onPressed: () {
                                                                final itemId =
                                                                    row['id'];
                                                                if (itemId !=
                                                                    null) {
                                                                  openAdditionalDrawer(
                                                                      itemId);
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      return DataCell(
                                                        MyText(
                                                          text:
                                                              value.toString(),
                                                          weight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      );
                                                    }
                                                  }).toList(),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
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
}
