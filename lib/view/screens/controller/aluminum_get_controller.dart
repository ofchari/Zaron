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

class AluminumController extends GetxController {
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var billamt = 0.0.obs;
  var orderNO = ''.obs;
  var orderIDD = 0.obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var materialTypeList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var brandsList = <String>[].obs;
  var colorsList = <String>[].obs;
  var selectedMaterialType = ''.obs;
  var selectedThickness = ''.obs;
  var selectedBrand = ''.obs;
  var selectedColor = ''.obs;
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var apiProductsList = <Map<String, dynamic>>[].obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMaterialType();
  }

  // Method to display selected items
  String selectedItems() {
    print(
        "selectedItems called - Material: ${selectedMaterialType.value}, Thickness: ${selectedThickness.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}");
    List<String> items = [];
    if (selectedMaterialType.value.isNotEmpty) {
      items.add("Material: ${selectedMaterialType.value}");
    }
    if (selectedThickness.value.isNotEmpty) {
      items.add("Thickness: ${selectedThickness.value}");
    }
    if (selectedBrand.value.isNotEmpty) {
      items.add("Brand: ${selectedBrand.value}");
    }
    if (selectedColor.value.isNotEmpty) {
      items.add("Color: ${selectedColor.value}");
    }
    String result = items.isNotEmpty ? items.join(" | ") : "No selections made";
    print("selectedItems result: $result");
    return result;
  }

  Future<void> fetchMaterialType() async {
    materialTypeList.clear();
    selectedMaterialType.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/36');

    try {
      final response = await client.get(url);
      print("fetchMaterialType response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][1];
        if (materials is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          materialTypeList.value = materials
              .whereType<Map>()
              .map((e) => e["material_type"]?.toString())
              .whereType<String>()
              .toList();
          print("materialTypeList updated: ${materialTypeList.value}");
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
    }
  }

  Future<void> fetchThickness() async {
    if (selectedMaterialType.isEmpty) return;
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedMaterialType.value],
          "base_label_filters": ["material_type"],
          "base_category_id": "36",
        }),
      );
      print("fetchThickness response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thick = data["message"]["message"][0];
        if (thick is List) {
          thicknessList.value = thick
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

  Future<void> fetchBrand() async {
    if (selectedMaterialType.isEmpty || selectedThickness.isEmpty) return;
    brandsList.clear();
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value
          ],
          "base_label_filters": ["material_type", "thickness"],
          "base_category_id": "36",
        }),
      );
      print("fetchBrand response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brand = data["message"]["message"][0];
        if (brand is List) {
          brandsList.value = brand
              .whereType<Map>()
              .map((e) => e["brand"]?.toString())
              .whereType<String>()
              .toList();
          print("brandsList updated: ${brandsList.value}");
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
    }
  }

  Future<void> fetchColor() async {
    if (selectedMaterialType.isEmpty ||
        selectedThickness.isEmpty ||
        selectedBrand.isEmpty) return;
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value,
            selectedBrand.value
          ],
          "base_label_filters": ["material_type", "thickness", "brand"],
          "base_category_id": "36",
        }),
      );
      print("fetchColor response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["message"]["message"] is List) {
          final List message = data["message"]["message"];
          final colorData = message[0];
          if (colorData is List) {
            colorsList.value = colorData
                .whereType<Map>()
                .map((e) => e["color"]?.toString())
                .whereType<String>()
                .toList();
            print("colorsList updated: ${colorsList.value}");
          }
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId.value = idData.first["id"]?.toString() ?? '';
            selectedBaseProductName.value =
                idData.first["base_product_id"]?.toString() ?? '';
            print(
                "selectedProductBaseId: ${selectedProductBaseId.value}, selectedBaseProductName: ${selectedBaseProductName.value}");
          }
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch color: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching color: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch color: $e",
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
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name": selectedBaseProductName.value,
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
    selectedMaterialType.value = '';
    selectedThickness.value = '';
    selectedBrand.value = '';
    selectedColor.value = '';
    selectedProductBaseId.value = '';
    selectedBaseProductName.value = '';
    thicknessList.clear();
    brandsList.clear();
    colorsList.clear();
    print(
        "After reset - Material: ${selectedMaterialType.value}, Thickness: ${selectedThickness.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}");
    print(
        "Lists cleared - materialTypeList: ${materialTypeList.length}, thicknessList: ${thicknessList.length}, brandsList: ${brandsList.length}, colorsList: ${colorsList.length}");
    fetchMaterialType();
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

    String lengthText = _getFieldValue(productId, "Length", data);
    String nosText = _getFieldValue(productId, "Nos", data);
    String crimpText = _getFieldValue(productId, "Crimp", data);

    double profileValue = _isValidNonZeroNumber(lengthText)
        ? (double.tryParse(lengthText) ?? 0.0)
        : 0.0;
    int nosValue =
        _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 1) : 1;
    double crimpValue = _isValidNonZeroNumber(crimpText)
        ? (double.tryParse(crimpText) ?? 0.0)
        : 0.0;

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 36,
      "product": data["Products"]?.toString() ?? "",
      "height": crimpValue,
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
      print("performCalculation response status: ${response.statusCode}");
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

          String newCrimp = responseData["crimp"]?.toString() ?? "0";
          if (_isValidNonZeroNumber(newCrimp) && newCrimp != crimpText) {
            data["Crimp"] = newCrimp;
            if (fieldControllers[productId]?["Crimp"] != null) {
              fieldControllers[productId]!["Crimp"]!.text = newCrimp;
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

    return DropdownButtonFormField<String>(
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
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          "SQMtr",
          "cgst",
          "sgst",
          "Crimp"
        ].contains(key)
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: onChanged,
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
}
