import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/dashboard/quotationPage/total_quoation_view.dart';
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/universal_api/api_key.dart';

import '../../../widgets/text.dart';

///part 1

class QuotationPage extends StatefulWidget {
  const QuotationPage({super.key});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
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

  void _onEnquiryNumberChanged() {
    filterData();
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

  Future<void> fetchEnquiryData() async {
    setState(() => isLoading = true);

    final String url = '$apiUrl/totalquotation/${UserSession().userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("total_quotation")) {
          final List<dynamic> enquiryList = jsonData["total_quotation"];

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
    return Scaffold(
      backgroundColor: Colors.purple[50],
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
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: MyText(
              text: "Total Quotation",
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
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
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
                padding: const EdgeInsets.all(8),
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
                        labelText: 'Quotation No',
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
              Gap(10),
              Container(
                // margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                padding: EdgeInsets.all(14.r),
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
              Gap(10),
              isLoading
                  ? Expanded(child: Center(child: CircularProgressIndicator()))
                  : filteredData.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey.shade100,
                                        Colors.grey.shade200,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.inbox_outlined,
                                    size: 60,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'No records found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try adjusting your filters',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              var row = filteredData[index];
                              bool isSelected = selectedRowIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedRowIndex == index) {
                                      selectedRowIndex = null;
                                    } else {
                                      selectedRowIndex = index;
                                    }
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.deepPurple.shade400,
                                              Colors.indigo.shade600,
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.grey.shade50,
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? Colors.deepPurple.shade200
                                            : Colors.grey.shade200,
                                        spreadRadius: isSelected ? 4 : 0,
                                        blurRadius: isSelected ? 25 : 15,
                                        offset: Offset(0, isSelected ? 8 : 4),
                                      ),
                                      if (isSelected)
                                        BoxShadow(
                                          color: Colors.white70,
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: Offset(0, -2),
                                        ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Enhanced decorative elements with gradient orbs
                                      Positioned(
                                        top: -30,
                                        right: -30,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: isSelected
                                                  ? [
                                                      Colors.white70,
                                                      Colors.white24,
                                                    ]
                                                  : [
                                                      Colors.purple.shade100,
                                                      Colors.purple.shade50,
                                                    ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -20,
                                        left: -20,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: isSelected
                                                  ? [
                                                      Colors.white60,
                                                      Colors.white12,
                                                    ]
                                                  : [
                                                      Colors.cyan.shade100,
                                                      Colors.cyan.shade50,
                                                    ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Additional floating elements
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? Colors.white70
                                                : Colors.pink.shade300,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 60,
                                        right: 40,
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? Colors.white60
                                                : Colors.green.shade400,
                                          ),
                                        ),
                                      ),

                                      // Main content with glassmorphism effect
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white70,
                                                    Colors.white54,
                                                  ],
                                                )
                                              : null,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.r),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Header row with enhanced design
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: isSelected
                                                            ? [
                                                                Colors
                                                                    .deepPurple
                                                                    .shade400,
                                                                Colors.indigo
                                                                    .shade600,
                                                              ]
                                                            : [
                                                                Colors.purple
                                                                    .shade400,
                                                                Colors.pink
                                                                    .shade400,
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: isSelected
                                                              ? Colors.white54
                                                              : Colors.purple
                                                                  .shade200,
                                                          blurRadius: 8,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 6,
                                                          height: 6,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          '#${index + 1}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 13.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: isSelected
                                                            ? [
                                                                Colors.white70,
                                                                Colors.white60,
                                                              ]
                                                            : [
                                                                Colors.blue
                                                                    .shade400,
                                                                Colors.cyan
                                                                    .shade400,
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: isSelected
                                                              ? Colors.white54
                                                              : Colors.blue
                                                                  .shade200,
                                                          blurRadius: 8,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .visibility_rounded,
                                                        color: isSelected
                                                            ? Colors.deepPurple
                                                                .shade700
                                                            : Colors.white,
                                                        size: 22,
                                                      ),
                                                      onPressed: () {
                                                        Get.to(() =>
                                                            TotalQuoationView(
                                                              id: row['id'] ??
                                                                  '',
                                                            ));
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(height: 20),

                                              // Order number with premium design
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: isSelected
                                                        ? [
                                                            Colors.deepPurple
                                                                .shade400,
                                                            Colors.indigo
                                                                .shade600,
                                                          ]
                                                        : [
                                                            Colors
                                                                .indigo.shade50,
                                                            Colors.indigo
                                                                .shade100,
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors
                                                            .indigo.shade200,
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: isSelected
                                                          ? Colors.white54
                                                          : Colors
                                                              .indigo.shade100,
                                                      blurRadius: 10,
                                                      offset: Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: isSelected
                                                              ? [
                                                                  Colors
                                                                      .white70,
                                                                  Colors
                                                                      .white60,
                                                                ]
                                                              : [
                                                                  Colors.indigo
                                                                      .shade400,
                                                                  Colors.purple
                                                                      .shade400,
                                                                ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: isSelected
                                                                ? Colors.white54
                                                                : Colors.indigo
                                                                    .shade200,
                                                            blurRadius: 6,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .receipt_long_rounded,
                                                        color: isSelected
                                                            ? Colors.deepPurple
                                                                .shade700
                                                            : Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Order Number',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .indigo
                                                                      .shade600,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2),
                                                          Text(
                                                            row['order_no'] ??
                                                                'N/A',
                                                            style: GoogleFonts
                                                                .dmSans(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : Colors.grey
                                                                      .shade800,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              SizedBox(height: 20),

                                              // Enhanced grid layout with premium cards
                                              Row(
                                                children: [
                                                  // Bill Total with enhanced design
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: isSelected
                                                              ? [
                                                                  Colors
                                                                      .deepPurple
                                                                      .shade400,
                                                                  Colors.indigo
                                                                      .shade600
                                                                ]
                                                              : [
                                                                  Colors.green
                                                                      .shade50,
                                                                  Colors.green
                                                                      .shade100,
                                                                ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : Colors.green
                                                                  .shade200,
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: isSelected
                                                                ? Colors.white54
                                                                : Colors.green
                                                                    .shade100,
                                                            blurRadius: 8,
                                                            offset:
                                                                Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(6),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors:
                                                                        isSelected
                                                                            ? [
                                                                                Colors.white70,
                                                                                Colors.white60,
                                                                              ]
                                                                            : [
                                                                                Colors.green.shade400,
                                                                                Colors.green.shade500,
                                                                              ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .currency_rupee_rounded,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .deepPurple
                                                                          .shade700
                                                                      : Colors
                                                                          .white,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'Bill Total',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize:
                                                                      11.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .green
                                                                          .shade700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            '₹${row['bill_total'] ?? '0'}',
                                                            style: GoogleFonts
                                                                .dmSans(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : Colors.green
                                                                      .shade800,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: 16),

                                                  // Date & Time with premium design
                                                  Expanded(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: isSelected
                                                              ? [
                                                                  Colors
                                                                      .deepPurple
                                                                      .shade400,
                                                                  Colors.indigo
                                                                      .shade600,
                                                                ]
                                                              : [
                                                                  Colors.orange
                                                                      .shade50,
                                                                  Colors.orange
                                                                      .shade100,
                                                                ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : Colors.orange
                                                                  .shade200,
                                                          width: 1,
                                                        ),
                                                        // boxShadow: [
                                                        //   BoxShadow(
                                                        //     color: isSelected
                                                        //         ? Colors.blue
                                                        //         : Colors.orange
                                                        //             .shade100,
                                                        //     blurRadius: 8,
                                                        //     offset:
                                                        //         Offset(0, 4),
                                                        //   ),
                                                        // ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(6),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                    colors:
                                                                        isSelected
                                                                            ? [
                                                                                Colors.white70,
                                                                                Colors.white60,
                                                                              ]
                                                                            : [
                                                                                Colors.orange.shade400,
                                                                                Colors.orange.shade500,
                                                                              ],
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .access_time_rounded,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .deepPurple
                                                                          .shade700
                                                                      : Colors
                                                                          .white,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'Created',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize:
                                                                      11.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .orange
                                                                          .shade700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            '${row['create_date'] ?? 'N/A'}',
                                                            style: GoogleFonts
                                                                .dmSans(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .orange
                                                                      .shade800,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Text(
                                                            '${row['create_time'] ?? 'N/A'}',
                                                            style: GoogleFonts
                                                                .dmSans(
                                                              fontSize: 11.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isSelected
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors
                                                                      .orange
                                                                      .shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Enhanced selection indicator
                                              if (isSelected) ...[
                                                SizedBox(height: 16),
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.deepPurple
                                                            .shade400,
                                                        Colors.indigo.shade600,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.white54,
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.white70,
                                                              Colors.white60,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .check_circle_rounded,
                                                          color: Colors
                                                              .deepPurple
                                                              .shade700,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        'Selected',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
