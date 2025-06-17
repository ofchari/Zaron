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
import 'package:zaron/view/widgets/text.dart';

import '../global_user/global_user.dart';

class CutToLengthSheet extends StatefulWidget {
  const CutToLengthSheet({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<CutToLengthSheet> createState() => _CutToLengthSheetState();
}

class _CutToLengthSheetState extends State<CutToLengthSheet> {
  late TextEditingController editController;
  String? selectedProduct;
  String? selectedMeterial;
  String? selectedThichness;
  String? selsectedCoat;
  String? selectedyie;
  String? selectedBrand;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> productList = [];
  List<String> meterialList = [];
  List<String> thichnessLists = [];
  List<String> coatMassList = [];
  List<String> yieldsListt = [];
  List<String> brandList = [];
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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/626');

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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/626');

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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "category_id": "3",
          // "selectedlabel": "material_type",
          // "selectedvalue": selectedMeterial,
          // "label_name": "thickness",

          "product_label": "thickness",
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 626,
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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "category_id": "3",
          // "selectedlabel": "thickness",
          // "selectedvalue": selectedThichness,
          // "label_name": "coating_mass",

          "product_label": "coating_mass",
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 626,
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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // "category_id": "3",
          // "selectedlabel": "coating_mass",
          // "selectedvalue": selsectedCoat,
          // "label_name": "yield_strength",

          "product_label": "yield_strength",
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 626,
          "base_product_filters": [
            selectedMeterial,
            selectedThichness,
            selsectedCoat
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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/labelinputdata');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "brand",
          "product_filters": [selectedProduct],
          "product_label_filters": ["product_name"],
          "product_category_id": 626,
          "base_product_filters": [
            selectedMeterial,
            selectedThichness,
            selsectedCoat,
            selectedyie
          ],
          "base_label_filters": [
            "material_type",
            "thickness",
            "coating_mass",
            "yield_strength"
          ],
          "base_category_id": "34",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          final brands = message[0];
          if (brands is List) {
            setState(() {
              brandList = brands
                  .whereType<Map>()
                  .map((e) => e["brand"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          // Extract base_product_id and id from message[1]
          if (message.length > 1) {
            final baseProductData = message[1];
            if (baseProductData is List && baseProductData.isNotEmpty) {
              final item = baseProductData.first;
              if (item is Map) {
                selectedProductBaseId = item["id"]?.toString();
                selectedBaseProductName =
                    item["base_product_id"]?.toString(); // <-- New line
                print("Selected Product Base ID: $selectedProductBaseId");
                print(
                    "Base Product Name: $selectedBaseProductName"); // <-- New line
              }
            }
          }
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

// 1. ADD THESE VARIABLES at the top of your _CutToLengthSheetState class (around line 30)
  Map<String, dynamic>? apiResponse;
  bool showApiResponse = false;

// 2. MODIFY the postAllData() method to store the response (replace your existing postAllData method)
  Future<void> postAllData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": 2193,
      "product_name": selectedProduct,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": 34,
      "category_name": "Cut to Length Sheets"
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
      if (selectedProduct == null ||
          selectedMeterial == null ||
          selectedThichness == null ||
          selsectedCoat == null ||
          selectedyie == null ||
          selectedBrand == null) return;
      if (response.statusCode == 200) {
        // STORE THE API RESPONSE
        setState(() {
          apiResponse = jsonDecode(response.body);
          showApiResponse = true;
        });
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

// 3. ADD THIS NEW METHOD to build the API response UI
  Widget _buildApiResponseSection() {
    if (!showApiResponse || apiResponse == null) return SizedBox.shrink();

    final labels = apiResponse!['lebels'] as List;
    if (labels.isEmpty) return SizedBox.shrink();

    final categoryData = labels[0];
    final categoryLabels = categoryData['labels'] as List<dynamic>;
    final categoryDataList = categoryData['data'] as List<dynamic>;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Subhead(
                  text: "Order Details",
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
                Text(
                  "Order ID: ${apiResponse!['order_id']}",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...categoryDataList
                .map((item) => _buildApiResponseItem(item, categoryLabels))
                .toList(),
          ],
        ),
      ),
    );
  }

// 4. ADD THIS NEW METHOD to build individual API response items
  Widget _buildApiResponseItem(
      Map<String, dynamic> item, List<dynamic> labels) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name header
            Text(
              "${item['S.No']}. ${item['Products']}",
              style: GoogleFonts.figtree(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),

            // First Row: UOM and Billing Option (Dropdowns)
            Row(
              children: [
                Expanded(child: _buildUOMDropdown(item)),
                SizedBox(width: 10),
                Expanded(child: _buildBillingOptionDropdown(item)),
              ],
            ),
            SizedBox(height: 12),

            // Second Row: Length and Nos (Editable)
            Row(
              children: [
                Expanded(child: _buildEditableApiField(item, 'Length')),
                SizedBox(width: 10),
                Expanded(child: _buildEditableApiField(item, 'Nos')),
              ],
            ),
            SizedBox(height: 12),

            // Third Row: Basic Rate, Qty, Amount
            Row(
              children: [
                Expanded(child: _buildReadOnlyApiField(item, 'Basic Rate')),
                SizedBox(width: 10),
                Expanded(child: _buildEditableApiField(item, 'Qty')),
                SizedBox(width: 10),
                Expanded(child: _buildReadOnlyApiField(item, 'Amount')),
              ],
            ),
          ],
        ),
      ),
    );
  }

// 5. ADD THESE HELPER METHODS for the API response fields
  Widget _buildUOMDropdown(Map<String, dynamic> item) {
    final uomData = item['UOM'] as Map<String, dynamic>;
    final options = uomData['options'] as Map<String, dynamic>;
    final currentValue = uomData['value'].toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UOM',
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 6),
        SizedBox(
          height: 40.h,
          child: DropdownButtonFormField<String>(
            value: currentValue.isEmpty ? null : currentValue,
            items: options.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                item['UOM']['value'] = val!;
              });
            },
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
        ),
      ],
    );
  }

  Widget _buildBillingOptionDropdown(Map<String, dynamic> item) {
    final billingData = item['Billing Option'] as Map<String, dynamic>;
    final options = billingData['options'] as Map<String, dynamic>;
    final currentValue = billingData['value'].toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing Option',
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 6),
        SizedBox(
          height: 40.h,
          child: DropdownButtonFormField<String>(
            value: currentValue.isEmpty ? null : currentValue,
            items: options.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                item['Billing Option']['value'] = val!;
              });
            },
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
        ),
      ],
    );
  }

  Widget _buildEditableApiField(Map<String, dynamic> item, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldName,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 6),
        SizedBox(
          height: 38.h,
          child: TextField(
            controller: TextEditingController(text: item[fieldName].toString()),
            onChanged: (val) => item[fieldName] = val,
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
        ),
      ],
    );
  }

  Widget _buildReadOnlyApiField(Map<String, dynamic> item, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldName,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 6),
        Container(
          height: 38.h,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[100],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item[fieldName].toString(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      ],
    );
  }

  void _submitData() {
    if (selectedProduct == null ||
        selectedMeterial == null ||
        selectedThichness == null ||
        selsectedCoat == null ||
        selectedyie == null ||
        selectedBrand == null) {
// Show elegant error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Form'),
          content: Text('Please fill all required fields to add a product.'),
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
    setState(() {
      submittedData.add({
        "Product": "Length Sheets",
        "UOM": "Feet",
        "Length": "0",
        "Nos": "1",
        "Basic Rate": "0",
        "SQ": "0",
        "Amount": "0",
        "Base Product":
            "$selectedMeterial ,$selectedThichness, $selsectedCoat, $selectedyie, $selectedBrand, ",
      });
      selectedProduct = null;
      selectedMeterial = null;
      selectedThichness = null;
      selsectedCoat = null;
      selectedyie = null;
      selectedBrand = null;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSubmittedDataList() {
    if (submittedData.isEmpty) {
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
      children: submittedData.asMap().entries.map((entry) {
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
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SizedBox(
                      // color: Colors.red,
                      height: 40.h,
                      width: 210.w,

                      child: Text(
                        "  ${index + 1}.  ${data["Product"]}" ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
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
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Subhead(
                                      text:
                                          "Are you Sure to Delete This Item ?",
                                      weight: FontWeight.w500,
                                      color: Colors.black),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          submittedData.removeAt(index);
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
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                  )
                ],
              ),
              _buildApiResponseSection(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8),
                child: Container(
                  height: 40.h,
                  width: double.infinity.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // color: Colors.red,
                        height: 40.h,
                        width: 280.w,
                        child: TextField(
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          controller: TextEditingController(
                              text: " ${data["Base Product"]}"),
                          readOnly: true,
                        ),
                      ),
                      Gap(5),
                      Container(
                          height: 30.h,
                          width: 30.w,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: IconButton(
                              onPressed: () {
                                editController.text = data["Base Product"];
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Edit Your Length Sheet"),
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
                                                padding: const EdgeInsets.only(
                                                    left: 7.0),
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                  ),
                                                  controller: editController,
                                                  onSubmitted: (value) {
                                                    setState(() {
                                                      data["Base Product"] =
                                                          value;
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
                                                  color: Colors.black))
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 15,
                              )))
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

  String _selectedItems() {
    List<String> values = [
      if (selectedMeterial != null) "Material: $selectedMeterial",
      if (selectedThichness != null) "Thickness: $selectedThichness",
      if (selsectedCoat != null) "CoatingMass: $selsectedCoat",
      if (selectedyie != null) "YieldStrength: $selectedyie",
      if (selectedBrand != null) "Brand: $selectedBrand",
    ];

    return values.isEmpty ? "No selection yet" : values.join(",  ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Cut To Length Sheets',
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
                              color: Colors.black),
                          SizedBox(height: 16),
                          _buildAnimatedDropdown(productList, selectedProduct,
                              (value) {
                            setState(() {
                              selectedProduct = value;
                            });
                          },
                              label: "Product Name",
                              icon: Icons.category_outlined),
                          _buildAnimatedDropdown(meterialList, selectedMeterial,
                              (value) {
                            setState(() {
                              selectedMeterial = value;
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
                              icon: Icons.difference_outlined),
                          _buildAnimatedDropdown(
                              thichnessLists, selectedThichness, (value) {
                            setState(() {
                              selectedThichness = value;
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
                              icon: Icons.straighten_outlined),
                          _buildAnimatedDropdown(coatMassList, selsectedCoat,
                              (value) {
                            setState(() {
                              selsectedCoat = value;
                              selectedyie = null;
                              selectedBrand = null;
                              yieldsListt = [];
                              brandList = [];
                            });
                            _fetchYie();
                          },
                              enabled: coatMassList.isNotEmpty,
                              label: "Coating Mass",
                              icon: Icons.layers_outlined),
                          _buildAnimatedDropdown(yieldsListt, selectedyie,
                              (value) {
                            setState(() {
                              selectedyie = value;
                              selectedBrand = null;
                              brandList = [];
                            });
                            _fetchBrandss();
                          },
                              enabled: yieldsListt.isNotEmpty,
                              label: "Yield Strength",
                              icon: Icons.radio_button_checked),
                          _buildAnimatedDropdown(brandList, selectedBrand,
                              (value) {
                            setState(() {
                              selectedBrand = value;
                            });
                          },
                              enabled: brandList.isNotEmpty,
                              label: "Brand",
                              icon: Icons.brightness_auto_outlined),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.deepPurple[400]!, width: 1.5),
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
                              onPressed: () async {
                                await postAllData();
                                _submitData();
                              },
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

                // ADD THIS LINE - API Response Section
                _buildApiResponseSection(),

                SizedBox(height: 24),
                if (submittedData.isNotEmpty)
                  Subhead(
                      text: "   Added Products",
                      weight: FontWeight.w600,
                      color: Colors.black),
                SizedBox(height: 8),
                _buildSubmittedDataList(),
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
              prefixIcon:
                  Icon(icon, color: enabled ? Colors.blue : Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
