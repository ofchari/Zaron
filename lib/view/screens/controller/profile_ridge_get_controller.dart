import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api_key.dart';

import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

class ProfileRidgeAndArchController extends GetxController {
  var materialList = <String>[].obs;
  var brandandList = <String>[].obs;
  var colorandList = <String>[].obs;
  var thickAndList = <String>[].obs;
  var coatingAndList = <String>[].obs;
  var responseProducts = <Map<String, dynamic>>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var baseProductResults = <String, List<dynamic>>{}.obs;
  var selectedBaseProducts = <String, String?>{}.obs;
  var isSearchingBaseProducts = <String, bool>{}.obs;
  var baseProductControllers = <String, TextEditingController>{}.obs;
  var baseProductFocusNodes = <String, FocusNode>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var rawProfilearch = <dynamic>[].obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var billamt = 0.0.obs;

  // Non-reactive variables
  var selectedMaterial = null;
  var selectedBrands = null;
  var selectedColors = null;
  var selectedThickness = null;
  var selectedCoatingMass = null;
  var selectedProductBaseId = null;
  var selectedBaseProductId = null;
  var currentMainProductId = null;
  var orderIDD = null;
  var orderNO = null;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchMaterial();
    fetchBrandData();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    baseProductControllers.forEach((_, controller) => controller.dispose());
    baseProductFocusNodes.forEach((_, node) => node.dispose());
    super.onClose();
  }

  Future<void> fetchMaterial() async {
    materialList.clear();
    selectedMaterial = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/32');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        rawProfilearch.value = products;

        if (products is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          materialList.value = products
              .whereType<Map>()
              .map((e) => e["product_name"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching materials: $e");
    }
  }

  Future<void> fetchBrandData() async {
    brandandList.clear();
    selectedBrands = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/32');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brandData = data["message"]["message"][2][1];

        if (brandData is List) {
          brandandList.value = brandData
              .whereType<Map>()
              .map((e) => e["brand"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  Future<void> fetchColorData() async {
    if (selectedBrands == null) return;

    colorandList.clear();
    selectedColors = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": [selectedMaterial],
          "product_label_filters": ["product_name"],
          "product_category_id": 32,
          "base_product_filters": [selectedBrands],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];

        if (colors is List) {
          colorandList.value = colors
              .whereType<Map>()
              .map((e) => e["color"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching colors: $e");
    }
  }

  Future<void> fetchThicknessData() async {
    if (selectedBrands == null || selectedColors == null) return;

    thickAndList.clear();
    selectedThickness = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "product_filters": [selectedMaterial],
          "product_label_filters": ["product_name"],
          "product_category_id": 32,
          "base_product_filters": [selectedBrands, selectedColors],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];

        if (thickness is List) {
          thickAndList.value = thickness
              .whereType<Map>()
              .map((e) => e["thickness"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  Future<void> fetchCoatingMassData() async {
    if (selectedBrands == null ||
        selectedColors == null ||
        selectedThickness == null) return;

    coatingAndList.clear();
    selectedCoatingMass = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "coating_mass",
          "product_filters": [selectedMaterial],
          "product_label_filters": ["product_name"],
          "product_category_id": 32,
          "base_product_filters": [
            selectedColors,
            selectedBrands,
            selectedThickness
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        if (message is List && message.isNotEmpty) {
          final coating = message[0];
          if (coating is List) {
            coatingAndList.value = coating
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
          }

          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductId = idData.first["base_product_id"]?.toString();
          }
        }
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    }
  }

  Future<void> postAllData() async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/addbag');
    final globalOrderManager = GlobalOrderManager();

    final matchingAccessory = rawProfilearch.firstWhere(
      (item) => item["product_name"] == selectedMaterial,
      orElse: () => null,
    );

    final productID = matchingAccessory?["id"];
    final categoryId = categoryMeta["category_id"];
    final categoryName = categoryMeta["categories"];

    final data = {
      "customer_id": UserSession().userId,
      "product_id": productID,
      "product_name": selectedMaterial,
      "product_base_id": null,
      "product_base_name": selectedProductBaseId,
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId,
    };

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      final String orderID = responseData["order_id"]?.toString() ?? "";
      orderIDD = int.tryParse(orderID);
      orderNO = responseData["order_no"]?.toString() ?? "Unknown";

      if (!globalOrderManager.hasGlobalOrderId()) {
        globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNO);
      }

      orderIDD = globalOrderManager.globalOrderId;
      orderNO = globalOrderManager.globalOrderNo;
      currentMainProductId = responseData["product_id"]?.toString();

      if (responseData["lebels"] != null && responseData["lebels"].isNotEmpty) {
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

            if (product["UOM"] != null && product["UOM"]["options"] != null) {
              uomOptions[productId] = Map<String, String>.from(
                (product["UOM"]["options"] as Map).map(
                  (key, value) => MapEntry(key.toString(), value.toString()),
                ),
              );
            }
          }
        }

        responseProducts.addAll(newProducts);
      }
    } catch (e) {
      print("Error posting data: $e");
    }
  }

  Future<void> deleteCard(String deleteId) async {
    final url = Uri.parse('$apiUrl/enquirydelete/$deleteId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((product) => product["id"].toString() == deleteId);
        Get.snackbar("Success", "Data deleted successfully",
            backgroundColor: Colors.red.shade400,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        throw Exception("Failed to delete card with ID $deleteId");
      }
    } catch (e) {
      print("Error deleting card: $e");
      Get.snackbar("Error", "Error deleting card: $e",
          backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> searchBaseProducts(String query, String productId) async {
    if (query.isEmpty) {
      baseProductResults[productId] = [];
      return;
    }

    isSearchingBaseProducts[productId] = true;
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse("$apiUrl/baseproducts_search");

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"category_id": "1", "searchbase": query}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        baseProductResults[productId] = responseData['base_products'] ?? [];
        isSearchingBaseProducts[productId] = false;
      } else {
        baseProductResults[productId] = [];
        isSearchingBaseProducts[productId] = false;
      }
    } catch (e) {
      print("Error searching base products: $e");
      baseProductResults[productId] = [];
      isSearchingBaseProducts[productId] = false;
    }
  }

  Widget buildBaseProductSearchField(Map<String, dynamic> data) {
    String productId = data["id"].toString();

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
        Text(
          "Base Product",
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 15),
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            onChanged: (value) => searchBaseProducts(value, productId),
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
                      color: Colors.black87),
                ),
                SizedBox(height: 8),
                ...baseProductResults[productId]!.map((product) {
                  return GestureDetector(
                    onTap: () {
                      selectedBaseProducts[productId] = product.toString();
                      baseProductControllers[productId]!.text =
                          product.toString();
                      baseProductResults[productId] = [];
                      update();
                    },
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 12, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                }),
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
                        color: Colors.black87),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    selectedBaseProducts[productId] = null;
                    baseProductControllers[productId]!.clear();
                    baseProductResults[productId] = [];
                    update();
                  },
                  child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> updateBaseProduct(String productId, String baseProduct) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse("$apiUrl/baseproduct_update");
    final data = {"id": productId, "base_product": baseProduct};

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Base product updated successfully!",
            backgroundColor: Colors.green);
      } else {
        Get.snackbar("Error", "Failed to update base product.",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      print("Error updating base product: $e");
      Get.snackbar("Error", "Error updating base product: $e",
          backgroundColor: Colors.red);
    }
  }

  void updateSelectedBaseProduct(String productId) {
    if (selectedBaseProducts[productId] != null &&
        selectedBaseProducts[productId]!.isNotEmpty) {
      updateBaseProduct(productId, selectedBaseProducts[productId]!);
    } else {
      Get.snackbar("Warning", "Please select a base product first.",
          backgroundColor: Colors.orange);
    }
  }

  void clearSelection() {
    selectedMaterial = null;
    selectedBrands = null;
    selectedColors = null;
    selectedThickness = null;
    selectedCoatingMass = null;
    selectedProductBaseId = null;
    selectedBaseProductId = null;
    currentMainProductId = null;
    orderIDD = null;
    orderNO = null;
    responseProducts.clear();
    fieldControllers.clear();
    baseProductControllers.clear();
    baseProductFocusNodes.clear();
    previousUomValues.clear();
    calculationResults.clear();
    billamt.value = 0.0;
    update();
  }

  TextEditingController getController(Map<String, dynamic> data, String key) {
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
    return fieldControllers[productId]![key]!;
  }

  Widget editableTextField(
      Map<String, dynamic> data, String key, Function(String) onChanged,
      {bool readOnly = false,
      required RxMap<String, Map<String, TextEditingController>>
          fieldControllers}) {
    final controller = getController(data, key);
    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: readOnly,
        style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
        controller: controller,
        keyboardType: (key == "Profile" ||
                key == "Nos" ||
                key == "Basic Rate" ||
                key == "Amount" ||
                key == "SQMtr" ||
                key == "cgst" ||
                key == "sgst" ||
                key == "height")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (val) {
          data[key] = val;
          onChanged(val);
          update();
        },
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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide:
                    BorderSide(color: Get.theme.primaryColor, width: 2)),
            filled: true,
            fillColor: Colors.grey[50],
          )),
    );
  }

  void debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer =
        Timer(Duration(seconds: 1), () => performCalculation(data));
  }

  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');
    String productId = data["id"].toString();

    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();
    String? profileText = fieldControllers[productId]?["Profile"]?.text ??
        data["Profile"]?.toString();
    double? profileValue = profileText != null && profileText.isNotEmpty
        ? double.tryParse(profileText)
        : null;
    String? nosText =
        fieldControllers[productId]?["Nos"]?.text ?? data["Nos"]?.toString();
    int nosValue =
        nosText != null && nosText.isNotEmpty ? int.tryParse(nosText) ?? 1 : 1;
    String? heightValue = fieldControllers[productId]?["height"]?.text ??
        data["height"]?.toString();

    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 32,
      "product": data["Products"]?.toString() ?? "",
      "height": heightValue,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": null,
      "nos": nosValue,
      "basic_rate": double.tryParse(
              fieldControllers[productId]?["Basic Rate"]?.text ??
                  data["Basic Rate"]?.toString() ??
                  "0") ??
          0,
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
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          if (responseData["rate"] != null) {
            data["Basic Rate"] = responseData["rate"].toString();
            if (fieldControllers[productId]?["Basic Rate"] != null) {
              fieldControllers[productId]!["Basic Rate"]!.text =
                  responseData["rate"].toString();
            }
          }

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
                fieldControllers[productId]?["Nos"]?.text.trim() ?? "";
            if (currentInput.isEmpty || currentInput == "0") {
              data["Nos"] = newNos;
              if (fieldControllers[productId]?["Nos"] != null) {
                fieldControllers[productId]!["Nos"]!.text = newNos;
              }
            }
          }

          if (responseData["crimp"] != null) {
            data["height"] = responseData["crimp"].toString();
            if (fieldControllers[productId]?["height"] != null) {
              fieldControllers[productId]!["height"]!.text =
                  responseData["crimp"].toString();
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
          update();
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
  }
}
