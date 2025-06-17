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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
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

    final client =
        IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
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
            selectedThickness
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
              "Base Product Name: $selectedBaseProductName"); // <-- Optional debug
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
      "category_name": "Iron And Steel Corrugated Sheet"
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
        // Parse the API response and store it
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['lebels'] != null) {
          setState(() {
            apiResponseData = List<Map<String, dynamic>>.from(
                responseData['lebels'][0]['data']);
          });
        }
      }
    } catch (e) {
      throw Exception("Error posting data: $e");
    }
  }

  Widget _buildApiResponseList() {
    if (apiResponseData.isEmpty) {
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
      children: apiResponseData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> data = entry.value;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with product name and delete button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "${data["S.No"]}. ${data["Products"]}" ?? "",
                        style: GoogleFonts.figtree(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            builder: (context) => AlertDialog(
                              title: Text("Are you sure to delete this item?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      apiResponseData.removeAt(index);
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
                  ),
                ],
              ),

              // Product details in rows
              _buildApiProductDetails(data, index),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApiProductDetails(Map<String, dynamic> data, int index) {
    return Column(
      children: [
        // Row 1: UOM, Profile, Crimp
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem("UOM", _buildUOMDropdown(data, index)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Profile", _buildEditableField(data, "Profile", index)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Crimp", _buildEditableField(data, "Crimp", index)),
              ),
            ],
          ),
        ),

        // Row 2: Nos, Basic Rate, Sq.Mtr
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                    "Nos", _buildEditableField(data, "Nos", index)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem("Basic Rate",
                    _buildEditableField(data, "Basic Rate", index)),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                    "Sq.Mtr", _buildEditableField(data, "Sq.Mtr", index)),
              ),
            ],
          ),
        ),

        // Row 3: Amount
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                    "Amount", _buildEditableField(data, "Amount", index)),
              ),
              SizedBox(width: 20),
              Expanded(child: Container()), // Empty space
              SizedBox(width: 20),
              Expanded(child: Container()), // Empty space
            ],
          ),
        ),

        Gap(10),
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

  Widget _buildUOMDropdown(Map<String, dynamic> data, int index) {
    Map<String, dynamic> uomData = data["UOM"];
    String currentValue = uomData["value"];
    Map<String, dynamic> options = uomData["options"];

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.entries
            .map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            apiResponseData[index]["UOM"]["value"] = val!;
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
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildEditableField(Map<String, dynamic> data, String key, int index) {
    return SizedBox(
      height: 38.h,
      child: TextField(
        style: GoogleFonts.figtree(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15.sp,
        ),
        controller: TextEditingController(text: data[key].toString()),
        onChanged: (val) {
          setState(() {
            apiResponseData[index][key] = val;
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
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
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
                          _buildAnimatedDropdown(brandsList, selectedBrand,
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
                              icon: Icons.brightness_auto_outlined),
                          _buildAnimatedDropdown(colorsList, selectedColor,
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
                              icon: Icons.color_lens_outlined),
                          _buildAnimatedDropdown(
                              thicknessList, selectedThickness, (value) {
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
                              icon: Icons.straighten_outlined),
                          _buildAnimatedDropdown(
                              coatingMassList, selectedCoatingMass, (value) {
                            setState(() {
                              selectedCoatingMass = value;
                            });
                          },
                              enabled: coatingMassList.isNotEmpty,
                              label: "Coating Mass",
                              icon: Icons.layers_outlined),
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
                                // _submitData();
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
                SizedBox(height: 24),
                if (apiResponseData.isNotEmpty)
                  Subhead(
                      text: "   Added Products",
                      weight: FontWeight.w600,
                      color: Colors.black),
                SizedBox(height: 8),
                _buildApiResponseList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
