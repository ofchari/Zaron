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
import '../global_user/global_user.dart';

class IronSteelController extends GetxController {
  var categoryMeta = <String, dynamic>{}.obs;
  var billamt = 0.0.obs;
  var orderNo = ''.obs;
  var orderIDD = 0.obs;
  var selectedBrand = RxString('');
  var selectedColor = RxString('');
  var selectedThickness = RxString('');
  var selectedCoatingMass = RxString('');
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var brandsList = <String>[].obs;
  var colorsList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var coatingMassList = <String>[].obs;
  var responseProducts = <Map<String, dynamic>>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  Map<String, Map<String, TextEditingController>> fieldControllers = {};
  Timer? debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  @override
  void onClose() {
    debounceTimer?.cancel();
    for (var controllers in fieldControllers.values) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.onClose();
  }

  Future<void> fetchBrands() async {
    brandsList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/3');
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
          final brands = message[1];
          if (brands is List) {
            brandsList.value = brands
                .whereType<Map>()
                .map((e) => e["brand"]?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching brands: $e");
    }
  }

  Future<void> fetchColors() async {
    if (selectedBrand.value.isEmpty) return;
    colorsList.clear();
    selectedColor.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "color",
        "product_filters": null,
        "product_label_filters": null,
        "product_category_id": null,
        "base_product_filters": [selectedBrand.value],
        "base_label_filters": ["brand"],
        "base_category_id": "3",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final colors = data["message"]["message"][0];
      if (colors is List) {
        colorsList.value = colors
            .whereType<Map>()
            .map((e) => e["color"]?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
  }

  Future<void> fetchThickness() async {
    if (selectedBrand.value.isEmpty || selectedColor.value.isEmpty) return;
    thicknessList.clear();
    selectedThickness.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "thickness",
        "product_filters": null,
        "product_label_filters": null,
        "product_category_id": null,
        "base_product_filters": [selectedBrand.value, selectedColor.value],
        "base_label_filters": ["brand", "color"],
        "base_category_id": "3",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final thickness = data["message"]["message"][0];
      if (thickness is List) {
        thicknessList.value = thickness
            .whereType<Map>()
            .map((e) => e["thickness"]?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
  }

  Future<void> fetchCoatingMass() async {
    if (selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty ||
        selectedThickness.value.isEmpty) return;
    coatingMassList.clear();
    selectedCoatingMass.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final response = await client.post(
      Uri.parse('$apiUrl/labelinputdata'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "product_label": "coating_mass",
        "product_filters": null,
        "product_label_filters": null,
        "product_category_id": null,
        "base_product_filters": [
          selectedBrand.value,
          selectedColor.value,
          selectedThickness.value,
        ],
        "base_label_filters": ["brand", "color", "thickness"],
        "base_category_id": "3",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data["message"]["message"];
      final coating = message[0];
      if (coating is List) {
        coatingMassList.value = coating
            .whereType<Map>()
            .map((e) => e["coating_mass"]?.toString() ?? '')
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

  Future<void> postAllData() async {
    if (selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty ||
        selectedThickness.value.isEmpty ||
        selectedCoatingMass.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select all required fields",
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
      "product_id": null,
      "product_name": null,
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
            if (item["UOM"] != null && item["UOM"]["options"] != null) {
              uomOptions[productId] = Map<String, String>.from(
                  (item["UOM"]["options"] as Map)
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
          selectedBrand.value = '';
          selectedColor.value = '';
          selectedThickness.value = '';
          selectedCoatingMass.value = '';
          brandsList.clear();
          colorsList.clear();
          thicknessList.clear();
          coatingMassList.clear();
          fetchBrands();
        }
      }
    } catch (e) {
      debugPrint("Error posting data: $e");
      Get.snackbar(
        "Error",
        "Failed to add product",
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
    String? profileText = fieldControllers[productId]?["Length"]?.text ??
        data["Length"]?.toString();
    double? profileValue = double.tryParse(profileText ?? "0");
    String? nosText =
        fieldControllers[productId]?["Nos"]?.text ?? data["Nos"]?.toString();
    int nosValue = int.tryParse(nosText ?? "1") ?? 1;
    String? heightText = fieldControllers[productId]?["height"]?.text ??
        data["height"]?.toString();

    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 3,
      "product": data["Products"]?.toString() ?? "",
      "height": heightText,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue ?? 0,
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

          if (responseData["profile"] != null) {
            data["Length"] = responseData["profile"].toString();
            fieldControllers[productId]?["Length"]?.text = data["Length"] ?? "";
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
            data["height"] = responseData["crimp"].toString();
            fieldControllers[productId]?["height"]?.text = data["height"] ?? "";
          }
          if (responseData["sqmtr"] != null) {
            data["SQMtr"] = responseData["sqmtr"].toString();
            fieldControllers[productId]?["SQMtr"]?.text = data["SQMtr"] ?? "";
          }
          if (responseData["cgst"] != null) {
            data["Cgst"] = responseData["cgst"].toString();
            fieldControllers[productId]?["Cgst"]?.text = data["Cgst"] ?? "";
          }
          if (responseData["sgst"] != null) {
            data["Sgst"] = responseData["sgst"].toString();
            fieldControllers[productId]?["Sgst"]?.text = data["Sgst"] ?? "";
          }
          if (responseData["Amount"] != null) {
            data["Amount"] = responseData["Amount"].toString();
            fieldControllers[productId]?["Amount"]?.text = data["Amount"] ?? "";
          }
          if (responseData["rate"] != null) {
            data["Basic Rate"] = responseData["rate"].toString();
            fieldControllers[productId]?["Basic Rate"]?.text =
                data["Basic Rate"] ?? "";
          }
          previousUomValues[productId] = currentUom;
          responseProducts.refresh();
        }
      }
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
      height: 38.h,
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
        throw Exception("Failed to delete card with ID $deleteId");
      }
    } catch (e) {
      debugPrint("Error deleting card: $e");
      Get.snackbar(
        "Error",
        "Failed to delete product",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String selectedItems() {
    List<String> values = [
      if (selectedBrand.value.isNotEmpty) "Brand: ${selectedBrand.value}",
      if (selectedColor.value.isNotEmpty) "Color: ${selectedColor.value}",
      if (selectedThickness.value.isNotEmpty)
        "Thickness: ${selectedThickness.value}",
      if (selectedCoatingMass.value.isNotEmpty)
        "CoatingMass: ${selectedCoatingMass.value}",
    ];
    return values.isEmpty ? "No selections yet" : values.join(", ");
  }
}
