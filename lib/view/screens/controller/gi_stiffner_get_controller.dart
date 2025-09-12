import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';

import '../../universal_api/api_key.dart';
import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

class GIStiffnerController extends GetxController {
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var billamt = 0.0.obs;
  var orderNO = ''.obs;
  var orderIDD = 0.obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var productList = <String>[].obs;
  var materialTypeList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var coatingMassList = <String>[].obs;
  var yieldStrengthList = <String>[].obs;
  var brandList = <String>[].obs;
  var selectedProduct = ''.obs;
  var selectedMaterialType = ''.obs;
  var selectedThickness = ''.obs;
  var selectedCoatingMass = ''.obs;
  var selectedYieldStrength = ''.obs;
  var selectedBrand = ''.obs;
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var currentMainProductId = ''.obs;
  var apiProductsList = <Map<String, dynamic>>[].obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
// ✅ store plain list, plain string, plain bool
  var baseProductResults = <String, List<dynamic>>{}.obs;
  var selectedBaseProducts = <String, String?>{}.obs;
  var isSearchingBaseProducts = <String, bool>{}.obs;
  var isBaseProductUpdated = false.obs;
  final formKey = GlobalKey<FormState>();
  var rawGIStiffner = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductName();
  }

  @override
  void onClose() {
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.onClose();
  }

  String selectedItems() {
    List<String> items = [];
    if (selectedProduct.value.isNotEmpty) {
      items.add("Product: ${selectedProduct.value}");
    }
    if (selectedMaterialType.value.isNotEmpty) {
      items.add("Material: ${selectedMaterialType.value}");
    }
    if (selectedThickness.value.isNotEmpty) {
      items.add("Thickness: ${selectedThickness.value}");
    }
    if (selectedCoatingMass.value.isNotEmpty) {
      items.add("Coating Mass: ${selectedCoatingMass.value}");
    }
    if (selectedYieldStrength.value.isNotEmpty) {
      items.add("Yield Strength: ${selectedYieldStrength.value}");
    }
    if (selectedBrand.value.isNotEmpty) {
      items.add("Brand: ${selectedBrand.value}");
    }
    return items.isEmpty ? "No Selections yet" : items.join(" | ");
  }

  Future<void> fetchProductName() async {
    productList.clear();
    selectedProduct.value = '';
    rawGIStiffner.clear();
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/627');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        if (products is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          rawGIStiffner.value = products;
          productList.value = products
              .whereType<Map>()
              .map((e) => e["product_name"]?.toString())
              .whereType<String>()
              .toList();
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
    } finally {
      client.close();
    }
  }

  Future<void> fetchMaterialType() async {
    if (selectedProduct.isEmpty) return;
    materialTypeList.clear();
    selectedMaterialType.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/627');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][2][1];
        if (materials is List) {
          materialTypeList.value = materials
              .whereType<Map>()
              .map((e) => e["material_type"]?.toString())
              .whereType<String>()
              .toList();
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch material types: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching material types: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch material types: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      client.close();
    }
  }

  Future<void> fetchThickness() async {
    if (selectedProduct.isEmpty || selectedMaterialType.isEmpty) return;
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
          "product_category_id": 627,
          "base_product_filters": [selectedMaterialType.value],
          "base_label_filters": ["material_type"],
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thick = data["message"]["message"][0];
        if (thick is List) {
          thicknessList.value = thick
              .whereType<Map>()
              .map((e) => e["thickness"]?.toString())
              .whereType<String>()
              .toList();
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
    } finally {
      client.close();
    }
  }

  Future<void> fetchCoatingMass() async {
    if (selectedProduct.isEmpty ||
        selectedMaterialType.isEmpty ||
        selectedThickness.isEmpty) return;
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
          "product_category_id": 627,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value
          ],
          "base_label_filters": ["material_type", "thickness"],
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coat = data["message"]["message"][0];
        if (coat is List) {
          coatingMassList.value = coat
              .whereType<Map>()
              .map((e) => e["coating_mass"]?.toString())
              .whereType<String>()
              .toList();
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
    } finally {
      client.close();
    }
  }

  Future<void> fetchYieldStrength() async {
    if (selectedProduct.isEmpty ||
        selectedMaterialType.isEmpty ||
        selectedThickness.isEmpty ||
        selectedCoatingMass.isEmpty) return;
    yieldStrengthList.clear();
    selectedYieldStrength.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "yield_strength",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 627,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value,
            selectedCoatingMass.value
          ],
          "base_label_filters": ["material_type", "thickness", "coating_mass"],
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final yields = data["message"]["message"][0];
        if (yields is List) {
          yieldStrengthList.value = yields
              .whereType<Map>()
              .map((e) => e["yield_strength"]?.toString())
              .whereType<String>()
              .toList();
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch yield strength: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching yield strength: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch yield strength: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      client.close();
    }
  }

  Future<void> fetchBrand() async {
    if (selectedProduct.isEmpty ||
        selectedMaterialType.isEmpty ||
        selectedThickness.isEmpty ||
        selectedCoatingMass.isEmpty ||
        selectedYieldStrength.isEmpty) return;
    brandList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "brand",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 627,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value,
            selectedCoatingMass.value,
            selectedYieldStrength.value
          ],
          "base_label_filters": [
            "material_type",
            "thickness",
            "coating_mass",
            "yield_strength"
          ],
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        if (message is List && message.isNotEmpty) {
          final brands = message[0];
          if (brands is List) {
            brandList.value = brands
                .whereType<Map>()
                .map((e) => e["brand"]?.toString())
                .whereType<String>()
                .toList();
          }
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId.value = idData.first["id"]?.toString() ?? '';
            selectedBaseProductName.value =
                idData.first["base_product_id"]?.toString() ?? '';
          }
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch brand: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching brand: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch brand: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      client.close();
    }
  }

  Future<void> searchBaseProducts(String query, String productId) async {
    if (query.isEmpty) {
      baseProductResults[productId] = [];
      return;
    }

    isSearchingBaseProducts[productId] = true;
    update();

    HttpClient client = HttpClient()
      ..badCertificateCallback = ((_, __, ___) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"category_id": "627", "searchbase": query};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/baseproducts_search"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(response.body);
        print(response.statusCode);
        baseProductResults[productId] = responseData['base_products'] ?? [];
      } else {
        baseProductResults[productId] = [];
      }
    } catch (e) {
      print("Error searching base products for $productId: $e");
      baseProductResults[productId] = [];
    } finally {
      isSearchingBaseProducts[productId] = false;
      ioClient.close();
      update();
    }
  }

  Future<void> updateBaseProduct(String productId, String baseProduct) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = ((_, __, ___) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"id": productId, "base_product": baseProduct};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/baseproduct_update"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isBaseProductUpdated.value = true;
        Get.snackbar("Success", "Base product updated successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar(
            "Error", "Failed to update base product. Please try again.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Error updating base product: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      ioClient.close();
    }
  }

  Widget buildBaseProductSearchField(Map<String, dynamic> data) {
    String productId = data["id"].toString();

    fieldControllers.putIfAbsent(productId, () => {});
    baseProductResults.putIfAbsent(productId, () => []);
    selectedBaseProducts.putIfAbsent(productId, () => null);
    isSearchingBaseProducts.putIfAbsent(productId, () => false);
    if (!fieldControllers[productId]!.containsKey("BaseProduct")) {
      fieldControllers[productId]!["BaseProduct"] = TextEditingController();
    }

    return Obx(() => Column(
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
                controller: fieldControllers[productId]!["BaseProduct"],
                decoration: InputDecoration(
                  hintText: "Search base product...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: isSearchingBaseProducts[productId]!
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                ),
                onChanged: (value) => searchBaseProducts(value, productId),
              ),
            ),
            if (baseProductResults[productId]?.isNotEmpty ?? false)
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
                    ...baseProductResults[productId]!
                        .map((product) => GestureDetector(
                              onTap: () {
                                selectedBaseProducts[productId] =
                                    product.toString();
                                fieldControllers[productId]!["BaseProduct"]!
                                    .text = product.toString();
                                baseProductResults[productId] = [];
                                isBaseProductUpdated.value = false;
                                update();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
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
                                        offset: Offset(0, 1))
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory_2,
                                        size: 16, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Expanded(
                                        child: Text(product.toString(),
                                            style: GoogleFonts.figtree(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w400))),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 12, color: Colors.grey[400]),
                                  ],
                                ),
                              ),
                            )),
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
                                color: Colors.black87))),
                    GestureDetector(
                      onTap: () {
                        selectedBaseProducts[productId] = null;
                        fieldControllers[productId]!["BaseProduct"]!.clear();
                        baseProductResults[productId] = [];
                        update();
                      },
                      child:
                          Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ],
                ),
              ),
            if (selectedBaseProducts[productId] != null &&
                !isBaseProductUpdated.value)
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 200.w,
                child: ElevatedButton(
                  onPressed: () => updateBaseProduct(
                      productId, selectedBaseProducts[productId]!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Update Base Product",
                    style: GoogleFonts.figtree(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ));
  }

  Future<void> postAllData() async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/addbag');
    final globalOrderManager = GlobalOrderManager();
    final headers = {"Content-Type": "application/json"};
    final matchingProduct = rawGIStiffner.firstWhere(
      (item) => item["product_name"] == selectedProduct.value,
      orElse: () => null,
    );
    final productId = matchingProduct?["id"];
    final data = {
      "customer_id": UserSession().userId,
      "product_id": productId,
      "product_name": selectedProduct.value,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name": selectedBaseProductName.value,
      "category_id": categoryMeta["category_id"],
      "category_name": categoryMeta["categories"],
      "OrderID": globalOrderManager.globalOrderId,
    };

    try {
      final response =
          await client.post(url, headers: headers, body: jsonEncode(data));
      print("Post all data response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String orderId = responseData["order_id"].toString();
        final String orderNo =
            responseData["order_no"]?.toString() ?? "Unknown";
        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(int.parse(orderId), orderNo);
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
        }
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
          "Failed to add product: ${response.statusCode}",
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
    } finally {
      client.close();
    }
  }

  void submitData() {
    if (selectedProduct.value.isEmpty ||
        selectedMaterialType.value.isEmpty ||
        selectedThickness.value.isEmpty ||
        selectedCoatingMass.value.isEmpty ||
        selectedYieldStrength.value.isEmpty ||
        selectedBrand.value.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Incomplete Form'),
          content: Text('Please fill all required fields to add a product.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    postAllData();
  }

  void resetSelections() {
    selectedProduct.value = '';
    selectedMaterialType.value = '';
    selectedThickness.value = '';
    selectedCoatingMass.value = '';
    selectedYieldStrength.value = '';
    selectedBrand.value = '';
    selectedProductBaseId.value = '';
    selectedBaseProductName.value = '';
    materialTypeList.clear();
    thicknessList.clear();
    coatingMassList.clear();
    yieldStrengthList.clear();
    brandList.clear();
    fetchProductName();
  }

  Future<void> deleteCard(String deleteId) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/enquirydelete/$deleteId');
    try {
      final response = await client.delete(url);
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((product) => product["id"].toString() == deleteId);
        fieldControllers.remove(deleteId);
        previousUomValues.remove(deleteId);
        calculationResults.remove(deleteId);
        baseProductResults.remove(deleteId);
        isSearchingBaseProducts.remove(deleteId);
        selectedBaseProducts.remove(deleteId);
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
    } finally {
      client.close();
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

    String lengthText = _getFieldValue(productId, "Length", data);
    String nosText = _getFieldValue(productId, "Nos", data);

    double profileValue = _isValidNonZeroNumber(lengthText)
        ? (double.tryParse(lengthText) ?? 0.0)
        : 0.0;
    int nosValue =
        _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 1) : 1;

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 627,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
      "billing_option": data["Billing Option"] is Map
          ? int.tryParse(data["Billing Option"]["value"]?.toString() ?? "2")
          : null,
    };

    try {
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      print("Calculation response: ${response.body}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          String newProfile = responseData["length"]?.toString() ?? "0";
          if (_isValidNonZeroNumber(newProfile) && newProfile != lengthText) {
            data["Length"] = newProfile;
            if (fieldControllers[productId]?["Length"] != null) {
              fieldControllers[productId]!["Length"]!.text = newProfile;
            }
          }

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

          if (responseData["qty"] != null) {
            data["qty"] = responseData["qty"].toString();
            if (fieldControllers[productId]?["qty"] != null) {
              fieldControllers[productId]!["qty"]!.text =
                  responseData["qty"].toString();
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
    } finally {
      client.close();
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

    return DropdownButtonFormField<String>(
      value: currentValue,
      items: options.entries
          .map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value.toString(),
                  style: GoogleFonts.figtree(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget billingDropdown(Map<String, dynamic> data) {
    Map<String, dynamic> billingData = data['Billing Option'] ?? {};
    String currentValue = billingData['value']?.toString() ?? "";
    Map<String, dynamic> options = billingData['options'] ?? {};

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: currentValue.isNotEmpty ? currentValue : null,
      items: options.entries
          .map((entry) => DropdownMenuItem<String>(
                value: entry.key.toString(),
                child: Text(
                  entry.value.toString(),
                  style: GoogleFonts.figtree(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
      onChanged: (val) {
        if (data['Billing Option'] is! Map) {
          data['Billing Option'] = {};
        }
        data['Billing Option']['value'] = val;
        data['Billing Option']['options'] = options;
        debounceCalculation(data);
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
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
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
          "Length",
          "Nos",
          "Basic Rate",
          "Amount",
          "qty",
          "cgst",
          "sgst"
        ].contains(key)
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: onChanged,
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
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
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
