import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:zaron/view/widgets/subhead.dart';

class OpenEnquiryPage extends StatefulWidget {
  const OpenEnquiryPage({super.key});

  @override
  State<OpenEnquiryPage> createState() => _OpenEnquiryPageState();
}

class _OpenEnquiryPageState extends State<OpenEnquiryPage> {
  bool isLoading = true;
  List<dynamic> data = [];

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    String url =
        "https://demo.zaron.in:8181/index.php/order/fetch_data_table?page=1&size=10&search=&tablename=orders&order_base=0&from_date=2025-05-13&to_date=2025-05-13";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final portalList = json['PortalActivity'];

        if (mounted) {
          setState(() {
            data = portalList;
            isLoading = false;
          });
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  int selectedRecords = 10;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  TextEditingController searchController = TextEditingController();

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: size.width,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Subhead(
                      text: "Open Enquiry",
                      weight: FontWeight.w600,
                      color: Colors.black),
                ),
                Gap(30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTextfield("Record"),
                      Gap(6),
                      SizedBox(
                        height: size.height * 0.06,
                        width: size.width * 0.37,
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd/MM/yyyy').format(fromDate),
                          ),
                          onTap: () => _pickDate(context, true),
                        ),
                      ),
                      Gap(6),
                      SizedBox(
                        height: size.height * 0.06,
                        width: size.width * 0.37,
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd/MM/yyyy').format(toDate),
                          ),
                          onTap: () => _pickDate(context, false),
                        ),
                      ),
                      Gap(6),
                      _buildTextfield("Order No"),

                      // _textfields("Order No"),
                    ],
                  ),
                ),
                Gap(10),
                isLoading
                    ? Expanded(
                        child: Center(child: CircularProgressIndicator()))
                    : Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(
                                  label: Text(
                                "No",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                "Enquiry No",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                "Name",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                "Phone",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                "Total",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                "Enquiry Date",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                              DataColumn(
                                  label: Text(
                                "Action",
                                style: GoogleFonts.outfit(
                                  textStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              )),
                            ],
                            rows: data.asMap().entries.map((entry) {
                              int index = entry.key;
                              var item = entry.value as Map<String, dynamic>;

                              return DataRow(
                                  color:
                                      WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      return entry.key % 2 == 0
                                          ? Colors.white
                                          : Colors.grey.shade200;
                                    },
                                  ),
                                  cells: [
                                    DataCell(Text(
                                      '${item["no"] ?? ''}',
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                          fontSize: 14.2.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                                    DataCell(Text(
                                      item["order_no"] ?? '',
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                          fontSize: 14.2.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                                    DataCell(Text(
                                      item["name"] ?? '',
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                          fontSize: 14.2.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                                    DataCell(Text(
                                      item["phone"] ?? '',
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                          fontSize: 14.2.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                                    DataCell(Text(
                                      "${item["totalamount".toString()] ?? 0.toString()}",
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                          fontSize: 14.2.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                                    DataCell(Text(
                                      item["enquiry_date"] ?? '',
                                      style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(
                                          fontSize: 14.2.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
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
                                  ]);
                            }).toList(),
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextfield(String hinttext) {
    var size = MediaQuery.sizeOf(context);
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.37,
      child: TextFormField(
        decoration:
            InputDecoration(hintText: hinttext, border: OutlineInputBorder()),
      ),
    );
  }
}
