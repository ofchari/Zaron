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
import 'package:zaron/view/screens/global_user/global_user.dart';
import 'package:zaron/view/universal_api/api_key.dart';
import 'package:zaron/view/widgets/subhead.dart';

import '../../global_user/global_oredrID.dart';

class TileSheetPage extends StatefulWidget {
  const TileSheetPage({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<TileSheetPage> createState() => _TileSheetPageState();
}

class _TileSheetPageState extends State<TileSheetPage> {
  Map<String, dynamic>? categoryMeta;
  double? billamt;
  late TextEditingController editController;
  int? orderIDD;
  String? orderNO;
  String? selectedMaterial;
  String? selectedBrands;
  String? selectedColors;
  String? selectedThickness;
  String? selectedCoatingMass;
  String? selectedProductBaseId;

  // String? selectedBrand;

  List<String> materialList = [];
  List<String> brandandList = [];
  List<String> colorandList = [];
  List<String> thickAndList = [];
  List<String> coatingAndList = [];
  List<dynamic> rawTilesheet = [];

  // List<String> brandList = [];
  List<Map<String, dynamic>> submittedData = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController = TextEditingController(text: widget.data["Base Product"]);
    _fetchMaterialType();
    _fetchBrandData();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaterialType() async {
    setState(() {
      materialList = [];
      selectedMaterial = null;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/26');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final materials = data["message"]["message"][1];
        debugPrint("PRoduct:::$materials");
        debugPrint(response.body, wrapWidth: 1024);
        rawTilesheet = materials;

        if (materials is List) {
          setState(() {
            ///  Extract category info (message[0][0])
            final categoryInfoList = data["message"]["message"][0];
            if (categoryInfoList is List && categoryInfoList.isNotEmpty) {
              categoryMeta = Map<String, dynamic>.from(categoryInfoList[0]);
            }

            materialList = materials
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

  Future<void> _fetchBrandData() async {
    setState(() {
      brandandList = [];
      selectedBrands;
    });

    final client = IOClient(
      HttpClient()..badCertificateCallback = (_, __, ___) => true,
    );
    final url = Uri.parse('$apiUrl/showlables/26');

    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final brandData = data["message"]["message"][2][1];
        debugPrint(response.body);

        if (brandData is List) {
          setState(() {
            brandandList = brandData
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

  /// fetch colors Api's //
  Future<void> _fetchColorData() async {
    if (selectedBrands == null) return;

    setState(() {
      colorandList = [];
      selectedColors = null;
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
          // "category_id": "3",
          // "selectedlabel": "brand",
          // "selectedvalue": selectedBrands,
          // "label_name": "color",
          "product_label": "color",
          "product_filters": [selectedMaterial],
          "product_label_filters": ["material_type"],
          "product_category_id": 26,
          "base_product_filters": [selectedBrands],
          "base_label_filters": ["brand"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final selectedThickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedThickness");
        print("API response: ${response.body}");

        if (selectedThickness is List) {
          setState(() {
            colorandList = selectedThickness
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
  Future<void> _fetchThicknessData() async {
    if (selectedBrands == null) return;

    setState(() {
      thickAndList = [];
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
          // "category_id": "3",
          // "selectedlabel": "color",
          // "selectedvalue": selectedColors,
          // "label_name": "thickness",
          "product_label": "thickness",
          "product_filters": [selectedMaterial],
          "product_label_filters": ["material_type"],
          "product_category_id": 26,
          "base_product_filters": [selectedBrands, selectedColors],
          "base_label_filters": ["brand", "color"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"][0];
        print("Fetching colors for brand: $selectedColors");
        print("API response: ${response.body}");

        if (thickness is List) {
          setState(() {
            thickAndList = thickness
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
  Future<void> _fetchCoatingMassData() async {
    if (selectedBrands == null) return;

    setState(() {
      coatingAndList = [];
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
          "product_filters": [selectedMaterial],
          "product_label_filters": ["material_type"],
          "product_category_id": 26,
          "base_product_filters": [
            selectedBrands,
            selectedColors,
            selectedThickness,
          ],
          "base_label_filters": ["brand", "color", "thickness"],
          "base_category_id": 3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data["message"]["message"];
        print("Fetching coating_mass for brand: $selectedBrands");
        print("API response: ${response.body}");

        if (message is List && message.isNotEmpty) {
          final coatingList = message[0];
          if (coatingList is List) {
            setState(() {
              coatingAndList = coatingList
                  .whereType<Map>()
                  .map((e) => e["coating_mass"]?.toString())
                  .whereType<String>()
                  .toList();
            });
          }

          // Optional: extract product_base_id
          final baseIdData = message.length > 1 ? message[1] : null;
          if (baseIdData is List &&
              baseIdData.isNotEmpty &&
              baseIdData.first is Map) {
            selectedProductBaseId = baseIdData.first["id"]?.toString();
            print("Selected Product Base ID: $selectedProductBaseId");
          }
        }
      }
    } catch (e) {
      print("Exception fetching coating_mass: $e");
    }
  }

  ///post All Data
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

    // Find the matching item from rawAccessoriesData
    final matchingAccessory = rawTilesheet.firstWhere(
      (item) => item["material_type"] == selectedMaterial,
      orElse: () => null,
    );
    // Extract values
    final tileSheetProID = matchingAccessory?["id"];
    print("this os $tileSheetProID");
    final headers = {"Content-Type": "application/json"};
    final data = {
      "customer_id": UserSession().userId,
      "product_id": tileSheetProID,
      "product_name": selectedMaterial,
      "product_base_id": selectedProductBaseId,
      "product_base_name": "$selectedBrands,$selectedColors,$selectedThickness",
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

      if (selectedMaterial == null ||
          selectedBrands == null ||
          selectedColors == null ||
          selectedThickness == null ||
          selectedCoatingMass == null) {
        return;
      }

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

          if (responseData["lebels"] != null &&
              responseData["lebels"].isNotEmpty) {
            // Safely handle the response data
            List<dynamic> fullList = responseData["lebels"][0]["data"];
            List<Map<String, dynamic>> newProducts = [];

            for (var item in fullList) {
              if (item is Map<String, dynamic>) {
                Map<String, dynamic> product = Map<String, dynamic>.from(item);

                // Prevent duplicates
                String productId = product["id"].toString();
                bool alreadyExists = responseProducts
                    .any((existing) => existing["id"].toString() == productId);

                if (!alreadyExists) {
                  newProducts.add(product);
                }

                // Save UOM options if present
                if (product["UOM"] != null &&
                    product["UOM"]["options"] != null) {
                  uomOptions[product["id"].toString()] =
                      Map<String, String>.from(
                    (product["UOM"]["options"] as Map).map(
                      (key, value) =>
                          MapEntry(key.toString(), value.toString()),
                    ),
                  );
                }

                debugPrint(
                    "Product added: ${product["id"]} - ${product["Products"]}");
              }
            }

            // Add only new (non-duplicate) products
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

  TextEditingController baseProductController = TextEditingController();
  List<dynamic> baseProductResults = [];
  bool isSearchingBaseProduct = false;
  String? selectedBaseProduct;
  FocusNode baseProductFocusNode = FocusNode();

  void _submitData() {
    if (selectedMaterial == null ||
        selectedBrands == null ||
        selectedColors == null ||
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
          "Product": "Tile Sheets",
          "UOM": "Feet",
          "Length": "0",
          "Nos": "1",
          "Basic Rate": "0",
          "SQ": "0",
          "Amount": "0",
          "Base Product":
              "$selectedMaterial, $selectedBrands,$selectedColors, $selectedThickness, $selectedCoatingMass,",
        });
        selectedMaterial = null;
        selectedBrands = null;
        selectedColors = null;
        selectedThickness = null;
        selectedCoatingMass = null;
        brandandList = [];
        colorandList = [];
        thickAndList = [];
        coatingAndList = [];
        _fetchBrandData();
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
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // Add these variables after line 25 (after the existing List declarations)
  Map<String, dynamic>? apiResponseData;
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
                  Container(
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
                                        deleteCards(data["id"].toString());
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
              Gap(5),
            ],
          ),
        );
      }).toList(),
    );
  }

  // New method that organizes fields in rows, two fields per row
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
                  "Length",
                  _editableTextField(data, "Length"),
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
        Gap(5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  "CGST",
                  _editableTextField(data, "cgst"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildDetailItem(
                  "SGST",
                  _editableTextField(data, "sgst"),
                ),
              ),
            ],
          ),
        ),
        Gap(5.h),
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

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    final controller = _getController(data, key);

    return SizedBox(
      height: 38.h,
      child: TextField(
        readOnly: (key == "Basic Rate" ||
                key == "Amount" ||
                key == "SQMtr" ||
                key == "cgst" ||
                key == "sgst")
            ? true
            : false,
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
                key == "SQMtr" ||
                key == "cgst" ||
                key == "sgst")
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.numberWithOptions(decimal: true),
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

          if (key == "Length" || key == "Nos" || key == "Basic Rate") {
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

  Widget _uomDropdownFromApi(Map<String, dynamic> data) {
    String productId = data["id"].toString();
    Map<String, String>? options = uomOptions[productId];

    if (options == null || options.isEmpty) {
      return _editableTextField(data, "UOM");
    }

    String? currentValue;
    if (data["UOM"] is Map) {
      currentValue = data["UOM"]["value"]?.toString();
    } else {
      currentValue = data["UOM"]?.toString();
    }

    return SizedBox(
      height: 40.h,
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: options.entries
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = {"value": val, "options": options};
          });
          print("UOM changed to: $val"); // Debug print
          print(
            "Product data: ${data["Products"]}, ID: ${data["id"]}",
          ); // Debug print
          // Trigger calculation with debounce
          _debounceCalculation(data);
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

  String _selectedItems() {
    List<String> value = [
      if (selectedMaterial != null) "Material Type: $selectedMaterial",
      if (selectedBrands != null) "Brand: $selectedBrands",
      if (selectedColors != null) "Color: $selectedColors",
      if (selectedThickness != null) "Thickness: $selectedThickness",
      if (selectedCoatingMass != null) "CoatingMass: $selectedCoatingMass",
    ];
    return value.isEmpty ? "No selection yet" : value.join(",  ");
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

    // Get Length value from controller
    double lengthValue = 0;
    String? lengthText;

    if (fieldControllers.containsKey(productId) &&
        fieldControllers[productId]!.containsKey("Length")) {
      lengthText = fieldControllers[productId]!["Length"]!.text;
      print("Length from controller: $lengthText");
    }

    if (lengthText == null || lengthText.isEmpty) {
      lengthText = data["Length"]?.toString();
      print("Length from data: $lengthText");
    }

    if (lengthText != null && lengthText.isNotEmpty) {
      lengthValue = double.tryParse(lengthText) ?? 0;
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

    print("Final Profile Value: $lengthValue");
    print("Final Nos Value: $nosValue");

    final requestBody = {
      "id": int.tryParse(data["id"].toString()) ?? 0,
      "category_id": 26,
      "product": data["Products"]?.toString() ?? "",
      "height": null,
      "previous_uom": previousUomValues[productId] != null
          ? int.tryParse(previousUomValues[productId]!)
          : null,
      "current_uom": currentUom != null ? int.tryParse(currentUom) : null,
      "length": lengthValue,
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
            billamt = responseData["bill_total"].toDouble() ?? 0.0;

            print("billamt updated to: $billamt");
            calculationResults[productId] = responseData;

            // Handle Length update
            if (responseData["length"] != null) {
              String newLength = responseData["length"].toString().trim();
              data["Length"] = newLength;
              if (fieldControllers[productId]?["Length"] != null) {
                fieldControllers[productId]!["Length"]!.text = newLength;
              }
              print("Length field updated to: $newLength");
            }

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

            if (responseData["sqmtr"] != null) {
              data["SQMtr"] = responseData["sqmtr"].toString();
              if (fieldControllers[productId]?["SQMtr"] != null) {
                fieldControllers[productId]!["SQMtr"]!.text =
                    responseData["sqmtr"].toString();
              }
            }

            if (responseData["cgst"] != null) {
              data["cgst"] = responseData["cgst"].toString();
              if (fieldControllers[productId]?["cgst"] != null) {
                fieldControllers[productId]!["cgst"]!.text =
                    responseData["cgst"].toString();
              }
            }
            if (responseData["sgst"] != null) {
              data["sgst"] = responseData["sgst"].toString();
              if (fieldControllers[productId]?["sgst"] != null) {
                fieldControllers[productId]!["sgst"]!.text =
                    responseData["sgst"].toString();
              }
            }

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
            "Updated data: Length=${data["Profile"]}, Nos=${data["Nos"]}, R.Ft=${data["R.Ft"]}, Amount=${data["Amount"]}",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(
          text: 'Tile Sheet',
          weight: FontWeight.w500,
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
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
                          Subhead(
                            text: "Add New Product",
                            weight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          SizedBox(height: 16),
                          _buildAnimatedDropdown(
                            materialList,
                            selectedMaterial,
                            (value) {
                              setState(() {
                                selectedMaterial = value;
                              });
                              // _fetchProductName();
                            },
                            // enabled: productList.isNotEmpty,
                            label: "Material Type",
                            icon: Icons.category_outlined,
                          ),
                          _buildAnimatedDropdown(
                            brandandList,
                            selectedBrands,
                            (value) {
                              setState(() {
                                selectedBrands = value;

                                ///clear fields
                                selectedColors = null;
                                selectedThickness = null;
                                selectedCoatingMass = null;
                                colorandList = [];
                                thickAndList = [];
                                coatingAndList = [];
                              });
                              _fetchColorData();
                            },
                            enabled: brandandList.isNotEmpty,
                            label: "Brand",
                            icon: Icons.brightness_auto_outlined,
                          ),
                          _buildAnimatedDropdown(
                            colorandList,
                            selectedColors,
                            (value) {
                              setState(() {
                                selectedColors = value;

                                ///clear fields
                                selectedThickness = null;
                                selectedCoatingMass = null;
                                thickAndList = [];
                                coatingAndList = [];
                              });
                              _fetchThicknessData();
                            },
                            enabled: colorandList.isNotEmpty,
                            label: "Color",
                            icon: Icons.color_lens_outlined,
                          ),
                          _buildAnimatedDropdown(
                            thickAndList,
                            selectedThickness,
                            (value) {
                              setState(() {
                                selectedThickness = value;

                                ///clear fields
                                selectedCoatingMass = null;
                                coatingAndList = [];
                              });
                              _fetchCoatingMassData();
                            },
                            enabled: thickAndList.isNotEmpty,
                            label: "Thickness",
                            icon: Icons.straighten_outlined,
                          ),
                          _buildAnimatedDropdown(
                            coatingAndList,
                            selectedCoatingMass,
                            (value) {
                              setState(() {
                                selectedCoatingMass = value;
                              });
                            },
                            enabled: coatingAndList.isNotEmpty,
                            label: "Coating Mass",
                            icon: Icons.layers_outlined,
                          ),
                          // SizedBox(height: 24),
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
                if (submittedData.isNotEmpty) ...[
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Decking Sheets",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
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
                                      "ID: ${orderNO ?? 0.0}",
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
}
