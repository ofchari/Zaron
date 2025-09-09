import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../universal_api/api_key.dart';
import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

// Screw Controller
class ScrewController extends GetxController {
  var brandList = <String>[].obs;
  var screwLengthList = <String>[].obs;
  var threadList = <String>[].obs;
  var selectedBrand = RxString('');
  var selectedScrew = RxString('');
  var selectedThread = RxString('');
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var responseProducts = <Map<String, dynamic>>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var billamt = 0.0.obs;
  var orderIDD = 0.obs;
  var orderNO = ''.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  Map<String, Map<String, TextEditingController>> fieldControllers = {};

  Timer? debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchBrand();
  }

  Future<void> fetchBrand() async {
    brandList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/7');
    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        if (message is List && message.length > 1) {
          final categoryInfoList = message[0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          final brands = message[1];
          if (brands is List) {
            brandList.value = brands
                .whereType<Map>()
                .map((e) => e["brand"]?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching brand: $e");
    }
  }

  Future<void> fetchScrew() async {
    if (selectedBrand.value.isEmpty) return;
    screwLengthList.clear();
    selectedScrew.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');
    try {
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "product_label": "length_of_screw",
            "product_filters": null,
            "product_label_filters": null,
            "product_category_id": null,
            "base_product_filters": [selectedBrand.value],
            "base_label_filters": ["brand"],
            "base_category_id": "7",
          }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        if (message is List && message.length > 1) {
          final screws = message[0];
          if (screws is List) {
            screwLengthList.value = screws
                .whereType<Map>()
                .map((e) => e["length_of_screw"]?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching screw: $e");
    }
  }

  Future<void> fetchThreads() async {
    if (selectedBrand.value.isEmpty || selectedScrew.value.isEmpty) return;
    threadList.clear();
    selectedThread.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');
    try {
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "product_label": "type_of_thread",
            "product_filters": null,
            "product_label_filters": null,
            "product_category_id": null,
            "base_product_filters": [selectedBrand.value, selectedScrew.value],
            "base_label_filters": ["brand", "length_of_screw"],
            "base_category_id": "7",
          }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        if (message is List && message.isNotEmpty) {
          final threadTypes = message[0];
          if (threadTypes is List) {
            threadList.value = threadTypes
                .whereType<Map>()
                .map((e) => e["type_of_thread"]?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId.value = idData.first["id"]?.toString() ?? '';
            selectedBaseProductName.value =
                idData.first["base_product_id"]?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching thread types: $e");
    }
  }

  Future<void> postScrewData() async {
    if (selectedBrand.value.isEmpty ||
        selectedScrew.value.isEmpty ||
        selectedThread.value.isEmpty) {
      Get.snackbar("Error", "Please select all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final categoryId = categoryMeta['category_id'];
    final categoryName = categoryMeta['categories'];
    final globalOrderManager = GlobalOrderManager();
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name": selectedBaseProductName.value,
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId
    };

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse("$apiUrl/addbag");
    try {
      final response = await client.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final orderID = decodedResponse["order_id"]?.toString() ?? "";
        orderIDD.value = int.tryParse(orderID) ?? 0;
        orderNO.value = decodedResponse["order_no"]?.toString() ?? "Unknown";

        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(
              int.parse(orderID), orderNO.value);
        }

        orderIDD.value = globalOrderManager.globalOrderId!;
        orderNO.value = globalOrderManager.globalOrderNo!;

        if (decodedResponse["lebels"] != null &&
            decodedResponse["lebels"].isNotEmpty) {
          final fullList = decodedResponse["lebels"][0]["data"];
          final newProducts = <Map<String, dynamic>>[];
          for (var item in fullList) {
            if (item is Map<String, dynamic>) {
              final product = Map<String, dynamic>.from(item);
              product['category_id'] = 7;
              product["Cgst"] = product["Cgst"] ?? "0";
              product["Sgst"] = product["Sgst"] ?? "0";
              final productId = product["id"].toString();
              if (!responseProducts
                  .any((p) => p["id"].toString() == productId)) {
                newProducts.add(product);
                if (product["UOM"] != null &&
                    product["UOM"]["options"] != null) {
                  uomOptions[productId] = Map<String, String>.from(
                      (product["UOM"]["options"] as Map)
                          .map((k, v) => MapEntry(k.toString(), v.toString())));
                }
                Future.delayed(Duration(milliseconds: 500),
                    () => performCalculation(product));
              }
            }
          }
          responseProducts.addAll(newProducts);
          Get.snackbar("Success", "Product added successfully",
              backgroundColor: Colors.green, colorText: Colors.white);
          selectedBrand.value = '';
          selectedScrew.value = '';
          selectedThread.value = '';
          brandList.clear();
          screwLengthList.clear();
          threadList.clear();
          fetchBrand();
        }
      }
    } catch (e) {
      debugPrint("Error posting data: $e");
      Get.snackbar("Error", "Failed to add product",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> performCalculation(Map<String, dynamic> data) async {
    debugPrint("=== STARTING CALCULATION API ===");
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');

    final productId = data["id"].toString();

    // --- UOM ---
    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();

    // --- Nos field ---
    String? nosText =
        fieldControllers[productId]?["Nos"]?.text ?? data["Nos"]?.toString();
    int nosValue = int.tryParse(nosText ?? "0") ?? 0;

    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 7,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": null,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
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
          billamt.value = responseData["bill_total"]?.toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          // ✅ Preserve Nos if API does not return it
          data["Nos"] = responseData["Nos"]?.toString() ?? data["Nos"];
          data["Amount"] = responseData["Amount"]?.toString();
          data["Cgst"] = responseData["cgst"]?.toString() ?? "0";
          data["Sgst"] = responseData["sgst"]?.toString() ?? "0";

          if (fieldControllers[productId] != null) {
            fieldControllers[productId]!["Nos"]?.text = data["Nos"] ?? "";
            fieldControllers[productId]!["Amount"]?.text = data["Amount"] ?? "";
            fieldControllers[productId]!["Cgst"]?.text = data["Cgst"] ?? "";
            fieldControllers[productId]!["Sgst"]?.text = data["Sgst"] ?? "";
          }

          previousUomValues[productId] = currentUom;
          responseProducts.refresh();
        }
      }
    } catch (e) {
      debugPrint("Calculation API Error: $e");
    }
  }

  void debounceCalculation(Map<String, dynamic> data) {
    debounceTimer?.cancel();
    debounceTimer =
        Timer(Duration(milliseconds: 1500), () => performCalculation(data));
  }

  Future<void> deleteCard(String deleteId) async {
    final url = '$apiUrl/enquirydelete/$deleteId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        responseProducts.removeWhere((p) => p["id"].toString() == deleteId);
        Get.snackbar("Success", "Data deleted successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error deleting card: $e");
      Get.snackbar("Error", "Error deleting card",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
