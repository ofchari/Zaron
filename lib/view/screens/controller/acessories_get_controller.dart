import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api_key.dart';

import '../global_user/global_oredrID.dart';
import '../global_user/global_user.dart';

class AccessoriesController extends GetxController {
  var billamt = 0.0.obs;
  var orderIDD = 0.obs;
  var selectedAccessories = Rxn<String>();
  var selectedBrands = Rxn<String>();
  var selectedColors = Rxn<String>();
  var selectedThickness = Rxn<String>();
  var selectedCoatingMass = Rxn<String>();
  var selectedProductBaseId = Rxn<String>();
  var accessoriesList = <String>[].obs;
  var brandandList = <String>[].obs;
  var colorandList = <String>[].obs;
  var thickAndList = <String>[].obs;
  var coatingAndList = <String>[].obs;
  var categoryMeta = Rxn<Map<String, dynamic>>();
  var rawAccessoriesData = <dynamic>[].obs;
  var responseProducts = <dynamic>[].obs;
  var uomOptions = <String, Map<String, String>>{}.obs;
  var apiResponseData = Rxn<Map<String, dynamic>>();
  var currentMainProductId = Rxn<String>();
  var categoryyName = Rxn<String>();
  var orderNoo = Rxn<String>();
  var baseProductResults = <String, List<dynamic>>{}.obs;
  var selectedBaseProducts = <String, String?>{}.obs;
  var isSearchingBaseProducts = <String, bool>{}.obs;
  var calculationResults = <String, dynamic>{}.obs;
  var previousUomValues = <String, String?>{}.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  var isBaseProductUpdated = false.obs;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchAccessories();
    fetchBrandData();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.onClose();
  }

  Future<void> fetchAccessories() async {
    accessoriesList.clear();
    selectedAccessories.value = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/1');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessories = data["message"]["message"][1];
        rawAccessoriesData.value = accessories;

        if (accessories is List) {
          final categoryInfoList = data["message"]["message"][0];
          if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
            categoryMeta.value = Map<String, dynamic>.from(categoryInfoList[0]);
          }

          accessoriesList.value = accessories
              .whereType<Map>()
              .map((e) => e["accessories_name"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching accessories: $e");
    } finally {
      client.close();
    }
  }

  Future<void> fetchBrandData() async {
    brandandList.clear();
    selectedBrands.value = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/1');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brandData = data["message"]["message"][2][1];

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
    } finally {
      client.close();
    }
  }

  Future<void> fetchColorData() async {
    if (selectedBrands.value == null) return;

    colorandList.clear();
    selectedColors.value = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "product_filters": [selectedAccessories.value],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [selectedBrands.value],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"][0];

        if (selectedThickness is List) {
          colorandList.value = selectedThickness
              .whereType<Map>()
              .map((e) => e["color"]?.toString())
              .whereType<String>()
              .toList();
        }
      }
    } catch (e) {
      print("Exception fetching colors: $e");
    } finally {
      client.close();
    }
  }

  Future<void> fetchThicknessData() async {
    if (selectedBrands.value == null) return;

    thickAndList.clear();
    selectedThickness.value = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "product_filters": [selectedAccessories.value],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [selectedBrands.value, selectedColors.value],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];

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
    } finally {
      client.close();
    }
  }

  Future<void> fetchCoatingMassData() async {
    if (selectedBrands.value == null ||
        selectedColors.value == null ||
        selectedThickness.value == null) {
      return;
    }

    coatingAndList.clear();
    selectedCoatingMass.value = null;

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "coating_mass",
          "product_filters": [selectedAccessories.value],
          "product_label_filters": ["accessories_name"],
          "product_category_id": 1,
          "base_product_filters": [
            selectedBrands.value,
            selectedColors.value,
            selectedThickness.value
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        if (message is List && message.length >= 2) {
          final coatingData = message[0];
          final idData = message[1];

          if (coatingData is List) {
            coatingAndList.value = coatingData
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId.value = idData.first["id"]?.toString();
          }
        }
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    } finally {
      client.close();
    }
  }

  Future<void> postAllData() async {
    if (selectedAccessories.value == null ||
        selectedBrands.value == null ||
        selectedColors.value == null ||
        selectedThickness.value == null ||
        selectedCoatingMass.value == null) {
      Get.snackbar("Error", "Please fill all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final matchingAccessory = rawAccessoriesData.firstWhere(
      (item) => item["accessories_name"] == selectedAccessories.value,
      orElse: () => null,
    );

    final accessoryID = matchingAccessory?["id"];
    final categoryId = categoryMeta.value?["category_id"];
    final categoryName = categoryMeta.value?["categories"];
    final globalOrderManager = GlobalOrderManager();

    final data = {
      "customer_id": UserSession().userId,
      "product_id": accessoryID,
      "product_name": selectedAccessories.value,
      "product_base_id": null,
      "product_base_name":
          "${selectedBrands.value},${selectedColors.value},${selectedThickness.value},${selectedCoatingMass.value},",
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId,
    };

    try {
      final response = await client.post(
        Uri.parse('$apiUrl/addbag'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String orderID = responseData["order_id"].toString();
        final String orderNo =
            responseData["order_no"]?.toString() ?? "Unknown";

        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNo);
        }

        orderIDD.value = globalOrderManager.globalOrderId!;
        orderNoo.value = globalOrderManager.globalOrderNo;
        apiResponseData.value = responseData;
        currentMainProductId.value = responseData["product_id"]?.toString();

        if (responseData["lebels"] != null &&
            responseData["lebels"].isNotEmpty) {
          String categoryName = responseData["category_name"] ?? "";
          categoryyName.value =
              categoryName.isEmpty ? "Accessories" : categoryName;

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
                  (product["UOM"]["options"] as Map).map((key, value) =>
                      MapEntry(key.toString(), value.toString())),
                );
              }
            }
          }
          responseProducts.addAll(newProducts);
        }

        Get.snackbar("Success", "Product added successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        resetSelections();
        fetchAccessories();
        fetchBrandData();
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Error adding product: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      client.close();
    }
  }

  Future<void> deleteCard(String deleteId) async {
    try {
      final response =
          await http.delete(Uri.parse('$apiUrl/enquirydelete/$deleteId'));
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((product) => product["id"].toString() == deleteId);
        Get.snackbar("Success", "Data deleted successfully",
            backgroundColor: Colors.red.shade400, colorText: Colors.white);
      } else {
        throw Exception("Failed to delete card with ID $deleteId");
      }
    } catch (e) {
      Get.snackbar("Error", "Error deleting card: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> searchBaseProducts(String query, String productId) async {
    if (query.isEmpty) {
      baseProductResults[productId] = [];
      return;
    }

    isSearchingBaseProducts[productId] = true;
    update();

    HttpClient client = HttpClient()
      ..badCertificateCallback = ((_, __, ___) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"category_id": "1", "searchbase": query};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/baseproducts_search"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        baseProductResults[productId] = responseData['base_products'] ?? [];
      } else {
        baseProductResults[productId] = [];
      }
    } catch (e) {
      print("Error searching base products for $productId: $e");
      baseProductResults[productId] = [];
    } finally {
      isSearchingBaseProducts[productId] = false;
      ioClient.close();
      update();
    }
  }

  Future<void> updateBaseProduct(String productId, String baseProduct) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = ((_, __, ___) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"id": productId, "base_product": baseProduct};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/baseproduct_update"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isBaseProductUpdated.value = true;
        Get.snackbar("Success", "Base product updated successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar(
            "Error", "Failed to update base product. Please try again.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Error updating base product: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      ioClient.close();
    }
  }

  void resetSelections() {
    selectedAccessories.value = null;
    selectedBrands.value = null;
    selectedColors.value = null;
    selectedThickness.value = null;
    selectedCoatingMass.value = null;
    accessoriesList.clear();
    brandandList.clear();
    colorandList.clear();
    thickAndList.clear();
    coatingAndList.clear();
  }

  void debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      performCalculation(data);
    });
  }

  Future<void> performCalculation(Map<String, dynamic> data) async {
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();
    String? currentUom = data["UOM"] is Map
        ? data["UOM"]["value"]?.toString()
        : data["UOM"]?.toString();

    double? profileValue;
    String? profileText = fieldControllers[productId]?["Profile"]?.text ??
        data["Profile"]?.toString();
    if (profileText != null && profileText.isNotEmpty) {
      profileValue = double.tryParse(profileText);
    }

    int nosValue = 0;
    String? nosText =
        fieldControllers[productId]?["Nos"]?.text ?? data["Nos"]?.toString();
    if (nosText != null && nosText.isNotEmpty) {
      nosValue = int.tryParse(nosText) ?? 1;
    }

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 1,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
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
          billamt.value = responseData["bill_total"].toDouble() ?? 0.0;
          calculationResults[productId] = responseData;

          if (responseData["Length"] != null) {
            data["Profile"] = responseData["Length"].toString();
            fieldControllers[productId]?["Profile"]?.text =
                responseData["Length"].toString();
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
          if (responseData["R.Ft"] != null) {
            data["R.Ft"] = responseData["R.Ft"].toString();
            fieldControllers[productId]?["R.Ft"]?.text =
                responseData["R.Ft"].toString();
          }
          if (responseData["bill_total"] != null) {
            data["bill_total"] = responseData["bill_total"].toString();
            fieldControllers[productId]?["bill_total"]?.text =
                responseData["bill_total"].toString();
          }
          if (responseData["cgst"] != null) {
            data["cgst"] = responseData["cgst"].toString();
            fieldControllers[productId]?["cgst"]?.text =
                responseData["cgst"].toString();
          }
          if (responseData["sgst"] != null) {
            data["sgst"] = responseData["sgst"].toString();
            fieldControllers[productId]?["sgst"]?.text =
                responseData["sgst"].toString();
          }
          if (responseData["Amount"] != null) {
            data["Amount"] = responseData["Amount"].toString();
            fieldControllers[productId]?["Amount"]?.text =
                responseData["Amount"].toString();
          }
          previousUomValues[productId] = currentUom;
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
    } finally {
      client.close();
    }
  }

  // Widget uomDropdown(Map<String, dynamic> data) {
  //   String productId = data["id"].toString();
  //   Map<String, String>? options = uomOptions[productId];
  //
  //   if (options == null || options.isEmpty) {
  //     return editableTextField(data, "UOM", (val) {
  //       data["UOM"] = val;
  //       debounceCalculation(data);
  //     }, fieldControllers: fieldControllers);
  //   }
  //
  //   String? currentValue = data["UOM"] is Map
  //       ? data["UOM"]["value"]?.toString()
  //       : data["UOM"]?.toString();
  //
  //   return SizedBox(
  //     height: 40.h,
  //     child: DropdownButtonFormField<String>(
  //       value: currentValue,
  //       items: options.entries
  //           .map((entry) =>
  //               DropdownMenuItem(value: entry.key, child: Text(entry.value)))
  //           .toList(),
  //       onChanged: (val) {
  //         data["UOM"] = {"value": val, "options": options};
  //         debounceCalculation(data);
  //       },
  //       decoration: InputDecoration(
  //         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //         border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(6),
  //             borderSide: BorderSide(color: Colors.grey[300]!)),
  //         enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(6),
  //             borderSide: BorderSide(color: Colors.grey[300]!)),
  //         focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(6),
  //             borderSide: BorderSide(color: Get.theme.primaryColor, width: 2)),
  //         filled: true,
  //         fillColor: Colors.grey[50],
  //       ),
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
              borderSide: BorderSide(color: Get.theme.primaryColor, width: 2)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget buildBaseProductSearchField(Map<String, dynamic> data) {
    String productId = data["id"].toString();

    fieldControllers.putIfAbsent(productId, () => {});
    baseProductResults.putIfAbsent(productId, () => []);
    selectedBaseProducts.putIfAbsent(productId, () => null);
    isSearchingBaseProducts.putIfAbsent(productId, () => false);
    if (!fieldControllers[productId]!.containsKey("BaseProduct")) {
      fieldControllers[productId]!["BaseProduct"] = TextEditingController();
    }

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Base Product",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 15),
            ),
            Gap(5),
            Container(
              height: 40.h,
              width: 200.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: fieldControllers[productId]!["BaseProduct"],
                decoration: InputDecoration(
                  hintText: "Search base product...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: isSearchingBaseProducts[productId]!
                      ? Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                ),
                onChanged: (value) => searchBaseProducts(value, productId),
              ),
            ),
            if (baseProductResults[productId]?.isNotEmpty ?? false)
              Container(
                width: 200.w,
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Search Results:",
                      style: GoogleFonts.figtree(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    ...baseProductResults[productId]!
                        .map((product) => GestureDetector(
                              onTap: () {
                                selectedBaseProducts[productId] =
                                    product.toString();
                                fieldControllers[productId]!["BaseProduct"]!
                                    .text = product.toString();
                                baseProductResults[productId] = [];
                                isBaseProductUpdated.value = false;
                                update();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                margin: EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 1))
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.inventory_2,
                                        size: 16, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Expanded(
                                        child: Text(product.toString(),
                                            style: GoogleFonts.figtree(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w400))),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 12, color: Colors.grey[400]),
                                  ],
                                ),
                              ),
                            )),
                  ],
                ),
              ),
            if (selectedBaseProducts[productId] != null)
              Container(
                width: 200.w,
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            "Selected: ${selectedBaseProducts[productId]}",
                            style: GoogleFonts.figtree(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87))),
                    GestureDetector(
                      onTap: () {
                        selectedBaseProducts[productId] = null;
                        fieldControllers[productId]!["BaseProduct"]!.clear();
                        baseProductResults[productId] = [];
                        update();
                      },
                      child:
                          Icon(Icons.close, color: Colors.grey[600], size: 20),
                    ),
                  ],
                ),
              ),
            if (selectedBaseProducts[productId] != null &&
                !isBaseProductUpdated.value)
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 200.w,
                child: ElevatedButton(
                  onPressed: () => updateBaseProduct(
                      productId, selectedBaseProducts[productId]!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "Update Base Product",
                    style: GoogleFonts.figtree(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ));
  }

  Widget editableTextField(
      Map<String, dynamic> data, String key, Function(String) onChanged,
      {bool readOnly = false,
      required Map<String, Map<String, TextEditingController>>
          fieldControllers}) {
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
        style: GoogleFonts.figtree(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15.sp),
        controller: fieldControllers[productId]![key],
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: (val) {
          if (val.trim().isNotEmpty) {
            final numVal = double.tryParse(val);
            if (numVal != null && numVal != 0) {
              data[key] = val;
              onChanged(val);
            }
          } else {
            data.remove(key);
          }
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
}
