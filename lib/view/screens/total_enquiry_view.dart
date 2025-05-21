import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  late double height;
  late double width;
  String categoryName = '';

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
    fetchAdditionalInfo();
  }

  Future<void> fetchTableData() async {
    final response =
        await http.get(Uri.parse('$apiUrl/rowlabels/${widget.id}'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final category = jsonData['categories'][0];
      print(response.body);
      print(response.statusCode);

      setState(() {
        categoryName = category['category_name'];
        labels = List<String>.from(category['labels']);
        data = List<Map<String, dynamic>>.from(category['data']);
        isLoading = false;
      });

      if (data.isNotEmpty && data[0]['UOM'] is Map) {
        uomOptions = Map<String, dynamic>.from(data[0]['UOM']['options']);
      }

      if (data.isNotEmpty && data[0]['Billing Option'] is Map) {
        billingOptions =
            Map<String, dynamic>.from(data[0]['Billing Option']['options']);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAdditionalInfo() async {
    final response = await http.get(Uri.parse("$apiUrl/add_info"));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        additionalInfo = jsonData['data'];
        additionalValues = {
          for (var key in additionalInfo.keys) key: additionalInfo[key]['value']
        };
      });
    }
  }

  void openAdditionalDrawer() {
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
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Subhead(
                      text: "Additional Information",
                      weight: FontWeight.w500,
                      color: Colors.black),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: additionalInfo.length,
                      itemBuilder: (context, index) {
                        final entry = additionalInfo.entries.elementAt(index);
                        final key = entry.key;
                        final options =
                            Map<String, String>.from(entry.value['options']);
                        final selectedValue = additionalValues[key] ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  text: key,
                                  weight: FontWeight.w400,
                                  color: Colors.black),
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
                                      textStyle: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black)),
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
                                        color: Colors.black),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Gap(7),
                  Center(
                    child: Buttons(
                        text: "Save",
                        weight: FontWeight.w500,
                        color: Colors.blue,
                        height: height / 20.5,
                        width: width / 4,
                        radius: BorderRadius.circular(5)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  //// Poscope for delete ///

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
          : Column(
              children: [
                Gap(5),
                Text(
                  categoryName.toString(),
                  style: GoogleFonts.outfit(
                      textStyle: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey)),
                ),
                Gap(20),
                Expanded(
                  child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            border: TableBorder.all(
                                color: Colors.purple, width: 0.5),
                            dataRowHeight: 60,
                            columnSpacing: 40,
                            headingRowHeight: 56,
                            columns: labels
                                .map((label) => DataColumn(
                                    label: MyText(
                                        text: label,
                                        weight: FontWeight.w500,
                                        color: Colors.black)))
                                .toList(),
                            rows: data.map((row) {
                              return DataRow(
                                cells: labels.map((label) {
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
                                                color: Colors.black)),
                                        onChanged: (newValue) {
                                          setState(() {
                                            row[label]['value'] = newValue!;
                                          });
                                        },
                                        items: uomOptions.entries
                                            .map((entry) =>
                                                DropdownMenuItem<String>(
                                                  value: entry.key,
                                                  child: Text(entry.value),
                                                ))
                                            .toList(),
                                      ),
                                    );
                                  } else if (label == "Billing Option" &&
                                      value is Map) {
                                    String selectedValue = value['value'];
                                    return DataCell(
                                      DropdownButton<String>(
                                        style: GoogleFonts.outfit(
                                            textStyle: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)),
                                        value: billingOptions
                                                .containsKey(selectedValue)
                                            ? selectedValue
                                            : billingOptions.keys.first,
                                        onChanged: (newValue) {
                                          setState(() {
                                            row[label]['value'] = newValue!;
                                          });
                                        },
                                        items: billingOptions.entries
                                            .map((entry) =>
                                                DropdownMenuItem<String>(
                                                  value: entry.key,
                                                  child: Text(entry.value),
                                                ))
                                            .toList(),
                                      ),
                                    );
                                  } else if (label == "Length" ||
                                      label == "Nos") {
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (label == "Action") {
                                    return DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.groups,
                                                color: Colors.blue),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              final itemId = row['id'];
                                              if (itemId != null) {
                                                deleteItem(itemId);
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.settings,
                                                color: Colors.grey),
                                            onPressed: () {
                                              openAdditionalDrawer();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return DataCell(MyText(
                                        text: value.toString(),
                                        weight: FontWeight.w400,
                                        color: Colors.black));
                                  }
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                ),
              ],
            ),
    );
  }
}
