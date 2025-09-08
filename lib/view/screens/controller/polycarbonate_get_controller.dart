// Polycarbonate Controller
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../getx/summary_screen.dart';
import '../../universal_api/api_key.dart';
import '../global_user/global_oredrID.dart';

class PolycarbonateController extends GetxController {
  var brandsList = <String>[].obs;
  var colorsList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var selectedBrand = RxString('');
  var selectedColor = RxString('');
  var selectedThickness = RxString('');
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
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    brandsList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.get(Uri.parse('$apiUrl/showlables/19'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data["message"]["message"];
      if (message is List && message.length >= 2) {
        final categoryInfoList = message[0];
        if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
          categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
        }
        final brandsData = message[1];
        if (brandsData is List) {
          brandsList.value = brandsData
              .whereType<Map>()
              .map((e) => e["type_of_panel"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    }
  }

  Future<void> fetchColors() async {
    if (selectedBrand.value.isEmpty) return;
    colorsList.clear();
    selectedColor.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(Uri.parse('$apiUrl/labelinputdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand.value],
          "base_label_filters": ["type_of_panel"],
          "base_category_id": "19",
        }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data["message"]["message"];
      if (message is List && message.length >= 2) {
        final colorData = message[0];
        if (colorData is List) {
          colorsList.value = colorData
              .whereType<Map>()
              .map((e) => e["color"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    }
  }

  Future<void> fetchThickness() async {
    if (selectedBrand.value.isEmpty || selectedColor.value.isEmpty) return;
    thicknessList.clear();
    selectedThickness.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(Uri.parse('$apiUrl/labelinputdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand.value, selectedColor.value],
          "base_label_filters": ["type_of_panel", "color"],
          "base_category_id": "19",
        }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data["message"]["message"];
      if (message is List && message.length >= 2) {
        final thicknessData = message[0];
        if (thicknessData is List) {
          thicknessList.value = thicknessData
              .whereType<Map>()
              .map((e) => e["thickness"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        final idData = message[1];
        if (idData is List && idData.isNotEmpty && idData.first is Map) {
          selectedProductBaseId.value = idData.first["id"]?.toString() ?? '';
          selectedBaseProductName.value =
              idData.first["base_product_id"]?.toString() ?? '';
        }
      }
    }
  }

  Future<void> postPolycarbonateData() async {
    if (selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty ||
        selectedThickness.value.isEmpty) {
      Get.snackbar("Error", "Please select all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final categoryId = categoryMeta['category_id'];
    final categoryName = categoryMeta['categories'];
    final globalOrderManager = GlobalOrderManager();
    final data = {
      "customer_id": 377423,
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
              product['category_id'] = 19;
              product["cgst"] = product["cgst"] ?? "0";
              product["sgst"] = product["sgst"] ?? "0";
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
          selectedColor.value = '';
          selectedThickness.value = '';
          brandsList.clear();
          colorsList.clear();
          thicknessList.clear();
          fetchBrands();
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

    // ---------- SYNC INPUTS (controller -> data) ----------
    String controllerProfile =
        fieldControllers[productId]?["Profile"]?.text ?? "";
    String controllerLength =
        fieldControllers[productId]?["Length"]?.text ?? "";

    String profileText = "";

    if (controllerProfile.isNotEmpty) {
      profileText = controllerProfile;
    } else if (controllerLength.isNotEmpty) {
      profileText = controllerLength;
    } else {
      profileText =
          (data["Profile"]?.toString() ?? data["Length"]?.toString() ?? "");
    }

    if (profileText.isNotEmpty) {
      data["Profile"] = profileText;
      data["Length"] = profileText;
    }

    double profileValue = double.tryParse(profileText) ?? 0.0;

    // ---------- NOS ----------
    String controllerNos = fieldControllers[productId]?["Nos"]?.text ?? "";
    String nosText = controllerNos.isNotEmpty
        ? controllerNos
        : (data["Nos"]?.toString() ?? "");
    if (nosText.isNotEmpty) {
      data["Nos"] = nosText;
    }
    int nosValue = int.tryParse(nosText) ?? 1;

    debugPrint(
        "performCalculation -> productId: $productId, length: '$profileText' ($profileValue), nos: '$nosText' ($nosValue)");

    // ---------- PREPARE REQUEST ----------
    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();
    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 19,
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
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        debugPrint("Calculation API HTTP Error: ${response.statusCode}");
        return;
      }

      final responseData = jsonDecode(response.body);
      debugPrint("Calculation response: $responseData");

      if (responseData["status"] != "success") {
        debugPrint("Calculation failed: ${responseData["message"]}");
        return;
      }

      // ---------- APPLY RESPONSE ----------
      billamt.value = (responseData["bill_total"] as num?)?.toDouble() ?? 0.0;
      calculationResults[productId] = responseData;

      // --- Handle API returned length/profile ---
      String? apiLength = responseData["length"]?.toString();
      String? apiProfile = responseData["profile"]?.toString();

      if ((apiLength != null && apiLength.isNotEmpty) ||
          (apiProfile != null && apiProfile.isNotEmpty)) {
        final newLength =
            apiLength?.isNotEmpty == true ? apiLength! : apiProfile!;

        data["Profile"] = newLength;
        data["Length"] = newLength;

        if (fieldControllers[productId]?["Profile"] != null) {
          fieldControllers[productId]!["Profile"]!.text = newLength;
        }
        if (fieldControllers[productId]?["Length"] != null) {
          fieldControllers[productId]!["Length"]!.text = newLength;
        }
      }

      // Nos
      if (responseData["Nos"] != null &&
          responseData["Nos"].toString().isNotEmpty) {
        final nosStr = responseData["Nos"].toString();
        data["Nos"] = nosStr;
        if (fieldControllers[productId]?["Nos"] != null) {
          fieldControllers[productId]!["Nos"]!.text = nosStr;
        }
      }

      // Always update calculated fields
      data["SQMtr"] = responseData["sqmtr"]?.toString();
      data["Amount"] = responseData["Amount"]?.toString();
      data["cgst"] = responseData["cgst"]?.toString() ?? "0";
      data["sgst"] = responseData["sgst"]?.toString() ?? "0";

      fieldControllers[productId]?["SQMtr"]?.text = data["SQMtr"] ?? "";
      fieldControllers[productId]?["Amount"]?.text = data["Amount"] ?? "";
      fieldControllers[productId]?["cgst"]?.text = data["cgst"] ?? "";
      fieldControllers[productId]?["sgst"]?.text = data["sgst"] ?? "";

      // save UOM
      previousUomValues[productId] = currentUom;

      // refresh observable list so UI updates
      responseProducts.refresh();

      debugPrint(
          "performCalculation finished for $productId. data.Profile='${data['Profile']}', data.Nos='${data['Nos']}'");
    } catch (e) {
      debugPrint("Calculation API Error: $e");
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
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
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
