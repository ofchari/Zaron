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
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../../widgets/text.dart';
import '../../camera_upload/acessories_uploads/accessories_attahment.dart';
import '../../global_user/global_oredrID.dart';
import '../../global_user/global_user.dart';

class Accessories extends StatefulWidget {
  const Accessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Accessories> createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
  int? billamt;
  late TextEditingController editController;
  int? orderIDD;
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
  Map<String, dynamic>? categoryMeta;
  List<dynamic> rawAccessoriesData = []; // Add this line at class level
  List<Map<String, dynamic>> submittedData = [];
  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};
  final _formKey = GlobalKey<FormState>();
  bool isGridView = true;
  TextEditingController baseProductController = TextEditingController();
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();
  String? currentMainProductId;
  Timer? _debounceTimer;
  String? categoryyName;
  String? orderNoo;
  final Map<String, TextEditingController> baseProductControllers = {};
  final Map<String, FocusNode> baseProductFocusNodes = {};

  ///change the controller
  final Map<String, List<dynamic>> baseProductResults = {};
  final Map<String, String?> selectedBaseProducts = {};
  final Map<String, bool> isSearchingBaseProducts = {};
  Map<String, dynamic> calculationResults = {};
  Map<String, String?> previousUomValues = {};
  Map<String, Map<String, TextEditingController>> fieldControllers = {};

  @override
  void initState() {
    super.initState();
    editController = TextEditingController();
    _fetchAccessories();
    _fetchBrandData();
    clearOldSelections();
    // Clear any previous data from other pages
    responseProducts.clear();
    apiResponseData?.clear();
    uomOptions.clear();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    editController.dispose();
    baseProductController.dispose();
    baseProductFocusNode.dispose();
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.dispose();
  }

  Future<void> _fetchAccessories() async {
    setState(() {
      accessoriesList = [];
      selectedAccessories = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/1');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessories = data["message"]["message"][1];
        debugPrint("Accessories:::$accessories");
        debugPrint(response.body, wrapWidth: 1024);
        rawAccessoriesData = accessories;

        if (accessories is List) {
          setState(() {
            ///  Extract category info (message[0][0])
            final categoryInfoList = data["message"]["message"][0];
            if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
              categoryMeta = Map<String, dynamic>.from(categoryInfoList[0]);
            }

            accessoriesList = accessories
                .whereType<Map>()
                .map((e) => e["accessories_name"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching accessories:$e");
    }
  }

  Future<void> _fetchBrandData() async {
    setState(() {
      brandandList = [];
      selectedBrands = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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

  Future<void> _fetchColorData() async {
    if (selectedBrands == null) return;

    setState(() {
      colorandList = [];
      selectedColors = null;
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
          "product_filters": [selectedAccessories],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [selectedBrands],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
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

  Future<void> _fetchThicknessData() async {
    if (selectedBrands == null) return;

    setState(() {
      thickAndList = [];
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
          "product_filters": [selectedAccessories],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [selectedBrands, selectedColors],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
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

  Future<void> _fetchCoatingMassData() async {
    if (selectedBrands == null ||
        selectedColors == null ||
        selectedThickness == null ||
        !mounted) return;

    setState(() {
      coatingAndList = [];
      selectedCoatingMass = null;
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
          "product_filters": [selectedAccessories],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [
            selectedBrands,
            selectedColors,
            selectedThickness,
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

  void clearOldSelections() {
    setState(() {
      // Clear accessories data
      selectedAccessories = null;
      selectedBrands = null;
      selectedColors = null;
      selectedThickness = null;
      selectedCoatingMass = null;
    });
  }

  Future<void> postAllData() async {
    setState(() {
      responseProducts.clear();
      apiResponseData?.clear();
      uomOptions.clear();

      print("Before API call state:");
      print(responseProducts);
      print(apiResponseData);
      print(uomOptions);
    });
    if (selectedAccessories == null ||
        selectedBrands == null ||
        selectedColors == null ||
        selectedThickness == null ||
        selectedCoatingMass == null) {
      return;
    }

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );

    final matchingAccessory = rawAccessoriesData.firstWhere(
      (item) => item["accessories_name"] == selectedAccessories,
      orElse: () => null,
    );

    final accessoryID = matchingAccessory?["id"];
    final categoryId = categoryMeta?["category_id"];
    final categoryName = categoryMeta?["categories"];

    final url = Uri.parse('$apiUrl/addbag');
    final headers = {'Content-Type': 'application/json'};

    // Use global order ID if available, otherwise null for first time
    final globalOrderManager = GlobalOrderManager();

    final data = {
      "customer_id": UserSession().userId,
      "product_id": accessoryID,
      "product_name": selectedAccessories,
      "product_base_id": null,
      "product_base_name":
          "$selectedBrands,$selectedColors,$selectedThickness,$selectedCoatingMass,",
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId // Use global order ID
    };

    print("Posting data: $data");

    try {
      final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          final String orderID = responseData["order_id"].toString();
          final String orderNo =
              responseData["order_no"]?.toString() ?? "Unknown";

          // Set global order ID if this is the first time
          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNo);
          }

          // Update local variables
          orderIDD = globalOrderManager.globalOrderId;
          orderNoo = globalOrderManager.globalOrderNo;
          apiResponseData = responseData;
          currentMainProductId = responseData["product_id"]?.toString();

          // Rest of your existing logic for processing response...
          if (responseData["lebels"] != null &&
              responseData["lebels"].isNotEmpty) {
            String categoryName = responseData["category_name"] ?? "";
            categoryyName = categoryName.isEmpty ? "Accessories" : categoryName;

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
                }

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
              }
            }
            // To this:
            setState(() {
              responseProducts = newProducts; // Replace instead of add
              print("Before API call state:");
              print(responseProducts);
              print(newProducts);
            });
          }
        });
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding product: $e")),
      );
      throw Exception("Error posting data: $e");
    }
  }

  Future<void> deleteCards(String deleteId) async {
    final url = '$apiUrl/enquirydelete/$deleteId';
    try {
      final response = await http.delete(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        print("delee response ${response.statusCode}");
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

  Future<void> searchBaseProducts(String query, String productId) async {
    if (query.isEmpty) {
      setState(() {
        baseProductResults[productId] = [];
      });
      return;
    }

    setState(() {
      isSearchingBaseProducts[productId] = true;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"category_id": "1", "searchbase": query};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/baseproducts_search"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Base product response for $productId: $responseData");
        setState(() {
          baseProductResults[productId] = responseData['base_products'] ?? [];
          isSearchingBaseProducts[productId] = false;
        });
      } else {
        setState(() {
          baseProductResults[productId] = [];
          isSearchingBaseProducts[productId] = false;
        });
      }
    } catch (e) {
      print("Error searching base products for $productId: $e");
      setState(() {
        baseProductResults[productId] = [];
        isSearchingBaseProducts[productId] = false;
      });
    }
  }

  bool isBaseProductUpdated = false;

  Widget _buildBaseProductSearchField(Map<String, dynamic> data) {
    String productId = data["id"].toString();

// Create a unique controller for this product if it doesn't exist
    if (!baseProductControllers.containsKey(productId)) {
      baseProductControllers[productId] = TextEditingController();
      baseProductFocusNodes[productId] = FocusNode();
      baseProductResults[productId] = [];
      selectedBaseProducts[productId] = null;
      isSearchingBaseProducts[productId] = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isGridView
            ? Text(
                "Base Product",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              )
            : Text(
                "Base Product",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
        Gap(5),
        Container(
          height: 40.h,
          width: 200.w,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: baseProductControllers[productId],
            focusNode: baseProductFocusNodes[productId],
            decoration: InputDecoration(
              hintText: "Search base product...",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              suffixIcon: isSearchingBaseProducts[productId] == true
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
              searchBaseProducts(value, productId);
            },
            onTap: () {
              if (baseProductControllers[productId]!.text.isNotEmpty) {
                searchBaseProducts(
                    baseProductControllers[productId]!.text, productId);
              }
            },
          ),
        ),
        if (baseProductResults[productId]?.isNotEmpty == true)
          Container(
            width: 200.w,
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
                ...baseProductResults[productId]!.map((product) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBaseProducts[productId] = product.toString();
                        baseProductControllers[productId]!.text =
                            selectedBaseProducts[productId]!;
                        baseProductResults[productId] = [];
                        isBaseProductUpdated = false;
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
        if (selectedBaseProducts[productId] != null)
          Container(
            width: 200.w,
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
                    "Selected: ${selectedBaseProducts[productId]}",
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
                      selectedBaseProducts[productId] = null;
                      baseProductControllers[productId]!.clear();
                      baseProductResults[productId] = [];
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                ),
              ],
            ),
          ),
        if (selectedBaseProducts[productId] != null && !isBaseProductUpdated)
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 200.w,
            child: ElevatedButton(
              onPressed: () {
                updateSelectedBaseProduct(data["id"].toString());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Update Base Product",
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> updateBaseProduct(String productId, String baseProduct) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"id": productId, "base_product": baseProduct};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/api/baseproduct_update"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Base product updated successfully: $responseData");
        print("Product Id  xxxx $productId");

// Show success message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Base product updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(
            "Failed to update base product. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");

// Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update base product. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error updating base product: $e");

// Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating base product: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      ioClient.close();
    }
  }

// Method to call when user wants to update the selected base product
  void updateSelectedBaseProduct(String productId) {
    if (selectedBaseProducts[productId] != null &&
        selectedBaseProducts[productId]!.isNotEmpty) {
      setState(() {
        isBaseProductUpdated = true;
// baseProductController.clear();
      });
      updateBaseProduct(productId, selectedBaseProducts[productId]!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a base product first."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _submitData() {
    if (selectedAccessories == null ||
        selectedBrands == null ||
        selectedColors == null ||
        selectedThickness == null ||
        selectedCoatingMass == null) {
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
          duration: Duration(seconds: 3),
        ),
      );
    });
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
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade500, Colors.deepPurple.shade200],
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
                // Total Amount Section - Fixed width to prevent overflow
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                SizedBox(width: 12),

// View Toggle Section - Fixed width
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isGridView = true;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isGridView
                                    ? Colors.white.withOpacity(0.25)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.grid_view_rounded,
                                color:
                                    isGridView ? Colors.white : Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isGridView = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: !isGridView
                                    ? Colors.white.withOpacity(0.25)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.view_list_rounded,
                                color:
                                    !isGridView ? Colors.white : Colors.white70,
                                size: 18,
                              ),
                            ),
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

        SizedBox(height: 16),

// Content with smooth transition
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: isGridView ? _buildGridView() : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildGridView() {
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
// color: Colors.red,
                        height: 65.h,
                        width: 200.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}.  ${data["Products"] ?? ""}",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.figtree(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
// color: Colors.deepPurple[50],
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
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
                    ),
                  ],
                ),
                Gap(5),
                _buildProductDetailInRows(data),
                Gap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBaseProductSearchField(data),
                    Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green[100]!),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green[50],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.attach_file,
                            color: Colors.green[600], size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttachmentScreen(
                                productId: data['id'].toString(),
                                mainProductId:
                                    currentMainProductId ?? "Unknown ID",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red[200]!),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red[50],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
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
                  ],
                ),
                Gap(10),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListView() {
    return Column(
      children: responseProducts.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = Map<String, dynamic>.from(entry.value);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${index + 1}. ${data["Products"] ?? ""}",
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                        border: Border.all(color: Colors.blue[100]!),
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
                Gap(5),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactField(
                              "UOM",
                              _uomDropdownFromApi(data),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactField(
                              "Length",
                              _editableTextField(data, "Profile"),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactField(
                              "Nos",
                              _editableTextField(data, "Nos"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactField(
                              "Basic Rate",
                              _editableTextField(data, "Basic Rate"),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactField(
                              "R.Ft",
                              _editableTextField(data, "R.Ft"),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactField(
                              "Amount",
                              _editableTextField(data, "Amount"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBaseProductSearchField(data),
                    SizedBox(width: 8),
                    Material(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttachmentScreen(
                                productId: data['id'].toString(),
                                mainProductId:
                                    currentMainProductId ?? "Unknown ID",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green[100]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.attach_file,
                            color: Colors.green[600],
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Material(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Subhead(
                                text: "Delete This Item?",
                                weight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("No",
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(
                                        () => responseProducts.removeAt(index));
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text("Yes"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red[100]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        SizedBox(height: 32, child: field),
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
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = {"value": val, "options": options};
          });
          print("UOM changed to: $val");
          print("Product data: ${data["Products"]}, ID: ${data["id"]}");
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

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" ||
                key == "Amount" ||
                key == "R.Ft" ||
                key == "bill_total")
            ? true
            : false,
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: controller,
        keyboardType: (key == "Profile" ||
                key == "Nos" ||
                key == "Basic Rate" ||
                key == "Amount" ||
                key == "R.Ft")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          setState(() {
// Only update the data if the value is not empty
            if (val.trim().isNotEmpty) {
// Convert to double and check if it's not zero
              final numVal = double.tryParse(val);
              if (numVal != null && numVal != 0) {
                data[key] = val;
                print("Field $key changed to: $val");
                print("Controller text: ${controller.text}");
                print("Data after change: ${data[key]}");

                if (key == "Profile" ||
                    key == "Nos" ||
                    key == "Basic Rate" ||
                    key == "bill_total") {
                  print("Triggering calculation for $key with value: $val");
                  _debounceCalculation(data);
                }
              }
            } else {
// Remove the key from data if value is empty
              data.remove(key);
              print("Removed empty field $key from data");
            }
          });
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

  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem("UOM", _uomDropdownFromApi(data)),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem(
                "Length", // Changed from "Length" to match the actual key
                _editableTextField(data, "Profile"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
            ),
          ],
        ),
        Gap(5),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                "Basic Rate",
                _editableTextField(data, "Basic Rate"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem(
                "R.Ft",
                _editableTextField(data, "R.Ft"),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem(
                "Amount",
                _editableTextField(data, "Amount"),
              ),
            ),
          ],
        ),
        Gap(5),
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

  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();
    fieldControllers.putIfAbsent(productId, () => {});
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] = TextEditingController(
        text: initialValue,
      );
      print("Created controller for [$key] with value: '$initialValue'");
    } else {
      final controller = fieldControllers[productId]![key]!;
      final dataValue = data[key]?.toString() ?? "";
      if (controller.text.isEmpty && dataValue.isNotEmpty && dataValue != "0") {
        controller.text = dataValue;
        print("Synced controller for [$key] to: '$dataValue'");
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
    print("=== STARTING CALCULATION API ===");
    print("Data received: $data");

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

    print("Current UOM: $currentUom");
    print("Previous UOM: ${previousUomValues[productId]}");

    double? profileValue;
    String? profileText;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Profile")) {
      profileText = fieldControllers[productId]!["Profile"]!.text;
      print("Profile from controller: $profileText");
    }
    if (profileText == null || profileText.isEmpty) {
      profileText = data["Profile"]?.toString();
      print("Profile from data: $profileText");
    }
    if (profileText != null && profileText.isNotEmpty) {
      profileValue = double.tryParse(profileText);
    }

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

    print("Final Profile Value: $profileValue");
    print("Final Nos Value: $nosValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 1,
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

    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Bodyyyy: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          setState(() {
            billamt = responseData["bill_total"] ?? 0;
            print("billamt updated to: $billamt");
            calculationResults[productId] = responseData;
            if (responseData["Length"] != null) {
              data["Profile"] = responseData["Length"].toString();
              if (fieldControllers[productId]?["Profile"] != null) {
                fieldControllers[productId]!["Profile"]!.text =
                    responseData["Length"].toString();
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
                print("Nos field updated to: $newNos");
              } else {
                print("Nos NOT updated because user input = '$currentInput'");
              }
            }
            if (responseData["R.Ft"] != null) {
              data["R.Ft"] = responseData["R.Ft"].toString();
              if (fieldControllers[productId]?["R.Ft"] != null) {
                fieldControllers[productId]!["R.Ft"]!.text =
                    responseData["R.Ft"].toString();
              }
            }
            if (responseData["bill_total"] != null) {
              data["bill_total"] = responseData["bill_total"].toString();
              if (fieldControllers[productId]?["bill_total"] != null) {
                fieldControllers[productId]!["bill_total"]!.text =
                    responseData["bill_total"].toString();
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
          print("=== CALCULATION SUCCESS ===");
          print(
            "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, R.Ft=${data["R.Ft"]}, Amount=${data["Amount"]}",
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
          'Accessories',
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
          onPressed: () => {
            clearOldSelections(), // Add this line
            Navigator.pop(context),
          },
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
                          SizedBox(width: 10),
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
                            accessoriesList,
                            selectedAccessories,
                            (value) {
                              setState(() {
                                selectedAccessories = value;
                              });
                            },
                            label: "Accessories Name",
                            icon: Icons.category_outlined,
                          ),
                          _buildAnimatedDropdown(
                            brandandList,
                            selectedBrands,
                            (value) {
                              setState(() {
                                selectedBrands = value;
                                selectedColors = null;
                                selectedThickness = null;
                                selectedCoatingMass = null;
                                colorandList = [];
                                thickAndList = [];
                                coatingAndList = [];
                              });
                              _fetchColorData();
                            },
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          _buildAnimatedDropdown(
                            colorandList,
                            selectedColors,
                            (value) {
                              setState(() {
                                selectedColors = value;
                                selectedThickness = null;
                                selectedCoatingMass = null;
                                thickAndList = [];
                                coatingAndList = [];
                              });
                              _fetchThicknessData();
                            },
                            enabled: colorandList.isNotEmpty,
                            label: "Color",
                            icon: Icons.color_lens_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thickAndList,
                            selectedThickness,
                            (value) {
                              setState(() {
                                selectedThickness = value;
                                selectedCoatingMass = null;
                                coatingAndList = [];
                              });
                              _fetchCoatingMassData();
                            },
                            enabled: thickAndList.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            coatingAndList,
                            selectedCoatingMass,
                            (value) {
                              setState(() {
                                selectedCoatingMass = value;
                              });
                            },
                            enabled: coatingAndList.isNotEmpty,
                            label: "Coating Mass",
                            icon: Icons.layers_outlined,
                          ),
                          SizedBox(height: 16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: categoryyName ?? "Accessories",
                                    weight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
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
                                          "ID: $orderNoo",
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
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
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
