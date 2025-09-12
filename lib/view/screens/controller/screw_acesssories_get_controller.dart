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

class ScrewAccessoriesController extends GetxController {
  final Map<String, dynamic> data;
  ScrewAccessoriesController({required this.data});
  var billamt = 0.0.obs;

  var productList = <String>[].obs;
  var colorsList = <String>[].obs;
  var brandList = <String>[].obs;
  var selectedProduct = ''.obs;
  var selectedColor = ''.obs;
  var selectedBrand = ''.obs;
  var selectedProductBaseId = ''.obs;
  var selectedBaseProductName = ''.obs;
  var responseProducts = <dynamic>[].obs;
  var orderIDD = 0.obs;
  var orderNO = ''.obs;
  var fieldControllers = <String, Map<String, TextEditingController>>{}.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  @override
  void onClose() {
    fieldControllers.forEach((_, controllers) {
      controllers.forEach((_, controller) => controller.dispose());
    });
    super.onClose();
  }

  String selectedItems() {
    List<String> value = [
      if (selectedProduct.value.isNotEmpty) "Product: ${selectedProduct.value}",
      if (selectedColor.value.isNotEmpty) "Color: ${selectedColor.value}",
      if (selectedBrand.value.isNotEmpty) "Brand: ${selectedBrand.value}",
    ];
    return value.isEmpty ? "No selections yet" : value.join(",  ");
  }

  Future<void> fetchBrands() async {
    productList.clear();
    selectedProduct.value = '';
    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/9');

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        if (products is List) {
          productList.value = products
              .whereType<Map>()
              .map((e) => e["product_name"]?.toString())
              .whereType<String>()
              .toList();
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
    }
  }

  Future<void> fetchColors() async {
    if (selectedProduct.isEmpty) return;
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
          "base_product_filters": [selectedProduct.value],
          "base_label_filters": ["product_name"],
          "base_category_id": "9",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];
        if (colors is List) {
          colorsList.value = colors
              .whereType<Map>()
              .map((e) => e["color"]?.toString())
              .whereType<String>()
              .toList();
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

  Future<void> fetchBrand() async {
    if (selectedProduct.isEmpty || selectedColor.isEmpty) return;
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
          "base_product_filters": [selectedProduct.value, selectedColor.value],
          "base_label_filters": ["product_name", "color"],
          "base_category_id": "9",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        if (message is List && message.isNotEmpty) {
          final brandListData = message[0];
          if (brandListData is List) {
            brandList.value = brandListData
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
      "category_id": 9,
      "category_name": "Screw accessories",
      "OrderID": globalOrderManager.globalOrderId,
    };

    try {
      final response =
          await client.post(url, headers: headers, body: jsonEncode(data));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        billamt.value = jsonResponse["bill_total"]?.toDouble() ?? 0.0;

        final String orderId = jsonResponse["order_id"]?.toString() ?? '';
        final String orderNo =
            jsonResponse["order_no"]?.toString() ?? "Unknown";
        if (!globalOrderManager.hasGlobalOrderId()) {
          globalOrderManager.setGlobalOrderId(int.parse(orderId), orderNo);
        }
        orderIDD.value = globalOrderManager.globalOrderId!;
        orderNO.value = globalOrderManager.globalOrderNo!;
        if (jsonResponse['lebels'] != null &&
            jsonResponse['lebels'].isNotEmpty) {
          responseProducts.value = List<Map<String, dynamic>>.from(
              jsonResponse['lebels'][0]['data']);
          responseProducts.forEach((product) {
            String productId = product["id"].toString();
// Initialize CGST and SGST if not provided by API
            final amount =
                double.tryParse(product['Amount']?.toString() ?? '0') ?? 0;
            product['cgst'] = product['cgst'] ??
                (amount * 0.09).toStringAsFixed(2); // 9% CGST
            product['sgst'] = product['sgst'] ??
                (amount * 0.09).toStringAsFixed(2); // 9% SGST
            fieldControllers.putIfAbsent(
                productId,
                () => {
                      'Basic Rate': TextEditingController(
                          text: product['Basic Rate']?.toString() ?? '0'),
                      'Nos': TextEditingController(
                          text: product['Nos']?.toString() ?? '1'),
                      'Amount': TextEditingController(
                          text: product['Amount']?.toString() ?? '0'),
                      'cgst': TextEditingController(
                          text: product['cgst']?.toString() ?? '0'),
                      'sgst': TextEditingController(
                          text: product['sgst']?.toString() ?? '0'),
                    });
            calculateAmount(product);
          });
        }
        resetSelections();
        Get.snackbar(
          "Success",
          "Product added successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
// behavior: SnackBarBehavior.floating,
// shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to create order: ${response.statusCode}",
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

  void submitData() {
    if (selectedProduct.value.isEmpty || selectedColor.value.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Incomplete Form'),
          content: Text('Please fill all required fields to add a product.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    postAllData();
  }

  void resetSelections() {
    selectedProduct.value = '';
    selectedColor.value = '';
    selectedBrand.value = '';
    selectedProductBaseId.value = '';
    selectedBaseProductName.value = '';
    productList.clear();
    colorsList.clear();
    brandList.clear();
    fetchBrands();
  }

  Future<void> deleteCard(String deleteId) async {
    final url = Uri.parse('$apiUrl/enquirydelete/$deleteId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        responseProducts
            .removeWhere((product) => product["id"].toString() == deleteId);
        fieldControllers.remove(deleteId);
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

  void calculateAmount(Map<String, dynamic> product) {
    String productId = product["id"].toString();
    final rate = double.tryParse(
            fieldControllers[productId]?['Basic Rate']?.text ?? '0') ??
        0;
    final nos =
        double.tryParse(fieldControllers[productId]?['Nos']?.text ?? '0') ?? 0;
    final amount = (rate * nos).toStringAsFixed(2);
    product['Amount'] = amount;
    product['cgst'] =
        (double.parse(amount) * 0.09).toStringAsFixed(2); // 9% CGST
    product['sgst'] =
        (double.parse(amount) * 0.09).toStringAsFixed(2); // 9% SGST
    if (fieldControllers[productId]?['Amount'] != null) {
      fieldControllers[productId]!['Amount']!.text = amount;
    }
    if (fieldControllers[productId]?['cgst'] != null) {
      fieldControllers[productId]!['cgst']!.text = product['cgst'];
    }
    if (fieldControllers[productId]?['sgst'] != null) {
      fieldControllers[productId]!['sgst']!.text = product['sgst'];
    }
    update(); // Trigger UI update
  }

  Widget editableTextField(
    Map<String, dynamic> product,
    String key,
    ValueChanged<String> onChanged, {
    bool readOnly = false,
    required RxMap<String, Map<String, TextEditingController>> fieldControllers,
  }) {
    String productId = product["id"].toString();
    fieldControllers.putIfAbsent(productId, () => {});
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue =
          (product[key] != null && product[key].toString() != "0")
              ? product[key].toString()
              : "";
      fieldControllers[productId]![key] =
          TextEditingController(text: initialValue);
    } else {
      final controller = fieldControllers[productId]![key]!;
      final dataValue = product[key]?.toString() ?? "";
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
          "Basic Rate",
          "Nos",
          "Amount",
          "cgst",
          "sgst",
        ].contains(key)
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
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
}
