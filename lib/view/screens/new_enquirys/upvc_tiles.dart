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

import '../global_user/global_user.dart';

class UpvcTiles extends StatefulWidget {
  const UpvcTiles({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<UpvcTiles> createState() => _UpvcTilesState();
}

class _UpvcTilesState extends State<UpvcTiles> {
  late TextEditingController editController;

  String? selectMaterial;
  String? selectedColor;
  String? selectThickness;
  String? selectedBaseProductName;

  List<String> materialList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  String? selectedProductBaseId;

  List<Map<String, dynamic>> submittedData = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchMaterial();
  }

  // Add this to your dispose method
  @override
  void dispose() {
    editController.dispose();
    debounceTimer?.cancel();

    // Dispose all field controllers
    fieldControllers.values.forEach((controllers) {
      controllers.values.forEach((controller) => controller.dispose());
    });

    super.dispose();
  }

  Future<void> _fetchMaterial() async {
    setState(() {
      materialList = [];
      selectMaterial = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/631');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final material = data["message"]["message"][1];
        print(response.body);

        if (material is List) {
          setState(() {
            materialList = material
                .whereType<Map>()
                .map((e) => e["material_type"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching material type: $e");
    }
  }

  /// fetch Color Api's ///
  Future<void> _fetchColor() async {
    if (selectMaterial == null) return;

    setState(() {
      colorsList = [];
      selectedColor = null;
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
          "product_label": "color",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectMaterial],
          "base_label_filters": ["material_type"],
          "base_category_id": "631",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final color = data["message"]["message"][0];
        print("Fetching colors for brand: $selectMaterial");
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

  /// fetch Thickness Api's ///
  Future<void> _fetchThickness() async {
    if (selectMaterial == null || selectedColor == null || !mounted) return;

    setState(() {
      thicknessList = [];
      selectThickness = null;
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
          "base_product_filters": [selectMaterial, selectedColor],
          "base_label_filters": ["material_type", "color"],
          "base_category_id": "631",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        print("Full API Response: $message");

        if (message is List && message.length >= 2) {
          final thicknessData = message[0];
          final idData = message[1];

          if (thicknessData is List) {
            setState(() {
              thicknessList = thicknessData
                  .whereType<Map>()
                  .map((e) => e["thickness"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString(); // <-- New line
            debugPrint("Selected Base Product ID: $selectedProductBaseId");
            debugPrint(
              "Base Product Name: $selectedBaseProductName",
            ); // <-- Optional
          }
        } else {
          debugPrint("Unexpected message format.");
        }
      } else {
        debugPrint("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  // 1. ADD THESE VARIABLES after your existing variables (around line 25)
  List<Map<String, dynamic>> apiResponseData = [];
  Map<String, dynamic>? apiResponse;

  // 2. MODIFY the postUPVCData() method - REPLACE the existing method with this:
  Future<void> postUPVCData() async {
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
      "category_id": 631,
      "category_name": "UPVC Tiles",
    };
    print("User input Data $data");
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
        // Parse the API response
        final responseData = jsonDecode(response.body);
        setState(() {
          apiResponse = responseData;
          if (responseData['lebels'] != null &&
              responseData['lebels'].isNotEmpty) {
            apiResponseData = List<Map<String, dynamic>>.from(
              responseData['lebels'][0]['data'] ?? [],
            );
          }
        });
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

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
    final data = {"category_id": "631", "searchbase": query};

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

  // 3. REPLACE the _buildSubmittedDataList() method with this:
  Widget _buildSubmittedDataList() {
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Header with product name and delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${data["S.No"]}. ${data["Products"]}",
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Product"),
                              content: Text(
                                "Are you sure you want to delete this item?",
                              ),
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
          ),
        );
      }).toList(),
    );
  }

  // 4. ADD this new method:
  Widget _buildApiResponseFields(Map<String, dynamic> data) {
    return Column(
      children: [
        // Row 1: UOM and Length
        Row(
          children: [
            Expanded(child: _buildUOMDropdownFromAPI(data)),
            SizedBox(width: 12),
            Expanded(
              child: _buildEditableFieldFromAPI("Length", data, "Length"),
            ),
            Gap(10),
            Expanded(child: _buildEditableFieldFromAPI("Nos", data, "Nos")),
          ],
        ),
        SizedBox(height: 12),

        // Row 2: Nos and Basic Rate
        Row(
          children: [
            Expanded(
              child: _buildEditableFieldFromAPI(
                "Basic Rate",
                data,
                "Basic Rate",
              ),
            ),
            Gap(10),
            Expanded(
              child: _buildEditableFieldFromAPI("Sq.Mtr", data, "Sq.Mtr"),
            ),
            Gap(10),
            Expanded(
              child: _buildEditableFieldFromAPI("Amount", data, "Amount"),
            ),
          ],
        ),
      ],
    );
  }

  // 5. ADD this method for UOM dropdown:
  // REPLACE your existing _buildUOMDropdownFromAPI method with this:
  Widget _buildUOMDropdownFromAPI(Map<String, dynamic> data) {
    Map<String, String> uomOptions = {};
    String? currentValue;

    if (data["UOM"] is Map) {
      currentValue = data["UOM"]["value"]?.toString();
      if (data["UOM"]["options"] is Map) {
        Map<String, dynamic> options = data["UOM"]["options"];
        options.forEach((key, value) {
          uomOptions[key] = value.toString();
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "UOM",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        SizedBox(height: 6),
        SizedBox(
          height: 38.h,
          child: DropdownButtonFormField<String>(
            value: currentValue,
            items: uomOptions.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() {
                data["UOM"]["value"] = val;
              });
              // Trigger calculation when UOM changes
              debounceCalculation(data);
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
        ),
      ],
    );
  }

  // REPLACE your existing _buildEditableFieldFromAPI method with this:
  Widget _buildEditableFieldFromAPI(
    String label,
    Map<String, dynamic> data,
    String key,
  ) {
    TextEditingController controller = getController(data, key);

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
        SizedBox(
          height: 38.h,
          child: TextField(
            readOnly:
                (key == "Basic Rate" || key == "Amount" || key == "Sq.Mtr")
                    ? true
                    : false,
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 15.sp,
            ),
            controller: controller,
            onChanged: (val) {
              data[key] = val;
              // Trigger calculation for specific fields
              if (key == "Length" || key == "Nos" || key == "Basic Rate") {
                debounceCalculation(data);
              }
            },
            keyboardType: _getKeyboardType(key),
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
        ),
      ],
    );
  }

  // Helper method for keyboard types
  TextInputType _getKeyboardType(String key) {
    switch (key) {
      case "Length":
      case "Nos":
      case "Basic Rate":
      case "Sq.Mtr":
      case "Amount":
        return TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  // 7. MODIFY the _submitData() method - REPLACE with this:
  void _submitData() {
    if (selectMaterial == null ||
        selectedColor == null ||
        selectThickness == null) {
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
      return; // Return early without proceeding further
    }

    // Only proceed with posting data if all fields are filled
    postUPVCData().then((_) {
      // Reset the form after successful submission
      setState(() {
        selectMaterial = null;
        selectedColor = null;
        selectThickness = null;
        materialList = [];
        colorsList = [];
        thicknessList = [];
        _fetchMaterial();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  String _selectedItems() {
    List<String> values = [
      if (selectMaterial != null) "Material Type:  $selectMaterial",
      if (selectedColor != null) "Color:  $selectedColor",
      if (selectThickness != null) "Thickness:  $selectThickness",
    ];

    return values.isEmpty ? "No selections yet" : values.join(",  ");
  }

  Timer? debounceTimer;
  Map<String, String?> previousUomValues = {}; // Track previous UOM values
  Map<String, Map<String, TextEditingController>> fieldControllers =
      {}; // Store controllers

  // Add this helper method to get/create controllers
  TextEditingController getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    fieldControllers.putIfAbsent(productId, () => {});

    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] = TextEditingController(
        text: initialValue,
      );
    }

    return fieldControllers[productId]![key]!;
  }

  // Add debounce method
  void debounceCalculation(Map<String, dynamic> data) {
    debounceTimer?.cancel();
    debounceTimer = Timer(Duration(seconds: 1), () {
      performCalculation(data);
    });
  }

  // Add calculation API method
  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();

    // Get current UOM value - handle both string and Map cases
    String? currentUom;
    if (data["UOM"] is Map) {
      currentUom = data["UOM"]["value"]?.toString();
    } else {
      currentUom = data["UOM"]?.toString();
    }

    // Get previous UOM
    String? previousUom = previousUomValues[productId];

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 631, // Your category ID
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUom,
      "current_uom": currentUom,
      "length": data["Length"]?.toString(),
      "nos": int.tryParse(data["Nos"]?.toString() ?? "0") ?? 0,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
    };

    print("Calculation Request: $requestBody");

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        // Clean the response body - remove any prefix characters
        String cleanResponseBody = response.body;

        // Find the first '{' character (start of JSON)
        int jsonStart = cleanResponseBody.indexOf('{');
        if (jsonStart > 0) {
          cleanResponseBody = cleanResponseBody.substring(jsonStart);
        }

        print("Cleaned Response: $cleanResponseBody");

        try {
          final responseData = jsonDecode(cleanResponseBody);

          if (responseData["status"] == "success") {
            setState(() {
              // Update fields based on API response - match exact field names from API
              if (responseData["length"] != null) {
                data["Length"] = responseData["length"].toString();
                getController(data, "Length").text = data["Length"];
              }
              if (responseData["nos"] != null) {
                data["Nos"] = responseData["nos"].toString();
                getController(data, "Nos").text = data["Nos"];
              }
              if (responseData["sqmtr"] != null) {
                data["Sq.Mtr"] = responseData["sqmtr"].toString();
                getController(data, "Sq.Mtr").text = data["Sq.Mtr"];
              }
              if (responseData["Amount"] != null) {
                data["Amount"] = responseData["Amount"].toString();
                getController(data, "Amount").text = data["Amount"];
              }
              if (responseData["rate"] != null) {
                data["Basic Rate"] = responseData["rate"].toString();
                getController(data, "Basic Rate").text = data["Basic Rate"];
              }

              // Store current UOM as previous for next call
              previousUomValues[productId] = currentUom;
            });
          }
        } catch (jsonError) {
          print("JSON Parse Error: $jsonError");
          print("Problematic JSON: $cleanResponseBody");
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
  }

  ////UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UPVC Tiles',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add New Product",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 24),
                          _buildAnimatedDropdown(
                            materialList,
                            selectMaterial,
                            (value) {
                              setState(() {
                                selectMaterial = value;
                                selectedColor = null;
                                selectThickness = null;
                                colorsList = [];
                                thicknessList = [];
                              });
                              _fetchColor();
                            },
                            label: "Material Type",
                            icon: Icons.difference_outlined,
                          ),
                          _buildAnimatedDropdown(
                            colorsList,
                            selectedColor,
                            (value) {
                              setState(() {
                                selectedColor = value;
                                selectThickness = null;
                                thicknessList = [];
                              });
                              _fetchThickness();
                            },
                            enabled: colorsList.isNotEmpty,
                            label: "Color",
                            icon: Icons.color_lens_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thicknessList,
                            selectThickness,
                            (value) {
                              setState(() {
                                selectThickness = value;
                              });
                            },
                            enabled: thicknessList.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
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
                if (apiResponseData.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Added Products",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildSubmittedDataList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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
          ),
        ),
      ),
    );
  }
}
