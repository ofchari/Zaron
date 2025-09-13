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

class UpvcTilesController extends GetxController {
  var materialList = <String>[].obs;
  var colorsList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var selectMaterial = RxString('');
  var selectedColor = RxString('');
  var selectThickness = RxString('');
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
  var availableLengths = <String, List<String>>{}.obs;
  var selectedLengths = <String, String?>{}.obs;
  Map<String, Map<String, TextEditingController>> fieldControllers = {};

  Timer? debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchMaterial();
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

  Future<void> fetchMaterial() async {
    materialList.clear();
    selectMaterial.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/631');
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
          final materialData = message[1];
          if (materialData is List) {
            materialList.value = materialData
                .whereType<Map>()
                .map((e) => e["material_type"]?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint("Exception fetching material type: $e");
    }
  }

  Future<void> fetchColors() async {
    if (selectMaterial.value.isEmpty) return;
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
        "base_product_filters": [selectMaterial.value],
        "base_label_filters": ["material_type"],
        "base_category_id": "631",
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data["message"]["message"];
      if (message is List && message.length >= 1) {
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
    if (selectMaterial.value.isEmpty || selectedColor.value.isEmpty) return;
    thicknessList.clear();
    selectThickness.value = '';
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
        "base_product_filters": [selectMaterial.value, selectedColor.value],
        "base_label_filters": ["material_type", "color"],
        "base_category_id": "631",
      }),
    );
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

  Future<void> postUpvcData() async {
    if (selectMaterial.value.isEmpty ||
        selectedColor.value.isEmpty ||
        selectThickness.value.isEmpty) {
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
        final orderID = responseData["order_id"]?.toString() ?? "";
        orderIDD.value = int.tryParse(orderID) ?? 0;
        orderNO.value = responseData["order_no"]?.toString() ?? "Unknown";

        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(
              int.parse(orderID), orderNO.value);
        }

        orderIDD.value = globalOrderManager.globalOrderId!;
        orderNO.value = globalOrderManager.globalOrderNo!;

        if (responseData["lebels"] != null &&
            responseData["lebels"].isNotEmpty) {
          final fullList = responseData["lebels"][0]["data"];
          final newProducts = <Map<String, dynamic>>[];
          for (var item in fullList) {
            if (item is Map<String, dynamic>) {
              final product = Map<String, dynamic>.from(item);
              product['category_id'] = 631;
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
          Get.snackbar(
            "Success",
            "Product added successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          selectMaterial.value = '';
          selectedColor.value = '';
          selectThickness.value = '';
          materialList.clear();
          colorsList.clear();
          thicknessList.clear();
          fetchMaterial();
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

  Widget lengthDropdown(Map<String, dynamic> data) {
    String productId = data["id"].toString();
    List<String> lengths = availableLengths[productId] ?? [];

    if (lengths.isEmpty) {
      return SizedBox(
        height: 38.h,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[50],
          ),
          child: Center(
            child: Text(
              "Loading lengths...",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    }

    String? selectedValue = selectedLengths[productId];
    if (selectedValue != null && !lengths.contains(selectedValue)) {
      selectedValue = null;
      selectedLengths[productId] = null;
    }

    return SizedBox(
      height: 38.h,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
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
        hint: Text(
          "Select Length",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
        items: lengths.map((String length) {
          return DropdownMenuItem<String>(
            value: length,
            child: Text('$length ft'),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            selectedLengths[productId] = newValue;
            data["Length"] = newValue;
            debounceCalculation(data);
          }
        },
        isExpanded: true,
      ),
    );
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

  ///part 2

  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');

    final productId = data["id"].toString();
    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();

    // Get Length value from selected dropdown (same logic as Part 1)
    double lengthValue = 0;
    String? lengthText = selectedLengths[productId];
    if (lengthText == null || lengthText.isEmpty) {
      lengthText = _getFieldValue(productId, "Length", data);
    }
    if (lengthText != null && lengthText.isNotEmpty) {
      lengthValue = double.tryParse(lengthText) ?? 0;
    }

    String nosText = _getFieldValue(productId, "Nos", data);
    int nosValue =
        _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 0) : 0;

    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 631,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": lengthValue,
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
        print("performCalculation response status: $requestBody");
        print("thhh ${response.body}");
        String cleanResponseBody = response.body;
        int jsonStart = cleanResponseBody.indexOf('{');
        if (jsonStart > 0) {
          cleanResponseBody = cleanResponseBody.substring(jsonStart);
        }
        final responseData = jsonDecode(cleanResponseBody);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"]?.toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          // Extract available lengths from profile array (same logic as Part 1)
          if (responseData["profile"] != null &&
              responseData["profile"] is List) {
            Set<String> lengthSet = {};
            for (var profile in responseData["profile"]) {
              String? lengthValue;
              if (profile["length_mm"] != null) {
                lengthValue = profile["length_mm"].toString().trim();
              } else if (profile["length_feet"] != null) {
                lengthValue = profile["length_feet"].toString().trim();
              } else if (profile["length_mtr"] != null) {
                lengthValue = profile["length_mtr"].toString().trim();
              } else if (profile["length_inch"] != null) {
                lengthValue = profile["length_inch"].toString().trim();
              }
              if (lengthValue != null &&
                  lengthValue.isNotEmpty &&
                  lengthValue != "0" &&
                  lengthValue != "0.0") {
                lengthSet.add(lengthValue);
              }
            }
            List<String> lengths = lengthSet.toList();
            lengths.sort((a, b) {
              double aNum = double.tryParse(a) ?? 0;
              double bNum = double.tryParse(b) ?? 0;
              return aNum.compareTo(bNum);
            });
            availableLengths[productId] = lengths;

            // Set initial selected value if not already set
            if (selectedLengths[productId] == null && lengths.isNotEmpty) {
              String? currentLength = data["Length"]?.toString()?.trim();
              if (currentLength != null && lengths.contains(currentLength)) {
                selectedLengths[productId] = currentLength;
              } else {
                selectedLengths[productId] = lengths.first;
                data["Length"] = lengths.first;
              }
            }
          }

          // Handle Length update
          if (responseData["length"] != null) {
            String newLength = responseData["length"].toString().trim();
            data["Length"] = newLength;
            selectedLengths[productId] = newLength;
          }

          // Handle Nos field update
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
          } else if (responseData["nos"] != null) {
            String newNos = responseData["nos"].toString().trim();
            String currentInput =
                fieldControllers[productId]?["Nos"]?.text.trim() ?? "";
            if (!_isValidNonZeroNumber(currentInput)) {
              data["Nos"] = newNos;
              if (fieldControllers[productId]?["Nos"] != null) {
                fieldControllers[productId]!["Nos"]!.text = newNos;
              }
            }
          }

          data["Sq.Mtr"] = responseData["sqmtr"]?.toString();
          data["Amount"] = responseData["Amount"]?.toString();
          data["cgst"] = responseData["cgst"]?.toString() ?? "0";
          data["sgst"] = responseData["sgst"]?.toString() ?? "0";

          if (fieldControllers[productId] != null) {
            fieldControllers[productId]!["Length"]?.text = data["Length"] ?? "";
            fieldControllers[productId]!["Nos"]?.text = data["Nos"] ?? "";
            fieldControllers[productId]!["Sq.Mtr"]?.text = data["Sq.Mtr"] ?? "";
            fieldControllers[productId]!["Amount"]?.text = data["Amount"] ?? "";
            fieldControllers[productId]!["cgst"]?.text = data["cgst"] ?? "";
            fieldControllers[productId]!["sgst"]?.text = data["sgst"] ?? "";
          }

          if (responseData["rate"] != null) {
            data["Basic Rate"] = responseData["rate"]?.toString();
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
    debounceTimer =
        Timer(Duration(milliseconds: 1000), () => performCalculation(data));
  }

  Future<void> deleteCard(String deleteId) async {
    final url = '$apiUrl/enquirydelete/$deleteId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        responseProducts.removeWhere((p) => p["id"].toString() == deleteId);
        Get.snackbar(
          "Success",
          "Data deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error deleting card: $e");
      Get.snackbar(
        "Error",
        "Error deleting card",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
