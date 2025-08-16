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
import 'package:zaron/view/universal_api/api_key.dart';

import '../../global_user/global_oredrID.dart';
import '../../global_user/global_user.dart';

class Screw extends StatefulWidget {
  const Screw({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Screw> createState() => _ScrewState();
}

class _ScrewState extends State<Screw> {
  Map<String, dynamic>? categoryMeta;
  double? billamt;
  late TextEditingController editController;
  int? orderIDD;
  String? orderNO;
  String? selectedBrand;
  String? selectedScrew;
  String? selectedThread;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> brandList = [];
  List<String> screwLengthList = [];
  List<String> threadList = [];
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};
  Map<String, dynamic>? apiResponse;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchBrand();

    // *** Add this to restore any existing calculated values ***
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDataIntegrity();
    });
  }

  // *** Add this new method ***
  void _ensureDataIntegrity() {
    debugPrint("=== ENSURING DATA INTEGRITY ===");
    for (var product in responseProducts) {
      debugPrint(
          "Product ${product["id"]}: Cgst=${product["Cgst"]}, Sgst=${product["Sgst"]}");
    }
  }

  @override
  void dispose() {
    editController.dispose();
    baseProductController.dispose();
    baseProductFocusNode.dispose();
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  Future<void> _fetchBrand() async {
    setState(() {
      brandList = [];
      selectedBrand = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/7');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        debugPrint("Brand API Response: ${response.body}");

        if (message is List && message.length > 1) {
          final brands = message[1];
          if (brands is List) {
            setState(() {
              ///  Extract category info (message[0][0])
              final categoryInfoList = data["message"]["message"][0];
              if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
                categoryMeta = Map<String, dynamic>.from(categoryInfoList[0]);
              }

              brandList = brands
                  .whereType<Map>()
                  .map((e) => e["brand"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }
        } else {
          _showErrorSnackBar("Invalid brand data format");
        }
      } else {
        _showErrorSnackBar("Failed to load brands: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching brand: $e");
      _showErrorSnackBar("Error loading brands");
    }
  }

  Future<void> _fetchScrew() async {
    if (selectedBrand == null) return;

    setState(() {
      screwLengthList = [];
      selectedScrew = null;
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
        debugPrint("Screw API Response: ${response.body}");

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
        } else {
          _showErrorSnackBar("Invalid screw data format");
        }
      } else {
        _showErrorSnackBar("Failed to load screws: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching screw: $e");
      _showErrorSnackBar("Error loading screws");
    }
  }

  Future<void> _fetchThreads() async {
    if (selectedBrand == null || selectedScrew == null) return;

    setState(() {
      threadList = [];
      selectedThread = null;
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
        debugPrint("Thread API Response: ${response.body}");

        final message = data["message"]["message"];
        if (message is List && message.isNotEmpty) {
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

          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString();
            debugPrint("Selected Base Product ID: $selectedProductBaseId");
            debugPrint("Base Product Name: $selectedBaseProductName");
          }
        } else {
          _showErrorSnackBar("Invalid thread data format");
        }
      } else {
        _showErrorSnackBar("Failed to load threads: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception fetching thread types: $e");
      _showErrorSnackBar("Error loading threads");
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

// 1. First, modify your postScrewData method to initialize CGST/SGST fields:
  Future<void> postScrewData() async {
    debugPrint("Posting screw data...");
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final categoryId = categoryMeta?["category_id"];
    final categoryName = categoryMeta?["categories"];
    print("this os $categoryId");
    print("this os $categoryName");

    final globalOrderManager = GlobalOrderManager();
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": selectedBaseProductName,
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
        body: body,
        headers: headers,
      );

      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (selectedBrand == null ||
          selectedScrew == null ||
          selectedThread == null) {
        _showErrorSnackBar("Please select all required fields");
        return;
      }

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          final String orderID = decodedResponse["order_id"]?.toString() ?? "";
          orderIDD = int.tryParse(orderID);
          orderNO = decodedResponse["order_no"]?.toString() ?? "Unknown";

          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNO!);
          }

          orderIDD = globalOrderManager.globalOrderId;
          orderNO = globalOrderManager.globalOrderNo;
          apiResponse = decodedResponse;

          if (decodedResponse["lebels"] != null &&
              decodedResponse["lebels"].isNotEmpty) {
            final categoryData = decodedResponse["lebels"][0];
            if (categoryData["data"] != null) {
              List<dynamic> fullList = categoryData["data"];
              List<Map<String, dynamic>> newProducts = [];

              for (var item in fullList) {
                if (item is Map<String, dynamic>) {
                  Map<String, dynamic> product =
                      Map<String, dynamic>.from(item);

// *** CRITICAL FIX: Initialize CGST/SGST fields if they don't exist ***
                  if (!product.containsKey("Cgst") || product["Cgst"] == null) {
                    product["Cgst"] =
                        "0"; // Initialize with "0" instead of null
                  }
                  if (!product.containsKey("Sgst") || product["Sgst"] == null) {
                    product["Sgst"] =
                        "0"; // Initialize with "0" instead of null
                  }

                  String productId = product["id"].toString();
                  bool alreadyExists = responseProducts.any(
                      (existing) => existing["id"].toString() == productId);

                  if (!alreadyExists) {
                    newProducts.add(product);
                    if (product["UOM"] != null &&
                        product["UOM"]["options"] != null) {
                      uomOptions[product["id"].toString()] =
                          Map<String, String>.from(
                        (product["UOM"]["options"] as Map).map(
                          (key, value) =>
                              MapEntry(key.toString(), value.toString()),
                        ),
                      );
                    }
                    debugPrint(
                        "Product added with initialized CGST/SGST: ${product["id"]} - ${product["Products"]}");
                    debugPrint(
                        "CGST: ${product["Cgst"]}, SGST: ${product["Sgst"]}");
                  }
                }
              }
              responseProducts.addAll(newProducts);
              debugPrint("Updated responseProducts: $responseProducts");

// *** TRIGGER INITIAL CALCULATIONS FOR NEW PRODUCTS ***
              _triggerInitialCalculations(newProducts);
            }
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

  void _triggerInitialCalculations(List<Map<String, dynamic>> newProducts) {
    debugPrint("=== TRIGGERING INITIAL CALCULATIONS ===");
    for (var product in newProducts) {
// Add a small delay to prevent overwhelming the API
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _performCalculation(product);
        }
      });
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${index + 1}. ${data["Products"] ?? 'N/A'}",
                        style: GoogleFonts.figtree(
                          fontSize: 18,
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
                                        deleteCards(data["id"].toString());
                                        responseProducts.removeAt(index);
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
                _buildApiResponseRows(data),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApiResponseRows(Map<String, dynamic> data) {
    debugPrint("Product details: $data");
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                  "Basic Rate", _editableTextField(data, "Basic Rate")),
            ),
            Gap(5),
            Expanded(
              child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
            ),
            Gap(5),
            Expanded(
              child: _buildDetailItem(
                  "Amount", _editableTextField(data, "Amount")),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                "Cgst",
                _editableTextField(data, "Cgst"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem(
                "Sgst",
                _editableTextField(data, "Sgst"),
              ),
            ),
          ],
        )
      ],
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

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);
    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" ||
            key == "Amount" ||
            key == "Cgst" ||
            key == "Sgst"),
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: controller,
        keyboardType: (key == "Nos" || key == "Basic Rate" || key == "Amount")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (val) {
          setState(() {
            data[key] = val;
          });
          debugPrint("Field $key changed to: $val");
          debugPrint("Controller text: ${controller.text}");
          debugPrint("Data after change: ${data[key]}");
          if (key == "Nos" || key == "Basic Rate") {
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

    postScrewData().then((_) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  String _selectedItems() {
    List<String> selectedData = [
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedScrew != null) "Length of Screw: $selectedScrew",
      if (selectedThread != null) "Thread: $selectedThread",
    ];
    return selectedData.isEmpty ? "No Selection Yet" : selectedData.join(", ");
  }

  Timer? _debounceTimer;
  Map<String, dynamic> calculationResults = {};
  Map<String, String?> previousUomValues = {};
  Map<String, Map<String, TextEditingController>> fieldControllers = {};

// Replace your _performCalculation method with this fixed version:

// 4. Enhanced _performCalculation with better persistence:
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

    int nosValue = 0;
    String? nosText;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Nos")) {
      nosText = fieldControllers[productId]!["Nos"]!.text;
    }
    if (nosText == null || nosText.isEmpty) {
      nosText = data["Nos"]?.toString();
    }
    if (nosText != null && nosText.isNotEmpty && nosText != "0") {
      nosValue = int.tryParse(nosText) ?? 1;
    } else {
      nosValue = 1; // Default to 1 if no quantity specified
    }

    debugPrint("Final Nos Value: $nosValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 7,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": null,
      "current_uom": null,
      "length": null,
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
            billamt = responseData["bill_total"]?.toDouble() ?? 0.0;
            debugPrint("billamt updated to: $billamt");

// Store calculation results
            calculationResults[productId] = responseData;

// *** CRITICAL: Update BOTH the local data AND responseProducts list ***
// Find the product in responseProducts and update it
            for (int i = 0; i < responseProducts.length; i++) {
              if (responseProducts[i]["id"].toString() == productId) {
// Update Nos
                if (responseData["Nos"] != null) {
                  String newNos = responseData["Nos"].toString();
                  responseProducts[i]["Nos"] = newNos;
                  data["Nos"] = newNos;
                  fieldControllers[productId]?["Nos"]?.text = newNos;
                  debugPrint("✅ Updated and persisted Nos: $newNos");
                }

// Update Amount
                if (responseData["Amount"] != null) {
                  String newAmount = responseData["Amount"].toString();
                  responseProducts[i]["Amount"] = newAmount;
                  data["Amount"] = newAmount;
                  fieldControllers[productId]?["Amount"]?.text = newAmount;
                  debugPrint("✅ Updated and persisted Amount: $newAmount");
                }

// *** CRITICAL: Update and persist CGST ***
                if (responseData["cgst"] != null) {
                  String newCgst = responseData["cgst"].toString();
                  responseProducts[i]["Cgst"] =
                      newCgst; // *** PERSIST IN MAIN LIST ***
                  data["Cgst"] = newCgst; // *** UPDATE LOCAL DATA ***
                  fieldControllers[productId]?["Cgst"]?.text = newCgst;
                  debugPrint("✅ Updated and persisted CGST: $newCgst");
                }

// *** CRITICAL: Update and persist SGST ***
                if (responseData["sgst"] != null) {
                  String newSgst = responseData["sgst"].toString();
                  responseProducts[i]["Sgst"] =
                      newSgst; // *** PERSIST IN MAIN LIST ***
                  data["Sgst"] = newSgst; // *** UPDATE LOCAL DATA ***
                  fieldControllers[productId]?["Sgst"]?.text = newSgst;
                  debugPrint("✅ Updated and persisted SGST: $newSgst");
                }

                debugPrint(
                    "✅ PERSISTENCE CHECK - Product ${responseProducts[i]["id"]}:");
                debugPrint("   - Cgst: ${responseProducts[i]["Cgst"]}");
                debugPrint("   - Sgst: ${responseProducts[i]["Sgst"]}");
                debugPrint("   - Amount: ${responseProducts[i]["Amount"]}");
                debugPrint("   - Nos: ${responseProducts[i]["Nos"]}");

                break;
              }
            }

            previousUomValues[productId] = currentUom;
          });

          debugPrint("=== CALCULATION SUCCESS - VALUES PERSISTED ===");
        } else {
          debugPrint("❌ API returned error status: ${responseData["status"]}");
        }
      } else {
        debugPrint("❌ HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Calculation API Error: $e");
    }
  }

  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    debugPrint("=== DEBUG _getController ===");
    debugPrint("ProductId: $productId, Key: $key");
    debugPrint("Data for key '$key': ${data[key]}");
    debugPrint("Data type: ${data[key].runtimeType}");

    fieldControllers.putIfAbsent(productId, () => {});

    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = "";

// *** ENHANCED: Better handling of different data types and null values ***
      if (data[key] != null) {
        String dataValue = data[key].toString();
// For CGST/SGST, treat "0" as empty but preserve calculated values
        if (key == "Cgst" || key == "Sgst") {
          if (dataValue != "0" && dataValue != "null" && dataValue.isNotEmpty) {
            initialValue = dataValue;
            debugPrint("Found calculated $key in data: $initialValue");
          }
        }
// For other fields, use non-zero values
        else if (dataValue != "0" &&
            dataValue != "null" &&
            dataValue.isNotEmpty) {
          initialValue = dataValue;
          debugPrint("Found $key in data: $initialValue");
        }
      }

// *** FALLBACK: Check calculation results ***
      if (initialValue.isEmpty && calculationResults.containsKey(productId)) {
        var calcResult = calculationResults[productId];
        debugPrint("Checking calculation results for $productId: $calcResult");

        if (key == "Cgst" && calcResult["cgst"] != null) {
          initialValue = calcResult["cgst"].toString();
          debugPrint("Found CGST in calculationResults: $initialValue");
        } else if (key == "Sgst" && calcResult["sgst"] != null) {
          initialValue = calcResult["sgst"].toString();
          debugPrint("Found SGST in calculationResults: $initialValue");
        } else if (key == "Amount" && calcResult["Amount"] != null) {
          initialValue = calcResult["Amount"].toString();
          debugPrint("Found Amount in calculationResults: $initialValue");
        } else if (key == "Nos" && calcResult["Nos"] != null) {
          initialValue = calcResult["Nos"].toString();
          debugPrint("Found Nos in calculationResults: $initialValue");
        }
      }

      fieldControllers[productId]![key] =
          TextEditingController(text: initialValue);
      debugPrint("Created controller for [$key] with value: '$initialValue'");
    } else {
// *** ENHANCED: Controller exists, ensure sync with latest data ***
      final controller = fieldControllers[productId]![key]!;
      debugPrint(
          "Controller already exists for [$key] with value: '${controller.text}'");

// *** Check if we need to update controller with latest calculated values ***
      if ((key == "Cgst" || key == "Sgst") && controller.text.isEmpty) {
        if (data[key] != null) {
          String dataValue = data[key].toString();
          if (dataValue != "0" && dataValue != "null" && dataValue.isNotEmpty) {
            controller.text = dataValue;
            debugPrint(
                "Synced $key controller to calculated value: $dataValue");
          }
        }
      }

// *** For other fields, sync if controller is empty but data has value ***
      else if (controller.text.isEmpty && data[key] != null) {
        String dataValue = data[key].toString();
        if (dataValue != "0" && dataValue != "null" && dataValue.isNotEmpty) {
          controller.text = dataValue;
          debugPrint("Synced controller for [$key] to: $dataValue");
        }
      }
    }

    return fieldControllers[productId]![key]!;
  }

  void _debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 1500), () {
      _performCalculation(data);
    });
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Screw',
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
                            brandList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;
                                selectedScrew = null;
                                selectedThread = null;
                                screwLengthList = [];
                                threadList = [];
                              });
                              _fetchScrew();
                            },
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          _buildAnimatedDropdown(
                            screwLengthList,
                            selectedScrew,
                            (value) {
                              setState(() {
                                selectedScrew = value;
                                selectedThread = null;
                                threadList = [];
                              });
                              _fetchThreads();
                            },
                            enabled: screwLengthList.isNotEmpty,
                            label: "Length of Screw",
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            threadList,
                            selectedThread,
                            (value) {
                              setState(() {
                                selectedThread = value;
                              });
                            },
                            enabled: threadList.isNotEmpty,
                            label: "Type of Thread",
                            icon: Icons.keyboard_command_key_outlined,
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
                                "Decking Sheets",
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
                                        "₹${billamt ?? 0.0}",
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
