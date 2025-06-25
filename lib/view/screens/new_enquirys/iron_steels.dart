import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api&key.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../global_user/global_user.dart';

class IronSteel extends StatefulWidget {
  const IronSteel({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<IronSteel> createState() => _IronSteelState();
}

class _IronSteelState extends State<IronSteel> {
  late TextEditingController editController;

  String? selectedBrand;
  String? selectedColor;
  String? selectedThickness;
  String? selectedCoatingMass;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<String> coatingMassList = [];
  List<Map<String, dynamic>> submittedData = [];

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchBrands();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    setState(() {
      brandsList = [];
      selectedBrand = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/3');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brands = data["message"]["message"][1];
        print(response.body);

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
      print("Exception fetching brands: $e");
    }
  }

  /// fetch colors Api's ///

  Future<void> _fetchColors() async {
    if (selectedBrand == null) return;

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
          "product_label": "color",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand],
          "base_label_filters": ["brand"],
          "base_category_id": "3",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (colors is List) {
          setState(() {
            colorsList = colors
                .whereType<Map>()
                .map((e) => e["color"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching colors: $e");
    }
  }

  /// fetch Thickness Api's ///
  Future<void> _fetchThickness() async {
    if (selectedBrand == null) return;

    setState(() {
      thicknessList = [];
      selectedThickness = null;
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
          "product_label": "thickness",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedBrand, selectedColor],
          "base_label_filters": ["brand", "color"],
          "base_category_id": "3",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedBrand");
        print("API response: ${response.body}");

        if (thickness is List) {
          setState(() {
            thicknessList = thickness
                .whereType<Map>()
                .map((e) => e["thickness"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching thickness: $e");
    }
  }

  /// fetch Thickness Api's ///
  Future<void> _fetchCoatingMass() async {
    if (selectedBrand == null) return;

    setState(() {
      coatingMassList = [];
      selectedCoatingMass = null;
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
          "product_label": "coating_mass",
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [
            selectedBrand,
            selectedColor,
            selectedThickness,
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": "3",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];

        // Extract coating_mass list
        final coating = message[0];
        if (coating is List) {
          setState(() {
            coatingMassList = coating
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
                .whereType<String>()
                .toList();
          });
        }

        // Extract product_base_id and base_product_id
        final idData = message.length > 1 ? message[1] : null;
        if (idData is List && idData.isNotEmpty && idData.first is Map) {
          selectedProductBaseId = idData.first["id"]?.toString();
          selectedBaseProductName =
              idData.first["base_product_id"]?.toString(); // <-- Add this
          print("Selected Base Product ID: $selectedProductBaseId");
          print(
            "Base Product Name: $selectedBaseProductName",
          ); // <-- Optional debug
        }

        print("API response: ${response.body}");
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    }
  }

  List<Map<String, dynamic>> apiResponseData = [];
  Map<String, dynamic>? apiResponse;

  Future<void> postAllData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": 3,
      "category_name": "Iron And Steel Corrugated Sheet",
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
      if (selectedColor == null ||
          selectedThickness == null ||
          selectedCoatingMass == null) {
        return;
      }
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['lebels'] != null) {
          setState(() {
            // Get the new data
            List<Map<String, dynamic>> newData =
                List<Map<String, dynamic>>.from(
              responseData['lebels'][0]['data'],
            );

            // Append new data to existing lists
            apiResponseData.addAll(newData);
            responseProducts.addAll(newData);
          });
        }
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  void _submitData() {
    if (selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null ||
        selectedCoatingMass == null) {
      // Show elegant error message
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
      setState(() {
        submittedData.add({
          "Product": "Accessories",
          "UOM": "Feet",
          "Length": "0",
          "Nos": "1",
          "Basic Rate": "0",
          "SQ": "0",
          "Amount": "0",
          "Base Product":
              "$selectedBrand, $selectedColor, $selectedThickness, $selectedCoatingMass,",
        });
        selectedBrand = null;
        selectedColor = null;
        selectedThickness = null;
        selectedCoatingMass = null;
        brandsList = [];
        colorsList = [];
        thicknessList = [];
        coatingMassList = [];
        _fetchBrands();
      });

      // Show success message with a more elegant snackBar
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
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  TextEditingController baseProductController = TextEditingController();
  List<dynamic> baseProductResults = [];
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();

  // Add this method for searching base products
  Future<void> searchBaseProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        baseProductResults = [];
      });
      return;
    }

    setState(() {
      isSearchingBaseProduct = true;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {"category_id": "3", "searchbase": query};

    try {
      final response = await ioClient.post(
        Uri.parse("https://demo.zaron.in:8181/ci4/api/baseproducts_search"),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Base product response: $responseData"); // Debug print
        setState(() {
          baseProductResults = responseData['base_products'] ?? [];
          isSearchingBaseProduct = false;
        });
      } else {
        setState(() {
          baseProductResults = [];
          isSearchingBaseProduct = false;
        });
      }
    } catch (e) {
      print("Error searching base products: $e");
      setState(() {
        baseProductResults = [];
        isSearchingBaseProduct = false;
      });
    }
  }

  // Add this method to build the base product search field
  Widget _buildBaseProductSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Base Product",
          style: GoogleFonts.figtree(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: baseProductController,
            focusNode: baseProductFocusNode,
            decoration: InputDecoration(
              hintText: "Search base product...",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: isSearchingBaseProduct
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              searchBaseProducts(value);
            },
            onTap: () {
              if (baseProductController.text.isNotEmpty) {
                searchBaseProducts(baseProductController.text);
              }
            },
          ),
        ),

        // Search Results Display (line by line, not dropdown)
        if (baseProductResults.isNotEmpty)
          Container(
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
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                ...baseProductResults.map((product) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBaseProduct = product.toString();
                        baseProductController.text = selectedBaseProduct!;
                        baseProductResults = [];
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
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
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2, size: 16, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              product.toString(),
                              style: GoogleFonts.figtree(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

        // Selected Base Product Display
        if (selectedBaseProduct != null)
          Container(
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
                    "Selected: $selectedBaseProduct",
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBaseProduct = null;
                      baseProductController.clear();
                      baseProductResults = [];
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Add these variables after line 25 (after the existing List declarations)
  // Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];
  Map<String, Map<String, String>> uomOptions = {};

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

    return Column(
      children: responseProducts.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = Map<String, dynamic>.from(entry.value);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: SizedBox(
                        height: 40.h,
                        width: 210.w,
                        child: Text(
                          "  ${index + 1}.  ${data["Products"]}" ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
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
                      "ID: ${data['id']}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
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
                            builder: (context) {
                              return AlertDialog(
                                title: Subhead(
                                  text: "Are you Sure to Delete This Item ?",
                                  weight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        responseProducts.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text("Yes"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              _buildProductDetailInRows(data),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0, left: 8),
              //   child: Container(
              //     height: 40.h,
              //     width: double.infinity.w,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: [
              //         Container(
              //           height: 40.h,
              //           width: 280.w,
              //           child: TextField(
              //             style: TextStyle(
              //               fontSize: 13.sp,
              //               color: Colors.black87,
              //               fontWeight: FontWeight.w500,
              //             ),
              //             decoration: InputDecoration(
              //               enabledBorder: InputBorder.none,
              //               focusedBorder: InputBorder.none,
              //             ),
              //             controller: TextEditingController(
              //               text: " ${data["Material Specification"]}",
              //             ),
              //             readOnly: true,
              //           ),
              //         ),
              //         Gap(5),
              //         Container(
              //           height: 30.h,
              //           width: 30.w,
              //           decoration: BoxDecoration(
              //             color: Colors.grey[200],
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: IconButton(
              //             onPressed: () {
              //               editController.text =
              //                   data["Material Specification"].toString();
              //               showDialog(
              //                 context: context,
              //                 builder: (context) {
              //                   return AlertDialog(
              //                     title: Text("Edit Your Liner Sheet"),
              //                     content: Column(
              //                       mainAxisSize: MainAxisSize.min,
              //                       children: [
              //                         Container(
              //                           height: 40.h,
              //                           width: double.infinity.w,
              //                           decoration: BoxDecoration(
              //                             borderRadius:
              //                                 BorderRadius.circular(10),
              //                             color: Colors.white,
              //                           ),
              //                           child: Padding(
              //                             padding: const EdgeInsets.only(
              //                               left: 7.0,
              //                             ),
              //                             child: TextField(
              //                               decoration: InputDecoration(
              //                                 enabledBorder: InputBorder.none,
              //                                 focusedBorder: InputBorder.none,
              //                               ),
              //                               controller: editController,
              //                               onSubmitted: (value) {
              //                                 setState(() {
              //                                   data["Material Specification"] =
              //                                       value;
              //                                 });
              //                                 Navigator.pop(context);
              //                               },
              //                             ),
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //                     actions: [
              //                       ElevatedButton(
              //                         onPressed: () {
              //                           setState(() {
              //                             data["Material Specification"] =
              //                                 editController.text;
              //                           });
              //                           Navigator.pop(context);
              //                         },
              //                         child: MyText(
              //                           text: "Save",
              //                           weight: FontWeight.w500,
              //                           color: Colors.black,
              //                         ),
              //                       ),
              //                     ],
              //                   );
              //                 },
              //               );
              //             },
              //             icon: Icon(Icons.edit, size: 15),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem("UOM", _uomDropdownFromApi(data)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "Profile",
                  _editableTextField(data, "Profile"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
              ),
            ],
          ),
        ),
        Gap(5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  "Basic Rate",
                  _editableTextField(data, "Basic Rate"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "SQMtr",
                  _editableTextField(data, "SQMtr"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "Amount",
                  _editableTextField(data, "Amount"),
                ),
              ),
            ],
          ),
        ),
        Gap(5.h),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  "Crimp",
                  _editableTextField(data, "height"),
                ),
              ),
            ],
          ),
        ),
      ],
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

  // Widget _uomDropdownFromApi(Map<String, dynamic> data) {
  //   String productId = data["id"].toString();
  //   Map<String, String>? options = uomOptions[productId];
  //
  //   if (options == null || options.isEmpty) {
  //     return _editableTextField(data, "UOM");
  //   }
  //
  //   String? currentValue;
  //   if (data["UOM"] is Map) {
  //     currentValue = data["UOM"]["value"]?.toString();
  //   } else {
  //     currentValue = data["UOM"]?.toString();
  //   }
  //
  //   return SizedBox(
  //     height: 40.h,
  //     child: DropdownButtonFormField<String>(
  //       value: currentValue,
  //       items: options.entries
  //           .map(
  //             (entry) => DropdownMenuItem(
  //               value: entry.key,
  //               child: Text(entry.value),
  //             ),
  //           )
  //           .toList(),
  //       onChanged: (val) {
  //         setState(() {
  //           data["UOM"] = {"value": val, "options": options};
  //         });
  //         print("UOM changed to: $val"); // Debug print
  //         print(
  //           "Product data: ${data["Products"]}, ID: ${data["id"]}",
  //         ); // Debug print
  //         // Trigger calculation with debounce
  //         _debounceCalculation(data);
  //       },
  //       decoration: InputDecoration(
  //         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(6),
  //           borderSide: BorderSide(color: Colors.grey[300]!),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(6),
  //           borderSide: BorderSide(color: Colors.grey[300]!),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(6),
  //           borderSide: BorderSide(
  //             color: Theme.of(context).primaryColor,
  //             width: 2,
  //           ),
  //         ),
  //         filled: true,
  //         fillColor: Colors.grey[50],
  //       ),
  //     ),
  //   );
  // }

  Widget _uomDropdownFromApi(Map<String, dynamic> data) {
    String productId = data["id"].toString();

    // Extract UOM data from the response
    Map<String, dynamic>? uomData;
    if (data["UOM"] is Map) {
      uomData = Map<String, dynamic>.from(data["UOM"]);
    }

    // If no UOM data, return text field
    if (uomData == null || !uomData.containsKey('options')) {
      return _editableTextField(data, "UOM");
    }

    // Get the options map
    Map<String, String> options =
        Map<String, String>.from(uomData['options'] as Map);

    // Get current value
    String currentValue = uomData['value']?.toString() ?? options.keys.first;

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.value,
              style: GoogleFonts.figtree(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              // Update the UOM data structure
              data["UOM"] = {
                "value": val,
                "options": options,
              };
            });
            print("UOM changed to: $val (${options[val]})");
            _debounceCalculation(data);
          }
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
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: controller,
        keyboardType: (key == "Length" ||
                key == "Nos" ||
                key == "Basic Rate" ||
                key == "Amount" ||
                key == "sqmtr")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        onChanged: (val) {
          setState(() {
            data[key] = val;
          });

          print("Field $key changed to: $val");
          print("Controller text: ${controller.text}");
          print("Data after change: ${data[key]}");

          // 🚫 DO NOT forcefully reset controller.text here!
          // if (controller.text != val) {
          //   controller.text = val;
          // }

          if (key == "Length" ||
              key == "Nos" ||
              key == "Basic Rate" ||
              key == "height") {
            print("Triggering calculation for $key with value: $val");
            _debounceCalculation(data);
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
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
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  String _selectedItems() {
    List<String> values = [
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedColor != null) "Color: $selectedColor",
      if (selectedThickness != null) "Thickness: $selectedThickness",
      if (selectedCoatingMass != null) "CoatingMass: $selectedCoatingMass",
    ];
    return values.isEmpty ? "No selections yet" : values.join(",  ");
  }

  Timer? _debounceTimer;
  Map<String, dynamic> calculationResults = {};
  Map<String, String?> previousUomValues = {}; // Track previous UOM values
  Map<String, Map<String, TextEditingController>> fieldControllers =
      {}; // Store controllers

  // Method to get or create controller for each field
  TextEditingController _getController(Map<String, dynamic> data, String key) {
    String productId = data["id"].toString();

    // Initialize controllers map for this product ID
    fieldControllers.putIfAbsent(productId, () => {});

    // If controller for this key doesn't exist, create it
    if (!fieldControllers[productId]!.containsKey(key)) {
      String initialValue = (data[key] != null && data[key].toString() != "0")
          ? data[key].toString()
          : ""; // Avoid initializing with "0"

      fieldControllers[productId]![key] = TextEditingController(
        text: initialValue,
      );

      print("Created controller for [$key] with value: '$initialValue'");
    } else {
      // Existing controller: check if it needs sync from data
      final controller = fieldControllers[productId]![key]!;

      final dataValue = data[key]?.toString() ?? "";

      // If the controller is empty but data has a value, sync it
      if (controller.text.isEmpty && dataValue.isNotEmpty && dataValue != "0") {
        controller.text = dataValue;
        print("Synced controller for [$key] to: '$dataValue'");
      }
    }

    return fieldControllers[productId]![key]!;
  }

  // Add this method for debounced calculation
  void _debounceCalculation(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: 1), () {
      _performCalculation(data);
    });
  }

  Future<void> _performCalculation(Map<String, dynamic> data) async {
    print("=== STARTING CALCULATION API ===");
    print("Data received: $data");

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/calculation');

    String productId = data["id"].toString();

    // Get current UOM value
    String? currentUom;
    if (data["UOM"] is Map) {
      currentUom = data["UOM"]["value"]?.toString();
    } else {
      currentUom = data["UOM"]?.toString();
    }

    print("Current UOM: $currentUom");
    print("Previous UOM: ${previousUomValues[productId]}");

    // Get Profile value from controller
    double? profileValue;
    String? profileText;

    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Profile")) {
      profileText = fieldControllers[productId]!["Profile"]!.text;
      print("Profile from controller: $profileText");
    }

    if (profileText == null || profileText.isEmpty) {
      profileText = data["Profile"]?.toString();
      print("Profile from data: $profileText");
    }

    if (profileText != null && profileText.isNotEmpty) {
      profileValue = double.tryParse(profileText);
    }

    // Get Nos value from controller
    int nosValue = 0;
    String? nosText;

    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Nos")) {
      nosText = fieldControllers[productId]!["Nos"]!.text;
      print("Nos from controller: $nosText");
    }

    if (nosText == null || nosText.isEmpty) {
      nosText = data["Nos"]?.toString();
      print("Nos from data: $nosText");
    }

    if (nosText != null && nosText.isNotEmpty) {
      nosValue = int.tryParse(nosText) ?? 1;
    }

    // Get height (crimp) value from controller
    String? heightValue;
    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("height")) {
      heightValue = fieldControllers[productId]!["height"]!.text;
      print("Height from controller: $heightValue");
    }

    if (heightValue == null || heightValue.isEmpty) {
      heightValue = data["height"]?.toString();
      print("Height from data: $heightValue");
    }

    print("Final Profile Value: $profileValue");
    print("Final Nos Value: $nosValue");
    print("Final Height Value: $heightValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 3,
      "product": data["Products"]?.toString() ?? "",
      "height": heightValue,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": profileValue ?? 0,
      "nos": nosValue,
      "basic_rate": double.tryParse(data["Basic Rate"]?.toString() ?? "0") ?? 0,
    };

    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["status"] == "success") {
          setState(() {
            calculationResults[productId] = responseData;

            // Update Profile/Length
            if (responseData["Length"] != null) {
              data["Profile"] = responseData["Length"].toString();
              if (fieldControllers[productId]?["Profile"] != null) {
                fieldControllers[productId]!["Profile"]!.text =
                    responseData["Length"].toString();
              }
            }

            // Update Nos
            if (responseData["Nos"] != null) {
              String newNos = responseData["Nos"].toString().trim();
              String currentInput =
                  fieldControllers[productId]!["Nos"]!.text.trim();

              if (currentInput.isEmpty || currentInput == "0") {
                data["Nos"] = newNos;
                if (fieldControllers[productId]?["Nos"] != null) {
                  fieldControllers[productId]!["Nos"]!.text = newNos;
                }
                print("Nos field updated to: $newNos");
              } else {
                print("Nos NOT updated because user input = '$currentInput'");
              }
            }

            // Update Height/Crimp
            if (responseData["crimp"] != null) {
              String newCrimp = responseData["crimp"].toString();
              String currentCrimp =
                  fieldControllers[productId]!["height"]?.text.trim() ?? "";

              if (currentCrimp.isEmpty || currentCrimp == "0") {
                data["height"] = newCrimp;
                if (fieldControllers[productId]?["height"] != null) {
                  fieldControllers[productId]!["height"]!.text = newCrimp;
                }
                print("Height field updated to: $newCrimp");
              } else {
                print(
                    "Height NOT updated because user input = '$currentCrimp'");
              }
            }

            // Update SQMtr
            if (responseData["sqmtr"] != null) {
              data["SQMtr"] = responseData["sqmtr"].toString();
              if (fieldControllers[productId]?["SQMtr"] != null) {
                fieldControllers[productId]!["SQMtr"]!.text =
                    responseData["sqmtr"].toString();
              }
            }

            // Update Amount
            if (responseData["Amount"] != null) {
              data["Amount"] = responseData["Amount"].toString();
              if (fieldControllers[productId]?["Amount"] != null) {
                fieldControllers[productId]!["Amount"]!.text =
                    responseData["Amount"].toString();
              }
            }

            previousUomValues[productId] = currentUom;
          });

          print("=== CALCULATION SUCCESS ===");
          print(
            "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, Height=${data["height"]}, Amount=${data["Amount"]}",
          );
        } else {
          print("API returned error status: ${responseData["status"]}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Calculation API Error: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Iron and Steel',
          weight: FontWeight.w500,
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Subhead(
                            text: "Add New Product",
                            weight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedDropdown(
                            brandsList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;

                                ///clear Data
                                selectedColor = null;
                                selectedThickness = null;
                                selectedCoatingMass = null;
                                colorsList = [];
                                thicknessList = [];
                                coatingMassList = [];
                              });
                              _fetchColors();
                            },
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          _buildAnimatedDropdown(
                            colorsList,
                            selectedColor,
                            (value) {
                              setState(() {
                                selectedColor = value;

                                ///clear Data
                                selectedThickness = null;
                                selectedCoatingMass = null;
                                thicknessList = [];
                                coatingMassList = [];
                              });
                              _fetchThickness();
                            },
                            enabled: colorsList.isNotEmpty,
                            label: "Color",
                            icon: Icons.color_lens_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thicknessList,
                            selectedThickness,
                            (value) {
                              setState(() {
                                selectedThickness = value;

                                ///clear Data
                                selectedCoatingMass = null;
                                coatingMassList = [];
                              });
                              _fetchCoatingMass();
                            },
                            enabled: thicknessList.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            coatingMassList,
                            selectedCoatingMass,
                            (value) {
                              setState(() {
                                selectedCoatingMass = value;
                              });
                            },
                            enabled: coatingMassList.isNotEmpty,
                            label: "Coating Mass",
                            icon: Icons.layers_outlined,
                          ),
                          SizedBox(height: 24),
                          _buildBaseProductSearchField(),
                          SizedBox(height: 16),
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
                SizedBox(height: 24),
                if (apiResponseData.isNotEmpty)
                  Subhead(
                    text: "   Added Products",
                    weight: FontWeight.w600,
                    color: Colors.black,
                  ),
                SizedBox(height: 8),
                _buildSubmittedDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
