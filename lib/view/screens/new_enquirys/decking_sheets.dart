import 'dart:async';
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

class DeckingSheets extends StatefulWidget {
  const DeckingSheets({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<DeckingSheets> createState() => _DeckingSheetsState();
}

class _DeckingSheetsState extends State<DeckingSheets> {
  int? orderIDD;
  late TextEditingController editController;
  String? selectedMaterialType;
  String? selectedThickness;
  String? selectCoatingMass;
  String? selectedYieldStrength;
  String? selectedBrand;
  String? selectedProductBaseId;

  List<String> materialTypeList = [];
  List<String> thicknessList = [];
  List<String> coatingMassList = [];
  List<String> yieldStrengthList = [];
  List<String> brandList = [];
  List<Map<String, dynamic>> submittedData = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
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

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/34');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meterialType = data["message"]["message"][1];
        print(response.body);
        debugPrint(response.body);

        if (meterialType is List) {
          setState(() {
            materialTypeList = meterialType
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

  /// fetch colors Api's //
  Future<void> _fetchThick() async {
    if (selectedMaterialType == null) return;

    setState(() {
      thicknessList = [];
      selectedThickness = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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
          "base_product_filters": ["$selectedMaterialType"],
          "base_label_filters": ["material_type"],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");
        debugPrint(response.body);

        if (selectedThickness is List) {
          setState(() {
            thicknessList = selectedThickness
                .whereType<Map>()
                .map((e) => e["thickness"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching colors: $e");
    }
  }

  /// fetch Thickness Api's ///
  Future<void> _fetchCoat() async {
    if (selectedThickness == null) return;

    setState(() {
      coatingMassList = [];
      selectCoatingMass = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "coating_mass",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedMaterialType, selectedThickness],
          "base_label_filters": ["material_type", "thickness"],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");
        debugPrint(response.body);

        if (thickness is List) {
          setState(() {
            coatingMassList = thickness
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  /// fetch Coating Mass Api's ///
  Future<void> _yieldStrength() async {
    if (selectCoatingMass == null) return;

    setState(() {
      yieldStrengthList = [];
      selectedYieldStrength = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "yield_strength",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedMaterialType,
            selectedThickness,
            selectCoatingMass,
          ],
          "base_label_filters": ["material_type", "thickness", "coating_mass"],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coating = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");
        debugPrint(response.body);

        if (coating is List) {
          setState(() {
            yieldStrengthList = coating
                .whereType<Map>()
                .map((e) => e["yield_strength"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    }
  }

  /// fetch Brand Api's ///
  Future<void> _fetchBrand() async {
    if (selectedYieldStrength == null) return;

    setState(() {
      brandList = [];
      selectedBrand = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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
          "base_product_filters": [
            selectedMaterialType,
            selectedThickness,
            selectCoatingMass,
            selectedYieldStrength,
          ],
          "base_label_filters": [
            "material_type",
            "thickness",
            "coating_mass",
            "yield_strength",
          ],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        // Extract brand names
        final brands = message[0];
        if (brands is List) {
          setState(() {
            brandList = brands
                .whereType<Map>()
                .map((e) => e["brand"]?.toString())
                .whereType<String>()
                .toList();
          });
        }

        // Extract product_base_id
        final idData = message.length > 1 ? message[1] : null;
        if (idData is List && idData.isNotEmpty && idData.first is Map) {
          selectedProductBaseId = idData.first["id"]?.toString();
          print("Selected Base Product ID: $selectedProductBaseId");
        }

        print("API response: ${response.body}");
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  // Add these variables after line 25 (after the existing List declarations)
  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};

  // 2. Modify the postAllData() method to store the response:
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
      "product_base_name":
          "$selectedMaterialType,$selectedThickness,$selectCoatingMass$selectedYieldStrength$selectedBrand",
      "category_id": 34,
      "category_name": "Decking sheets",
      "OrderID": (orderIDD != null) ? orderIDD : null,
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

      // Store the API response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          final String orderID = responseData["order_id"].toString();
          print("Order IDDDD: $orderID");
          orderIDD = int.parse(orderID);
          apiResponseData = jsonDecode(response.body);
          if (apiResponseData!['lebels'] != null &&
              apiResponseData!['lebels'].isNotEmpty) {
            responseProducts = apiResponseData!['lebels'][0]['data'] ?? [];
          }
        });
      }

      if (selectedMaterialType == null ||
          selectedThickness == null ||
          selectCoatingMass == null ||
          selectedYieldStrength == null ||
          selectedBrand == null) {
        return;
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  // 5. Modify the _submitData() method to not add local data:
  void _submitData() {
    if (selectedMaterialType == null ||
        selectedThickness == null ||
        selectCoatingMass == null ||
        selectedYieldStrength == null ||
        selectedBrand == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Form'),
          content: Text(
            'Please fill all required fields to add a product.',
          ),
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

    postAllData().then((_) {
      // Reset form fields
      setState(() {
        selectedMaterialType = null;
        selectedThickness = null;
        selectCoatingMass = null;
        selectedYieldStrength = null;
        selectedBrand = null;
        materialTypeList = [];
        thicknessList = [];
        coatingMassList = [];
        yieldStrengthList = [];
        brandList = [];
        _fetchMaterialType(); // Re-fetch material types for the next selection
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // 4. Add these new methods:
  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem("UOM", _uomDropdownFromApi(data)),
              ),
              Gap(10),
              Expanded(
                  child: _buildDetailItem(
                      "Billing Option", _buildApiBillingDropdown(data))),
              Gap(10),
              Expanded(
                child: _buildDetailItem(
                  "Length",
                  _editableTextField(data, "Length"),
                ),
              ),
            ],
          ),
        ),
        Gap(5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
              ),
              Gap(10),
              Expanded(
                child: _buildDetailItem(
                  "Basic Rate",
                  _editableTextField(data, "Basic Rate"),
                ),
              ),
              Gap(10),
              Expanded(
                child: _buildDetailItem("Qty", _editableTextField(data, "qty")),
              ),
            ],
          ),
        ),
        Gap(5.h),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  "Amount",
                  _editableTextField(data, "Amount"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _uomDropdownFromApi(Map<String, dynamic> data) {
    // Extract UOM data from the product data
    Map<String, dynamic>? uomData = data['UOM'];
    String? currentValue = uomData?['value']?.toString();
    Map<String, dynamic>? options =
        uomData?['options'] as Map<String, dynamic>?;

    if (options == null || options.isEmpty) {
      return _editableTextField(data, "UOM");
    }

    return SizedBox(
      height: 38.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.entries
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value.toString(),
                  style: GoogleFonts.figtree(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: (val) {
          setState(() {
            if (data['UOM'] is! Map) {
              data['UOM'] = {};
            }
            data['UOM']['value'] = val;
            data['UOM']['options'] = options;
          });
          print("UOM changed to: $val");
          _debounceCalculation(data);
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
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildApiBillingDropdown(Map<String, dynamic> data) {
    Map<String, dynamic> billingData = data['Billing Option'] ?? {};
    String currentValue = billingData['value']?.toString() ?? "";
    Map<String, dynamic> options = billingData['options'] ?? {};
    return Container(
      height: 40,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: currentValue.isNotEmpty ? currentValue : null,
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key.toString(),
            child: Text(
              entry.value.toString(),
              style: GoogleFonts.figtree(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            if (data['Billing Option'] is! Map) {
              data['Billing Option'] = {};
            }
            data['Billing Option']['value'] = val;
            data['Billing Option']['options'] = options;
          });
          // Trigger calculation when billing option changes
          _debounceCalculation(data);
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
            borderSide: BorderSide(color: Colors.deepPurple[400]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" || key == "Amount" || key == "qty")
            ? true
            : false,
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: controller,
        keyboardType: (key == "Length" ||
                key == "Nos" ||
                key == "Basic Rate" ||
                key == "Amount" ||
                key == "SQMtr")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          setState(() {
            data[key] = val;
          });

          print("Field $key changed to: $val");
          print("Controller text: ${controller.text}");
          print("Data after change: ${data[key]}");

          // 🚫 DO NOT forcefully reset controller.text here!
          // if (controller.text != val) {
          //   controller.text = val;
          // }

          if (key == "Length" ||
              key == "Nos" ||
              key == "Basic Rate" ||
              key == "Crimp" ||
              key == "qty") {
            print("Triggering calculation for $key with value: $val");
            _debounceCalculation(data);
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
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
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(Map<String, dynamic> data, String key) {
    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          fontSize: 15.sp,
        ),
        controller: TextEditingController(text: data[key].toString()),
        readOnly: true,
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
          filled: true,
          fillColor: Colors.grey[100],
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

  /// Base View Products data //
  TextEditingController baseProductController = TextEditingController();
  List<dynamic> baseProductResults = [];
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();

  // Add this method for searching base products
  Future<void> searchBaseProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        baseProductResults = [];
      });
      return;
    }

    setState(() {
      isSearchingBaseProduct = true;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"category_id": "34", "searchbase": query};

    try {
      final response = await ioClient.post(
        Uri.parse("https://demo.zaron.in:8181/ci4/api/baseproducts_search"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Base product response: $responseData"); // Debug print
        setState(() {
          baseProductResults = responseData['base_products'] ?? [];
          isSearchingBaseProduct = false;
        });
      } else {
        setState(() {
          baseProductResults = [];
          isSearchingBaseProduct = false;
        });
      }
    } catch (e) {
      print("Error searching base products: $e");
      setState(() {
        baseProductResults = [];
        isSearchingBaseProduct = false;
      });
    }
  }

  // Add this method to build the base product search field
  Widget _buildBaseProductSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Base Product",
          style: GoogleFonts.figtree(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: baseProductController,
            focusNode: baseProductFocusNode,
            decoration: InputDecoration(
              hintText: "Search base product...",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: isSearchingBaseProduct
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              searchBaseProducts(value);
            },
            onTap: () {
              if (baseProductController.text.isNotEmpty) {
                searchBaseProducts(baseProductController.text);
              }
            },
          ),
        ),

        // Search Results Display (line by line, not dropdown)
        if (baseProductResults.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Search Results:",
                  style: GoogleFonts.figtree(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                ...baseProductResults.map((product) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBaseProduct = product.toString();
                        baseProductController.text = selectedBaseProduct!;
                        baseProductResults = [];
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      margin: EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              product.toString(),
                              style: GoogleFonts.figtree(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

        // Selected Base Product Display
        if (selectedBaseProduct != null)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Selected: $selectedBaseProduct",
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBaseProduct = null;
                      baseProductController.clear();
                      baseProductResults = [];
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Helper method to format the preview text
  String _selectedItems() {
    List<String> selectedValues = [
      if (selectedMaterialType != null) "Material: $selectedMaterialType",
      if (selectedThickness != null) "Thickness: $selectedThickness",
      if (selectCoatingMass != null) "Coating Mass: $selectCoatingMass",
      if (selectedYieldStrength != null)
        "Yield Strength: $selectedYieldStrength",
      if (selectedBrand != null) "Brand: $selectedBrand",
    ];
    return selectedValues.isEmpty
        ? "No selections yet"
        : selectedValues.join(",  ");
  }

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

    ///old column

    return Column(
      children: responseProducts.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = Map<String, dynamic>.from(entry.value);
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: SizedBox(
                        height: 40.h,
                        width: 210.w,
                        child: Text(
                          "  ${index + 1}.  ${data["Products"]}" ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                            builder: (context) {
                              return AlertDialog(
                                title: Subhead(
                                  text: "Are you Sure to Delete This Item ?",
                                  weight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        responseProducts.removeAt(index);
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
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _buildProductDetailInRows(data),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0, left: 8),
              //   child: Container(
              //     height: 40.h,
              //     width: double.infinity.w,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Container(
              //           height: 40.h,
              //           width: 280.w,
              //           child: TextField(
              //             style: TextStyle(
              //               fontSize: 13.sp,
              //               color: Colors.black87,
              //               fontWeight: FontWeight.w500,
              //             ),
              //             decoration: InputDecoration(
              //               enabledBorder: InputBorder.none,
              //               focusedBorder: InputBorder.none,
              //             ),
              //             controller: TextEditingController(
              //               text: " ${data["Material Specification"]}",
              //             ),
              //             readOnly: true,
              //           ),
              //         ),
              //         Gap(5),
              //         Container(
              //           height: 30.h,
              //           width: 30.w,
              //           decoration: BoxDecoration(
              //             color: Colors.grey[200],
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: IconButton(
              //             onPressed: () {
              //               editController.text =
              //                   data["Material Specification"].toString();
              //               showDialog(
              //                 context: context,
              //                 builder: (context) {
              //                   return AlertDialog(
              //                     title: Text("Edit Your Liner Sheet"),
              //                     content: Column(
              //                       mainAxisSize: MainAxisSize.min,
              //                       children: [
              //                         Container(
              //                           height: 40.h,
              //                           width: double.infinity.w,
              //                           decoration: BoxDecoration(
              //                             borderRadius:
              //                                 BorderRadius.circular(10),
              //                             color: Colors.white,
              //                           ),
              //                           child: Padding(
              //                             padding: const EdgeInsets.only(
              //                               left: 7.0,
              //                             ),
              //                             child: TextField(
              //                               decoration: InputDecoration(
              //                                 enabledBorder: InputBorder.none,
              //                                 focusedBorder: InputBorder.none,
              //                               ),
              //                               controller: editController,
              //                               onSubmitted: (value) {
              //                                 setState(() {
              //                                   data["Material Specification"] =
              //                                       value;
              //                                 });
              //                                 Navigator.pop(context);
              //                               },
              //                             ),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                     actions: [
              //                       ElevatedButton(
              //                         onPressed: () {
              //                           setState(() {
              //                             data["Material Specification"] =
              //                                 editController.text;
              //                           });
              //                           Navigator.pop(context);
              //                         },
              //                         child: MyText(
              //                           text: "Save",
              //                           weight: FontWeight.w500,
              //                           color: Colors.black,
              //                         ),
              //                       ),
              //                     ],
              //                   );
              //                 },
              //               );
              //             },
              //             icon: Icon(Icons.edit, size: 15),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Timer? _debounceTimer;
  Map<String, dynamic> calculationResults = {};
  Map<String, String?> previousUomValues = {}; // Track previous UOM values
  Map<String, Map<String, TextEditingController>> fieldControllers =
      {}; // Store controllers

  // Method to get or create controller for each field
  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    // Initialize controllers map for this product ID
    fieldControllers.putIfAbsent(productId, () => {});

    // If controller for this key doesn't exist, create it
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : ""; // Avoid initializing with "0"

      fieldControllers[productId]![key] = TextEditingController(
        text: initialValue,
      );

      print("Created controller for [$key] with value: '$initialValue'");
    } else {
      // Existing controller: check if it needs sync from data
      final controller = fieldControllers[productId]![key]!;

      final dataValue = data[key]?.toString() ?? "";

      // If the controller is empty but data has a value, sync it
      if (controller.text.isEmpty && dataValue.isNotEmpty && dataValue != "0") {
        controller.text = dataValue;
        print("Synced controller for [$key] to: '$dataValue'");
      }
    }

    return fieldControllers[productId]![key]!;
  }

  // Add this method for debounced calculation
  void _debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      _performCalculation(data);
    });
  }

  Future<void> _performCalculation(Map<String, dynamic> data) async {
    print("=== STARTING CALCULATION API ===");
    print("Data received: $data");

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();

    // Get current UOM value
    String? currentUom;
    if (data["UOM"] is Map) {
      currentUom = data["UOM"]["value"]?.toString();
    } else {
      currentUom = data["UOM"]?.toString();
    }

    print("Current UOM: $currentUom");
    print("Previous UOM: ${previousUomValues[productId]}");

    // Get Profile value from controller
    double? profileValue;
    String? profileText;

    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Length")) {
      profileText = data["Length"]?.toString(); // First check the latest data
      if (profileText == null || profileText.isEmpty) {
        profileText = fieldControllers[productId]!["Length"]!
            .text; // Then check controller
      }
      print("Length/Profile from data/controller: $profileText");
    }

    if (profileText != null && profileText.isNotEmpty) {
      profileValue = double.tryParse(profileText);
      print("Parsed profile value: $profileValue");
    }

    // Get Nos value from controller
    int nosValue = 0;
    String? nosText;

    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Nos")) {
      nosText = fieldControllers[productId]!["Nos"]!.text;
      print("Nos from controller: $nosText");
    }

    if (nosText == null || nosText.isEmpty) {
      nosText = data["Nos"]?.toString();
      print("Nos from data: $nosText");
    }

    if (nosText != null && nosText.isNotEmpty) {
      nosValue = int.tryParse(nosText) ?? 1;
    }

    // Get Crimp value
    double? crimpValue;
    String? crimpText = data["Crimp"]?.toString();

    if (crimpText == null || crimpText.isEmpty || crimpText == "0") {
      if (fieldControllers.containsKey(productId) &&
          fieldControllers[productId]!.containsKey("Crimp")) {
        crimpText = fieldControllers[productId]!["Crimp"]!.text.trim();
      }
    }

    if (crimpText != null && crimpText.isNotEmpty) {
      crimpValue = double.tryParse(crimpText);
      print("Using crimp value: $crimpValue from text: $crimpText");
    }

    print("Final Profile Value: $profileValue");
    print("Final Nos Value: $nosValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 34,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue ?? 0,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
      "billing_option": data["Billing Option"] is Map
          ? int.tryParse(data["Billing Option"]["value"]?.toString() ?? "2")
          : null,
    };

    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["status"] == "success") {
          setState(() {
            calculationResults[productId] = responseData;

            // Update Profile/Length
            if (responseData["profile"] != null) {
              String newProfile = responseData["profile"].toString();
              // Only update if calculation returned different value
              if (data["Length"]?.toString() != newProfile) {
                data["Length"] = newProfile;
                if (fieldControllers[productId]?["Length"] != null) {
                  fieldControllers[productId]!["Length"]!.text = newProfile;
                }
                print("Length/Profile updated to: $newProfile");
              }
            }

            // Update Nos
            if (responseData["Nos"] != null) {
              String newNos = responseData["Nos"].toString().trim();
              String currentInput =
                  fieldControllers[productId]!["Nos"]!.text.trim();

              if (currentInput.isEmpty || currentInput == "0") {
                data["Nos"] = newNos;
                if (fieldControllers[productId]?["Nos"] != null) {
                  fieldControllers[productId]!["Nos"]!.text = newNos;
                }
                print("Nos field updated to: $newNos");
              } else {
                print("Nos NOT updated because user input = '$currentInput'");
              }
            }

            // Update Crimp
            if (responseData["crimp"] != null) {
              String newCrimp = responseData["crimp"].toString();
              if (newCrimp != "0" && newCrimp != "0.0") {
                data["Crimp"] = newCrimp;
                if (fieldControllers[productId]?["Crimp"] != null) {
                  String currentCrimp =
                      fieldControllers[productId]!["Crimp"]!.text.trim();
                  if (currentCrimp.isEmpty || currentCrimp == "0") {
                    fieldControllers[productId]!["Crimp"]!.text = newCrimp;
                    print("Crimp field updated to: $newCrimp");
                  }
                }
              }
            }

            // Update SQMtr
            if (responseData["qty"] != null) {
              data["qty"] = responseData["qty"].toString();
              if (fieldControllers[productId]?["qty"] != null) {
                fieldControllers[productId]!["qty"]!.text =
                    responseData["qty"].toString();
              }
            }

            // Update Amount
            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
              if (fieldControllers[productId]?["Amount"] != null) {
                fieldControllers[productId]!["Amount"]!.text =
                    responseData["Amount"].toString();
              }
            }
            previousUomValues[productId] = currentUom;
          });

          print("=== CALCULATION SUCCESS ===");
          print(
            "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, Height=${data["Crimp"]}, Amount=${data["Amount"]}",
          );
        } else {
          print("API returned error status: ${responseData["status"]}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
  }

  Widget _buildAnimatedDropdown(
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: enabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: DropdownSearch<String>(
          items: items,
          selectedItem: selectedValue,
          onChanged: enabled ? onChanged : null,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.deepPurple : Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            constraints: BoxConstraints(maxHeight: 300),
            // borderRadius: BorderRadius.circular(12),
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
          text: 'Decking Sheets',
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
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  color: Colors.white,
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
                            color: Colors.black,
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedDropdown(
                            materialTypeList,
                            selectedMaterialType,
                            (value) {
                              setState(() {
                                selectedMaterialType = value;
                                // Clear dependent fields
                                selectedThickness = null;
                                selectCoatingMass = null;
                                selectedYieldStrength = null;
                                selectedBrand = null;
                                thicknessList = [];
                                coatingMassList = [];
                                yieldStrengthList = [];
                                brandList = [];
                              });
                              _fetchThick();
                            },
                            label: "Material Type",
                            icon: Icons.difference_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thicknessList,
                            selectedThickness,
                            (value) {
                              setState(() {
                                selectedThickness = value;
                                // Clear dependent
                                // fields
                                selectCoatingMass = null;
                                selectedYieldStrength = null;
                                selectedBrand = null;
                                coatingMassList = [];
                                yieldStrengthList = [];
                                brandList = [];
                              });
                              _fetchCoat();
                            },
                            enabled: thicknessList.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            coatingMassList,
                            selectCoatingMass,
                            (value) {
                              setState(() {
                                selectCoatingMass = value;
                                // Clear dependent fields
                                selectedYieldStrength = null;
                                selectedBrand = null;
                                yieldStrengthList = [];
                                brandList = [];
                              });
                              _yieldStrength();
                            },
                            enabled: coatingMassList.isNotEmpty,
                            label: "Coating Mass",
                            icon: Icons.layers_outlined,
                          ),
                          _buildAnimatedDropdown(
                            yieldStrengthList,
                            selectedYieldStrength,
                            (value) {
                              setState(() {
                                selectedYieldStrength = value;
                                // Clear dependent fields
                                selectedBrand = null;
                                brandList = [];
                              });
                              _fetchBrand();
                            },
                            enabled: yieldStrengthList.isNotEmpty,
                            label: "Yield Strength",
                            icon: Icons.radio_button_checked,
                          ),
                          _buildAnimatedDropdown(
                            brandList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;
                              });
                            },
                            enabled: brandList.isNotEmpty,
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          SizedBox(height: 24),
                          _buildBaseProductSearchField(),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.deepPurple[400]!,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selected Product Details",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepPurple[400],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _selectedItems(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 54.h,
                            child: ElevatedButton(
                              onPressed: _submitData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple[400],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_shopping_cart_outlined,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Add Product",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
                    color: Colors.black,
                  ),
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
