import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

class Aluminum extends StatefulWidget {
  const Aluminum({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Aluminum> createState() => _AluminumState();
}

class _AluminumState extends State<Aluminum> {
  late TextEditingController editController;

  String? selectedBrand;
  String? selectedColor;
  String? selectedThickness;
  String? selectedMaterialType;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<String> materialTypeList = [];
  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    print(UserSession().userId);
    _fetchMaterialType();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaterialType() async {
    setState(() {
      materialTypeList = [];
      selectedMaterialType = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/36');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][1];
        print(response.body);

        if (materials is List) {
          setState(() {
            materialTypeList = materials
                .whereType<Map>()
                .map((e) => e["material_type"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  /// fetch thickness Api's //
  Future<void> _fetchThickness() async {
    if (selectedMaterialType == null) return;

    setState(() {
      thicknessList = [];
      selectedThickness = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedMaterialType],
          "base_label_filters": ["material_type"],
          "base_category_id": "36",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thick = data["message"]["message"][0];
        print("Fetching colors for thick: $selectedMaterialType");
        print("API response: ${response.body}");

        if (thick is List) {
          setState(() {
            thicknessList = thick
                .whereType<Map>()
                .map((e) => e["thickness"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  /// fetch Brand Api's ///
  Future<void> _fetchBrand() async {
    if (selectedMaterialType == null) return;

    setState(() {
      brandsList = [];
      selectedBrand = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "brand",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedMaterialType, selectedThickness],
          "base_label_filters": ["material_type", "thickness"],
          "base_category_id": "36",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brand = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");

        if (brand is List) {
          setState(() {
            brandsList = brand
                .whereType<Map>()
                .map((e) => e["brand"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

//
// /// fetch Color Api's ///
  Future<void> _fetchColor() async {
    if (selectedMaterialType == null) return;

    setState(() {
      colorsList = [];
      selectedColor = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedMaterialType,
            selectedThickness,
            selectedBrand
          ],
          "base_label_filters": ["material_type", "thickness", "brand"],
          "base_category_id": "36",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (data["message"]["message"] is List) {
          final List message = data["message"]["message"];

          // Extract colors
          final colorData = message[0];
          if (colorData is List) {
            setState(() {
              colorsList = colorData
                  .whereType<Map>()
                  .map((e) => e["color"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          // Extract ID and base_product_id
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString(); // <-- New line
            print("Selected Base Product ID: $selectedProductBaseId");
            print(
                "Base Product Name: $selectedBaseProductName"); // <-- New line
          }
        }
      }
    } catch (e) {
      print("Exception fetching color: $e");
    }
  }

  // 1. ADD THESE VARIABLES AT THE TOP OF YOUR CLASS (after existing variables)
  Map<String, dynamic>? apiResponseData;
  List<Map<String, dynamic>> apiProductsList = [];

// 2. MODIFY YOUR postAllData() METHOD - Replace the existing method with this:
  Future<void> postAllData() async {
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
      "category_id": 36,
      "category_name": "Aluminum"
    };

    print("This is a body data: $data");
    final url = "$apiUrl/addbag";
    final body = jsonEncode(data);
    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      debugPrint("This is a response: ${response.body}");

      if (response.statusCode == 200) {
        // Parse and store the API response
        final responseData = jsonDecode(response.body);
        setState(() {
          apiResponseData = responseData;
          if (responseData['lebels'] != null &&
              responseData['lebels'].isNotEmpty) {
            apiProductsList = List<Map<String, dynamic>>.from(
                responseData['lebels'][0]['data']);
          }
        });
      }

      if (selectedBrand == null ||
          selectedColor == null ||
          selectedThickness == null ||
          selectedMaterialType == null) {
        return;
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  /// 3. ADD THIS NEW METHOD to build API response data display:
  Widget _buildApiResponseDataList() {
    if (apiProductsList.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No API data available yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: apiProductsList.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = entry.value;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with S.No and Product Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${data['S.No']}. ${data['Products']}",
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
                  ],
                ),
                SizedBox(height: 16),

                // First Row: UOM, Billing Option, Length
                Row(
                  children: [
                    Expanded(
                      child: _buildApiDetailItem(
                          "UOM", _buildApiUomDropdown(data)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildApiDetailItem(
                          "Billing Option", _buildApiBillingDropdown(data)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildApiDetailItem(
                          "Length", _buildApiEditableField(data, "Length")),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Second Row: Crimp, Nos, Qty
                Row(
                  children: [
                    Expanded(
                      child: _buildApiDetailItem(
                          "Crimp", _buildApiReadOnlyField(data, "Crimp")),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildApiDetailItem(
                          "Nos", _buildApiEditableField(data, "Nos")),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildApiDetailItem(
                          "Qty", _buildApiEditableField(data, "Qty")),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Third Row: Basic Rate, Amount
                Row(
                  children: [
                    Expanded(
                      child: _buildApiDetailItem("Basic Rate",
                          _buildApiReadOnlyField(data, "Basic Rate")),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildApiDetailItem(
                          "Amount", _buildApiReadOnlyField(data, "Amount")),
                    ),
                    Expanded(
                        child: SizedBox()), // Empty space to balance the row
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 4. ADD THESE HELPER METHODS:
  Widget _buildApiDetailItem(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildApiEditableField(Map<String, dynamic> data, String key) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: TextEditingController(text: data[key]?.toString() ?? ""),
        onChanged: (val) => data[key] = val,
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildApiReadOnlyField(Map<String, dynamic> data, String key) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[50],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          data[key]?.toString() ?? "",
          style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildApiUomDropdown(Map<String, dynamic> data) {
    Map<String, dynamic> uomData = data['UOM'] ?? {};
    String currentValue = uomData['value']?.toString() ?? "";
    Map<String, dynamic> options = uomData['options'] ?? {};

    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        value: currentValue.isNotEmpty ? currentValue : null,
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key.toString(),
            child: Text(entry.value.toString()),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            data['UOM']['value'] = val;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildApiBillingDropdown(Map<String, dynamic> data) {
    Map<String, dynamic> billingData = data['Billing Option'] ?? {};
    String currentValue = billingData['value']?.toString() ?? "";
    Map<String, dynamic> options = billingData['options'] ?? {};

    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: currentValue.isNotEmpty ? currentValue : null,
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key.toString(),
            child: Text(entry.value.toString()),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            data['Billing Option']['value'] = val;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          fillColor: Colors.white,
        ),
      ),
    );
  }

  void _submitData() {
    if (selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null ||
        selectedMaterialType == null) {
// Show elegant error message
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
      submittedData.add({
        "Product": "Aluminum",
        "UOM": "Feet",
        "Length": "0",
        "Nos": "1",
        "Basic Rate": "0",
        "SQ": "0",
        "Amount": "0",
        "Base Product":
            " $selectedMaterialType,  $selectedThickness, $selectedBrand, $selectedColor,",
      });
      selectedMaterialType = null;
      selectedThickness = null;
      selectedBrand = null;
      selectedColor = null;
      materialTypeList = [];
      thicknessList = [];
      brandsList = [];
      colorsList = [];
      _fetchMaterialType();
    });

// Show success message with a more elegant snackbar
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

  Widget _buildSubmittedDataList() {
    if (submittedData.isEmpty) {
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
      children: submittedData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = entry.value;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      // color: Colors.red,
                      height: 40.h,
                      width: 210.w,

                      child: Text(
                        "  ${index + 1}.  ${data["Product"]}" ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
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
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Subhead(
                                      text:
                                          "Are you Sure to Delete This Item ?",
                                      weight: FontWeight.w500,
                                      color: Colors.black),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          submittedData.removeAt(index);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text("Yes"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("No"),
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                  )
                ],
              ),
              _buildApiResponseDataList(),
              // Row(
              //   children: [
              //     MyText(
              //         text: "  UOM - ",
              //         weight: FontWeight.w600,
              //         color: Colors.grey.shade600),
              //     MyText(
              //         text: "Length - ",
              //         weight: FontWeight.w600,
              //         color: Colors.grey.shade600),
              //     MyText(
              //         text: "Nos  ",
              //         weight: FontWeight.w600,
              //         color: Colors.grey.shade600),
              //   ],
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8),
                child: Container(
                  height: 40.h,
                  width: double.infinity.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // color: Colors.red,
                        height: 40.h,
                        width: 280.w,
                        child: TextField(
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          controller: TextEditingController(
                              text: " ${data["Base Product"]}"),
                          readOnly: true,
                        ),
                      ),
                      Gap(5),
                      Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: IconButton(
                              onPressed: () {
                                editController.text = data["Base Product"];
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Edit Your Aluminum"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              height: 40.h,
                                              width: double.infinity.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 7.0),
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                  ),
                                                  controller: editController,
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      data["Base Product"] =
                                                          value;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  data["Base Product"] =
                                                      editController.text;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: MyText(
                                                  text: "Save",
                                                  weight: FontWeight.w500,
                                                  color: Colors.black))
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 15,
                              )))
                    ],
                  ),
                ),
              ),
              Gap(5),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _selectedItems() {
    List<String> value = [
      if (selectedMaterialType != null) "Material: $selectedMaterialType",
      if (selectedThickness != null) "Thickness: $selectedThickness",
      if (selectedBrand != null) "brand: $selectedBrand",
      if (selectedColor != null) "Color: $selectedColor",
    ];
    return value.isEmpty ? "No selections yet" : value.join(",  ");
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
          text: 'Aluminum',
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
                          _buildDropdown(materialTypeList, selectedMaterialType,
                              (value) {
                            setState(() {
                              selectedMaterialType = value;

                              ///clear fields
                              selectedThickness = null;
                              selectedBrand = null;
                              selectedColor = null;
                              thicknessList = [];
                              brandsList = [];
                              colorsList = [];
                            });
                            _fetchThickness();
                          }, label: "Material Type"),
                          _buildDropdown(thicknessList, selectedThickness,
                              (value) {
                            setState(() {
                              selectedThickness = value;

                              ///clear fields
                              selectedBrand = null;
                              selectedColor = null;
                              brandsList = [];
                              colorsList = [];
                            });
                            _fetchBrand();
                          },
                              enabled: thicknessList.isNotEmpty,
                              label: "Thickness"),
                          _buildDropdown(brandsList, selectedBrand, (value) {
                            setState(() {
                              selectedBrand = value;

                              ///clear fields
                              selectedColor = null;
                              colorsList = [];
                            });
                            _fetchColor();
                          }, enabled: brandsList.isNotEmpty, label: "Brand"),
                          _buildDropdown(colorsList, selectedColor, (value) {
                            setState(() {
                              selectedColor = value;
                            });
                          }, enabled: colorsList.isNotEmpty, label: "Color"),
                          Gap(20.h),
                          Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                await postAllData();
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
                // if (submittedData.isNotEmpty)
                //   Subhead(
                //       text: "   Added Products",
                //       weight: FontWeight.w600,
                //       color: Colors.black),
                // SizedBox(height: 8),
                // _buildSubmittedDataList(),
                SizedBox(height: 10),
                if (apiProductsList.isNotEmpty)
                  Subhead(
                      text: "   API Response Data",
                      weight: FontWeight.w600,
                      color: Colors.black),
                SizedBox(height: 8),
                _buildApiResponseDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
