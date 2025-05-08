import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

import '../../universal_api/api&key.dart';

class Polycarbonate extends StatefulWidget {
  const Polycarbonate({super.key, required this.data, required this.userid});
  final String userid;
  final Map<String, dynamic> data;

  @override
  State<Polycarbonate> createState() => _PolycarbonateState();
}

class _PolycarbonateState extends State<Polycarbonate> {
  late TextEditingController editController;

  String? selectedBrand;
  String? selectedColor;
  String? selectedThickness;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<Map<String, dynamic>> submittedData = [];
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    editController =
        TextEditingController(text: widget.data["Base Product"] ?? "");
    _fetchBrands();
  }

  @override
  void dispose() {
    editController.dispose();
    super.dispose();
  }

  Future<void> _fetchBrands() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final client =
          IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
      final response = await client.get(Uri.parse('$apiUrl/showlables/19'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Brands API Response: ${response.body}");

        final message = data["message"]["message"];
        if (message is List && message.isNotEmpty) {
          // Find the correct element containing brands
          final brandsData = message.firstWhere(
            (element) =>
                element is List &&
                element.any((e) => e["type_of_panel"] != null),
            orElse: () => [],
          );

          if (brandsData is List) {
            setState(() {
              brandsList = brandsData
                  .whereType<Map>()
                  .map((e) => e["type_of_panel"]?.toString() ?? "")
                  .where((e) => e.isNotEmpty)
                  .toList();
            });
          }
        }
      } else {
        _showErrorSnackBar("Failed to load brands: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Brands Error: $e");
      _showErrorSnackBar("Error loading brands");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchColors() async {
    if (selectedBrand == null || !mounted) return;

    setState(() => isLoading = true);

    try {
      final client =
          IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
      final response = await client.post(
        Uri.parse('$apiUrl/onchangeinputdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "color",
          "base_product_filters": [selectedBrand],
          "base_label_filters": ["type_of_panel"],
          "base_category_id": "19",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = data["message"]["message"] ?? [];

        if (colors is List) {
          setState(() {
            colorsList = colors
                .whereType<Map>()
                .map((e) => e["color"]?.toString() ?? "")
                .where((e) => e.isNotEmpty)
                .toList();
          });
        }
      } else {
        _showErrorSnackBar("Failed to load colors: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Colors Error: $e");
      _showErrorSnackBar("Error loading colors");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchThickness() async {
    if (selectedBrand == null || selectedColor == null || !mounted) return;

    setState(() => isLoading = true);

    try {
      final client =
          IOClient(HttpClient()..badCertificateCallback = (_, __, ___) => true);
      final response = await client.post(
        Uri.parse('$apiUrl/onchangeinputdata'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "product_label": "thickness",
          "base_product_filters": [selectedBrand, selectedColor],
          "base_label_filters": ["type_of_panel", "color"],
          "base_category_id": "19",
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thickness = data["message"]["message"] ?? [];

        if (thickness is List) {
          setState(() {
            thicknessList = thickness
                .whereType<Map>()
                .map((e) => e["thickness"]?.toString() ?? "")
                .where((e) => e.isNotEmpty)
                .toList();
          });
        }
      } else {
        _showErrorSnackBar("Failed to load thickness: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Thickness Error: $e");
      _showErrorSnackBar("Error loading thickness");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildDetailItem(String label, Widget field) {
    return Container(
      child: Column(
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
      ),
    );
  }

  String selectPolycarbonate() {
    List<String> values = [
      if (selectedBrand != null) "Brand: $selectedBrand",
      if (selectedColor != null) "Color: $selectedColor",
      if (selectedThickness != null) "Thickness: $selectedThickness",
    ];
    return values.isEmpty ? "No selection yet" : values.join(",  ");
  }

  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged,
      {bool enabled = true, String? label}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        items: items,
        selectedItem: selectedValue,
        onChanged: enabled ? onChanged : null,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label ?? "Select",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        enabled: enabled,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.search),
            ),
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
          text: 'Polycarbonate',
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
                          _buildDropdown(brandsList, selectedBrand, (value) {
                            setState(() {
                              selectedBrand = value;
// Clear dependent fields
                              selectedColor = null;
                              selectedThickness = null;
                              colorsList = [];
                              thicknessList = [];
                            });
                            _fetchColors();
                          }, label: "Brand"),
                          _buildDropdown(colorsList, selectedColor, (value) {
                            setState(() {
                              selectedColor = value;
// Clear dependent fields
                              selectedThickness = null;
                              thicknessList = [];
                            });
                            _fetchThickness();
                          }, enabled: colorsList.isNotEmpty, label: "Color"),
                          _buildDropdown(thicknessList, selectedThickness,
                              (value) {
                            setState(() {
                              selectedThickness = value;
                            });
                          },
                              enabled: thicknessList.isNotEmpty,
                              label: "Thickness"),
                          Gap(20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                      text: "Selected Product Details",
                                      weight: FontWeight.w600,
                                      color: Colors.black),
                                  Gap(5),
                                  MyText(
                                      text: selectPolycarbonate(),
                                      weight: FontWeight.w400,
                                      color: Colors.grey)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                // await postPolycarbonateData();
                                // _submitData();
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: MyText(
                                  text: "Add Product",
                                  weight: FontWeight.w600,
                                  color: Colors.white),
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
                // _buildSubmittedDataList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
