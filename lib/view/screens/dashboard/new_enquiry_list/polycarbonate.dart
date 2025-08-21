import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../../universal_api/api_key.dart';
import '../../global_user/global_oredrID.dart';

class Polycarbonate extends StatefulWidget {
  const Polycarbonate({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Polycarbonate> createState() => _PolycarbonateState();
}

class _PolycarbonateState extends State<Polycarbonate> {
  Map<String, dynamic>? categoryMeta;
  double? billamt;
  int? orderIDD;
  String? orderNO;
  late TextEditingController editController;

  String? selectedBrand;
  String? selectedColor;
  String? selectedThickness;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<Map<String, dynamic>> submittedData = [];
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(
      text: widget.data["Base Product"] ?? "",
    );
    _fetchBrands();
  }

  @override
  void dispose() {
    editController.dispose();
    baseProductController.dispose();
    baseProductFocusNode.dispose();
    // Dispose controllers in fieldControllers
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final client = IOClient(
        HttpClient()..badCertificateCallback = (_, __, ___) => true,
      );
      final response = await client.get(Uri.parse('$apiUrl/showlables/19'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Brands API Response: ${response.body}");

        final message = data["message"]["message"];
        if (message is List && message.length >= 2) {
          final brandsData = message[1];
          if (brandsData is List) {
            setState(() {
              ///  Extract category info (message[0][0])
              final categoryInfoList = data["message"]["message"][0];
              if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
                categoryMeta = Map<String, dynamic>.from(categoryInfoList[0]);
              }
              brandsList = brandsData
                  .whereType<Map>()
                  .map((e) => e["type_of_panel"]?.toString() ?? "")
                  .where((e) => e.isNotEmpty)
                  .toList();
            });
          }
        }
      } else {
        _showErrorSnackBar("Failed to load brands: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Brands Error: $e");
      _showErrorSnackBar("Error loading brands");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchColors() async {
    if (selectedBrand == null || !mounted) return;
    setState(() => isLoading = true);
    try {
      final client = IOClient(
        HttpClient()..badCertificateCallback = (_, __, ___) => true,
      );
      final response = await client.post(
        Uri.parse('$apiUrl/labelinputdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand],
          "base_label_filters": ["type_of_panel"],
          "base_category_id": "19",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        debugPrint("Colors API Response: ${response.body}");

        if (message is List && message.length >= 2) {
          final colorData = message[0];
          if (colorData is List) {
            setState(() {
              colorsList = colorData
                  .whereType<Map>()
                  .map((e) => e["color"]?.toString() ?? "")
                  .where((e) => e.isNotEmpty)
                  .toList();
            });
          }
        }
      } else {
        _showErrorSnackBar("Failed to load colors: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Colors Error: $e");
      _showErrorSnackBar("Error loading colors");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchThickness() async {
    if (selectedBrand == null || selectedColor == null || !mounted) return;

    setState(() => isLoading = true);

    try {
      final client = IOClient(
        HttpClient()..badCertificateCallback = (_, __, ___) => true,
      );
      final response = await client.post(
        Uri.parse('$apiUrl/labelinputdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand, selectedColor],
          "base_label_filters": ["type_of_panel", "color"],
          "base_category_id": "19",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        debugPrint("Thickness API Response: ${response.body}");
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        if (message is List && message.length >= 2) {
          final thicknessData = message[0];
          final idData = message[1];

          if (thicknessData is List) {
            setState(() {
              thicknessList = thicknessData
                  .whereType<Map>()
                  .map((e) => e["thickness"]?.toString() ?? "")
                  .where((e) => e.isNotEmpty)
                  .toList();
            });
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString();
            debugPrint("Selected Base Product ID: $selectedProductBaseId");
            debugPrint("Base Product Name: $selectedBaseProductName");
          }
        }
      } else {
        _showErrorSnackBar("Failed to load thickness: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Thickness Error: $e");
      _showErrorSnackBar("Error loading thickness");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> postPolycarbonateData() async {
    debugPrint("Posting polycarbonate data...");
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    // From saved categoryMeta
    final categoryId = categoryMeta?["category_id"];
    final categoryName = categoryMeta?["categories"];
    print("this os $categoryId");
    print("this os $categoryName");

    // Use global order ID if available, otherwise null for first time
    final globalOrderManager = GlobalOrderManager();
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": 377423,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId
    };

    debugPrint("Request Body: $data");
    final url = "$apiUrl/addbag";
    final body = jsonEncode(data);
    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (selectedBrand == null ||
          selectedColor == null ||
          selectedThickness == null) {
        _showErrorSnackBar("Please select all required fields");
        return;
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          final String orderID = responseData["order_id"]?.toString() ?? "";
          orderIDD = int.tryParse(orderID);
          orderNO = responseData["order_no"]?.toString() ?? "Unknown";
          apiResponseData = responseData;

          // Set global order ID if this is the first time
          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNO!);
          }

          // Update local variables
          orderIDD = globalOrderManager.globalOrderId;
          orderNO = globalOrderManager.globalOrderNo;

          if (responseData["lebels"] != null &&
              responseData["lebels"].isNotEmpty) {
            List<dynamic> fullList = responseData["lebels"][0]["data"];
            List<Map<String, dynamic>> newProducts = [];

            for (var item in fullList) {
              if (item is Map<String, dynamic>) {
                Map<String, dynamic> product = Map<String, dynamic>.from(item);
                String productId = product["id"].toString();

                bool alreadyExists = responseProducts
                    .any((existing) => existing["id"].toString() == productId);

                if (!alreadyExists) {
                  newProducts.add(product);
                  debugPrint(
                      "Product added: ${product["id"]} - ${product["Products"]}");

                  // Add UOM options if available
                  if (product["UOM"] != null &&
                      product["UOM"]["options"] != null) {
                    uomOptions[product["id"].toString()] =
                        Map<String, String>.from((product["UOM"]["options"]
                                as Map)
                            .map((key, value) =>
                                MapEntry(key.toString(), value.toString())));
                  }
                }
              }
            }

            // Add only non-duplicate products
            responseProducts.addAll(newProducts);
          }
        });
      } else {
        _showErrorSnackBar("Failed to add product: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error posting data: $e");
      _showErrorSnackBar("Failed to add product. Please try again.");
    }
  }

  ///delete cards ///
  Future<void> deleteCards(String deleteId) async {
    final url = '$apiUrl/enquirydelete/$deleteId';
    try {
      final response = await http.delete(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        print("delee response ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            content: Text("Data deleted successfully"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception("Failed to delete card with ID $deleteId");
      }
    } catch (e) {
      print("Error deleting card: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting card: $e")),
      );
    }
  }

  TextEditingController baseProductController = TextEditingController();
  List<dynamic> baseProductResults = [];
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();

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
        debugPrint("Rendering product: $data");
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
                          "  ${index + 1}.  ${data["Products"] ?? "Unknown Product"}",
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
                                        deleteCards(data["id"].toString());
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
              Gap(5),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    debugPrint("Product details: $data");
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
                child: _buildDetailItem(
                    "SQMtr", _editableTextField(data, "SQMtr")),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child:
                    _buildDetailItem("CGST", _editableTextField(data, "cgst")),
              ),
              SizedBox(width: 10),
              Expanded(
                child:
                    _buildDetailItem("SGST", _editableTextField(data, "sgst")),
              ),
            ],
          ),
        ),
        Gap(5.h),
      ],
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

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" ||
            key == "Amount" ||
            key == "SQMtr" ||
            key == "cgst" ||
            key == "sgst"),
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
                key == "SQMtr" ||
                key == "cgst" ||
                key == "sgst")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          setState(() {
            data[key] = val;
          });
          debugPrint("Field $key changed to: $val");
          debugPrint("Controller text: ${controller.text}");
          debugPrint("Data after change: ${data[key]}");

          if (key == "Length" ||
              key == "Nos" ||
              key == "Basic Rate" ||
              key == "Profile") {
            debugPrint("Triggering calculation for $key with value: $val");
            _debounceCalculation(data);
          }
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
            .map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = {"value": val, "options": options};
          });
          debugPrint("UOM changed to: $val");
          debugPrint("Product data: ${data["Products"]}, ID: ${data["id"]}");
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

  void _submitData() {
    if (selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null) {
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
    postPolycarbonateData().then((_) {
      setState(() {
        selectedBrand = null;
        selectedColor = null;
        selectedThickness = null;
        brandsList = [];
        colorsList = [];
        thicknessList = [];
        _fetchBrands();
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

  String _selectedItems() {
    List<String> values = [
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedColor != null) "Color: $selectedColor",
      if (selectedThickness != null) "Thickness: $selectedThickness",
    ];
    return values.isEmpty ? "No selection yet" : values.join(",  ");
  }

  Timer? _debounceTimer;
  Map<String, dynamic> calculationResults = {};
  Map<String, String?> previousUomValues = {};
  Map<String, Map<String, TextEditingController>> fieldControllers = {};

  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();
    fieldControllers.putIfAbsent(productId, () => {});
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] =
          TextEditingController(text: initialValue);
      debugPrint("Created controller for [$key] with value: '$initialValue'");
    } else {
      final controller = fieldControllers[productId]![key]!;
      final dataValue = data[key]?.toString() ?? "";
      if (controller.text.isEmpty && dataValue.isNotEmpty && dataValue != "0") {
        controller.text = dataValue;
        debugPrint("Synced controller for [$key] to: '$dataValue'");
      }
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
    debugPrint("=== STARTING CALCULATION API ===");
    debugPrint("Data received: $data");

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();
    String? currentUom;
    if (data["UOM"] is Map) {
      currentUom = data["UOM"]["value"]?.toString();
    } else {
      currentUom = data["UOM"]?.toString();
    }

    debugPrint("Current UOM: $currentUom");
    debugPrint("Previous UOM: ${previousUomValues[productId]}");

    double? profileValue;
    String? profileText;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Profile")) {
      profileText = fieldControllers[productId]!["Profile"]!.text;
      debugPrint("Profile from controller: $profileText");
    }
    if (profileText == null || profileText.isEmpty) {
      profileText = data["Profile"]?.toString();
      debugPrint("Profile from data: $profileText");
    }
    if (profileText != null && profileText.isNotEmpty) {
      profileValue = double.tryParse(profileText);
    }

    int nosValue = 0;
    String? nosText;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Nos")) {
      nosText = fieldControllers[productId]!["Nos"]!.text;
      debugPrint("Nos from controller: $nosText");
    }
    if (nosText == null || nosText.isEmpty) {
      nosText = data["Nos"]?.toString();
      debugPrint("Nos from data: $nosText");
    }
    if (nosText != null && nosText.isNotEmpty) {
      nosValue = int.tryParse(nosText) ?? 1;
    }

    debugPrint("Final Profile Value: $profileValue");
    debugPrint("Final Nos Value: $nosValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 19,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue ?? 0,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
    };

    debugPrint("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          setState(() {
            billamt = responseData["bill_total"].toDouble() ?? 0.0;
            print("billamt updated to: $billamt");
            calculationResults[productId] = responseData;

            if (responseData["length"] != null) {
              String lengthValue = responseData["length"].toString();
              data["Profile"] = lengthValue;
              if (fieldControllers[productId]?["Profile"] != null) {
                fieldControllers[productId]!["Profile"]!.text = lengthValue;
                print("Length/Profile updated to: $lengthValue");
              }
            }
            if (responseData["Nos"] != null) {
              String newNos = responseData["Nos"].toString().trim();
              String currentInput =
                  fieldControllers[productId]!["Nos"]!.text.trim();
              if (currentInput.isEmpty || currentInput == "0") {
                data["Nos"] = newNos;
                if (fieldControllers[productId]?["Nos"] != null) {
                  fieldControllers[productId]!["Nos"]!.text = newNos;
                }
                debugPrint("Nos field updated to: $newNos");
              } else {
                debugPrint(
                    "Nos NOT updated because user input = '$currentInput'");
              }
            }
            if (responseData["sqmtr"] != null) {
              data["SQMtr"] = responseData["sqmtr"].toString();
              if (fieldControllers[productId]?["SQMtr"] != null) {
                fieldControllers[productId]!["SQMtr"]!.text =
                    responseData["sqmtr"].toString();
              }
            }

            if (responseData["cgst"] != null) {
              data["cgst"] = responseData["cgst"].toString();
              if (fieldControllers[productId]?["cgst"] != null) {
                fieldControllers[productId]!["cgst"]!.text =
                    responseData["cgst"].toString();
              }
            }
            if (responseData["sgst"] != null) {
              data["sgst"] = responseData["sgst"].toString();
              if (fieldControllers[productId]?["sgst"] != null) {
                fieldControllers[productId]!["sgst"]!.text =
                    responseData["sgst"].toString();
              }
            }

            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
              if (fieldControllers[productId]?["Amount"] != null) {
                fieldControllers[productId]!["Amount"]!.text =
                    responseData["Amount"].toString();
              }
            }
            previousUomValues[productId] = currentUom;
          });
          debugPrint("=== CALCULATION SUCCESS ===");
          debugPrint(
              "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, SQMtr=${data["SQMtr"]}, Amount=${data["Amount"]}");
        } else {
          debugPrint("API returned error status: ${responseData["status"]}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Calculation API Error: $e");
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
          text: 'Polycarbonate',
          weight: FontWeight.w500,
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
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
                            brandsList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;
                                selectedColor = null;
                                selectedThickness = null;
                                colorsList = [];
                                thicknessList = [];
                              });
                              _fetchColors();
                            },
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          _buildAnimatedDropdown(
                            colorsList,
                            selectedColor,
                            (value) {
                              setState(() {
                                selectedColor = value;
                                selectedThickness = null;
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
                            selectedThickness,
                            (value) {
                              setState(() {
                                selectedThickness = value;
                              });
                            },
                            enabled: thicknessList.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
                          ),
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
                if (responseProducts.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade100,
                          Colors.blue.shade50
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepPurple.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    Colors.deepPurple.shade100.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.deepPurple.shade700,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Added Products",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Polycarbonate",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.receipt_outlined,
                                      size: 14,
                                      color: Colors.blue.shade700,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "ID: ${orderNO ?? 'N/A'}",
                                      style: GoogleFonts.figtree(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade500,
                                Colors.deepPurple.shade200
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TOTAL AMOUNT",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹${billamt ?? 0}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildSubmittedDataList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
