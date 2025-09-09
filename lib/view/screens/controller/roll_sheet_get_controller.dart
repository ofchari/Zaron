// roll_sheet_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../universal_api/api_key.dart';
import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

class RollSheetController extends GetxController {
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var billamt = 0.0.obs;
  var orderNO = ''.obs;
  var orderIDD = 0.obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var productList = <String>[].obs;
  var brandsList = <String>[].obs;
  var colorsList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var coatingMassList = <String>[].obs;
  var selectedProduct = ''.obs;
  var selectedBrand = ''.obs;
  var selectedColor = ''.obs;
  var selectedThickness = ''.obs;
  var selectedCoatingMass = ''.obs;
  var selectedBaseProductID = ''.obs;
  var selectedProductBaseId = ''.obs;
  var currentMainProductId = ''.obs;
  var rawRollsheet = <dynamic>[].obs;
  var apiProductsList = <Map<String, dynamic>>[].obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var baseProductControllers = <String, TextEditingController>{}.obs;
  var baseProductResults = <String, List<dynamic>>{}.obs;
  var selectedBaseProducts = <String, String?>{}.obs;
  var isSearchingBaseProducts = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductName();
    fetchBrands();
  }

  // Method to display selected items
  String selectedItems() {
    print(
        "selectedItems called - Product: ${selectedProduct.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}, Thickness: ${selectedThickness.value}, CoatingMass: ${selectedCoatingMass.value}");
    List<String> items = [];
    if (selectedProduct.value.isNotEmpty) {
      items.add("Product: ${selectedProduct.value}");
    }
    if (selectedBrand.value.isNotEmpty) {
      items.add("Brand: ${selectedBrand.value}");
    }
    if (selectedColor.value.isNotEmpty) {
      items.add("Color: ${selectedColor.value}");
    }
    if (selectedThickness.value.isNotEmpty) {
      items.add("Thickness: ${selectedThickness.value}");
    }
    if (selectedCoatingMass.value.isNotEmpty) {
      items.add("CoatingMass: ${selectedCoatingMass.value}");
    }
    String result = items.isNotEmpty ? items.join(" | ") : "No selections made";
    print("selectedItems result: $result");
    return result;
  }

  Future<void> fetchProductName() async {
    productList.clear();
    selectedProduct.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/591');

    try {
      final response = await client.get(url);
      print("fetchProductName response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        rawRollsheet.value = products;

        if (products is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          productList.value = products
              .whereType<Map>()
              .map((e) => e["product_name"]?.toString())
              .whereType<String>()
              .toList();
          print("productList updated: ${productList.value}");
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch products: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching products: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch products: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchBrands() async {
    brandsList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/591');

    try {
      final response = await client.get(url);
      print("fetchBrands response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brands = data["message"]["message"][2][1];
        if (brands is List) {
          brandsList.value = brands
              .whereType<Map>()
              .map((e) => e["brand"]?.toString())
              .whereType<String>()
              .toList();
          print("brandsList updated: ${brandsList.value}");
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch brands: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching brands: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch brands: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchColors() async {
    if (selectedProduct.value.isEmpty || selectedBrand.value.isEmpty) return;
    colorsList.clear();
    selectedColor.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 591,
          "base_product_filters": [selectedBrand.value],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
        }),
      );
      print("fetchColors response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];
        if (colors is List) {
          colorsList.value = colors
              .whereType<Map>()
              .map((e) => e["color"]?.toString())
              .whereType<String>()
              .toList();
          print("colorsList updated: ${colorsList.value}");
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch colors: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching colors: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch colors: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchThickness() async {
    if (selectedProduct.value.isEmpty ||
        selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty) return;
    thicknessList.clear();
    selectedThickness.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 591,
          "base_product_filters": [selectedBrand.value, selectedColor.value],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
        }),
      );
      print("fetchThickness response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        if (thickness is List) {
          thicknessList.value = thickness
              .whereType<Map>()
              .map((e) => e["thickness"]?.toString())
              .whereType<String>()
              .toList();
          print("thicknessList updated: ${thicknessList.value}");
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch thickness: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch thickness: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchCoatingMass() async {
    if (selectedProduct.value.isEmpty ||
        selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty ||
        selectedThickness.value.isEmpty) return;
    coatingMassList.clear();
    selectedCoatingMass.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "coating_mass",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 591,
          "base_product_filters": [
            selectedBrand.value,
            selectedColor.value,
            selectedThickness.value,
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": "3",
        }),
      );
      print("fetchCoatingMass response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        if (message is List && message.length >= 2) {
          final coatingData = message[0];
          final idData = message[1];

          if (coatingData is List) {
            coatingMassList.value = coatingData
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
            print("coatingMassList updated: ${coatingMassList.value}");
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedBaseProductID.value = idData.first["id"]?.toString() ?? '';
            selectedProductBaseId.value =
                idData.first["base_product_id"]?.toString() ?? '';
            print(
                "selectedBaseProductID: ${selectedBaseProductID.value}, selectedProductBaseId: ${selectedProductBaseId.value}");
          }
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch coating mass: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch coating mass: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> postAllData() async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/addbag');
    final globalOrderManager = GlobalOrderManager();
    final headers = {"Content-Type": "application/json"};

    // Find the matching item from rawRollsheet
    final matchingAccessory = rawRollsheet.firstWhereOrNull(
      (item) => item["product_name"] == selectedProduct.value,
    );
    final rollsheetProID = matchingAccessory?["id"];

    final data = {
      "customer_id": UserSession().userId,
      "product_id": rollsheetProID,
      "product_name": selectedProduct.value,
      "product_base_id": selectedBaseProductID.value,
      "product_base_name": selectedProductBaseId.value,
      "category_id": categoryMeta["category_id"],
      "category_name": categoryMeta["categories"],
      "OrderID": globalOrderManager.globalOrderId,
    };

    print("postAllData request body: ${jsonEncode(data)}");

    try {
      final response =
          await client.post(url, headers: headers, body: jsonEncode(data));
      print("postAllData response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("postAllData response data: $responseData");
        final String orderID = responseData["order_id"].toString();
        final String orderNo =
            responseData["order_no"]?.toString() ?? "Unknown";
        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNo);
        }
        orderIDD.value = globalOrderManager.globalOrderId!;
        orderNO.value = globalOrderManager.globalOrderNo!;
        currentMainProductId.value =
            responseData["product_id"]?.toString() ?? '';

        if (responseData['lebels'] != null &&
            responseData['lebels'].isNotEmpty) {
          apiProductsList.value = List<Map<String, dynamic>>.from(
              responseData['lebels'][0]['data']);
          List<Map<String, dynamic>> newProducts = [];
          for (var item in apiProductsList) {
            Map<String, dynamic> product = Map<String, dynamic>.from(item);
            String productId = product["id"].toString();
            bool alreadyExists = responseProducts
                .any((existing) => existing["id"].toString() == productId);
            if (!alreadyExists) {
              newProducts.add(product);
            }
            if (product["UOM"] != null && product["UOM"]["options"] != null) {
              uomOptions[productId] = Map<String, String>.from(
                (product["UOM"]["options"] as Map).map(
                    (key, value) => MapEntry(key.toString(), value.toString())),
              );
            }
          }
          responseProducts.addAll(newProducts);
          print("responseProducts updated: ${responseProducts.length} items");
        }
        // Reset dropdown selections after successful post
        resetSelections();
        Get.snackbar(
          "Success",
          "Product added successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to add product: Server returned ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error posting data: $e");
      Get.snackbar(
        "Error",
        "Failed to add product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to reset dropdown selections
  void resetSelections() {
    print("resetSelections called");
    selectedProduct.value = '';
    selectedBrand.value = '';
    selectedColor.value = '';
    selectedThickness.value = '';
    selectedCoatingMass.value = '';
    selectedBaseProductID.value = '';
    selectedProductBaseId.value = '';
    colorsList.clear();
    thicknessList.clear();
    coatingMassList.clear();
    print(
        "After reset - Product: ${selectedProduct.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}");
    fetchProductName();
    fetchBrands();
  }

  Future<void> deleteCard(String deleteId) async {
    final url = Uri.parse('$apiUrl/enquirydelete/$deleteId');
    try {
      final response = await http.delete(url);
      print("deleteCard response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((product) => product["id"].toString() == deleteId);
        fieldControllers.remove(deleteId);
        previousUomValues.remove(deleteId);
        calculationResults.remove(deleteId);
        baseProductControllers.remove(deleteId);
        baseProductResults.remove(deleteId);
        selectedBaseProducts.remove(deleteId);
        isSearchingBaseProducts.remove(deleteId);
        Get.snackbar(
          "Success",
          "Product deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception("Failed to delete card with ID $deleteId");
      }
    } catch (e) {
      print("Error deleting card: $e");
      Get.snackbar(
        "Error",
        "Failed to delete product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Timer? _debounceTimer;

  void debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer =
        Timer(Duration(seconds: 1), () => performCalculation(data));
  }

  bool _isValidNonZeroNumber(String value) {
    if (value.isEmpty) return false;
    double? parsedValue = double.tryParse(value);
    return parsedValue != null && parsedValue != 0.0;
  }

  String _getFieldValue(
      String productId, String fieldName, Map<String, dynamic> data) {
    String? value;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey(fieldName)) {
      value = fieldControllers[productId]![fieldName]!.text.trim();
    }
    if (value == null || value.isEmpty) {
      value = data[fieldName]?.toString();
    }
    return value ?? "";
  }

  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');
    String productId = data["id"].toString();

    String? currentUom;
    if (data["UOM"] is Map) {
      currentUom = data["UOM"]["value"]?.toString();
    } else {
      currentUom = data["UOM"]?.toString();
    }

    String profileText = _getFieldValue(productId, "Profile", data);
    String nosText = _getFieldValue(productId, "Nos", data);

    double profileValue = _isValidNonZeroNumber(profileText)
        ? (double.tryParse(profileText) ?? 0.0)
        : 0.0;
    int nosValue =
        _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 1) : 1;

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 26,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
    };

    try {
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));

      print("performCalculation response status: $requestBody");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("thhh ${response.body}");

        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          // ✅ FIXED: Handle Length or profile from API
          String newProfile = responseData["Length"]?.toString() ??
              responseData["profile"]?.toString() ??
              "0";

          if (_isValidNonZeroNumber(newProfile) && newProfile != profileText) {
            data["Profile"] = newProfile;
            if (fieldControllers[productId]?["Profile"] != null) {
              fieldControllers[productId]!["Profile"]!.text = newProfile;
            }
          }

          // --- Nos update ---
          if (responseData["Nos"] != null) {
            String newNos = responseData["Nos"].toString().trim();
            String currentInput =
                fieldControllers[productId]?["Nos"]?.text.trim() ?? "";
            if (!_isValidNonZeroNumber(currentInput)) {
              data["Nos"] = newNos;
              if (fieldControllers[productId]?["Nos"] != null) {
                fieldControllers[productId]!["Nos"]!.text = newNos;
              }
            }
          }

          // --- SQMtr ---
          if (responseData["sqmtr"] != null) {
            data["SQMtr"] = responseData["sqmtr"].toString();
            fieldControllers[productId]?["SQMtr"]?.text =
                responseData["sqmtr"].toString();
          }

          // --- CGST ---
          if (responseData["cgst"] != null) {
            data["cgst"] = responseData["cgst"].toString();
            fieldControllers[productId]?["cgst"]?.text =
                responseData["cgst"].toString();
          }

          // --- SGST ---
          if (responseData["sgst"] != null) {
            data["sgst"] = responseData["sgst"].toString();
            fieldControllers[productId]?["sgst"]?.text =
                responseData["sgst"].toString();
          }

          // --- Amount ---
          if (responseData["Amount"] != null) {
            data["Amount"] = responseData["Amount"].toString();
            fieldControllers[productId]?["Amount"]?.text =
                responseData["Amount"].toString();
          }

          previousUomValues[productId] = currentUom;
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to perform calculation: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Calculation API Error: $e");
      Get.snackbar(
        "Error",
        "Failed to perform calculation: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget uomDropdown(Map<String, dynamic> data) {
    Map<String, dynamic>? uomData = data['UOM'];
    String? currentValue = uomData?['value']?.toString();
    Map<String, dynamic>? options =
        uomData?['options'] as Map<String, dynamic>?;

    if (options == null || options.isEmpty) {
      return editableTextField(data, "UOM", (val) {},
          fieldControllers: fieldControllers);
    }

    return SizedBox(
      height: 38.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.entries
            .map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value.toString()),
                ))
            .toList(),
        onChanged: (val) {
          if (data['UOM'] is! Map) {
            data['UOM'] = {};
          }
          data['UOM']['value'] = val;
          data['UOM']['options'] = options;
          debounceCalculation(data);
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget editableTextField(
    Map<String, dynamic> data,
    String key,
    ValueChanged<String> onChanged, {
    bool readOnly = false,
    required RxMap<String, Map<String, TextEditingController>> fieldControllers,
  }) {
    String productId = data["id"].toString();
    fieldControllers.putIfAbsent(productId, () => {});
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] =
          TextEditingController(text: initialValue);
    } else {
      final controller = fieldControllers[productId]![key]!;
      final dataValue = data[key]?.toString() ?? "";
      if (controller.text.isEmpty && dataValue.isNotEmpty && dataValue != "0") {
        controller.text = dataValue;
      }
    }
    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: readOnly,
        controller: fieldControllers[productId]![key],
        keyboardType: [
          "Profile",
          "Nos",
          "Basic Rate",
          "Amount",
          "SQMtr",
          "cgst",
          "sgst"
        ].contains(key)
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Future<void> searchBaseProducts(String query, String productId) async {
    if (query.isEmpty) {
      baseProductResults[productId] = [];
      return;
    }

    isSearchingBaseProducts[productId] = true;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final headers = {"Content-Type": "application/json"};
    final data = {"category_id": "1", "searchbase": query};

    try {
      final response = await client.post(
        Uri.parse("$apiUrl/baseproducts_search"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Base product response for $productId: $responseData");
        baseProductResults[productId] = responseData['base_products'] ?? [];
      } else {
        baseProductResults[productId] = [];
      }
    } catch (e) {
      print("Error searching base products for $productId: $e");
      baseProductResults[productId] = [];
    } finally {
      isSearchingBaseProducts[productId] = false;
    }
  }

  Future<void> updateBaseProduct(String productId, String baseProduct) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final headers = {"Content-Type": "application/json"};
    final data = {"id": productId, "base_product": baseProduct};

    try {
      final response = await client.post(
        Uri.parse("$apiUrl/baseproduct_update"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print("Base product updated successfully: $responseData");
        Get.snackbar(
          "Success",
          "Base product updated successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print(
            "Failed to update base product. Status code: ${response.statusCode}");
        Get.snackbar(
          "Error",
          "Failed to update base product. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error updating base product: $e");
      Get.snackbar(
        "Error",
        "Error updating base product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
