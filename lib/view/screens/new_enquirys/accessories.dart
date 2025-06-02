import 'dart:async';
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

class Accessories extends StatefulWidget {
  const Accessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Accessories> createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
  late TextEditingController editController;
  String? selectedAccessories;
  String? selectedBrands;
  String? selectedColors;
  String? selectedThickness;
  String? selectedCoatingMass;
  String? selectedProductBaseId;

  List<String> accessoriesList = [];
  List<String> brandandList = [];
  List<String> colorandList = [];
  List<String> thickAndList = [];
  List<String> coatingAndList = [];

// List<String> brandList = [];
  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchAccessories();
    _fetchBrandData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchAccessories() async {
    setState(() {
      accessoriesList = [];
      selectedAccessories = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/1');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessories = data["message"]["message"][1];
        debugPrint("Accessories:::${accessories}");
        debugPrint(response.body, wrapWidth: 1024);

        if (accessories is List) {
          setState(() {
            accessoriesList = accessories
                .whereType<Map>()
                .map((e) => e["accessories_name"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  Future<void> _fetchBrandData() async {
    setState(() {
      brandandList = [];
      selectedBrands;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/1');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brandData = data["message"]["message"][2][1];
        debugPrint(response.body);

        if (brandData is List) {
          setState(() {
            brandandList = brandData
                .whereType<Map>()
                .map((e) => e["brand"]?.toString())
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
  Future<void> _fetchColorData() async {
    if (selectedBrands == null) return;

    setState(() {
      colorandList = [];
      selectedColors = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
// "category_id": "3",
// "selectedlabel": "brand",
// "selectedvalue": selectedBrands,
// "label_name": "color",

          "product_label": "color",
          "product_filters": [selectedAccessories],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [selectedBrands],
          "base_label_filters": ["brand"],
          "base_category_id": 3
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");

        if (selectedThickness is List) {
          setState(() {
            colorandList = selectedThickness
                .whereType<Map>()
                .map((e) => e["color"]?.toString())
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
  Future<void> _fetchThicknessData() async {
    if (selectedBrands == null) return;

    setState(() {
      thickAndList = [];
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
// "category_id": "3",
// "selectedlabel": "color",
// "selectedvalue": selectedColors,
// "label_name": "thickness",

          "product_label": "thickness",
          "product_filters": [selectedAccessories],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [selectedBrands, selectedColors],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedColors");
        print("API response: ${response.body}");

        if (thickness is List) {
          setState(() {
            thickAndList = thickness
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

  /// fetch Thickness Api's ///
  Future<void> _fetchCoatingMassData() async {
    if (selectedBrands == null ||
        selectedColors == null ||
        selectedThickness == null ||
        !mounted) return;

    setState(() {
      coatingAndList = [];
      selectedCoatingMass = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "coating_mass",
          "product_filters": [selectedAccessories],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [
            selectedBrands,
            selectedColors,
            selectedThickness
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        print("Full API Response: $message");

        if (message is List && message.length >= 2) {
          final coatingData = message[0];
          final idData = message[1];

          if (coatingData is List) {
            setState(() {
              coatingAndList = coatingData
                  .whereType<Map>()
                  .map((e) => e["coating_mass"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            debugPrint("Selected Product Base ID: $selectedProductBaseId");
          }
        } else {
          debugPrint("Unexpected message format for coating mass data.");
        }
      } else {
        debugPrint("Failed to fetch coating mass data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching coating mass data: $e");
    }
  }

  ///post All Data
// Add these variables after line 25 (after the existing List declarations)
  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};

  ///post All Data
// Replace the existing postAllData() method with this updated version:
  Future<void> postAllData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": 1,
      "product_name": selectedAccessories,
      "product_base_id": null,
      "product_base_name":
          "$selectedBrands,$selectedColors,$selectedThickness,$selectedCoatingMass,",
      "category_id": 1,
      "category_name": "accessories_name"
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
      if (selectedAccessories == null ||
          selectedBrands == null ||
          selectedColors == null ||
          selectedThickness == null ||
          selectedCoatingMass == null) return;

      if (response.statusCode == 200) {
        // Parse and store the API response
        final responseData = jsonDecode(response.body);
        setState(() {
          apiResponseData = responseData;
          if (responseData["lebels"] != null &&
              responseData["lebels"].isNotEmpty) {
            responseProducts = responseData["lebels"][0]["data"] ?? [];

            // Store UOM options for each product
            for (var product in responseProducts) {
              if (product["UOM"] != null && product["UOM"]["options"] != null) {
                uomOptions[product["id"].toString()] = Map<String, String>.from(
                    product["UOM"]["options"].map((key, value) =>
                        MapEntry(key.toString(), value.toString())));
              }
            }
          }
        });
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  void _submitData() {
    if (selectedAccessories == null ||
        selectedBrands == null ||
        selectedColors == null ||
        selectedThickness == null ||
        selectedCoatingMass == null) {
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
        "Product": "Accessories",
        "UOM": "Feet",
        "Length": "0",
        "Nos": "1",
        "Basic Rate": "0",
        "SQ": "0",
        "Amount": "0",
        "Base Product":
            "$selectedAccessories, $selectedBrands, $selectedColors, $selectedThickness, $selectedCoatingMass,",
      });
      selectedAccessories = null;
      selectedBrands = null;
      selectedColors = null;
      selectedThickness = null;
      selectedCoatingMass = null;
      accessoriesList = [];
      brandandList = [];
      colorandList = [];
      thickAndList = [];
      coatingAndList = [];
      _fetchAccessories();
      _fetchBrandData();
    });

// Show success message with a more elegant snackBar
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
                          "  ${data["S.No"]}.  ${data["Products"]}" ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
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
              _buildProductDetailInRows(data),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8),
                child: Container(
                  height: 40.h,
                  width: double.infinity.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
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
                              text: " ${data["Material Specification"]}"),
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
                                editController.text =
                                    data["Material Specification"].toString();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Edit Your Liner Sheet"),
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
                                                      data["Material Specification"] =
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
                                                  data["Material Specification"] =
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

// Replace the existing _buildProductDetailInRows() method with this:

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

  // Modified UOM dropdown with calculation trigger

// Modified UOM dropdown with calculation trigger
  Widget _uomDropdownFromApi(Map<String, dynamic> data) {
    String productId = data["id"].toString();
    Map<String, String>? options = uomOptions[productId];

    if (options == null || options.isEmpty) {
      return _editableTextField(data, "UOM");
    }

    String? currentValue;
    if (data["UOM"] is Map) {
      currentValue = data["UOM"]["value"]?.toString();
    } else {
      currentValue = data["UOM"]?.toString();
    }

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.entries
            .map((entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)))
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = {"value": val, "options": options};
          });
          print("UOM changed to: $val"); // Debug print
          print(
              "Product data: ${data["Products"]}, ID: ${data["id"]}"); // Debug print
          // Trigger calculation with debounce
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
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

// Modified editable text field with proper controller management
  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
        controller: controller,
        keyboardType: (key == "Length" ||
                key == "Nos" ||
                key == "Basic Rate" ||
                key == "Amount" ||
                key == "R.Ft")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (val) {
          setState(() {
            data[key] = val;
          });
          print("Field $key changed to: $val"); // Debug print
          print("Controller text: ${controller.text}"); // Check controller text
          print("Data after change: ${data[key]}"); // Additional debug print

          // Force sync the controller and data
          if (controller.text != val) {
            controller.text = val;
          }

          // Trigger calculation for specific fields
          if (key == "Length" || key == "Nos" || key == "Basic Rate") {
            print(
                "Triggering calculation for $key with value: $val"); // Debug print
            _debounceCalculation(data);
          }
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

// Modified product detail rows to include R.Ft
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
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Length", _editableTextField(data, "Profile")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
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
                child: _buildDetailItem(
                    "Basic Rate", _editableTextField(data, "Basic Rate")),
              ),
              SizedBox(width: 10),
              Expanded(
                child:
                    _buildDetailItem("R.Ft", _editableTextField(data, "R.Ft")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Amount", _editableTextField(data, "Amount")),
              ),
            ],
          ),
        ),
        Gap(5.h),
      ],
    );
  }

  String _selectedItems() {
    List<String> value = [
      if (selectedAccessories != null) "Product: $selectedAccessories",
      if (selectedBrands != null) "Brand: $selectedBrands",
      if (selectedColors != null) "Color: $selectedColors",
      if (selectedThickness != null) "Thickness: $selectedThickness",
      if (selectedCoatingMass != null) "CoatingMass: $selectedCoatingMass",
    ];
    return value.isEmpty ? "No selection yet" : value.join(",  ");
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

  // Add these variables after existing declarations

  Timer? _debounceTimer;
  Map<String, dynamic> calculationResults = {};
  Map<String, String?> previousUomValues = {}; // Track previous UOM values
  Map<String, Map<String, TextEditingController>> fieldControllers =
      {}; // Store controllers

// Method to get or create controller for each field
  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    // Initialize product controllers if not exists
    if (!fieldControllers.containsKey(productId)) {
      fieldControllers[productId] = {};
    }

    // Initialize field controller if not exists
    if (!fieldControllers[productId]!.containsKey(key)) {
      fieldControllers[productId]![key] =
          TextEditingController(text: data[key]?.toString() ?? "");
    }

    // FIXED: Only update controller text if it's empty or if it's different from current data
    // and user is not currently typing (to avoid overwriting user input)
    String currentValue = data[key]?.toString() ?? "";
    TextEditingController controller = fieldControllers[productId]![key]!;

    // Only sync if controller is empty or if the data was updated programmatically
    if (controller.text.isEmpty && currentValue.isNotEmpty) {
      controller.text = currentValue;
      print("Synced controller for $key: ${controller.text}");
    }

    return controller;
  }

// Add this method for debounced calculation
  void _debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 10), () {
      _performCalculation(data);
    });
  }

// Calculation API method - FIXED VERSION
  Future<void> _performCalculation(Map<String, dynamic> data) async {
    print("=== STARTING CALCULATION API ===");
    print("Data received: $data");

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('https://demo.zaron.in:8181/ci4/api/calculation');

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

    // FIXED: Get Profile/Length value from controller text instead of data map
    double? profileValue;
    String? profileText;

    // Try to get value from controller first
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Profile")) {
      profileText = fieldControllers[productId]!["Profile"]!.text;
      print("Profile from controller: $profileText");
    }

    // Fallback to data map
    if (profileText == null || profileText.isEmpty) {
      profileText = data["Profile"]?.toString();
      print("Profile from data: $profileText");
    }

    if (profileText != null && profileText.isNotEmpty) {
      profileValue = double.tryParse(profileText);
    }

    // FIXED: Get Nos value from controller first
    int nosValue = 1; // default value
    String? nosText;

    // Try to get value from controller first
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Nos")) {
      nosText = fieldControllers[productId]!["Nos"]!.text;
      print("Nos from controller: $nosText");
    }

    // Fallback to data map
    if (nosText == null || nosText.isEmpty) {
      nosText = data["Nos"]?.toString();
      print("Nos from data: $nosText");
    }

    if (nosText != null && nosText.isNotEmpty) {
      nosValue = int.tryParse(nosText) ?? 1;
    }

    print("Final Profile Value: $profileValue");
    print("Final Nos Value: $nosValue");

    // Prepare request body - FIXED
    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 1,
      "product": data["Products"]?.toString() ?? "",
      "height": null, // Use profileValue instead of null check
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue ?? 0, // Use profileValue, default to 0 if null
      "nos": nosValue, // Use the properly parsed nosValue
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
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

            // Update the data with calculated values
            if (responseData["Length"] != null) {
              data["Profile"] = responseData["Length"].toString();
            }
            if (responseData["Nos"] != null) {
              data["Nos"] = responseData["Nos"].toString();
            }
            if (responseData["R.Ft"] != null) {
              data["R.Ft"] = responseData["R.Ft"].toString();
            }
            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
            }

            // Update previous UOM for next calculation
            previousUomValues[productId] = currentUom;
          });

          print("=== CALCULATION SUCCESS ===");
          print(
              "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, R.Ft=${data["R.Ft"]}, Amount=${data["Amount"]}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Accessories',
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
                          _buildDropdown(accessoriesList, selectedAccessories,
                              (value) {
                            setState(() {
                              selectedAccessories = value;
                            });
// _fetchProductName();
                          },
// enabled: productList.isNotEmpty,
                              label: "Accessories Name"),
                          _buildDropdown(brandandList, selectedBrands, (value) {
                            setState(() {
                              selectedBrands = value;

                              ///clear fields
                              selectedColors = null;
                              selectedThickness = null;
                              selectedCoatingMass = null;
                              colorandList = [];
                              thickAndList = [];
                              coatingAndList = [];
                            });
                            _fetchColorData();
                          }, label: "Brand"),
                          _buildDropdown(colorandList, selectedColors, (value) {
                            setState(() {
                              selectedColors = value;

                              ///clear fields
                              selectedThickness = null;
                              selectedCoatingMass = null;
                              thickAndList = [];
                              coatingAndList = [];
                            });
                            _fetchThicknessData();
                          }, enabled: colorandList.isNotEmpty, label: "Color"),
                          _buildDropdown(thickAndList, selectedThickness,
                              (value) {
                            setState(() {
                              selectedThickness = value;

                              ///clear fields
                              selectedCoatingMass = null;
                              coatingAndList = [];
                            });
                            _fetchCoatingMassData();
                          },
                              enabled: thickAndList.isNotEmpty,
                              label: "Thickness"),
                          _buildDropdown(coatingAndList, selectedCoatingMass,
                              (value) {
                            setState(() {
                              selectedCoatingMass = value;
                            });
                          },
                              enabled: coatingAndList.isNotEmpty,
                              label: "Coating Mass"),

                          Gap(20),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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
// _buildDropdown(coatingAndList, selectedBrand, (value) {
//   setState(() {
//     selectedBrand = value;
//   });
// }, enabled: coatingAndList.isNotEmpty, label: "Brand"),
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
