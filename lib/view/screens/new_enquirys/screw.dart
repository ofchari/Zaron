import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

import '../global_user/global_user.dart';

class Screw extends StatefulWidget {
  const Screw({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Screw> createState() => _ScrewState();
}

class _ScrewState extends State<Screw> {
  late TextEditingController editController;

  String? selectedBrand;
  String? selectedScrew;
  String? selectedThread;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> brandList = [];
  List<String> screwLengthList = [];
  List<String> threadList = [];

  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchBrand();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrand() async {
    setState(() {
      brandList = [];
      selectedBrand = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/7');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print(response.body);

        if (message is List && message.length > 1) {
          final brands = message[1];
          if (brands is List) {
            setState(() {
              brandList = brands
                  .whereType<Map>()
                  .map((e) => e["brand"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

  /// fetch Screw Api's ///
  Future<void> _fetchScrew() async {
    if (selectedBrand == null) return;

    setState(() {
      screwLengthList = [];
      selectedScrew = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "length_of_screw",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand],
          "base_label_filters": ["brand"],
          "base_category_id": "7",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print("Fetching screws for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (message is List && message.length > 1) {
          final screws = message[0];
          if (screws is List) {
            setState(() {
              screwLengthList = screws
                  .whereType<Map>()
                  .map((e) => e["length_of_screw"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      print("Exception fetching screw: $e");
    }
  }

  /// fetch Types of thread Api's ///
  Future<void> _fetchThreads() async {
    if (selectedBrand == null || selectedScrew == null) return;

    setState(() {
      threadList = [];
      selectedThread = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "type_of_thread",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand, selectedScrew],
          "base_label_filters": ["brand", "length_of_screw"],
          "base_category_id": "7",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);
        print(response.statusCode);
        final message = data["message"]["message"];
        print("Fetching thread types for screw: $selectedScrew");
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          // Extract thread types from first list
          final threadTypes = message[0];
          if (threadTypes is List) {
            setState(() {
              threadList = threadTypes
                  .whereType<Map>()
                  .map((e) => e["type_of_thread"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          // Extract product_base_id and base_product_id from second list
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString(); // <-- Add this
            print("Selected Base Product ID: $selectedProductBaseId");
            print(
                "Base Product Name: $selectedBaseProductName"); // <-- Optional debug
          }
        }
      }
    } catch (e) {
      print("Exception fetching thread types: $e");
    }
  }

// 1. ADD NEW VARIABLES AT THE TOP OF _ScrewState CLASS (after existing variables)
  List<dynamic> responseData = [];
  Map<String, dynamic>? apiResponse;

// 2. MODIFY postScrewData() METHOD - Replace the existing method with this:
  Future<void> postScrewData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": 7,
      "category_name": "Screw"
    };

    print("User input Data: $data");
    final url = "$apiUrl/addbag";
    final body = jsonEncode(data);
    try {
      final response =
          await ioClient.post(Uri.parse(url), body: body, headers: headers);

      debugPrint("This is a response: ${response.body}");
      if (selectedBrand == null ||
          selectedScrew == null ||
          selectedThread == null) {
        return;
      }
      if (response.statusCode == 200) {
        // Parse the API response
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          apiResponse = decodedResponse;
          if (decodedResponse["lebels"] != null &&
              decodedResponse["lebels"].isNotEmpty) {
            final categoryData = decodedResponse["lebels"][0];
            if (categoryData["data"] != null) {
              responseData = categoryData["data"];
            }
          }
        });
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

// 3. MODIFY _submitData() METHOD - Replace existing method with this:
  void _submitData() {
    if (selectedBrand == null ||
        selectedScrew == null ||
        selectedThread == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Form'),
          content: Text('Please fill all required fields to add a product.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      selectedBrand = null;
      selectedScrew = null;
      selectedThread = null;
      brandList = [];
      screwLengthList = [];
      threadList = [];
      _fetchBrand();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Product added successfully"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

// 4. REPLACE _buildSubmittedDataList() METHOD with this:
  Widget _buildSubmittedDataList() {
    if (responseData.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No products added yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (apiResponse?["order_id"] != null)
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  "Order ID: ${apiResponse!["order_id"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ...responseData.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> data = entry.value;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header with product name and delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "${data["S.No"]}. ${data["Products"] ?? 'N/A'}",
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "ID: ${data['id']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 40.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.deepPurple[50],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Delete Item"),
                                content: Text(
                                    "Are you sure you want to delete this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        responseData.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Editable fields in organized rows
                _buildApiResponseRows(data),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

// 5. ADD NEW METHOD for API response data rows:
  Widget _buildApiResponseRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem("UOM", _uomDropdownForApi(data)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Length", _editableTextFieldForApi(data, "Length")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Qty/Nos", _editableTextFieldForApi(data, "Nos")),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                    "Basic Rate", _editableTextFieldForApi(data, "Basic Rate")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Amount", _editableTextFieldForApi(data, "Amount")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Billing Options", _billingOptionsDropdown(data)),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

// 6. ADD NEW HELPER METHODS:
  Widget _editableTextFieldForApi(Map<String, dynamic> data, String key) {
    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: TextEditingController(text: data[key]?.toString() ?? "0"),
        onChanged: (val) => data[key] = val,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _uomDropdownForApi(Map<String, dynamic> data) {
    List<String> uomOptions = ["Feet", "mm", "cm", "Inches", "Meters"];
    // Set default UOM if not present
    if (data["UOM"] == null) data["UOM"] = "Feet";

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: data["UOM"],
        items: uomOptions
            .map((uom) => DropdownMenuItem(value: uom, child: Text(uom)))
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = val!;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _billingOptionsDropdown(Map<String, dynamic> data) {
    List<String> billingOptions = [
      "Per Unit",
      "Per Meter",
      "Per Foot",
      "Bulk",
      "Custom"
    ];
    // Set default billing option if not present
    if (data["BillingOption"] == null) data["BillingOption"] = "Per Unit";

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: data["BillingOption"],
        items: billingOptions
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (val) {
          setState(() {
            data["BillingOption"] = val!;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, Widget field) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          field,
        ],
      ),
    );
  }

  ///Preview text///
  String _selectedItems() {
    List<String> selectedData = [
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedScrew != null) "Length of Screw: $selectedScrew",
      if (selectedThread != null) "Thread: $selectedThread",
    ];
    return selectedData.isEmpty ? "No Selection Yet" : selectedData.join(", ");
  }

  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged,
      {bool enabled = true, String? label}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        items: items,
        selectedItem: selectedValue,
        onChanged: enabled ? onChanged : null,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label ?? "Select",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        enabled: enabled,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Screw',
          weight: FontWeight.w500,
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Subhead(
                              text: "Add New Product",
                              weight: FontWeight.w600,
                              color: Colors.black),
                          SizedBox(height: 16),
                          _buildDropdown(brandList, selectedBrand, (value) {
                            setState(() {
                              selectedBrand = value;

// Clear dependent fields
                              selectedScrew = null;
                              selectedThread = null;
                              screwLengthList = [];
                              threadList = [];
                            });
                            _fetchScrew();
                          }, label: "Brand"),
                          _buildDropdown(screwLengthList, selectedScrew,
                              (value) {
                            setState(() {
                              selectedScrew = value;
// Clear dependent fields
                              selectedThread = null;
                              threadList = [];
                            });
                            _fetchThreads();
                          },
                              enabled: screwLengthList.isNotEmpty,
                              label: "Length of Screw"),
                          _buildDropdown(threadList, selectedThread, (value) {
                            setState(() {
                              selectedThread = value;
                            });
                          },
                              enabled: threadList.isNotEmpty,
                              label: "Type of Thread"),
                          Gap(20),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      text: "Selected Product Details",
                                      weight: FontWeight.w600,
                                      color: Colors.black),
                                  Gap(5),
                                  MyText(
                                      text: _selectedItems(),
                                      weight: FontWeight.w400,
                                      color: Colors.grey)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                await postScrewData();
                                _submitData();
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: MyText(
                                  text: "Add Product",
                                  weight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                if (submittedData.isNotEmpty)
                  Subhead(
                      text: "   Added Products",
                      weight: FontWeight.w600,
                      color: Colors.black),
                SizedBox(height: 8),
                _buildSubmittedDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
