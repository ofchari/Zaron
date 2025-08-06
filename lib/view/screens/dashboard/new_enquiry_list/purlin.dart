import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../camera_upload/purlin_uploads/purlin_attatchment.dart';
import '../../global_user/global_oredrID.dart';
import '../../global_user/global_user.dart';

class Purlin extends StatefulWidget {
  const Purlin({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<Purlin> createState() => _PurlinState();
}

class _PurlinState extends State<Purlin> {
  Map<String, dynamic>? categoryMeta;
  int? billamt;
  int? orderIDD;
  String? orderNO;
  late TextEditingController editController;

  String? selectProduct;
  String? selectedBrand;
  String? selectedSize;
  String? selectedThickness;
  String? selectedMaterialType;
  String? selectedProductBaseId;
  String? selectedBaseProductName;
  String? currentMainProductId;

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

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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
            ///  Extract category info (message[0][0])
            final categoryInfoList = data["message"]["message"][0];
            if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
              categoryMeta = Map<String, dynamic>.from(categoryInfoList[0]);
            }

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

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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
          "base_product_filters": [
            selectProduct,
            selectedSize,
            selectedMaterialType,
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
            selectProduct,
            selectedSize,
            selectedMaterialType,
            selectedThickness,
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
  Map<String, dynamic> apiResponseData = {};
  Map<String, dynamic>? apiResponse;

  // 2. MODIFY the postAllData() method - REPLACE the existing postAllData method with this:
  Future<void> postAllData() async {
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
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId
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

        setState(() {
          final String orderID = responseData["order_id"]?.toString() ?? "";
          orderIDD = int.tryParse(orderID);
          orderNO = responseData["order_no"]?.toString() ?? "Unknown";
          // Set global order ID if this is the first time
          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNO!);
          }

          // Update local variables
          orderIDD = globalOrderManager.globalOrderId;
          orderNO = globalOrderManager.globalOrderNo;
          apiResponseData = responseData;
          currentMainProductId = responseData["product_id"]?.toString();

          // Handle label data safely
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
                }

                // UOM options
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
                    "Product added: ${product["id"]} - ${product["Products"]}");
              }
            }

            // ⛔ DO NOT ADD FULL LIST DIRECTLY HERE
            // ✅ Only add unique new products
            responseProducts.addAll(newProducts);
          }
        });
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

  ///delete cards ///
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

  TextEditingController baseProductController = TextEditingController();
  List<dynamic> baseProductResults = [];
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();
  // Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};

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
                  Material(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurlinAttachment(
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

  // ADD this new method for the editable fields:
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
                  "Length",
                  _editableTextField(data, "Profile"),
                ),
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
                  "Basic Rate",
                  _editableTextField(data, "Basic Rate"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "Kg",
                  _editableTextField(data, "kg"),
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

  // 5. ADD this new method after _buildApiProductDetailInRows():
  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" || key == "Amount" || key == "kg")
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

          if (key == "Length" ||
              key == "Nos" ||
              key == "Basic Rate" ||
              key == "Profile") {
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

  // 6. ADD this new method after _apiEditableTextField():
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
          print("UOM changed to: $val"); // Debug print
          print(
            "Product data: ${data["Products"]}, ID: ${data["id"]}",
          ); // Debug print
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

    print("Final Profile Value: $profileValue");
    print("Final Nos Value: $nosValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 5,
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
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["status"] == "success") {
          setState(() {
            calculationResults[productId] = responseData;

            if (responseData["Length"] != null) {
              data["Profile"] = responseData["Length"].toString();
              if (fieldControllers[productId]?["Profile"] != null) {
                fieldControllers[productId]!["Profile"]!.text =
                    responseData["Length"].toString();
              }
            }

            // if (responseData["kg"] != null) {
            //   String kgValue = responseData["kg"].toString();
            //   print("KG value: $kgValue");
            //
            //   // ✅ Store KG in your data map
            //   data["KG"] = kgValue;
            //
            //   // ✅ If you have a KG field in UI, update it
            //   if (fieldControllers[productId]?["KG"] != null) {
            //     fieldControllers[productId]!["KG"]!.text = kgValue;
            //   }
            // }

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

            if (responseData["kg"] != null) {
              data["kg"] = responseData["kg"].toString();
              if (fieldControllers[productId]?["kg"] != null) {
                fieldControllers[productId]!["kg"]!.text =
                    responseData["kg"].toString();
              }
            }
            print("KG value updated: ${data["kg"]}");

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
            "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, KGG=${data["kg"]}, Amount=${data["Amount"]}",
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
          text: 'Purlin',
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
                            productList,
                            selectProduct,
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
                            icon: Icons.format_shapes_outlined,
                          ),
                          _buildAnimatedDropdown(
                            sizeList,
                            selectedSize,
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
                            icon: Icons.format_size_outlined,
                          ),
                          _buildAnimatedDropdown(
                            materialTypeList,
                            selectedMaterialType,
                            (value) {
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
                            icon: Icons.difference_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thicknessList,
                            selectedThickness,
                            (value) {
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
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            brandsList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;
                              });
                              // _fetchColor();
                            },
                            enabled: brandsList.isNotEmpty,
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
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
                if (submittedData.isNotEmpty) ...[
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
