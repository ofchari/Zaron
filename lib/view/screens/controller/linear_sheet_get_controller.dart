import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../universal_api/api_key.dart';
import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

class LinerSheetController extends GetxController {
  // New: Observable list for billing options
  var billingOptionsList = <Map<String, dynamic>>[].obs;
  var selectedProduct = ''.obs;
  var selectedBrands = ''.obs;
  var selectedColors = ''.obs;
  var selectedThickness = ''.obs;
  var selectedCoatingMass = ''.obs;
  var selectedProductBaseId = ''.obs;
  var apiResponseData = <String, dynamic>{}.obs;
  var productList = <String>[].obs;
  var brandandList = <String>[].obs;
  var colorandList = <String>[].obs;
  var thickAndList = <String>[].obs;
  var coatingAndList = <String>[].obs;
  var rawLiner = <dynamic>[].obs;
  var categoryMeta = <String, dynamic>{}.obs;
  var billamt = 0.0.obs;
  var orderNO = ''.obs;
  var orderIDD = 0.obs;
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var availableLengths = <String, List<String>>{}.obs;
  var selectedLengths = <String, String?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductName();
    fetchBrandData();
    // fetchBillingOptions(); //
  }

  // // New: Placeholder method to fetch billing options (adjust URL/body as needed)
  // Future<void> fetchBillingOptions() async {
  //   final client =
  //       IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
  //   final url = Uri.parse(
  //       '$apiUrl/billingoptions'); // Assume an API endpoint; replace with real one
  //
  //   try {
  //     final response = await client.get(url); // Or post if needed
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       billingOptionsList.value = List<Map<String, dynamic>>.from(
  //           data["message"]["options"] ?? []); // Adjust based on API response
  //     } else {
  //       Get.snackbar("Error", "Failed to fetch billing options",
  //           backgroundColor: Colors.red);
  //     }
  //   } catch (e) {
  //     print("Exception fetching billing options: $e");
  //     // Provide default options if API fails
  //     billingOptionsList.value = [
  //       {"id": "1", "name": "Option 1"},
  //       {"id": "2", "name": "Option 2"},
  //     ];
  //   }
  // }

  Future<void> fetchProductName() async {
    productList.clear();
    selectedProduct.value = '';
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/590');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        debugPrint("Products: $products");
        debugPrint(response.body, wrapWidth: 1024);
        rawLiner.value = products;

        if (products is List) {
          categoryMeta.value =
              Map<String, dynamic>.from(data["message"]["message"][0][0]);
          productList.value = products
              .whereType<Map>()
              .map((e) => e["product_name"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching products: $e");
    }
  }

  Future<void> fetchBrandData() async {
    brandandList.clear();
    selectedBrands.value = '';
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/590');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brandData = data["message"]["message"][2][1];
        debugPrint(response.body);

        if (brandData is List) {
          brandandList.value = brandData
              .whereType<Map>()
              .map((e) => e["brand"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  Future<void> fetchColorData() async {
    if (selectedBrands.isEmpty) return;
    colorandList.clear();
    selectedColors.value = '';
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 590,
          "base_product_filters": [selectedBrands.value],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colorData = data["message"]["message"][0];
        print("Fetching colors for brand: ${selectedBrands.value}");
        print("API response: ${response.body}");

        if (colorData is List) {
          colorandList.value = colorData
              .whereType<Map>()
              .map((e) => e["color"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching colors: $e");
    }
  }

  Future<void> fetchThicknessData() async {
    if (selectedBrands.isEmpty) return;
    thickAndList.clear();
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
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 590,
          "base_product_filters": [selectedBrands.value, selectedColors.value],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        print("Fetching thickness for color: ${selectedColors.value}");
        print("API response: ${response.body}");

        if (thickness is List) {
          thickAndList.value = thickness
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

  Future<void> fetchCoatingMassData() async {
    if (selectedBrands.isEmpty) return;
    coatingAndList.clear();
    selectedCoatingMass.value = '';
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "coating_mass",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 590,
          "base_product_filters": [
            selectedBrands.value,
            selectedColors.value,
            selectedThickness.value,
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print("Fetching coating_mass for brand: ${selectedBrands.value}");
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          final coatingList = message[0];
          if (coatingList is List) {
            coatingAndList.value = coatingList
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
          }

          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId.value = idData.first["id"]?.toString() ?? '';
            print("Selected Product Base ID: ${selectedProductBaseId.value}");
          }
        }
      }
    } catch (e) {
      print("Exception fetching coating_mass: $e");
    }
  }

  Future<void> fetchAvailableLengths(String productId) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "length",
          "product_filters": [selectedProduct.value],
          "product_label_filters": ["product_name"],
          "product_category_id": 590,
          "base_product_filters": [
            selectedBrands.value,
            selectedColors.value,
            selectedThickness.value,
            selectedCoatingMass.value,
          ],
          "base_label_filters": ["brand", "color", "thickness", "coating_mass"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lengthData = data["message"]["message"][0];
        if (lengthData is List) {
          availableLengths[productId] = lengthData
              .whereType<Map>()
              .map((e) => e["length"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching lengths: $e");
    }
  }

  Future<void> postAllData() async {
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/addbag');
    final globalOrderManager = GlobalOrderManager();

    final headers = {"Content-Type": "application/json"};
    final matchingAccessory = rawLiner.firstWhere(
      (item) => item["product_name"] == selectedProduct.value,
      orElse: () => null,
    );
    final linerProID = matchingAccessory?["id"];
    print("this is $linerProID");
    final data = {
      "customer_id": UserSession().userId,
      "product_id": linerProID,
      "product_name": selectedProduct.value,
      "product_base_id": selectedProductBaseId.value,
      "product_base_name":
          "${selectedBrands.value},${selectedColors.value},${selectedThickness.value}",
      "category_id": categoryMeta["category_id"],
      "category_name": categoryMeta["categories"],
      "OrderID": globalOrderManager.globalOrderId
    };

    try {
      final response =
          await client.post(url, headers: headers, body: jsonEncode(data));

      debugPrint("This is a response: ${response.body}");

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
                fetchAvailableLengths(
                    productId); // Fetch lengths for new product
              }

              if (product["UOM"] != null && product["UOM"]["options"] != null) {
                uomOptions[productId] = Map<String, String>.from(
                  (product["UOM"]["options"] as Map).map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  ),
                );
              }

              debugPrint(
                  "Product added: ${product["id"]} - ${product["Products"]}");
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
    selectedProduct.value = '';
    selectedBrands.value = '';
    selectedColors.value = '';
    selectedThickness.value = '';
    selectedCoatingMass.value = '';
    colorandList.clear();
    thickAndList.clear();
    coatingAndList.clear();
    fieldControllers.clear(); // New: Clear controllers to avoid stale data
    previousUomValues.clear();
    calculationResults.clear();
    availableLengths.clear();
    selectedLengths.clear();
    fetchProductName(); // Re-fetch
    fetchBrandData();
  }

  String selectedItems() {
    List<String> value = [
      if (selectedProduct.value.isNotEmpty) "Product: ${selectedProduct.value}",
      if (selectedBrands.value.isNotEmpty) "Brand: ${selectedBrands.value}",
      if (selectedColors.value.isNotEmpty) "Color: ${selectedColors.value}",
      if (selectedThickness.value.isNotEmpty)
        "Thickness: ${selectedThickness.value}",
      if (selectedCoatingMass.value.isNotEmpty)
        "Coating Mass: ${selectedCoatingMass.value}",
    ];
    return value.isEmpty ? "No selection yet" : value.join(",  ");
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
        availableLengths.remove(deleteId);
        selectedLengths.remove(deleteId);
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

    double profileValue = _isValidNonZeroNumber(lengthText)
        ? (double.tryParse(lengthText) ?? 0.0)
        : 0.0;
    int nosValue =
        _isValidNonZeroNumber(nosText) ? (int.tryParse(nosText) ?? 1) : 1;

    int? billingOptionId = data["billing_option_id"] != null
        ? int.tryParse(data["billing_option_id"])
        : null;

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 590,
      "product": data["Products"]?.toString() ?? "",
      "height": 0.0,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
      "billing_option": billingOptionId,
    };

    try {
      final response = await client.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody));
      if (response.statusCode == 200) {
        print("input data $requestBody");
        print("ou ${response.body}");
        final responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          if (responseData["profile"] != null) {
            data["Length"] = responseData["profile"].toString();
            fieldControllers[productId]?["Length"]?.text = data["Length"] ?? "";
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
      }
    } catch (e) {
      print("Calculation API Error: $e");
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
    String? currentValue = selectedLengths[productId];

    availableLengths.putIfAbsent(productId, () => <String>[]);

    if (availableLengths[productId]!.isEmpty) {
      fetchAvailableLengths(productId);
      availableLengths[productId] = ['1.0', '2.0', '3.0', '4.0', '5.0'];
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      items: availableLengths[productId]!
          .map((length) => DropdownMenuItem(
                value: length,
                child: Text(length),
              ))
          .toList(),
      onChanged: (val) {
        selectedLengths[productId] = val;
        data['Length'] = val;
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
    Function(String) onChanged, {
    bool readOnly = false,
    required Map<String, Map<String, TextEditingController>> fieldControllers,
  }) {
    String productId = data["id"].toString();
    fieldControllers.putIfAbsent(productId, () => {});
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null &&
              data[key].toString() != "0" &&
              data[key].toString() != "null")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] =
          TextEditingController(text: initialValue);
      debugPrint("Created controller for [$key] with value: '$initialValue'");
    }
    final controller = fieldControllers[productId]![key]!;
    if (controller.text.isEmpty &&
        data[key] != null &&
        data[key].toString() != "0" &&
        data[key].toString() != "null") {
      controller.text = data[key].toString();
      debugPrint("Synced controller for [$key] to: '${data[key]}'");
    }

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
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
