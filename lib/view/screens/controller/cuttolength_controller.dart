import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api_key.dart';

import '../../getx/summary_screen.dart';
import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

class CutToLengthSheetController extends GetxController {
  var categoryMeta = <String, dynamic>{}.obs;
  var billamt = 0.0.obs;
  var orderNo = ''.obs;
  var orderIDD = 0.obs;
  var selectedProduct = RxString('');
  var selectedMeterial = RxString('');
  var selectedThichness = RxString('');
  var selsectedCoat = RxString('');
  var selectedyie = RxString('');
  var selectedBrand = RxString('');
  var selectedProductBaseId = RxString('');
  var selectedBaseProductName = RxString('');
  var productList = <String>[].obs;
  var meterialList = <String>[].obs;
  var thichnessLists = <String>[].obs;
  var coatMassList = <String>[].obs;
  var yieldsListt = <String>[].obs;
  var brandList = <String>[].obs;
  var responseProducts = <Map<String, dynamic>>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var baseProductResults = <String, List<dynamic>>{}.obs;
  var selectedBaseProducts = <String, String?>{}.obs;
  var isSearchingBaseProducts = <String, bool>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var baseProductControllers = <String, TextEditingController>{}.obs;
  var baseProductFocusNodes = <String, FocusNode>{}.obs;
  var isBaseProductUpdated = false.obs;

  var rawProductData =
      <Map<String, dynamic>>[].obs; // Added to store raw product data
  Timer? debounceTimer;
  //
  // void updateBill(double value) {
  //   billamt.value = value; // ✅ must use .value
  // }

  @override
  void onInit() {
    super.onInit();
    fetchProductName();
    fetchMeterialType();
  }

  @override
  void onClose() {
    debounceTimer?.cancel();
    for (var controllers in fieldControllers.values) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    for (var controller in baseProductControllers.values) {
      controller.dispose();
    }
    for (var focusNode in baseProductFocusNodes.values) {
      focusNode.dispose();
    }
    super.onClose();
  }

  Future<void> fetchProductName() async {
    productList.clear();
    selectedProduct.value = '';
    rawProductData.clear(); // Clear raw data
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/626');
    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        if (message is List && message.length >= 2) {
          final categoryInfoList = message[0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          final products = message[1];
          if (products is List) {
            rawProductData.value = products
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList(); // Store raw data
            productList.value = products
                .whereType<Map>()
                .map((e) => e["product_name"]?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching products: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch products",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchMeterialType() async {
    meterialList.clear();
    selectedMeterial.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/626');
    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meterialData = data["message"]["message"][2][1];
        if (meterialData is List) {
          meterialList.value = meterialData
              .whereType<Map>()
              .map((e) => e["material_type"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Exception fetching material types: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch material types",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchThickness() async {
    if (selectedMeterial.value.isEmpty || selectedProduct.value.isEmpty) return;
    thichnessLists.clear();
    selectedThichness.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "thickness",
        "product_filters": [selectedProduct.value],
        "product_label_filters": ["product_name"],
        "product_category_id": 626,
        "base_product_filters": [selectedMeterial.value],
        "base_label_filters": ["material_type"],
        "base_category_id": "34",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final thickness = data["message"]["message"][0];
      if (thickness is List) {
        thichnessLists.value = thickness
            .whereType<Map>()
            .map((e) => e["thickness"]?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      debugPrint("Failed to fetch thickness: ${response.statusCode}");
      Get.snackbar(
        "Error",
        "Failed to fetch thickness",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchCoat() async {
    if (selectedMeterial.value.isEmpty || selectedThichness.value.isEmpty)
      return;
    coatMassList.clear();
    selsectedCoat.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "coating_mass",
        "product_filters": [selectedProduct.value],
        "product_label_filters": ["product_name"],
        "product_category_id": 626,
        "base_product_filters": [
          selectedMeterial.value,
          selectedThichness.value
        ],
        "base_label_filters": ["material_type", "thickness"],
        "base_category_id": "34",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coat = data["message"]["message"][0];
      if (coat is List) {
        coatMassList.value = coat
            .whereType<Map>()
            .map((e) => e["coating_mass"]?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      debugPrint("Failed to fetch coating mass: ${response.statusCode}");
      Get.snackbar(
        "Error",
        "Failed to fetch coating mass",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchYie() async {
    if (selectedMeterial.value.isEmpty ||
        selectedThichness.value.isEmpty ||
        selsectedCoat.value.isEmpty) return;
    yieldsListt.clear();
    selectedyie.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "yield_strength",
        "product_filters": [selectedProduct.value],
        "product_label_filters": ["product_name"],
        "product_category_id": 626,
        "base_product_filters": [
          selectedMeterial.value,
          selectedThichness.value,
          selsectedCoat.value
        ],
        "base_label_filters": ["material_type", "thickness", "coating_mass"],
        "base_category_id": "34",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final yieldsStrength = data["message"]["message"][0];
      if (yieldsStrength is List) {
        yieldsListt.value = yieldsStrength
            .whereType<Map>()
            .map((e) => e["yield_strength"]?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } else {
      debugPrint("Failed to fetch yield strength: ${response.statusCode}");
      Get.snackbar(
        "Error",
        "Failed to fetch yield strength",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchBrandss() async {
    if (selectedMeterial.value.isEmpty ||
        selectedThichness.value.isEmpty ||
        selsectedCoat.value.isEmpty ||
        selectedyie.value.isEmpty) return;
    brandList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "brand",
        "product_filters": [selectedProduct.value],
        "product_label_filters": ["product_name"],
        "product_category_id": 626,
        "base_product_filters": [
          selectedMeterial.value,
          selectedThichness.value,
          selsectedCoat.value,
          selectedyie.value
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
              .map((e) => e["brand"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        if (message.length > 1) {
          final baseProductData = message[1];
          if (baseProductData is List && baseProductData.isNotEmpty) {
            final item = baseProductData.first;
            if (item is Map) {
              selectedProductBaseId.value = item["id"]?.toString() ?? '';
              selectedBaseProductName.value =
                  item["base_product_id"]?.toString() ?? '';
            }
          }
        }
      }
    } else {
      debugPrint("Failed to fetch brands: ${response.statusCode}");
      Get.snackbar(
        "Error",
        "Failed to fetch brands",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> postAllData() async {
    if (selectedProduct.value.isEmpty ||
        selectedMeterial.value.isEmpty ||
        selectedThichness.value.isEmpty ||
        selsectedCoat.value.isEmpty ||
        selectedyie.value.isEmpty ||
        selectedBrand.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select all required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final product = rawProductData.firstWhere(
      (item) => item["product_name"] == selectedProduct.value,
      orElse: () => {},
    );
    if (product.isEmpty || product["id"] == null) {
      Get.snackbar(
        "Error",
        "Selected product not found",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final categoryId = categoryMeta['category_id'];
    final categoryName = categoryMeta['categories'];
    final globalOrderManager = GlobalOrderManager();
    final data = {
      "customer_id": UserSession().userId,
      "product_id": product["id"].toString(),
      "product_name": selectedProduct.value,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name": selectedBaseProductName.value,
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId,
    };

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse("$apiUrl/addbag");
    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['lebels'] != null) {
          final String orderID = responseData["order_id"].toString();
          orderIDD.value = int.parse(orderID);
          orderNo.value = responseData["order_no"]?.toString() ?? "Unknown";

          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(
                int.parse(orderID), orderNo.value);
          }

          orderIDD.value = globalOrderManager.globalOrderId!;
          orderNo.value = globalOrderManager.globalOrderNo!;

          final List<Map<String, dynamic>> newData =
              List<Map<String, dynamic>>.from(
                  responseData['lebels'][0]['data']);
          final uniqueNewData = newData.where((item) {
            final newId = item['id'].toString();
            return !responseProducts
                .any((existing) => existing['id'].toString() == newId);
          }).toList();

          for (var item in uniqueNewData) {
            final productId = item['id'].toString();
            if (!fieldControllers.containsKey(productId)) {
              fieldControllers[productId] = {
                "Length": TextEditingController(),
                "Nos": TextEditingController(),
                "Basic Rate": TextEditingController(),
                "qty": TextEditingController(),
                "Amount": TextEditingController(),
                "cgst": TextEditingController(),
                "sgst": TextEditingController(),
                "Crimp": TextEditingController(),
              };
            }
            if (item["UOM"] != null && item["UOM"]["options"] != null) {
              uomOptions[productId] = Map<String, String>.from(
                  (item["UOM"]["options"] as Map)
                      .map((k, v) => MapEntry(k.toString(), v.toString())));
            }
            if (item["Billing Option"] != null &&
                item["Billing Option"]["options"] != null) {
              uomOptions[productId + "_billing"] = Map<String, String>.from(
                  (item["Billing Option"]["options"] as Map)
                      .map((k, v) => MapEntry(k.toString(), v.toString())));
            }
            Future.delayed(
                Duration(milliseconds: 500), () => performCalculation(item));
          }
          responseProducts.addAll(uniqueNewData);
          Get.snackbar(
            "Success",
            "Product added successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          selectedProduct.value = '';
          selectedMeterial.value = '';
          selectedThichness.value = '';
          selsectedCoat.value = '';
          selectedyie.value = '';
          selectedBrand.value = '';
          productList.clear();
          meterialList.clear();
          thichnessLists.clear();
          coatMassList.clear();
          yieldsListt.clear();
          brandList.clear();
          fetchProductName();
          fetchMeterialType();
        } else {
          Get.snackbar(
            "Error",
            "Invalid response from server",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("Failed to add product: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to add product: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error posting data: $e");
      Get.snackbar(
        "Error",
        "Failed to add product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');

    final productId = data["id"].toString();
    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();
    String? billingOption = data["Billing Option"] is Map
        ? data["Billing Option"]["value"]?.toString()
        : data["Billing Option"]?.toString();
    String? lengthText = fieldControllers[productId]?["Length"]?.text ??
        data["Length"]?.toString();
    double? profileValue = double.tryParse(lengthText ?? "0");
    String? nosText =
        fieldControllers[productId]?["Nos"]?.text ?? data["Nos"]?.toString();
    int nosValue = int.tryParse(nosText ?? "1") ?? 1;
    String? crimpText = fieldControllers[productId]?["Crimp"]?.text ??
        data["Crimp"]?.toString();
    double? crimpValue = double.tryParse(crimpText ?? "");

    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 626,
      "product": data["Products"]?.toString() ?? "",
      "height": crimpValue,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue ?? 0,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
      "billing_option":
          billingOption != null ? int.tryParse(billingOption) : null,
    };

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        print("performCalculation response status: $requestBody");
        print("thhh ${response.body}");
        try {
          final responseData = jsonDecode(response.body);
          if (responseData["status"] == "success") {
            billamt.value = responseData["bill_total"]?.toDouble() ?? 0.0;
            calculationResults[productId] = responseData;

            if (responseData["profile"] != null) {
              data["Length"] = responseData["profile"].toString();
              fieldControllers[productId]?["Length"]?.text =
                  data["Length"] ?? "";
            }
            if (responseData["length"] != null) {
              data["Length"] = responseData["length"].toString();
              fieldControllers[productId]?["Length"]?.text =
                  data["Length"] ?? "";
            }
            if (responseData["Nos"] != null) {
              String newNos = responseData["Nos"].toString().trim();
              String currentInput =
                  fieldControllers[productId]?["Nos"]?.text.trim() ?? "";
              if (currentInput.isEmpty || currentInput == "0") {
                data["Nos"] = newNos;
                fieldControllers[productId]?["Nos"]?.text = newNos;
              }
            }
            if (responseData["crimp"] != null) {
              data["Crimp"] = responseData["crimp"].toString();
              fieldControllers[productId]?["Crimp"]?.text = data["Crimp"] ?? "";
            }
            if (responseData["qty"] != null) {
              data["qty"] = responseData["qty"].toString();
              fieldControllers[productId]?["qty"]?.text = data["qty"] ?? "";
            }
            if (responseData["cgst"] != null) {
              data["cgst"] = responseData["cgst"].toString();
              fieldControllers[productId]?["cgst"]?.text = data["cgst"] ?? "";
            }
            if (responseData["sgst"] != null) {
              data["sgst"] = responseData["sgst"].toString();
              fieldControllers[productId]?["sgst"]?.text = data["sgst"] ?? "";
            }
            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
              fieldControllers[productId]?["Amount"]?.text =
                  data["Amount"] ?? "";
            }
            previousUomValues[productId] = currentUom;
            responseProducts.refresh();
          } else {
            debugPrint("Calculation failed: ${responseData["message"]}");
            Get.snackbar(
              "Error",
              "Calculation failed: ${responseData["message"]}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          debugPrint("Invalid JSON response: ${response.body}");
          Get.snackbar(
            "Error",
            "Invalid response from calculation API",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("Calculation API failed: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        Get.snackbar(
          "Error",
          "Calculation API failed: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Calculation API Error: $e");
      Get.snackbar(
        "Error",
        "Calculation error: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget uomDropdown(Map<String, dynamic> data) {
    String productId = data["id"].toString();
    Map<String, String>? options = uomOptions[productId];
    if (options == null || options.isEmpty) {
      return editableTextField(data, "UOM", (v) {
        data["UOM"] = v;
        debounceCalculation(data);
      }, fieldControllers: fieldControllers);
    }
    String? currentValue = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();
    return SizedBox(
      height: 38.h,
      child: DropdownButtonFormField<String>(
        value: options.containsKey(currentValue) ? currentValue : null,
        items: options.entries
            .map((entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)))
            .toList(),
        onChanged: (val) {
          data["UOM"] = {"value": val, "options": options};
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
              borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget billingDropdown(Map<String, dynamic> data) {
    Map<String, dynamic> billingData = data['Billing Option'] ?? {};
    String currentValue = billingData['value']?.toString() ?? "";
    Map<String, dynamic> options = billingData['options'] ?? {};

    return SizedBox(
      height: 38.h,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: (currentValue != null && options.containsKey(currentValue))
            ? currentValue
            : null,
        items: options.entries
            .map((entry) => DropdownMenuItem<String>(
                  value: entry.key.toString(),
                  child: Text(entry.value.toString()),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2)),
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
    final data = {"category_id": "1", "searchbase": query};
    try {
      final response = await client.post(
        Uri.parse("$apiUrl/baseproducts_search"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        baseProductResults[productId] = responseData['base_products'] ?? [];
      } else {
        debugPrint("Failed to search base products: ${response.statusCode}");
        baseProductResults[productId] = [];
      }
    } catch (e) {
      debugPrint("Error searching base products: $e");
      baseProductResults[productId] = [];
    } finally {
      isSearchingBaseProducts[productId] = false;
    }
  }

  Future<void> updateBaseProduct(String productId, String baseProduct) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final data = {"id": productId, "base_product": baseProduct};
    try {
      final response = await client.post(
        Uri.parse("$apiUrl/baseproduct_update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Base product updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        isBaseProductUpdated.value = true;
      } else {
        debugPrint("Failed to update base product: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to update base product: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error updating base product: $e");
      Get.snackbar(
        "Error",
        "Error updating base product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
            fontSize: 15,
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: isSearchingBaseProducts[productId]!
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
        Obx(() {
          if (baseProductResults[productId]?.isNotEmpty ?? false) {
            return Container(
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...baseProductResults[productId]!.map((product) {
                    return GestureDetector(
                      onTap: () {
                        selectedBaseProducts[productId] = product.toString();
                        baseProductControllers[productId]!.text =
                            product.toString();
                        baseProductResults[productId] = [];
                        isBaseProductUpdated.value = false;
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
                            Icon(Icons.inventory_2,
                                size: 16, color: Colors.blue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                product.toString(),
                                style: TextStyle(
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
                  }),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }),
        Obx(() {
          if (selectedBaseProducts[productId] != null) {
            return Container(
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      selectedBaseProducts[productId] = null;
                      baseProductControllers[productId]!.clear();
                      baseProductResults[productId] = [];
                    },
                    child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }),
        Obx(() {
          if (selectedBaseProducts[productId] != null &&
              !isBaseProductUpdated.value) {
            return Container(
              margin: EdgeInsets.only(top: 8),
              width: 200.w,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedBaseProducts[productId] != null &&
                      selectedBaseProducts[productId]!.isNotEmpty) {
                    updateBaseProduct(
                        productId, selectedBaseProducts[productId]!);
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please select a base product first",
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  void debounceCalculation(Map<String, dynamic> data) {
    debounceTimer?.cancel();
    debounceTimer = Timer(Duration(seconds: 1), () => performCalculation(data));
  }

  Future<void> deleteCard(String deleteId) async {
    final url = '$apiUrl/enquirydelete/$deleteId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((item) => item['id'].toString() == deleteId);
        fieldControllers.remove(deleteId);
        baseProductControllers.remove(deleteId);
        baseProductFocusNodes.remove(deleteId);
        double total = 0.0;
        for (var product in responseProducts) {
          total +=
              (double.tryParse(product["Amount"]?.toString() ?? "0") ?? 0.0);
        }
        billamt.value = total;
        Get.snackbar(
          "Success",
          "Product deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        debugPrint("Failed to delete card: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to delete product: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error deleting card: $e");
      Get.snackbar(
        "Error",
        "Failed to delete product: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String selectedItems() {
    List<String> values = [
      if (selectedMeterial.value.isNotEmpty)
        "Material: ${selectedMeterial.value}",
      if (selectedThichness.value.isNotEmpty)
        "Thickness: ${selectedThichness.value}",
      if (selsectedCoat.value.isNotEmpty) "CoatingMass: ${selsectedCoat.value}",
      if (selectedyie.value.isNotEmpty) "YieldStrength: ${selectedyie.value}",
      if (selectedBrand.value.isNotEmpty) "Brand: ${selectedBrand.value}",
    ];
    return values.isEmpty ? "No selections yet" : values.join(", ");
  }
}
