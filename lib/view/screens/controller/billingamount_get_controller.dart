import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zaron/view/screens/global_user/global_oredrID.dart';
import 'package:zaron/view/universal_api/api_key.dart';

class BillAmountController extends GetxController {
  var billOrderData = {}.obs;
  final globalOrderManager = GlobalOrderManager();

  @override
  void onInit() {
    super.onInit();
    fetchOrder();
  }

  Future<void> fetchOrder() async {
    final orderId = globalOrderManager.globalOrderId;
    if (orderId == null || orderId.toString().isEmpty) {
      print("⚠️ Order ID is null or empty, cannot fetch order.");
      return;
    }

    final url = Uri.parse("$apiUrl/order_bill/$orderId");
    print("🔗 Fetching order from: $url");

    try {
      final response = await http.get(url);
      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        billOrderData.value = jsonDecode(response.body);
      } else {
        Get.snackbar("Error", "Failed to load order");
      }
    } catch (e) {
      print("❌ API Call Failed: $e");
    }
  }
}
