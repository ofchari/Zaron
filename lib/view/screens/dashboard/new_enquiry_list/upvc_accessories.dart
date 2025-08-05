import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';

import '../../../widgets/text.dart';
import '../../global_user/global_oredrID.dart';
import '../../global_user/global_user.dart';

class UpvcAccessories extends StatefulWidget {
  const UpvcAccessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<UpvcAccessories> createState() => _UpvcAccessoriesState();
}

class _UpvcAccessoriesState extends State<UpvcAccessories> {
  late TextEditingController editController;
  Map<String, dynamic>? categoryMeta;
  int? billamt;
  String? selectedProductBaseId;
  int? orderIDD;
  String? orderNO;
  String? selectedBrand;
  String? selectedColor;
  String? selectProductNameBase;
  String? selectedSize;
  String? selectedBaseProductName;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> productList = [];
  List<String> sizeList = [];
  List<Map<String, dynamic>> submittedData = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchProductName();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductName() async {
    setState(() {
      productList = [];
      selectProductNameBase = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/15');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final product = data["message"]["message"][1];
        print(response.body);

        if (product is List) {
          setState(() {
            ///  Extract category info (message[0][0])
            final categoryInfoList = data["message"]["message"][0];
            if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
              categoryMeta = Map<String, dynamic>.from(categoryInfoList[0]);
            }
            productList = product
                .whereType<Map>()
                .map((e) => e["product_name_base"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  /// fetch brand Api's //
  Future<void> _fetchbrand() async {
    if (selectProductNameBase == null) return;

    setState(() {
      brandsList = [];
      selectedBrand = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "category_id": "15",
          // "selectedlabel": "product_name_base",
          // "selectedvalue": selectProductNameBase,
          // "label_name": "brand",
          "base_category_id": "15",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_label_filters": ["product_name_base"],
          "base_product_filters": [selectProductNameBase],
          "product_label": "brand",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brands = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (brands is List) {
          setState(() {
            brandsList = brands
                .whereType<Map>()
                .map((e) => e["brand"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

  // /// fetch Color Api's ///
  Future<void> _fetchColor() async {
    if (selectProductNameBase == null) return;

    setState(() {
      colorsList = [];
      selectedColor = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "category_id": "15",
          // "selectedlabel": "brand",
          // "selectedvalue": selectedBrand,
          // "label_name": "color",
          "base_category_id": "15",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_label_filters": ["product_name_base", "brand"],
          "base_product_filters": [selectProductNameBase, selectedBrand],
          "product_label": "color",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final color = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (color is List) {
          setState(() {
            colorsList = color
                .whereType<Map>()
                .map((e) => e["color"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching color: $e");
    }
  }

  /// fetch Sizes Api's ///
  Future<void> _fetchSize() async {
    if (selectProductNameBase == null ||
        selectedBrand == null ||
        selectedColor == null ||
        !mounted) return;

    setState(() {
      sizeList = [];
      selectedSize = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "base_category_id": "15",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_label_filters": ["product_name_base", "brand", "color"],
          "base_product_filters": [
            selectProductNameBase,
            selectedBrand,
            selectedColor,
          ],
          "product_label": "SIZE",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        print("Full API Response: $message");

        if (message is List && message.length >= 2) {
          final sizeData = message[0];
          final idData = message[1];

          if (sizeData is List) {
            setState(() {
              sizeList = sizeData
                  .whereType<Map>()
                  .map((e) => e["SIZE"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName = idData.first["base_product_id"]
                ?.toString(); // <-- Add this line
            debugPrint(
              "Selected Base Product ID (SIZE): $selectedProductBaseId",
            );
            debugPrint(
              "Base Product Name (SIZE): $selectedBaseProductName",
            ); // <-- Optional debug
          }
        } else {
          debugPrint("Unexpected message format for SIZE.");
        }
      } else {
        debugPrint("Failed to fetch size data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching size: $e");
    }
  }

  // 1. ADD THESE NEW VARIABLES at the top of your _UpvcAccessoriesState class (around line 25)
  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];

  // 2. MODIFY the postAllData() method - REPLACE the existing method with this:
  Future<void> postAllData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    // From saved categoryMeta
    final categoryId = categoryMeta?["category_id"];
    final categoryName = categoryMeta?["categories"];
    print("this os $categoryId");
    print("this os $categoryName");

    // Use global order ID if available, otherwise null for first time
    final globalOrderManager = GlobalOrderManager();
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": categoryId,
      "category_name": categoryName,
      "OrderID": globalOrderManager.globalOrderId
    };

    print("This is a body data: $data");
    final url = "$apiUrl/addbag";
    final body = jsonEncode(data);
    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      debugPrint("This is a response: ${response.body}");
      if (selectedBrand == null ||
          selectedColor == null ||
          selectProductNameBase == null ||
          selectedSize == null) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          final String orderID = responseData["order_id"]?.toString() ?? "";
          orderIDD = int.tryParse(orderID);
          orderNO = responseData["order_no"]?.toString() ?? "Unknown";
          // Set global order ID if this is the first time
          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNO!);
          }

          // Update local variables
          orderIDD = globalOrderManager.globalOrderId;
          orderNO = globalOrderManager.globalOrderNo;
          apiResponseData = responseData;

          // Safely handle the response data
          if (responseData['lebels'] != null &&
              responseData['lebels'].isNotEmpty) {
            List<dynamic> fullList = responseData["lebels"][0]["data"];
            List<Map<String, dynamic>> newProducts = [];

            for (var item in fullList) {
              if (item is Map<String, dynamic>) {
                Map<String, dynamic> product = Map<String, dynamic>.from(item);

                // Prevent duplicates using product["id"]
                String productId = product["id"].toString();
                bool alreadyExists = responseProducts
                    .any((existing) => existing["id"].toString() == productId);

                if (!alreadyExists) {
                  newProducts.add(product);
                  debugPrint(
                      "Product added: ${product["id"]} - ${product["Products"]}");
                }
              }
            }

            // Append only non-duplicate products
            responseProducts.addAll(newProducts);
          }
        });
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  ///delete cards ///
  Future<void> deleteCards(String deleteId) async {
    final url = '$apiUrl/enquirydelete/$deleteId';
    try {
      final response = await http.delete(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        print("delee response ${response.statusCode}");
      } else {
        throw Exception("Failed to delete card with ID $deleteId");
      }
    } catch (e) {
      print("Error deleting card: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting card: $e")),
      );
    }
  }

  /// Base Product Search Functionality ///
  TextEditingController baseProductController = TextEditingController();
  List<dynamic> baseProductResults = [];
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();

  // // Add this method for searching base products
  // Future<void> searchBaseProducts(String query) async {
  //   if (query.isEmpty) {
  //     setState(() {
  //       baseProductResults = [];
  //     });
  //     return;
  //   }
  //
  //   setState(() {
  //     isSearchingBaseProduct = true;
  //   });
  //
  //   HttpClient client = HttpClient();
  //   client.badCertificateCallback =
  //       ((X509Certificate cert, String host, int port) => true);
  //   IOClient ioClient = IOClient(client);
  //   final headers = {"Content-Type": "application/json"};
  //   final data = {"category_id": "15", "searchbase": query};
  //
  //   try {
  //     final response = await ioClient.post(
  //       Uri.parse("$apiUrl/api/baseproducts_search"),
  //       headers: headers,
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       print("Base product response: $responseData"); // Debug print
  //       setState(() {
  //         baseProductResults = responseData['base_products'] ?? [];
  //         isSearchingBaseProduct = false;
  //       });
  //     } else {
  //       setState(() {
  //         baseProductResults = [];
  //         isSearchingBaseProduct = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error searching base products: $e");
  //     setState(() {
  //       baseProductResults = [];
  //       isSearchingBaseProduct = false;
  //     });
  //   }
  // }
  //
  // // Add this method to build the base product search field
  // Widget _buildBaseProductSearchField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Base Product",
  //         style: GoogleFonts.figtree(
  //           fontSize: 16,
  //           fontWeight: FontWeight.w500,
  //           color: Colors.black87,
  //         ),
  //       ),
  //       SizedBox(height: 8),
  //       Container(
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey[300]!),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: TextField(
  //           controller: baseProductController,
  //           focusNode: baseProductFocusNode,
  //           decoration: InputDecoration(
  //             hintText: "Search base product...",
  //             prefixIcon: Icon(Icons.search),
  //             border: InputBorder.none,
  //             contentPadding: EdgeInsets.symmetric(
  //               horizontal: 16,
  //               vertical: 12,
  //             ),
  //             suffixIcon: isSearchingBaseProduct
  //                 ? Padding(
  //                     padding: EdgeInsets.all(12),
  //                     child: SizedBox(
  //                       width: 20,
  //                       height: 20,
  //                       child: CircularProgressIndicator(strokeWidth: 2),
  //                     ),
  //                   )
  //                 : null,
  //           ),
  //           onChanged: (value) {
  //             searchBaseProducts(value);
  //           },
  //           onTap: () {
  //             if (baseProductController.text.isNotEmpty) {
  //               searchBaseProducts(baseProductController.text);
  //             }
  //           },
  //         ),
  //       ),
  //
  //       // Search Results Display (line by line, not dropdown)
  //       if (baseProductResults.isNotEmpty)
  //         Container(
  //           margin: EdgeInsets.only(top: 8),
  //           padding: EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[50],
  //             border: Border.all(color: Colors.grey[300]!),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "Search Results:",
  //                 style: GoogleFonts.figtree(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               ...baseProductResults.map((product) {
  //                 return GestureDetector(
  //                   onTap: () {
  //                     setState(() {
  //                       selectedBaseProduct = product.toString();
  //                       baseProductController.text = selectedBaseProduct!;
  //                       baseProductResults = [];
  //                     });
  //                   },
  //                   child: Container(
  //                     width: double.infinity,
  //                     padding: EdgeInsets.symmetric(
  //                       vertical: 12,
  //                       horizontal: 12,
  //                     ),
  //                     margin: EdgeInsets.only(bottom: 6),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(6),
  //                       border: Border.all(color: Colors.grey[300]!),
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.grey.withOpacity(0.1),
  //                           spreadRadius: 1,
  //                           blurRadius: 2,
  //                           offset: Offset(0, 1),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Icon(Icons.inventory_2, size: 16, color: Colors.blue),
  //                         SizedBox(width: 10),
  //                         Expanded(
  //                           child: Text(
  //                             product.toString(),
  //                             style: GoogleFonts.figtree(
  //                               fontSize: 14,
  //                               color: Colors.black87,
  //                               fontWeight: FontWeight.w400,
  //                             ),
  //                           ),
  //                         ),
  //                         Icon(
  //                           Icons.arrow_forward_ios,
  //                           size: 12,
  //                           color: Colors.grey[400],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               }).toList(),
  //             ],
  //           ),
  //         ),
  //
  //       // Selected Base Product Display
  //       if (selectedBaseProduct != null)
  //         Container(
  //           margin: EdgeInsets.only(top: 8),
  //           padding: EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: Colors.blue[50],
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: Colors.blue[200]!),
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.green, size: 20),
  //               SizedBox(width: 8),
  //               Expanded(
  //                 child: Text(
  //                   "Selected: $selectedBaseProduct",
  //                   style: GoogleFonts.figtree(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //               ),
  //               GestureDetector(
  //                 onTap: () {
  //                   setState(() {
  //                     selectedBaseProduct = null;
  //                     baseProductController.clear();
  //                     baseProductResults = [];
  //                   });
  //                 },
  //                 child: Icon(Icons.close, color: Colors.grey[600], size: 20),
  //               ),
  //             ],
  //           ),
  //         ),
  //     ],
  //   );
  // }

  // 3. REPLACE the existing _buildSubmittedDataList() method with this:
  Widget _buildSubmittedDataList() {
    if (responseProducts.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No products added yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Get labels from API response
    List<String> labels = [];
    if (apiResponseData != null &&
        apiResponseData!['lebels'] != null &&
        apiResponseData!['lebels'].isNotEmpty) {
      labels = List<String>.from(apiResponseData!['lebels'][0]['labels']);
    }

    return Column(
      children: responseProducts.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> product = entry.value;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Product Name and Delete Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${product['S.No']}. ${product['Products']}",
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "ID: ${product['id']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 40.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepPurple[50],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Product"),
                              content: Text(
                                "Are you sure you want to delete this item?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      deleteCards(product['id'].toString());
                                      responseProducts.removeAt(index);
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("No"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Editable Fields in Rows
                _buildApiProductDetailInRows(product),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 4. ADD THIS NEW METHOD (place it after _buildSubmittedDataList method):
  Widget _buildApiProductDetailInRows(Map<String, dynamic> product) {
    return Column(
      children: [
        // Row 1: Basic Rate, Nos, Amount
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                "Basic Rate",
                _buildReadOnlyField(product, "Basic Rate"),
              ),
            ),
            Gap(10),
            Expanded(
              child: _buildDetailItem(
                "Nos",
                _buildEditableField(product, "Nos"),
              ),
            ),
            Gap(10),
            Expanded(
              child: _buildDetailItem(
                "Amount",
                _buildReadOnlyField(product, "Amount"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(Map<String, dynamic> product, String key) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[100],
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        product[key]?.toString() ?? "0",
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 15.sp,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        SizedBox(height: 6),
        field,
      ],
    );
  }

  // 5. ADD THESE NEW HELPER METHODS (place them after _buildApiProductDetailInRows):

  Widget _buildEditableField(Map<String, dynamic> product, String key) {
    final controller = _getController(product, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" || key == "Amount") ? true : false,
        controller: controller,
        style: GoogleFonts.figtree(
          fontSize: 15.sp,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (val) {
          product[key] = val;
          // Trigger calculation API when Nos changes
          if (key == "Nos") {
            _debounceCalculation(product);
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  // 6. MODIFY the _submitData() method - REPLACE the existing method with this:
  void _submitData() {
    if (selectedBrand == null ||
        selectedColor == null ||
        selectProductNameBase == null ||
        selectedSize == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Form'),
          content: Text(
            'Please fill all required fields to add a product.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    postAllData().then((_) {
      // Reset form fields after successful addition
      setState(() {
        selectProductNameBase = null;
        selectedBrand = null;
        selectedColor = null;
        selectedSize = null;
        productList = [];
        brandsList = [];
        colorsList = [];
        sizeList = [];
        _fetchProductName();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Product added successfully"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  String _selectedItems() {
    List<String> value = [
      if (selectProductNameBase != null) "ProductName: $selectProductNameBase",
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedColor != null) "Color: $selectedColor",
      if (selectedSize != null) "Size: $selectedSize",
    ];
    return value.isEmpty ? "No selections yet" : value.join(",  ");
  }

  Timer? _debounceTimer;
  Map<String, String?> previousUomValues = {}; // Track previous UOM values
  Map<String, Map<String, TextEditingController>> fieldControllers =
      {}; // Store controllers

  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    fieldControllers.putIfAbsent(productId, () => {});

    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : "";
      fieldControllers[productId]![key] = TextEditingController(
        text: initialValue,
      );
    }

    return fieldControllers[productId]![key]!;
  }

  void _debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      _performCalculation(data);
    });
  }

  Future<void> _performCalculation(Map<String, dynamic> data) async {
    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();

    // Get current UOM value
    String? currentUom = data["UOM"]?.toString();

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 15,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": null,
      "current_uom": null,
      "length": null,
      "nos": int.tryParse(data["Nos"]?.toString() ?? "0") ?? 0,
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
          setState(() {
            billamt = responseData["bill_total"] ?? 0;
            print("billamt updated to: $billamt");
            // Update fields based on API response
            // if (responseData["Length"] != null) {
            //   data["Length"] = responseData["Length"].toString();
            // }
            if (responseData["Nos"] != null) {
              data["Nos"] = responseData["Nos"].toString();
            }
            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
            }

            // Store previous UOM for next call
            previousUomValues[productId] = currentUom;
          });
        }
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UPVC Accessories',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Add New Product",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 24),
                          _buildAnimatedDropdown(
                            productList,
                            selectProductNameBase,
                            (value) {
                              setState(() {
                                selectProductNameBase = value;
                                selectedBrand = null;
                                selectedColor = null;
                                selectedSize = null;
                                brandsList = [];
                                colorsList = [];
                                sizeList = [];
                              });
                              _fetchbrand();
                            },
                            label: "Product Name Base",
                            icon: Icons.category_outlined,
                          ),
                          _buildAnimatedDropdown(
                            brandsList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;
                                selectedColor = null;
                                selectedSize = null;
                                colorsList = [];
                                sizeList = [];
                              });
                              _fetchColor();
                            },
                            enabled: brandsList.isNotEmpty,
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          _buildAnimatedDropdown(
                            colorsList,
                            selectedColor,
                            (value) {
                              setState(() {
                                selectedColor = value;
                                selectedSize = null;
                                sizeList = [];
                              });
                              _fetchSize();
                            },
                            enabled: colorsList.isNotEmpty,
                            label: "Color",
                            icon: Icons.color_lens_outlined,
                          ),
                          _buildAnimatedDropdown(
                            sizeList,
                            selectedSize,
                            (value) {
                              setState(() {
                                selectedSize = value;
                              });
                            },
                            enabled: sizeList.isNotEmpty,
                            label: "Size",
                            icon: Icons.format_size_sharp,
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.deepPurple[400]!,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selected Product Details",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepPurple[400],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _selectedItems(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 54.h,
                            child: ElevatedButton(
                              onPressed: _submitData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple[400],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_shopping_cart_outlined,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Add Product",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (responseProducts.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade100,
                          Colors.blue.shade50
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepPurple.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    Colors.deepPurple.shade100.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.deepPurple.shade700,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Added Products",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: "UPVC Accessories",
                                    weight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.receipt_outlined,
                                          size: 14,
                                          color: Colors.blue.shade700,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "ID: $orderNO",
                                          style: GoogleFonts.figtree(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade500,
                                Colors.deepPurple.shade200
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "TOTAL AMOUNT",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹${billamt ?? 0}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildSubmittedDataList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown(
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: enabled ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: DropdownSearch<String>(
          items: items,
          selectedItem: selectedValue,
          onChanged: enabled ? onChanged : null,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.deepPurple : Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            constraints: BoxConstraints(maxHeight: 300),
            // borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
