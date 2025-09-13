// tile_sheet_controller.dart
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

class TileSheetController extends GetxController {
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var billamt = 0.0.obs;
  var orderNO = ''.obs;
  var orderIDD = 0.obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var materialList = <String>[].obs;
  var brandList = <String>[].obs;
  var colorList = <String>[].obs;
  var thicknessList = <String>[].obs;
  var coatingMassList = <String>[].obs;
  var selectedMaterial = ''.obs;
  var selectedBrand = ''.obs;
  var selectedColor = ''.obs;
  var selectedThickness = ''.obs;
  var selectedCoatingMass = ''.obs;
  var selectedProductBaseId = ''.obs;
  var rawTilesheet = <dynamic>[].obs;
  var apiProductsList = <Map<String, dynamic>>[].obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var availableLengths = <String, List<String>>{}.obs;
  var selectedLengths = <String, String?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMaterialType();
    fetchBrandData();
  }

  // Method to display selected items
  String selectedItems() {
    print(
        "selectedItems called - Material: ${selectedMaterial.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}, Thickness: ${selectedThickness.value}, CoatingMass: ${selectedCoatingMass.value}");
    List<String> items = [];
    if (selectedMaterial.value.isNotEmpty) {
      items.add("Material Type: ${selectedMaterial.value}");
    }
    if (selectedBrand.value.isNotEmpty) {
      items.add("Brand: ${selectedBrand.value}");
    }
    if (selectedColor.value.isNotEmpty) {
      items.add("Color: ${selectedColor.value}");
    }
    if (selectedThickness.value.isNotEmpty) {
      items.add("Thickness: ${selectedThickness.value}");
    }
    if (selectedCoatingMass.value.isNotEmpty) {
      items.add("CoatingMass: ${selectedCoatingMass.value}");
    }
    String result = items.isNotEmpty ? items.join(" | ") : "No selections made";
    print("selectedItems result: $result");
    return result;
  }

  Future<void> fetchMaterialType() async {
    materialList.clear();
    selectedMaterial.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/26');

    try {
      final response = await client.get(url);
      print("fetchMaterialType response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][1];
        rawTilesheet.value = materials;

        if (materials is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }
          materialList.value = materials
              .whereType<Map>()
              .map((e) => e["material_type"]?.toString())
              .whereType<String>()
              .toList();
          print("materialList updated: ${materialList.value}");
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch materials: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception fetching materials: $e");
      Get.snackbar(
        "Error",
        "Failed to fetch materials: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchBrandData() async {
    brandList.clear();
    selectedBrand.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/26');

    try {
      final response = await client.get(url);
      print("fetchBrandData response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brandData = data["message"]["message"][2][1];
        if (brandData is List) {
          brandList.value = brandData
              .whereType<Map>()
              .map((e) => e["brand"]?.toString())
              .whereType<String>()
              .toList();
          print("brandList updated: ${brandList.value}");
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
    }
  }

  Future<void> fetchColorData() async {
    if (selectedMaterial.value.isEmpty || selectedBrand.value.isEmpty) return;
    colorList.clear();
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
          "product_filters": [selectedMaterial.value],
          "product_label_filters": ["material_type"],
          "product_category_id": 26,
          "base_product_filters": [selectedBrand.value],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
        }),
      );
      print("fetchColorData response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];
        if (colors is List) {
          colorList.value = colors
              .whereType<Map>()
              .map((e) => e["color"]?.toString())
              .whereType<String>()
              .toList();
          print("colorList updated: ${colorList.value}");
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
    }
  }

  Future<void> fetchThicknessData() async {
    if (selectedMaterial.value.isEmpty ||
        selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty) return;
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
          "product_filters": [selectedMaterial.value],
          "product_label_filters": ["material_type"],
          "product_category_id": 26,
          "base_product_filters": [selectedBrand.value, selectedColor.value],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
        }),
      );
      print("fetchThicknessData response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        if (thickness is List) {
          thicknessList.value = thickness
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

  Future<void> fetchCoatingMassData() async {
    if (selectedMaterial.value.isEmpty ||
        selectedBrand.value.isEmpty ||
        selectedColor.value.isEmpty ||
        selectedThickness.value.isEmpty) return;
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
          "product_filters": [selectedMaterial.value],
          "product_label_filters": ["material_type"],
          "product_category_id": 26,
          "base_product_filters": [
            selectedBrand.value,
            selectedColor.value,
            selectedThickness.value,
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": 3,
        }),
      );
      print("fetchCoatingMassData response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        if (message is List && message.isNotEmpty) {
          final coatingList = message[0];
          if (coatingList is List) {
            coatingMassList.value = coatingList
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
            print("coatingMassList updated: ${coatingMassList.value}");
          }

          // Extract product_base_id
          final baseIdData = message.length > 1 ? message[1] : null;
          if (baseIdData is List &&
              baseIdData.isNotEmpty &&
              baseIdData.first is Map) {
            selectedProductBaseId.value =
                baseIdData.first["id"]?.toString() ?? '';
            print("Selected Product Base ID: ${selectedProductBaseId.value}");
          }
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
    }
  }

  Future<void> postAllData() async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/addbag');
    final globalOrderManager = GlobalOrderManager();
    final headers = {"Content-Type": "application/json"};

    // Find the matching item from rawTilesheet
    final matchingAccessory = rawTilesheet.firstWhereOrNull(
      (item) => item["material_type"] == selectedMaterial.value,
    );
    final tileSheetProID = matchingAccessory?["id"];

    final data = {
      "customer_id": UserSession().userId,
      "product_id": tileSheetProID,
      "product_name": selectedMaterial.value,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name":
          "${selectedBrand.value},${selectedColor.value},${selectedThickness.value}",
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
    selectedMaterial.value = '';
    selectedBrand.value = '';
    selectedColor.value = '';
    selectedThickness.value = '';
    selectedCoatingMass.value = '';
    selectedProductBaseId.value = '';
    colorList.clear();
    thicknessList.clear();
    coatingMassList.clear();
    print(
        "After reset - Material: ${selectedMaterial.value}, Brand: ${selectedBrand.value}, Color: ${selectedColor.value}");
    fetchMaterialType();
    fetchBrandData();
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
        availableLengths.remove(deleteId);
        selectedLengths.remove(deleteId);
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

//part 1
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

    // Get Length value from selected dropdown
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
        _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 1) : 1;

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 26,
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
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      print("performCalculation response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          // Extract available lengths from profile array
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
          }

          // Handle other calculated fields
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

          if (responseData["rate"] != null) {
            data["Basic Rate"] = responseData["rate"].toString();
            if (fieldControllers[productId]?["Basic Rate"] != null) {
              fieldControllers[productId]!["Basic Rate"]!.text =
                  responseData["rate"].toString();
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
          "sgst"
        ].contains(key)
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
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
