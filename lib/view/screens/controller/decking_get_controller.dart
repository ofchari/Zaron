import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/universal_api/api_key.dart';

import '../global_user/global_oredrID.dart';

class DeckingSheetsController extends GetxController {
  var categoryMeta = <String, dynamic>{}.obs;
  var billamt = 0.0.obs;
  var orderIDD = 0.obs;
  var orderNo = ''.obs;
  var selectedMaterialType = RxString('');
  var selectedThickness = RxString('');
  var selectedCoatingMass = RxString('');
  var selectedYieldStrength = RxString('');
  var selectedBrand = RxString('');
  var selectedProductBaseId = RxString('');
  var materialTypeList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var coatingMassList = <String>[].obs;
  var yieldStrengthList = <String>[].obs;
  var brandList = <String>[].obs;
  var responseProducts = <Map<String, dynamic>>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var baseProductController = TextEditingController().obs;
  var baseProductResults = <dynamic>[].obs;
  var isSearchingBaseProduct = false.obs;
  var selectedBaseProduct = RxString('');
  var baseProductFocusNode = FocusNode().obs;
  Timer? debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchMaterialType();
  }

  @override
  void onClose() {
    debounceTimer?.cancel();
    baseProductController.value.dispose();
    baseProductFocusNode.value.dispose();
    for (var controllers in fieldControllers.values) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.onClose();
  }

  Future<void> fetchMaterialType() async {
    materialTypeList.clear();
    selectedMaterialType.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/34');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meterialType = data["message"]["message"][1];
        debugPrint("Material Type Response: ${response.body}");

        if (meterialType is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value =
                Map<String, dynamic>.from(categoryInfoList[0] as Map);
          }
          materialTypeList.value = meterialType
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
              .map((e) => e["material_type"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } else {
        debugPrint("Failed to fetch material types: ${response.statusCode}");
        Get.snackbar(
          "Error",
          "Failed to fetch material types",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Exception fetching material types: $e");
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
    if (selectedMaterialType.value.isEmpty) return;
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
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"][0];
        debugPrint("Thickness Response: ${response.body}");
        if (selectedThickness is List) {
          thicknessList.value = selectedThickness
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
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
    } catch (e) {
      debugPrint("Exception fetching thickness: $e");
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
    if (selectedThickness.value.isEmpty) return;
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
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
        final thickness = data["message"]["message"][0];
        debugPrint("Coating Mass Response: ${response.body}");
        if (thickness is List) {
          coatingMassList.value = thickness
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
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
    } catch (e) {
      debugPrint("Exception fetching coating mass: $e");
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
    if (selectedCoatingMass.value.isEmpty) return;
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value,
            selectedCoatingMass.value,
          ],
          "base_label_filters": ["material_type", "thickness", "coating_mass"],
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coating = data["message"]["message"][0];
        debugPrint("Yield Strength Response: ${response.body}");
        if (coating is List) {
          yieldStrengthList.value = coating
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
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
    } catch (e) {
      debugPrint("Exception fetching yield strength: $e");
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
    if (selectedYieldStrength.value.isEmpty) return;
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedMaterialType.value,
            selectedThickness.value,
            selectedCoatingMass.value,
            selectedYieldStrength.value,
          ],
          "base_label_filters": [
            "material_type",
            "thickness",
            "coating_mass",
            "yield_strength",
          ],
          "base_category_id": "34",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        debugPrint("Brand Response: ${response.body}");
        final brands = message[0];
        if (brands is List) {
          brandList.value = brands
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e as Map))
              .map((e) => e["brand"]?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        final idData = message.length > 1 ? message[1] : null;
        if (idData is List && idData.isNotEmpty && idData.first is Map) {
          selectedProductBaseId.value = idData.first["id"]?.toString() ?? '';
          debugPrint(
              "Selected Base Product ID: ${selectedProductBaseId.value}");
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
    } catch (e) {
      debugPrint("Exception fetching brands: $e");
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

  Future<void> postAllData() async {
    if (selectedMaterialType.value.isEmpty ||
        selectedThickness.value.isEmpty ||
        selectedCoatingMass.value.isEmpty ||
        selectedYieldStrength.value.isEmpty ||
        selectedBrand.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select all required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse("$apiUrl/addbag");
    final globalOrderManager = GlobalOrderManager();
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name":
          "${selectedMaterialType.value},${selectedThickness.value},${selectedCoatingMass.value},${selectedYieldStrength.value},${selectedBrand.value}",
      "category_id": categoryMeta['category_id'],
      "category_name": categoryMeta['categories'],
      "OrderID": globalOrderManager.globalOrderId,
    };

    try {
      final response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

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
              List<Map<String, dynamic>>.from(responseData['lebels'][0]['data']
                  .map((item) => Map<String, dynamic>.from(item as Map)));
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
          resetSelections();
        } else {
          debugPrint("Invalid response from server");
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
    } finally {
      client.close();
    }
  }

  void resetSelections() {
    selectedMaterialType.value = '';
    selectedThickness.value = '';
    selectedCoatingMass.value = '';
    selectedYieldStrength.value = '';
    selectedBrand.value = '';
    materialTypeList.clear();
    thicknessList.clear();
    coatingMassList.clear();
    yieldStrengthList.clear();
    brandList.clear();
    fetchMaterialType();
  }

  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');
    final productId = data["id"].toString();

    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();
    String lengthText = getFieldValue(productId, "Length", data);
    String nosText = getFieldValue(productId, "Nos", data);
    double profileValue = isValidNonZeroNumber(lengthText)
        ? double.tryParse(lengthText) ?? 0.0
        : 0.0;
    int nosValue =
        isValidNonZeroNumber(nosText) ? int.tryParse(nosText) ?? 1 : 1;
    String? crimpText = data["Crimp"]?.toString();
    if (crimpText == null || crimpText.isEmpty || crimpText == "0") {
      if (fieldControllers.containsKey(productId) &&
          fieldControllers[productId]!.containsKey("Crimp")) {
        crimpText = fieldControllers[productId]!["Crimp"]!.text.trim();
      }
    }
    double? crimpValue = crimpText != null && crimpText.isNotEmpty
        ? double.tryParse(crimpText)
        : null;

    final requestBody = {
      "id": int.tryParse(productId) ?? 0,
      "category_id": 34,
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
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      debugPrint("Calculation Response Status: ${response.statusCode}");
      debugPrint("Calculation Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"]?.toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          if (responseData["profile"] != null &&
              isValidNonZeroNumber(responseData["profile"].toString())) {
            data["Length"] = responseData["profile"].toString();
            if (fieldControllers[productId]?["Length"] != null) {
              fieldControllers[productId]!["Length"]!.text =
                  data["Length"] ?? "";
            }
          }
          if (responseData["length"] != null &&
              isValidNonZeroNumber(responseData["length"].toString())) {
            data["Length"] = responseData["length"].toString();
            if (fieldControllers[productId]?["Length"] != null) {
              fieldControllers[productId]!["Length"]!.text =
                  data["Length"] ?? "";
            }
          }
          if (responseData["Nos"] != null) {
            String newNos = responseData["Nos"].toString().trim();
            String currentInput =
                fieldControllers[productId]?["Nos"]?.text.trim() ?? "";
            if (!isValidNonZeroNumber(currentInput)) {
              data["Nos"] = newNos;
              if (fieldControllers[productId]?["Nos"] != null) {
                fieldControllers[productId]!["Nos"]!.text = newNos;
              }
            }
          }
          if (responseData["crimp"] != null &&
              responseData["crimp"].toString() != "0" &&
              responseData["crimp"].toString() != "0.0") {
            data["Crimp"] = responseData["crimp"].toString();
            if (fieldControllers[productId]?["Crimp"] != null) {
              String currentCrimp =
                  fieldControllers[productId]!["Crimp"]!.text.trim();
              if (currentCrimp.isEmpty || currentCrimp == "0") {
                fieldControllers[productId]!["Crimp"]!.text =
                    data["Crimp"] ?? "";
              }
            }
          }
          if (responseData["qty"] != null) {
            data["qty"] = responseData["qty"].toString();
            if (fieldControllers[productId]?["qty"] != null) {
              fieldControllers[productId]!["qty"]!.text = data["qty"] ?? "";
            }
          }
          if (responseData["cgst"] != null) {
            data["cgst"] = responseData["cgst"].toString();
            if (fieldControllers[productId]?["cgst"] != null) {
              fieldControllers[productId]!["cgst"]!.text = data["cgst"] ?? "";
            }
          }
          if (responseData["sgst"] != null) {
            data["sgst"] = responseData["sgst"].toString();
            if (fieldControllers[productId]?["sgst"] != null) {
              fieldControllers[productId]!["sgst"]!.text = data["sgst"] ?? "";
            }
          }
          if (responseData["Amount"] != null) {
            data["Amount"] = responseData["Amount"].toString();
            if (fieldControllers[productId]?["Amount"] != null) {
              fieldControllers[productId]!["Amount"]!.text =
                  data["Amount"] ?? "";
            }
          }
          previousUomValues[productId] = currentUom;
          responseProducts.refresh();
        } else {
          debugPrint("API returned error status: ${responseData["status"]}");
          Get.snackbar(
            "Error",
            "Calculation failed: ${responseData["message"]}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("Calculation HTTP Error: ${response.statusCode}");
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
    } finally {
      client.close();
    }
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
          total += double.tryParse(product["Amount"]?.toString() ?? "0") ?? 0.0;
        }
        billamt.value = total;
        Get.snackbar(
          "Success",
          "Data deleted successfully",
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        debugPrint("Failed to delete card: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        Get.snackbar(
          "Error",
          "Failed to delete card: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error deleting card: $e");
      Get.snackbar(
        "Error",
        "Failed to delete card: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> searchBaseProducts(String query) async {
    if (query.isEmpty) {
      baseProductResults.clear();
      return;
    }
    isSearchingBaseProduct.value = true;
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final data = {"category_id": "34", "searchbase": query};

    try {
      final response = await client.post(
        Uri.parse("$apiUrl/baseproducts_search"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("Base product response: ${responseData}");
        baseProductResults.value = responseData['base_products'] ?? [];
      } else {
        debugPrint("Failed to search base products: ${response.statusCode}");
        baseProductResults.clear();
      }
    } catch (e) {
      debugPrint("Error searching base products: $e");
      baseProductResults.clear();
    } finally {
      isSearchingBaseProduct.value = false;
      client.close();
    }
  }

  Widget uomDropdown(Map<String, dynamic> data) {
    String productId = data["id"].toString();
    Map<String, String>? options = uomOptions[productId];
    if (options == null || options.isEmpty) {
      return editableTextField(data, "UOM", (v) {
        data["UOM"] = v;
        debounceCalculation(data);
      });
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
        isExpanded: true,
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

  Widget editableTextField(
      Map<String, dynamic> data, String key, ValueChanged<String> onChanged) {
    final controller = getController(data, key);
    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: ["Basic Rate", "Amount", "qty", "sgst", "cgst"].contains(key),
        style: TextStyle(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
        controller: controller,
        keyboardType: [
          "Length",
          "Nos",
          "Basic Rate",
          "Amount",
          "SQMtr",
          "sgst",
          "cgst"
        ].contains(key)
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          data[key] = val;
          onChanged(val);
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
      ),
    );
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
      debugPrint("Created controller for [$key] with value: '$initialValue'");
    } else {
      final controller = fieldControllers[productId]![key]!;
      final dataValue = data[key]?.toString() ?? "";
      if (controller.text.isEmpty && dataValue.isNotEmpty && dataValue != "0") {
        controller.text = dataValue;
        debugPrint("Synced controller for [$key] to: '$dataValue'");
      }
    }
    return fieldControllers[productId]![key]!;
  }

  String getFieldValue(
      String productId, String fieldName, Map<String, dynamic> data) {
    String? value;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey(fieldName)) {
      value = fieldControllers[productId]![fieldName]!.text.trim();
      debugPrint("$fieldName from controller: '$value'");
    }
    if (value == null || value.isEmpty) {
      value = data[fieldName]?.toString();
      debugPrint("$fieldName from data: '$value'");
    }
    return value ?? "";
  }

  bool isValidNonZeroNumber(String value) {
    if (value.isEmpty) return false;
    double? parsedValue = double.tryParse(value);
    return parsedValue != null && parsedValue != 0.0;
  }

  void debounceCalculation(Map<String, dynamic> data) {
    debounceTimer?.cancel();
    debounceTimer = Timer(Duration(seconds: 1), () => performCalculation(data));
  }

  String selectedItems() {
    List<String> selectedValues = [
      if (selectedMaterialType.value.isNotEmpty)
        "Material: ${selectedMaterialType.value}",
      if (selectedThickness.value.isNotEmpty)
        "Thickness: ${selectedThickness.value}",
      if (selectedCoatingMass.value.isNotEmpty)
        "Coating Mass: ${selectedCoatingMass.value}",
      if (selectedYieldStrength.value.isNotEmpty)
        "Yield Strength: ${selectedYieldStrength.value}",
      if (selectedBrand.value.isNotEmpty) "Brand: ${selectedBrand.value}",
    ];
    return selectedValues.isEmpty
        ? "No selections yet"
        : selectedValues.join(",  ");
  }
}
