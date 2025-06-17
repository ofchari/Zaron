import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../universal_api/api&key.dart';

class ScrewAccessories extends StatefulWidget {
  const ScrewAccessories({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<ScrewAccessories> createState() => _ScrewAccessoriesState();
}

class _ScrewAccessoriesState extends State<ScrewAccessories> {
  late TextEditingController editController;

  String? selectedProduct;
  String? selectedColor;
  String? selsectedBrand;
  String? selectedProductBaseId;
  String? selectedBaseProductName;

  List<String> productList = [];
  List<String> colorsList = [];
  List<String> brandList = [];
  List<Map<String, dynamic>> submittedData = [];

// Form key for validation
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
      productList = [];
      selectedProduct = null;
    });

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
    final url = Uri.parse('$apiUrl/showlables/9');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data["message"]["message"][1];

        debugPrint(response.body);

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

  /// fetch colors Api's //
  Future<void> _fetchColors() async {
    if (selectedProduct == null) return;

    setState(() {
      colorsList = [];
      selectedColor = null;
    });

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
          "base_product_filters": [selectedProduct],
          "base_label_filters": ["product_name"],
          "base_category_id": "9",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedProduct");
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
  Future<void> _fetchBrand() async {
    if (selectedProduct == null) return;

    setState(() {
      brandList = [];
      selsectedBrand = null;
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
          "product_filters": null,
          "product_label_filters": null,
          "product_category_id": null,
          "base_product_filters": [selectedProduct, selectedColor],
          "base_label_filters": ["product_name", "color"],
          "base_category_id": "9",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print("Fetching brand for product: $selectedProduct");
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          // Extract brand list
          final brandListData = message[0];
          if (brandListData is List) {
            setState(() {
              brandList = brandListData
                  .whereType<Map>()
                  .map((e) => e["brand"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          // Extract both id and base_product_id
          final idData = message.length > 1 ? message[1] : null;
          if (idData is List && idData.isNotEmpty && idData.first is Map) {
            selectedProductBaseId = idData.first["id"]?.toString();
            selectedBaseProductName =
                idData.first["base_product_id"]?.toString(); // <-- new line
            print("Selected Base Product ID: $selectedProductBaseId");
            print(
                "Base Product Name: $selectedBaseProductName"); // <-- optional debug
          }
        }
      }
    } catch (e) {
      print("Exception fetching brand: $e");
    }
  }

  Map<String, dynamic>? apiResponse;
  List<dynamic> responseData = [];

  ///postData

  Future<void> postAllData() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": 377423,
      "product_id": null,
      "product_name": null,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBaseProductName",
      "category_id": 9,
      "category_name": "Screw accessories"
    };

    print("User input Data $data");
    final url = "$apiUrl/addbag";
    final body = jsonEncode(data);

    try {
      final response =
          await ioClient.post(Uri.parse(url), headers: headers, body: body);

      debugPrint("This is a response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          apiResponse = jsonResponse;
          // Extract the data from first category
          if (jsonResponse['lebels'] != null &&
              jsonResponse['lebels'].isNotEmpty) {
            responseData = jsonResponse['lebels'][0]['data'];
          }
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Order created successfully!"),
          backgroundColor: Colors.green,
        ));
      } else {
        // Handle non-200 responses
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to create order: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ));
      }
    } on SocketException catch (e) {
      throw Exception("Network error: $e");
    } on HttpException catch (e) {
      throw Exception("HTTP error: $e");
    } on FormatException catch (e) {
      throw Exception("Data parsing error: $e");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    } finally {
      client.close();
    }
  }

  /// fetch Thickness Api's ///

  void _submitData() {
    if (selectedProduct == null || selectedColor == null) {
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
        "Product": "Screw Accessories",
        "UOM": "Feet",
        "Length": "0",
        "Nos": "1",
        "Basic Rate": "0",
        "SQ": "0",
        "Amount": "0",
        "Base Product": "$selectedProduct, $selectedColor, $selsectedBrand,",
      });
      selectedProduct = null;
      selectedColor = null;
      selsectedBrand = null;
      productList = [];
      colorsList = [];
      brandList = [];
      _fetchBrands();
    });

// Show success message with a more elegant snackbar
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
    if (responseData.isEmpty) {
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
      children: responseData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> product = entry.value as Map<String, dynamic>;

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
                    if (product['id'] != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      height: 40,
                      width: 50,
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
                                  "Are you sure you want to delete this item?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      responseData.removeAt(index);
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

  Widget _buildApiProductDetailInRows(Map<String, dynamic> product) {
    return Column(
      children: [
        // First Row: Basic Rate & Nos
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                "Basic Rate",
                _editableTextField(product, 'Basic Rate'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem(
                "Nos",
                _editableTextField(product, 'Nos'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Second Row: Amount
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                "Amount",
                Text(
                  product['Amount']?.toString() ?? '0',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
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
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _editableTextField(Map<String, dynamic> product, String key) {
    return TextField(
      controller: TextEditingController(text: product[key]?.toString() ?? ''),
      onChanged: (value) {
        product[key] = value;
        // Auto-calculate Amount if both Basic Rate and Nos are available
        if (key == 'Basic Rate' || key == 'Nos') {
          final rate = double.tryParse(product['Basic Rate'] ?? '0') ?? 0;
          final nos = double.tryParse(product['Nos'] ?? '0') ?? 0;
          product['Amount'] = (rate * nos).toStringAsFixed(2);
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  String _selectedItems() {
    List<String> value = [
      if (selectedProduct != null) "Product: $selectedProduct",
      if (selectedColor != null) "Color: $selectedColor",
      if (selsectedBrand != null) "Brand: $selsectedBrand",
    ];
    return value.isEmpty ? "No selections yet" : value.join(",  ");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Screw Accessories',
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

                              ///clear fields
                              selectedColor = null;
                              selsectedBrand = null;
                              colorsList = [];
                              brandList = [];
                            });
                            _fetchColors();
                          }, label: "Products", icon: Icons.category_outlined),
                          _buildAnimatedDropdown(colorsList, selectedColor,
                              (value) {
                            setState(() {
                              selectedColor = value;

                              ///clear fields
                              selsectedBrand = null;
                              brandList = [];
                            });
                            _fetchBrand();
                          },
                              enabled: colorsList.isNotEmpty,
                              label: "Color",
                              icon: Icons.color_lens_outlined),
                          _buildAnimatedDropdown(brandList, selsectedBrand,
                              (value) {
                            setState(() {
                              selsectedBrand = value;
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
}
