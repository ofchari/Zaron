// upvc_accessories_controller.dart
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

class UpvcAccessoriesController extends GetxController {
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var billamt = 0.0.obs;
  var orderNO = ''.obs;
  var orderIDD = 0.obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var productList = <String>[].obs;
  var brandsList = <String>[].obs;
  var colorsList = <String>[].obs;
  var sizeList = <String>[].obs;
  var selectedProductNameBase = ''.obs;
  var selectedBrand = ''.obs;
  var selectedColor = ''.obs;
  var selectedSize = ''.obs;
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var apiProductsList = <Map<String, dynamic>>[].obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductName();
  }

  // Method to display selected items (unchanged)
  String selectedItems() {
    print(
        "selectedItems called - ProductName: ${selectedProductNameBase.value.trim()}, Brand: ${selectedBrand.value.trim()}, Color: ${selectedColor.value.trim()}, Size: ${selectedSize.value.trim()}");
    List<String> items = [];
    if (selectedProductNameBase.value.trim().isNotEmpty) {
      items.add("ProductName: ${selectedProductNameBase.value.trim()}");
    }
    if (selectedBrand.value.trim().isNotEmpty) {
      items.add("Brand: ${selectedBrand.value.trim()}");
    }
    if (selectedColor.value.trim().isNotEmpty) {
      items.add("Color: ${selectedColor.value.trim()}");
    }
    if (selectedSize.value.trim().isNotEmpty) {
      items.add("Size: ${selectedSize.value.trim()}");
    }
    String result = items.isNotEmpty ? items.join(" | ") : "No selections made";
    print("selectedItems result: $result");
    return result;
  }

  Future<void> fetchProductName() async {
    productList.clear();
    selectedProductNameBase.value = '';
    final client =
    IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/15');

    try {
      final response = await client.get(url);
      print("fetchProductName response status: ${response.statusCode}");
      print(
          "fetchProductName full response body: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = data["message"]["message"][1];
        if (product is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          productList.value = product
              .whereType<Map>()
              .map((e) => e["product_name_base"]?.toString().trim())
              .whereType<String>()
              .where((s) => s.isNotEmpty) // Filter empty strings
              .toList();
          print(
              "productList updated: ${productList.value} (length: ${productList.length})"); // Debug log
        } else {
          print("Product data is not a list: $product"); // Debug log
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

  Future<void> fetchBrand() async {
    if (selectedProductNameBase.value.trim().isEmpty) {
      print(
          "fetchBrand skipped: selectedProductNameBase is empty"); // Debug log
      return;
    }
    brandsList.clear();
    selectedBrand.value = '';
    final client =
    IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final body = jsonEncode({
        "base_category_id": "15",
        "product_filters": null,
        "product_label_filters": null,
        "product_category_id": null,
        "base_label_filters": ["product_name_base"],
        "base_product_filters": [selectedProductNameBase.value.trim()],
        "product_label": "brand",
      });
      print("fetchBrand request body: $body"); // Debug log

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print("fetchBrand response status: ${response.statusCode}");
      print(
          "fetchBrand full response body: ${response.body}"); // Debug log - KEY FOR DIAGNOSIS
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brands = data["message"]["message"][0];
        print(
            "Brands raw data: $brands (type: ${brands.runtimeType})"); // Debug log
        if (brands is List && brands.isNotEmpty) {
          brandsList.value = brands
              .whereType<Map>()
              .map((e) => e["brand"]?.toString().trim())
              .whereType<String>()
              .where((s) => s.isNotEmpty) // Filter empty strings
              .toList();
          print(
              "brandsList updated: ${brandsList.value} (length: ${brandsList.length})"); // Debug log
          if (brandsList.isEmpty) {
            print(
                "No brands found for product: ${selectedProductNameBase.value}"); // Debug log
            Get.snackbar(
              "Info",
              "No brands available for '${selectedProductNameBase.value}'",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } else {
          print("Brands data is not a non-empty list: $brands"); // Debug log
          Get.snackbar(
            "Info",
            "No brands available for this product",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
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
    } finally {
      client.close();
    }
  }

  Future<void> fetchColor() async {
    if (selectedProductNameBase.value.trim().isEmpty ||
        selectedBrand.value.trim().isEmpty) {
      print("fetchColor skipped: missing product or brand"); // Debug log
      return;
    }
    colorsList.clear();
    selectedColor.value = '';
    final client =
    IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final body = jsonEncode({
        "base_category_id": "15",
        "product_filters": null,
        "product_label_filters": null,
        "product_category_id": null,
        "base_label_filters": ["product_name_base", "brand"],
        "base_product_filters": [
          selectedProductNameBase.value.trim(),
          selectedBrand.value.trim()
        ],
        "product_label": "color",
      });
      print("fetchColor request body: $body"); // Debug log

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print("fetchColor response status: ${response.statusCode}");
      print("fetchColor full response body: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final color = data["message"]["message"][0];
        print(
            "Colors raw data: $color (type: ${color.runtimeType})"); // Debug log
        if (color is List && color.isNotEmpty) {
          colorsList.value = color
              .whereType<Map>()
              .map((e) => e["color"]?.toString().trim())
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .toList();
          print(
              "colorsList updated: ${colorsList.value} (length: ${colorsList.length})"); // Debug log
          if (colorsList.isEmpty) {
            Get.snackbar(
              "Info",
              "No colors available for this selection",
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } else {
          print("Colors data is not a non-empty list: $color"); // Debug log
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
    } finally {
      client.close();
    }
  }

  Future<void> fetchSize() async {
    if (selectedProductNameBase.value.trim().isEmpty ||
        selectedBrand.value.trim().isEmpty ||
        selectedColor.value.trim().isEmpty) {
      print("fetchSize skipped: missing required selections"); // Debug log
      return;
    }
    sizeList.clear();
    selectedSize.value = '';
    final client =
    IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final body = jsonEncode({
        "base_category_id": "15",
        "product_filters": null,
        "product_label_filters": null,
        "product_category_id": null,
        "base_label_filters": ["product_name_base", "brand", "color"],
        "base_product_filters": [
          selectedProductNameBase.value.trim(),
          selectedBrand.value.trim(),
          selectedColor.value.trim(),
        ],
        "product_label": "SIZE",
      });
      print("fetchSize request body: $body"); // Debug log

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print("fetchSize response status: ${response.statusCode}");
      print("fetchSize full response body: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print(
            "Size message raw: $message (length: ${message.length}if message is List else 'not list'})"); // Debug log

        if (message is List && message.length >= 2) {
          final sizeData = message[0];
          final idData = message[1];

          if (sizeData is List && sizeData.isNotEmpty) {
            sizeList.value = sizeData
                .whereType<Map>()
                .map((e) => e["SIZE"]?.toString().trim())
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .toList();
            print(
                "sizeList updated: ${sizeList.value} (length: ${sizeList.length})"); // Debug log
            if (sizeList.isEmpty) {
              Get.snackbar(
                "Info",
                "No sizes available for this selection",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          } else {
            print("Size data is empty or not list: $sizeData"); // Debug log
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId.value =
                idData.first["id"]?.toString().trim() ?? '';
            selectedBaseProductName.value =
                idData.first["base_product_id"]?.toString().trim() ?? '';
            print(
                "Updated IDs - Base ID: ${selectedProductBaseId.value}, Base Name: ${selectedBaseProductName.value}"); // Debug log
          } else {
            print("No ID data found: $idData"); // Debug log
          }
        } else {
          print("Message is not a list with >=2 items: $message"); // Debug log
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch sizes: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching sizes: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch sizes: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      client.close();
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
    selectedProductNameBase.value = '';
    selectedBrand.value = '';
    selectedColor.value = '';
    selectedSize.value = '';
    selectedProductBaseId.value = '';
    selectedBaseProductName.value = '';
    brandsList.clear();
    colorsList.clear();
    sizeList.clear();
    print(
        "After reset - ProductName: ${selectedProductNameBase.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}");
    fetchProductName();
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

    String? currentUom = data["UOM"]?.toString();

    String nosText = _getFieldValue(productId, "Nos", data);
    int nosValue =
    _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 1) : 1;

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 15,
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
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      print("performCalculation response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

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
        keyboardType:
        ["Nos", "Basic Rate", "Amount", "cgst", "sgst"].contains(key)
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
