import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:zaron/view/screens/global_user/global_user.dart';

import '../../../universal_api/api&key.dart';

class DeliveryScopeBottomSheet extends StatefulWidget {
  final DateTime deliveryDate;
  final TimeOfDay deliveryTime;
  final String id;
  final Map<String, dynamic> rowData;

  const DeliveryScopeBottomSheet({
    super.key,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.rowData,
    required this.id,
  });

  @override
  State<DeliveryScopeBottomSheet> createState() =>
      _DeliveryScopeBottomSheetState();
}

class _DeliveryScopeBottomSheetState extends State<DeliveryScopeBottomSheet> {
  String? deliveryScope = 'Zaron';
  String? paymentMode = 'Cash';
  String customerAddressId = '';

  /// Post the  Customer Address //
  Future<void> postCustomerAddress() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final headers = {"Content-Type": "application/json"};
    final payload = {
      "customer_id": UserSession().userId,
    };
    print("User Input Data Fields$payload");
    print(widget.id);

    final url = "$apiUrl/customer_address";
    final body = json.encode(payload);

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print("This is the status code${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressList = data['customeradddrss'] as List;
        if (addressList.isNotEmpty) {
          customerAddressId = addressList[0]['id'].toString();
          print("Customer Address ID: $customerAddressId");
        }
        print("this is a post Data response : ${response.body}");
        Get.snackbar(
          "Customer Address",
          "Data Successfully Posted",
          colorText: Colors.white,
          backgroundColor: Colors.green,
        );
        print("this is a post Data response : ${response.body}");
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  /// Post the Move Quotation //
  bool isPosting = false;

  Future<void> postMoveQuotation() async {
    if (!mounted) return;

    setState(() {
      isPosting = true;
    });

    try {
      await postCustomerAddress();

      if (!mounted) return; // Re-check before accessing context

      if (customerAddressId.isNotEmpty) {
        final payload = {
          "customer_id": UserSession().userId,
          "customer_address_id": customerAddressId,
          "order_id": widget.id,
          "delivery_status": deliveryScope == 'Zaron' ? "2" : "1",
          "payment_mode": paymentMode,
          "delivery_date": DateFormat('yyyy-MM-dd').format(widget.deliveryDate),
          "delivery_time": widget.deliveryTime.format(context),
        };

        final headers = {"Content-Type": "application/json"};
        final url = "$apiUrl/createorder";
        final body = json.encode(payload);
        print("User Input Data Fields: $payload");

        final response =
            await http.post(Uri.parse(url), headers: headers, body: body);
        print("Status: ${response.statusCode}");

        if (response.statusCode == 200 && mounted) {
          print("Response: ${response.body}");
          Get.snackbar("Success", "Move to  Order \n created successfully",
              colorText: Colors.white, backgroundColor: Colors.green);
        } else {
          throw Exception(
              "Server returned status code: ${response.statusCode}");
        }
      } else {
        throw Exception("Customer address ID not found");
      }
    } catch (e) {
      print("Error in postMoveQuotation: $e");
      if (mounted) {
        Get.snackbar("Error", "Failed to create order: $e",
            colorText: Colors.white, backgroundColor: Colors.red);
      }
      rethrow; // Re-throw so the calling code can handle it
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade600,
                  Colors.green.shade800,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery Scope & Payment",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Configure delivery scope and payment method",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  // Delivery Scope
                  Text(
                    "Delivery Scope",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => deliveryScope = 'Zaron'),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: deliveryScope == 'Zaron'
                                  ? Colors.orange.shade50
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: deliveryScope == 'Zaron'
                                    ? Colors.orange.shade400
                                    : Colors.grey.shade300,
                                width: deliveryScope == 'Zaron' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.delivery_dining,
                                  color: deliveryScope == 'Zaron'
                                      ? Colors.orange.shade600
                                      : Colors.grey.shade600,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Zaron Scope",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: deliveryScope == 'Zaron'
                                        ? Colors.orange.shade800
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "We handle the delivery",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Radio<String>(
                                  value: 'Zaron',
                                  groupValue: deliveryScope,
                                  onChanged: (value) =>
                                      setState(() => deliveryScope = value),
                                  activeColor: Colors.orange.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => deliveryScope = 'Client'),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: deliveryScope == 'Client'
                                  ? Colors.purple.shade50
                                  : Colors.grey.shade50,
                              border: Border.all(
                                color: deliveryScope == 'Client'
                                    ? Colors.purple.shade400
                                    : Colors.grey.shade300,
                                width: deliveryScope == 'Client' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_pin_circle,
                                  color: deliveryScope == 'Client'
                                      ? Colors.purple.shade600
                                      : Colors.grey.shade600,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Client Scope",
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: deliveryScope == 'Client'
                                        ? Colors.purple.shade800
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Client will pickup",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Radio<String>(
                                  value: 'Client',
                                  groupValue: deliveryScope,
                                  onChanged: (value) =>
                                      setState(() => deliveryScope = value),
                                  activeColor: Colors.purple.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Payment Mode
                  Text(
                    "Payment Method",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      border:
                          Border.all(color: Colors.indigo.shade200, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: paymentMode,
                        isExpanded: true,
                        icon: Icon(Icons.expand_more,
                            color: Colors.indigo.shade600),
                        onChanged: (value) =>
                            setState(() => paymentMode = value),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.indigo.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        items: [
                          ('Cash', Icons.money),
                          ('Cheque', Icons.receipt),
                          ('Bank Transfer / Online', Icons.account_balance),
                          ('No Collection', Icons.block),
                        ]
                            .map((item) => DropdownMenuItem(
                                  value: item.$1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.$2,
                                        color: Colors.indigo.shade600,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(item.$1),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Back",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isPosting
                        ? null
                        : () async {
                            // Disable button while posting
                            if (deliveryScope == null) {
                              Get.snackbar(
                                "Error",
                                "Please select a delivery scope",
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            if (paymentMode == null) {
                              Get.snackbar(
                                "Error",
                                "Please select a payment method",
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                              );
                              return;
                            }

                            try {
                              await postMoveQuotation(); // Wait for the operation to complete
                              if (mounted) {
                                // Check if widget is still mounted before navigating
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              // Handle any errors
                              Get.snackbar(
                                "Error",
                                "Failed to process request: $e",
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isPosting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const Icon(Icons.check_circle,
                              color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isPosting ? "Processing..." : "Next",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
