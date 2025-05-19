import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/universal_api/api&key.dart';

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

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTableData();
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
        categoryName = category['category_name']; // Store name here
        labels = List<String>.from(category['labels']);
        data = List<Map<String, dynamic>>.from(category['data']);
        isLoading = false;
      });

      // Extract UOM options from first row
      if (data.isNotEmpty && data[0]['UOM'] is Map) {
        uomOptions = Map<String, dynamic>.from(data[0]['UOM']['options']);
      }
    } else {
      // handle error
      setState(() {
        isLoading = false;
      });
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Subhead(
            text: "Total Enquiry View",
            weight: FontWeight.w500,
            color: Colors.black),
        actions: [
          IconButton(
            onPressed: () async {
              // await _downloadExcelFile(filteredData);
            },
            icon: const Icon(Icons.download, color: Colors.black),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Subhead(
                    text: categoryName.toString(),
                    weight: FontWeight.w500,
                    color: Colors.black),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          border:
                              TableBorder.all(color: Colors.purple, width: 0.5),
                          dataRowHeight: 60,
                          columnSpacing: 40,
                          headingRowHeight: 56,
                          columns: labels
                              .map((label) => DataColumn(label: Text(label)))
                              .toList(),
                          // Inside the DataRow map function
                          rows: data.map((row) {
                            return DataRow(
                              cells: labels.map((label) {
                                var value = row[label];

                                if (label == "UOM" && value is Map) {
                                  String selectedValue = value['value'];
                                  return DataCell(
                                    DropdownButton<String>(
                                      value: selectedValue,
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
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return DataCell(Text(value.toString()));
                                }
                              }).toList(),
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
