import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

import '../global_user/global_user.dart';

class UpvcAccessories extends StatefulWidget {
  const UpvcAccessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<UpvcAccessories> createState() => _UpvcAccessoriesState();
}

class _UpvcAccessoriesState extends State<UpvcAccessories> {
  late TextEditingController editController;
  String? selectedProductBaseId;

  String? selectedBrand;
  String? selectedColor;
  String? selectProductNameBase;
  String? selectedSize;
  String? selectedBaseProductName;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> productList = [];
  List<String> sizeList = [];
  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchProductName();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductName() async {
    setState(() {
      productList = [];
      selectProductNameBase = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/15');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = data["message"]["message"][1];
        print(response.body);

        if (product is List) {
          setState(() {
            productList = product
                .whereType<Map>()
                .map((e) => e["product_name_base"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  /// fetch brand Api's //
  Future<void> _fetchbrand() async {
    if (selectProductNameBase == null) return;

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
// "category_id": "15",
// "selectedlabel": "product_name_base",
// "selectedvalue": selectProductNameBase,
// "label_name": "brand",

          "base_category_id": "15",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_label_filters": ["product_name_base"],
          "base_product_filters": [selectProductNameBase],
          "product_label": "brand",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brands = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (brands is List) {
          setState(() {
            brandsList = brands
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

// /// fetch Color Api's ///
  Future<void> _fetchColor() async {
    if (selectProductNameBase == null) return;

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
// "category_id": "15",
// "selectedlabel": "brand",
// "selectedvalue": selectedBrand,
// "label_name": "color",

          "base_category_id": "15",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_label_filters": ["product_name_base", "brand"],
          "base_product_filters": [selectProductNameBase, selectedBrand],
          "product_label": "color",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final color = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (color is List) {
          setState(() {
            colorsList = color
                .whereType<Map>()
                .map((e) => e["color"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching color: $e");
    }
  }

  /// fetch Sizes Api's ///
  Future<void> _fetchSize() async {
    if (selectProductNameBase == null ||
        selectedBrand == null ||
        selectedColor == null ||
        !mounted) return;

    setState(() {
      sizeList = [];
      selectedSize = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "base_category_id": "15",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_label_filters": ["product_name_base", "brand", "color"],
          "base_product_filters": [
            selectProductNameBase,
            selectedBrand,
            selectedColor,
          ],
          "product_label": "SIZE",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        print("Full API Response: $message");

        if (message is List && message.length >= 2) {
          final sizeData = message[0];
          final idData = message[1];

          if (sizeData is List) {
            setState(() {
              sizeList = sizeData
                  .whereType<Map>()
                  .map((e) => e["SIZE"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName = idData.first["base_product_id"]
                ?.toString(); // <-- Add this line
            debugPrint(
                "Selected Base Product ID (SIZE): $selectedProductBaseId");
            debugPrint(
                "Base Product Name (SIZE): $selectedBaseProductName"); // <-- Optional debug
          }
        } else {
          debugPrint("Unexpected message format for SIZE.");
        }
      } else {
        debugPrint("Failed to fetch size data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching size: $e");
    }
  }

// 1. ADD THESE NEW VARIABLES at the top of your _UpvcAccessoriesState class (around line 25)
  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];

// 2. MODIFY the postAllData() method - REPLACE the existing method with this:
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
      "category_id": 15,
      "category_name": "UPVC Accessories"
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
      if (selectedBrand == null ||
          selectedColor == null ||
          selectProductNameBase == null ||
          selectedSize == null) return;

      if (response.statusCode == 200) {
        // NEW CODE: Parse and store the API response
        final responseData = jsonDecode(response.body);
        setState(() {
          apiResponseData = responseData;
          if (responseData['lebels'] != null &&
              responseData['lebels'].isNotEmpty) {
            responseProducts = responseData['lebels'][0]['data'] ?? [];
          }
        });

        Get.snackbar(
          "Data Added",
          "Successfully",
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

// 3. REPLACE the existing _buildSubmittedDataList() method with this:
  Widget _buildSubmittedDataList() {
    if (responseProducts.isEmpty) {
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

    // Get labels from API response
    List<String> labels = [];
    if (apiResponseData != null &&
        apiResponseData!['lebels'] != null &&
        apiResponseData!['lebels'].isNotEmpty) {
      labels = List<String>.from(apiResponseData!['lebels'][0]['labels']);
    }

    return Column(
      children: responseProducts.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> product = entry.value;

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
                // Header Row with Product Name and Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${product['S.No']}. ${product['Products']}",
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
                        "ID: ${product['id']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
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
                              title: Text("Delete Product"),
                              content: Text(
                                  "Are you sure you want to delete this item?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      responseProducts.removeAt(index);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("No"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Editable Fields in Rows
                _buildApiProductDetailInRows(product),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

// 4. ADD THIS NEW METHOD (place it after _buildSubmittedDataList method):
  Widget _buildApiProductDetailInRows(Map<String, dynamic> product) {
    return Column(
      children: [
        // Row 1: Basic Rate, Nos, Amount
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                  "Basic Rate", _buildReadOnlyField(product, "Basic Rate")),
            ),
            SizedBox(width: 10),
            Expanded(
              child:
                  _buildDetailItem("Nos", _buildEditableField(product, "Nos")),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem(
                  "Amount", _buildReadOnlyField(product, "Amount")),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(Map<String, dynamic> product, String key) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[100],
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        product[key]?.toString() ?? "0",
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, Widget field) {
    return Column(
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
    );
  }

// 5. ADD THESE NEW HELPER METHODS (place them after _buildApiProductDetailInRows):

  Widget _buildEditableField(Map<String, dynamic> product, String key) {
    final controller = _getController(product, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        controller: controller,
        onChanged: (val) {
          product[key] = val;
          // Trigger calculation API when Nos changes
          if (key == "Nos") {
            _debounceCalculation(product);
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

// 6. MODIFY the _submitData() method - REPLACE the existing method with this:
  void _submitData() {
    if (selectedBrand == null ||
        selectedColor == null ||
        selectProductNameBase == null ||
        selectedSize == null) {
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

    // Reset form fields after successful addition
    setState(() {
      selectProductNameBase = null;
      selectedBrand = null;
      selectedColor = null;
      selectedSize = null;
      productList = [];
      brandsList = [];
      colorsList = [];
      sizeList = [];
      _fetchProductName();
    });

    // Show success message
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

  String _selectedItems() {
    List<String> value = [
      if (selectProductNameBase != null) "ProductName: $selectProductNameBase",
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedColor != null) "Color: $selectedColor",
      if (selectedSize != null) "Size: $selectedSize",
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

  Timer? _debounceTimer;
  Map<String, String?> previousUomValues = {}; // Track previous UOM values
  Map<String, Map<String, TextEditingController>> fieldControllers =
      {}; // Store controllers

  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    fieldControllers.putIfAbsent(productId, () => {});

    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] =
          TextEditingController(text: initialValue);
    }

    return fieldControllers[productId]![key]!;
  }

  void _debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      _performCalculation(data);
    });
  }

  Future<void> _performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();

    // Get current UOM value
    String? currentUom = data["UOM"]?.toString();

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 15,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": null,
      "current_uom": null,
      "length": null,
      "nos": int.tryParse(data["Nos"]?.toString() ?? "0") ?? 0,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
    };

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["status"] == "success") {
          setState(() {
            // Update fields based on API response
            // if (responseData["Length"] != null) {
            //   data["Length"] = responseData["Length"].toString();
            // }
            if (responseData["Nos"] != null) {
              data["Nos"] = responseData["Nos"].toString();
            }
            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
            }

            // Store previous UOM for next call
            previousUomValues[productId] = currentUom;
          });
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'UPVC Accessories',
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
                          _buildDropdown(productList, selectProductNameBase,
                              (value) {
                            setState(() {
                              selectProductNameBase = value;
// Clear dependent fields
                              selectedBrand = null;
                              selectedColor = null;
                              selectedSize = null;
                              brandsList = [];
                              colorsList = [];
                              sizeList = [];
                            });
                            _fetchbrand();
                          }, label: "Product Name Base"),
                          _buildDropdown(brandsList, selectedBrand, (value) {
                            setState(() {
                              selectedBrand = value;
// Clear dependent fields
                              selectedColor = null;
                              selectedSize = null;
                              colorsList = [];
                              sizeList = [];
                            });
                            _fetchColor();
// _fetchThickness();
                          }, enabled: brandsList.isNotEmpty, label: "Brand"),
                          _buildDropdown(colorsList, selectedColor, (value) {
                            setState(() {
                              selectedColor = value;
// Clear dependent fields
                              selectedSize = null;
                              sizeList = [];
                            });
                            _fetchSize();
                          }, enabled: colorsList.isNotEmpty, label: "Color"),
                          _buildDropdown(sizeList, selectedSize, (value) {
                            setState(() {
                              selectedSize = value;
                            });
                          }, enabled: sizeList.isNotEmpty, label: "Size"),
                          Gap(20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
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
                if (responseProducts.isNotEmpty)
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
