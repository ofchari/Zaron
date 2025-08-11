import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/universal_api/api_key.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

import '../../camera_upload/gi_glutter_uploads/gi_glutter_attachement.dart';
import '../../global_user/global_oredrID.dart';
import '../../global_user/global_user.dart';

class GIGlutter extends StatefulWidget {
  const GIGlutter({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<GIGlutter> createState() => _GIGlutterState();
}

class _GIGlutterState extends State<GIGlutter> {
  Map<String, dynamic>? categoryMeta;
  int? billamt;
  String? orderNo;
  int? orderIDD;
  late TextEditingController editController;
  String? selectedProduct;
  String? selectedMeterial;
  String? selectedThichness;
  String? selsectedCoat;
  String? selectedyie;
  String? selectedBrand;
  String? selectedProductBaseId;
  String? selectedBaseProductName;
  String? currentMainProductId;

  List<String> productList = [];
  List<String> meterialList = [];
  List<String> thichnessLists = [];
  List<String> coatMassList = [];
  List<String> yieldsListt = [];
  List<String> brandList = [];
  List<dynamic> rawGIutter = [];
  List<Map<String, dynamic>> submittedData = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchProductName();
    _fetchMeterialType();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductName() async {
    setState(() {
      productList = [];
      selectedProduct = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/628');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];
        debugPrint("PRoduct:::$products");
        debugPrint(response.body, wrapWidth: 1024);

        if (products is List) {
          setState(() {
            productList = products
                .whereType<Map>()
                .map((e) => e["product_name"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  Future<void> _fetchMeterialType() async {
    setState(() {
      meterialList = [];
      selectedMeterial;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/628');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meterialData = data["message"]["message"][2][1];
        debugPrint(response.body);

        if (meterialData is List) {
          setState(() {
            meterialList = meterialData
                .whereType<Map>()
                .map((e) => e["material_type"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching brands: $e");
    }
  }

  /// fetch colors Api's //
  Future<void> _fetchThickness() async {
    if (selectedMeterial == null) return;

    setState(() {
      thichnessLists = [];
      selectedThichness = null;
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
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 628,
          "base_product_filters": [selectedMeterial],
          "base_label_filters": ["material_type"],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");

        if (selectedThickness is List) {
          setState(() {
            thichnessLists = selectedThickness
                .whereType<Map>()
                .map((e) => e["thickness"]?.toString())
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
  Future<void> _fetchCoat() async {
    if (selectedMeterial == null) return;

    setState(() {
      coatMassList = [];
      selsectedCoat = null;
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
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 628,
          "base_product_filters": [selectedMeterial, selectedThichness],
          "base_label_filters": ["material_type", "thickness"],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coat = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThichness");
        print("API response: ${response.body}");

        if (coat is List) {
          setState(() {
            coatMassList = coat
                .whereType<Map>()
                .map((e) => e["coating_mass"]?.toString())
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
  Future<void> _fetchYie() async {
    if (selectedMeterial == null) return;

    setState(() {
      yieldsListt = [];
      selectedyie = null;
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
          "product_label": "yield_strength",
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 628,
          "base_product_filters": [
            selectedMeterial,
            selectedThichness,
            selsectedCoat,
          ],
          "base_label_filters": ["material_type", "thickness", "coating_mass"],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final yieldsStrength = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThichness");
        print("API response: ${response.body}");

        if (yieldsStrength is List) {
          setState(() {
            yieldsListt = yieldsStrength
                .whereType<Map>()
                .map((e) => e["yield_strength"]?.toString())
                .whereType<String>()
                .toList();
          });
        }
      }
    } catch (e) {
      print("Exception fetching coating mass: $e");
    }
  }

  Future<void> _fetchBrandss() async {
    if (selectedMeterial == null) return;

    setState(() {
      brandList = [];
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
          "product_label": "brand",
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 628,
          "base_product_filters": [
            selectedMeterial,
            selectedThichness,
            selsectedCoat,
            selectedyie,
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
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          final brandData = message[0];
          if (brandData is List) {
            setState(() {
              brandList = brandData
                  .whereType<Map>()
                  .map((e) => e["brand"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString(); // <-- New line
            print("Selected Base Product ID: $selectedProductBaseId");
            print(
              "Base Product Name: $selectedBaseProductName",
            ); // <-- Optional
          }
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

  // 1. ADD THESE NEW VARIABLES at the top of your _GIGlutterState class (around line 25)
  Map<String, dynamic>? apiResponseData;
  List<dynamic> responseProducts = [];

  ///post All Data
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

    // Find the matching item from rawAccessoriesData
    final matchingAccessory = rawGIutter.firstWhere(
      (item) => item["product_name"] == selectedProduct,
      orElse: () => null,
    );
    // Extract values
    final giglutterId = matchingAccessory?["id"];
    print("this os $giglutterId");
    // Use global order ID if available, otherwise null for first time
    final globalOrderManager = GlobalOrderManager();

    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": giglutterId,
      "product_name": selectedProduct,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProduct",
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

      if (response.statusCode == 200) {
        // PARSE THE API RESPONSE
        final responseData = jsonDecode(response.body);
        setState(() {
          final String orderID = responseData["order_id"].toString();
          print("Order IDDDD: $orderID");
          orderIDD = int.parse(orderID);
          String orderNos = responseData["order_no"]?.toString() ?? "Unknown";
          orderNo = orderNos.isEmpty ? "Unknown" : orderNos;

          // Set global order ID if this is the first time
          if (!globalOrderManager.hasGlobalOrderId()) {
            globalOrderManager.setGlobalOrderId(int.parse(orderID), orderNo!);
          }

          // Update local variables
          orderIDD = globalOrderManager.globalOrderId;
          orderNo = globalOrderManager.globalOrderNo;
          apiResponseData = responseData;
          currentMainProductId = responseData["product_id"]?.toString();
          // Extract the products from the response
          if (responseData['lebels'] != null &&
              responseData['lebels'].isNotEmpty) {
            responseProducts = responseData['lebels'][0]['data'] ?? [];
          }
        });
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  /// Base View Products data //
  // Add these variables with your existing variables
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
    final data = {"category_id": "628", "searchbase": query};

    try {
      final response = await ioClient.post(
        Uri.parse("$apiUrl/api/baseproducts_search"),
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
                }),
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

  // 3. MODIFY the _submitData() method - REPLACE the existing method with this:
  void _submitData() {
    if (selectedMeterial == null ||
        selectedThichness == null ||
        selsectedCoat == null ||
        selectedyie == null ||
        selectedBrand == null) {
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
      // RESET FORM FIELDS
      setState(() {
        selectedMeterial = null;
        selectedThichness = null;
        selsectedCoat = null;
        selectedyie = null;
        selectedBrand = null;
        selectedProduct = null;
        meterialList = [];
        thichnessLists = [];
        coatMassList = [];
        yieldsListt = [];
        brandList = [];
      });

      _fetchMeterialType();

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

  // 4. REPLACE the entire _buildSubmittedDataList() method with this:
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
        Map<String, dynamic> data = entry.value;

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
                          "  ${data["S.No"]}.  ${data["Products"]}" ?? "",
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
                  Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green[100]!),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green[50],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.attach_file,
                          color: Colors.green[600], size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GIGlutterAttachment(
                              productId: data['id'].toString(),
                              mainProductId:
                                  currentMainProductId ?? "Unknown ID",
                            ),
                          ),
                        );
                      },
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
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8),
                child: Container(
                  height: 40.h,
                  width: double.infinity.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: 280.w,
                        child: TextField(
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          controller: TextEditingController(
                            text: " ${data["Base Product"]}",
                          ),
                          readOnly: true,
                        ),
                      ),
                      Gap(5),
                      Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            editController.text = data["Base Product"];
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Edit Your GI GUTTER"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 40.h,
                                        width: double.infinity.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: 7.0.w,
                                          ),
                                          child: TextField(
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                            ),
                                            decoration: InputDecoration(
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                            controller: editController,
                                            onSubmitted: (value) {
                                              setState(() {
                                                data["Base Product"] = value;
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          data["Base Product"] =
                                              editController.text;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: MyText(
                                        text: "Save",
                                        weight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.edit, size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(5),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 5. REPLACE the _buildProductDetailInRows method with this:
  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem("UOM", _uomDropdownFromAPI(data)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "Billing Option",
                  _billingOptionDropdown(data),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "Length",
                  _editableTextField(data, "Length"),
                ),
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
                child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "Basic Rate",
                  _editableTextField(data, "Basic Rate"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem("Qty", _editableTextField(data, "Qty")),
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
                  "Amount",
                  _editableTextField(data, "Amount"),
                ),
              ),
              SizedBox(width: 20),
              SizedBox(width: 20),
            ],
          ),
        ),
        Gap(5.h),
      ],
    );
  }

  // 6. ADD THESE NEW METHODS after the existing _uomDropdown method:
  Widget _uomDropdownFromAPI(Map<String, dynamic> data) {
    Map<String, dynamic> uomData = data["UOM"] ?? {};
    String currentValue = uomData["value"]?.toString() ?? "";
    Map<String, dynamic> options = uomData["options"] ?? {};

    List<DropdownMenuItem<String>> items = options.entries
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value.toString()),
          ),
        )
        .toList();

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue.isEmpty ? null : currentValue,
        items: items,
        onChanged: (val) {
          setState(() {
            data["UOM"]["value"] = val!;
          });
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

  Widget _billingOptionDropdown(Map<String, dynamic> data) {
    Map<String, dynamic> billingData = data["Billing Option"] ?? {};
    String currentValue = billingData["value"]?.toString() ?? "";
    Map<String, dynamic> options = billingData["options"] ?? {};

    List<DropdownMenuItem<String>> items = options.entries
        .map(
          (entry) => DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value.toString()),
          ),
        )
        .toList();

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue.isEmpty ? null : currentValue,
        items: items,
        onChanged: (val) {
          setState(() {
            data["Billing Option"]["value"] = val!;
          });
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

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: TextEditingController(text: data[key]),
        onChanged: (val) => data[key] = val,
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

  String _selectedItems() {
    List<String> values = [
      if (selectedMeterial != null) "Material: $selectedMeterial",
      if (selectedThichness != null) "Thickness: $selectedThichness",
      if (selsectedCoat != null) "CoatingMass: $selsectedCoat",
      if (selectedyie != null) "yieldStrength: $selectedyie",
      if (selectedBrand != null) "Brand: $selectedBrand",
    ];
    return values.isEmpty ? "No Selections yet" : values.join(", ");
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
          text: 'GI Glutter',
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
                            productList,
                            selectedProduct,
                            (value) {
                              setState(() {
                                selectedProduct = value;
                              });
                              // _fetchProductName();
                            },
                            // enabled: productList.isNotEmpty,
                            label: "Product Name",
                            icon: Icons.category_outlined,
                          ),
                          _buildAnimatedDropdown(
                            meterialList,
                            selectedMeterial,
                            (value) {
                              setState(() {
                                selectedMeterial = value;

                                ///clear fields
                                selectedThichness = null;
                                selsectedCoat = null;
                                selectedyie = null;
                                selectedBrand = null;
                                thichnessLists = [];
                                coatMassList = [];
                                yieldsListt = [];
                                brandList = [];
                              });
                              _fetchThickness();
                            },
                            label: "Meterial Type",
                            icon: Icons.difference_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thichnessLists,
                            selectedThichness,
                            (value) {
                              setState(() {
                                selectedThichness = value;

                                ///clear fields

                                selsectedCoat = null;
                                selectedyie = null;
                                selectedBrand = null;

                                coatMassList = [];
                                yieldsListt = [];
                                brandList = [];
                              });
                              _fetchCoat();
                            },
                            enabled: thichnessLists.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            coatMassList,
                            selsectedCoat,
                            (value) {
                              setState(() {
                                selsectedCoat = value;

                                ///clear fields
                                selectedyie = null;
                                selectedBrand = null;
                                yieldsListt = [];
                                brandList = [];
                              });
                              _fetchYie();
                            },
                            enabled: coatMassList.isNotEmpty,
                            label: "Coating Mass",
                            icon: Icons.layers_outlined,
                          ),
                          _buildAnimatedDropdown(
                            yieldsListt,
                            selectedyie,
                            (value) {
                              setState(() {
                                selectedyie = value;

                                ///clear fields
                                selectedBrand = null;
                                brandList = [];
                              });
                              _fetchBrandss();
                            },
                            enabled: yieldsListt.isNotEmpty,
                            label: "Yield Strength",
                            icon: Icons.radio_button_checked,
                          ),
                          _buildAnimatedDropdown(
                            brandList,
                            selectedBrand,
                            (value) {
                              setState(() {
                                selectedBrand = value;
                              });
                            },
                            enabled: brandList.isNotEmpty,
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          SizedBox(height: 24),
                          // _buildBaseProductSearchField(),
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
                if (responseProducts.isNotEmpty)
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
