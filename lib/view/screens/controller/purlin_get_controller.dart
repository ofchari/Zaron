// PurlinController.dart
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

class PurlinController extends GetxController {
  var selectProduct = ''.obs;
  var selectedBrand = ''.obs;
  var selectedSize = ''.obs;
  var selectedThickness = ''.obs;
  var selectedMaterialType = ''.obs;
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var currentMainProductId = ''.obs;

  var productList = <String>[].obs;
  var brandsList = <String>[].obs;
  var sizeList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var materialTypeList = <String>[].obs;

  var categoryMeta = <String, dynamic>{}.obs;
  var billamt = 0.0.obs;
  var orderIDD = 0.obs;
  var orderNO = ''.obs;

  var apiResponseData = <String, dynamic>{}.obs;
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;

  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchShapeProduct();
  }

  Future<void> fetchShapeProduct() async {
    productList.clear();
    selectProduct.value = '';
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/5');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];

        if (products is List) {
          categoryMeta.value =
              Map<String, dynamic>.from(data["message"]["message"][0][0]);
          productList.value = products
              .whereType<Map>()
              .map((e) => e["shape_of_product"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching shape products: $e");
    }
  }

  Future<void> fetchSizes() async {
    if (selectProduct.isEmpty) return;
    sizeList.clear();
    selectedSize.value = '';
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
          "base_product_filters": [selectProduct.value],
          "base_label_filters": ["shape_of_product"],
          "base_category_id": "5",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sizes = data["message"]["message"][0];

        if (sizes is List) {
          sizeList.value = sizes
              .whereType<Map>()
              .map((e) => e["size"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching sizes: $e");
    }
  }

  Future<void> fetchMaterial() async {
    if (selectProduct.isEmpty) return;
    materialTypeList.clear();
    selectedMaterialType.value = '';
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
          "base_product_filters": [selectProduct.value, selectedSize.value],
          "base_label_filters": ["shape_of_product", "size"],
          "base_category_id": "5",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][0];

        if (materials is List) {
          materialTypeList.value = materials
              .whereType<Map>()
              .map((e) => e["material_type"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching material types: $e");
    }
  }

  Future<void> fetchThickness() async {
    if (selectProduct.isEmpty) return;
    thicknessList.clear();
    selectedThickness.value = '';
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
            selectProduct.value,
            selectedSize.value,
            selectedMaterialType.value,
          ],
          "base_label_filters": ["shape_of_product", "size", "material_type"],
          "base_category_id": "5",
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
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  Future<void> fetchBrand() async {
    if (selectProduct.isEmpty) return;
    brandsList.clear();
    selectedBrand.value = '';
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
            selectProduct.value,
            selectedSize.value,
            selectedMaterialType.value,
            selectedThickness.value,
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

        if (message is List && message.isNotEmpty) {
          final brandListRaw = message[0];
          if (brandListRaw is List) {
            brandsList.value = brandListRaw
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
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

  Future<void> postAllData() async {
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
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
      "OrderID": globalOrderManager.globalOrderId
    };

    try {
      final response =
          await client.post(url, headers: headers, body: jsonEncode(data));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String orderID = responseData["order_id"]?.toString() ?? "";
        orderIDD.value = int.tryParse(orderID) ?? 0;
        orderNO.value = responseData["order_no"]?.toString() ?? "Unknown";
        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(orderIDD.value, orderNO.value);
        }
        orderIDD.value = globalOrderManager.globalOrderId!;
        orderNO.value = globalOrderManager.globalOrderNo!;
        apiResponseData.assignAll(responseData);
        currentMainProductId.value =
            responseData["product_id"]?.toString() ?? '';

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
    }
  }

  void resetSelections() {
    selectProduct.value = '';
    selectedBrand.value = '';
    selectedSize.value = '';
    selectedThickness.value = '';
    selectedMaterialType.value = '';
    sizeList.clear();
    materialTypeList.clear();
    thicknessList.clear();
    brandsList.clear();
    fieldControllers.clear();
    previousUomValues.clear();
    calculationResults.clear();
    fetchShapeProduct();
  }

  String selectedItems() {
    List<String> values = [
      if (selectProduct.value.isNotEmpty) "Product: ${selectProduct.value}",
      if (selectedSize.value.isNotEmpty) "Size: ${selectedSize.value}",
      if (selectedMaterialType.value.isNotEmpty)
        "Material: ${selectedMaterialType.value}",
      if (selectedThickness.value.isNotEmpty)
        "Thickness: ${selectedThickness.value}",
      if (selectedBrand.value.isNotEmpty) "Brand: ${selectedBrand.value}",
    ];
    return values.isEmpty ? "No selection yet" : values.join(",  ");
  }

  Future<void> deleteCard(String deleteId) async {
    final url = Uri.parse('$apiUrl/enquirydelete/$deleteId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((product) => product["id"].toString() == deleteId);
        fieldControllers.remove(deleteId);
        previousUomValues.remove(deleteId);
        calculationResults.remove(deleteId);
        Get.snackbar(
          "Success",
          "Data deleted successfully",
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
        "Error deleting card: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
      "category_id": 5,
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
      if (response.statusCode == 200) {
        print("bodyyy ${response.body}");
        print("re ${requestBody}");

        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          String newProfile = responseData["length"]?.toString() ?? "0";
          if (_isValidNonZeroNumber(newProfile) && newProfile != profileText) {
            data["Profile"] = newProfile;
            if (fieldControllers[productId]?["Profile"] != null) {
              fieldControllers[productId]!["Profile"]!.text = newProfile;
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

          if (responseData["kg"] != null) {
            data["kg"] = responseData["kg"].toString();
            if (fieldControllers[productId]?["kg"] != null) {
              fieldControllers[productId]!["kg"]!.text =
                  responseData["kg"].toString();
            }
          }

          if (responseData["Amount"] != null) {
            data["Amount"] = responseData["Amount"].toString();
            if (fieldControllers[productId]?["Amount"] != null) {
              fieldControllers[productId]!["Amount"]!.text =
                  responseData["Amount"].toString();
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

          previousUomValues[productId] = currentUom;
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
  }

  // Widget uomDropdown(Map<String, dynamic> data) {
  //   String productId = data["id"].toString();
  //   Map<String, String>? options = uomOptions[productId];
  //
  //   if (options == null || options.isEmpty) {
  //     return editableTextField(data, "UOM", (val) {},
  //         fieldControllers: fieldControllers);
  //   }
  //
  //   String? currentValue;
  //   if (data["UOM"] is Map) {
  //     currentValue = data["UOM"]["value"]?.toString();
  //   } else {
  //     currentValue = data["UOM"]?.toString();
  //   }
  //
  //   return DropdownButtonFormField<String>(
  //     value: currentValue,
  //     items: options.entries
  //         .map((entry) => DropdownMenuItem(
  //               value: entry.key,
  //               child: Text(entry.value),
  //             ))
  //         .toList(),
  //     onChanged: (val) {
  //       data["UOM"] = {"value": val, "options": options};
  //       debounceCalculation(data);
  //     },
  //     decoration: InputDecoration(
  //       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
  //       enabledBorder:
  //           OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
  //       focusedBorder: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(6),
  //         borderSide: BorderSide(color: Colors.deepPurple, width: 2),
  //       ),
  //       filled: true,
  //       fillColor: Colors.grey[50],
  //     ),
  //   );
  // }
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
              borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
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
        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
}
