import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../global_user/global_user.dart';

class Purlin extends StatefulWidget {
  const Purlin({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Purlin> createState() => _PurlinState();
}

class _PurlinState extends State<Purlin> {
  late TextEditingController editController;

  String? selectProduct;
  String? selectedBrand;
  String? selectedSize;
  String? selectedThickness;
  String? selectedMaterialType;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> productList = [];
  List<String> brandsList = [];
  List<String> sizeList = [];
  List<String> thicknessList = [];
  List<String> materialTypeList = [];
  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchShapeProduct();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchShapeProduct() async {
    setState(() {
      productList = [];
      selectProduct = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/5');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        print("Shape of Product ${response.body}");
        debugPrint(response.body);

        if (products is List) {
          setState(() {
            productList = products
                .whereType<Map>()
                .map((e) => e["shape_of_product"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  /// fetch Sizes Api's ///
  Future<void> _fetchSizes() async {
    if (selectProduct == null) return;

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
          "product_label": "size",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectProduct],
          "base_label_filters": ["shape_of_product"],
          "base_category_id": "5",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sizes = data["message"]["message"][0];
        print("Fetching colors for thick: $selectProduct");
        print("API response: ${response.body}");
        debugPrint(response.body);

        if (sizes is List) {
          setState(() {
            sizeList = sizes
                .whereType<Map>()
                .map((e) => e["size"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching size: $e");
    }
  }

  /// fetch Material Type Api's ///
  Future<void> _fetchMaterial() async {
    if (selectProduct == null) return;

    setState(() {
      materialTypeList = [];
      selectedMaterialType = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "material_type",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectProduct, selectedSize],
          "base_label_filters": ["shape_of_product", "size"],
          "base_category_id": "5",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedSize");
        print("API response: ${response.body}");
        debugPrint(response.body);

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
      print("Exception fetching size: $e");
    }
  }

  /// fetch thickness Api's //
  Future<void> _fetchThickness() async {
    if (selectProduct == null) return;

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
          "base_product_filters": [
            selectProduct,
            selectedSize,
            selectedMaterialType
          ],
          "base_label_filters": ["shape_of_product", "size", "material_type"],
          "base_category_id": "5",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thick = data["message"]["message"][0];
        print("Fetching colors for thick: $selectedMaterialType");
        print("API response: ${response.body}");
        debugPrint(response.body);

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
    if (selectProduct == null) return;

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
          "base_product_filters": [
            selectProduct,
            selectedSize,
            selectedMaterialType,
            selectedThickness
          ],
          "base_label_filters": [
            "shape_of_product",
            "size",
            "material_type",
            "thickness",
          ],
          "base_category_id": "5",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print("Fetching brand: $selectedThickness");
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          // Extract brand names from the first list
          final brandListRaw = message[0];
          if (brandListRaw is List) {
            setState(() {
              brandsList = brandListRaw
                  .whereType<Map>()
                  .map((e) => e["brand"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          // Extract id and base_product_id from the second list
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString(); // <-- New
            print("Selected Base Product ID: $selectedProductBaseId");
            print("Base Product Name: $selectedBaseProductName"); // <-- New
          }
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

// 1. ADD THESE VARIABLES after your existing variables (around line 25)
  List<Map<String, dynamic>> apiResponseData = [];
  Map<String, dynamic>? apiResponse;

// 2. MODIFY the postAllData() method - REPLACE the existing postAllData method with this:
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
      "category_id": 5,
      "category_name": "Purlin"
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
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['status'] == true) {
          setState(() {
            apiResponse = responseData;
            apiResponseData = [];
            // Safely parse lebels and data
            if (responseData['lebels'] is List &&
                responseData['lebels'].isNotEmpty) {
              for (var label in responseData['lebels']) {
                if (label['data'] is List) {
                  apiResponseData.addAll(
                    (label['data'] as List).cast<Map<String, dynamic>>(),
                  );
                }
              }
            }
            print("Updated apiResponseData: $apiResponseData");
          });
          Get.snackbar(
            "Data Added",
            "Successfully",
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          print("API response status is false or invalid: ${response.body}");
          Get.snackbar(
            "Error",
            "Failed to add product: Invalid response",
            colorText: Colors.white,
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        print(
            "API request failed with status ${response.statusCode}: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to add product: Server error",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Exception posting data: $e");
      Get.snackbar(
        "Error",
        "Error posting data: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

// 3. REPLACE the existing _buildSubmittedDataList() method with this:
// REPLACE your existing _buildSubmittedDataList() method with this:
  Widget _buildSubmittedDataList() {
    print("apiResponseData length: ${apiResponseData.length}");

    if (apiResponseData.isEmpty) {
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
      children: apiResponseData.asMap().entries.map((entry) {
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
                        "${data["S.No"] ?? (index + 1)}. ${data["Products"] ?? 'Product'}",
                        style: GoogleFonts.figtree(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
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
                      "ID: ${data['id'] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    apiResponseData.removeAt(index);
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
                ],
              ),

              // Editable fields in rows
              _buildApiResponseFields(data),
              SizedBox(height: 16),
            ],
          ),
        );
      }).toList(),
    );
  }

// ADD this new method for the editable fields:
  Widget _buildApiResponseFields(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Row 1: UOM, Length, Nos
          Row(
            children: [
              Expanded(
                child: _buildDetailItem("UOM", _buildUomDropdown(data)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Length", _editableTextField(data, "Length")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Row 2: Basic Rate, Kg, Amount
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                    "Basic Rate", _editableTextField(data, "Basic Rate")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Kg",
                    Text(data['Kg']?.toString() ?? '0',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Amount",
                    Text(data['Amount']?.toString() ?? '0',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[600]))),
              ),
            ],
          ),
        ],
      ),
    );
  }

// 5. ADD this new method after _buildApiProductDetailInRows():
  Widget _editableTextField(Map<String, dynamic> data, String key) {
    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 14.sp,
        ),
        controller: TextEditingController(text: data[key]?.toString() ?? ''),
        onChanged: (val) {
          setState(() {
            data[key] = val.isEmpty ? '0' : val; // Default to '0' if empty
            // Optional: Calculate Amount client-side
            double length = double.tryParse(data['Length'] ?? '0') ?? 0;
            double nos = double.tryParse(data['Nos'] ?? '0') ?? 0;
            double rate = double.tryParse(data['Basic Rate'] ?? '0') ?? 0;
            data['Amount'] = (length * nos * rate).toStringAsFixed(2);
            // Note: Kg calculation requires a formula; left as read-only
          });
        },
        keyboardType: TextInputType.number,
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

// 6. ADD this new method after _apiEditableTextField():
  Widget _buildUomDropdown(Map<String, dynamic> data) {
    List<String> uomOptions = ['FEET', 'MM', 'MTR', 'INCH']; // Fallback options
    String? selectedValue =
        data['UOM']?['value'] == '3' ? 'FEET' : data['UOM']?['value'];

    try {
      if (data['UOM'] != null &&
          data['UOM']['options'] is Map<String, String>) {
        uomOptions = (data['UOM']['options'] as Map<String, String>)
            .entries
            .map((e) => e.value)
            .toList();
      }
    } catch (e) {
      print("Error parsing UOM options: $e");
    }

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: uomOptions.contains(selectedValue) ? selectedValue : null,
        items: uomOptions
            .map((uom) => DropdownMenuItem(value: uom, child: Text(uom)))
            .toList(),
        onChanged: (val) {
          setState(() {
            data['UOM'] = data['UOM'] ?? {};
            data['UOM']['value'] = val == 'FEET' ? '3' : val;
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

// 7. MODIFY the _submitData() method - REPLACE the existing _submitData method with this:
  void _submitData() {
    if (selectedSize == null ||
        selectedThickness == null ||
        selectProduct == null ||
        selectedMaterialType == null) {
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

    // Call postAllData and wait for completion
    postAllData().then((_) {
      setState(() {
        selectProduct = null;
        selectedSize = null;
        selectedMaterialType = null;
        selectedThickness = null;
        selectedBrand = null;
        productList = [];
        sizeList = [];
        materialTypeList = [];
        thicknessList = [];
        brandsList = [];
        _fetchShapeProduct();
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
    }).catchError((e) {
      print("Error in submitData: $e");
      Get.snackbar(
        "Error",
        "Failed to add product: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
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

  String _selectedItems() {
    List<String> values = [
      if (selectProduct != null) "Product: $selectProduct",
      if (selectedSize != null) "Size: $selectedSize",
      if (selectedMaterialType != null) "Material: $selectedMaterialType",
      if (selectedThickness != null) "Thickness: $selectedThickness",
      if (selectedBrand != null) "Brand: $selectedBrand",
    ];
    return values.isEmpty ? "No Selections yet" : values.join(", ");
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
              prefixIcon:
                  Icon(icon, color: enabled ? Colors.blue : Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          text: 'Purlin',
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
                              color: Colors.black),
                          SizedBox(height: 16),
                          _buildAnimatedDropdown(productList, selectProduct,
                              (value) {
                            setState(() {
                              selectProduct = value;
// Clear dependent fields
                              selectedSize = null;
                              selectedMaterialType = null;
                              selectedThickness = null;
                              selectedBrand = null;
                              sizeList = [];
                              materialTypeList = [];
                              thicknessList = [];
                              brandsList = [];
                            });
                            _fetchSizes();
                          },
                              label: "Shape of Product",
                              icon: Icons.format_shapes_outlined),
                          _buildAnimatedDropdown(sizeList, selectedSize,
                              (value) {
                            setState(() {
                              selectedSize = value;
// Clear dependent fields
                              selectedMaterialType = null;
                              selectedThickness = null;
                              selectedBrand = null;
                              materialTypeList = [];
                              thicknessList = [];
                              brandsList = [];
                            });
                            _fetchMaterial();
                          },
                              enabled: sizeList.isNotEmpty,
                              label: "Size",
                              icon: Icons.format_size_outlined),
                          _buildAnimatedDropdown(
                              materialTypeList, selectedMaterialType, (value) {
                            setState(() {
                              selectedMaterialType = value;
// Clear dependent fields
                              selectedThickness = null;
                              selectedBrand = null;
                              thicknessList = [];
                              brandsList = [];
                            });
                            _fetchThickness();
                          },
                              enabled: materialTypeList.isNotEmpty,
                              label: "Material Type",
                              icon: Icons.difference_outlined),
                          _buildAnimatedDropdown(
                              thicknessList, selectedThickness, (value) {
                            setState(() {
                              selectedThickness = value;
// Clear dependent fields
                              selectedBrand = null;
                              brandsList = [];
                            });
                            _fetchBrand();
                          },
                              enabled: thicknessList.isNotEmpty,
                              label: "Thickness",
                              icon: Icons.straighten_outlined),
                          _buildAnimatedDropdown(brandsList, selectedBrand,
                              (value) {
                            setState(() {
                              selectedBrand = value;
                            });
// _fetchColor();
                          },
                              enabled: brandsList.isNotEmpty,
                              label: "Brand",
                              icon: Icons.brightness_auto_outlined),
                          SizedBox(height: 24),
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
