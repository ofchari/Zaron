import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:zaron/view/screens/new_enquirys/new_enquiry.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

class Accessories extends StatefulWidget {
  const Accessories({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<Accessories> createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
  String? selectedAccessory;
  String? selectedBrand;
  String? selectedColor;
  String? selectedThickness;
  String? selectedCoatingMass;

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<String> coatingMassList = [];

  List<Map<String, dynamic>> submittedData = [];

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchBrands(String accessory) async {
    setState(() {
      brandsList = [];
      selectedBrand = null;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(client);

    final data = {
      "id": '3',
      "inputname": 'brand',
    };

    final url = 'http://demo.zaron.in:8181/index.php/order/first_check_select_base_product';
    final body = jsonEncode(data);

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey("brand")) {
          final brandData = responseData["brand"];
          if (brandData is List && brandData.isNotEmpty) {
            setState(() {
              brandsList = List<String>.from(brandData);
            });
          }
        }
      }
    } catch (e) {
      print("Exception: $e");
    }
  }


  Future<void> _fetchColors(String brand) async {
    setState(() {
      colorsList = [];

      selectedColor = null;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(client);

    final data = {
      "values": brand,
      "id": "3",
      "inputname": "brand",
      "setgetvalue": brand,
      "product_value": [brand, null, null, null],
      "category_value": ["brand", "color", "thickness", "coating_mass"]
    };

    final url = 'http://demo.zaron.in:8181/index.php/order/select_base_product';
    final body = jsonEncode(data);

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey("color")) {
          final colorData = responseData["color"];
          if (colorData is List && colorData.isNotEmpty) {
            setState(() {
              colorsList = List<String>.from(colorData);
            });
          }
        }
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> _fetchThickness(String color) async {
    setState(() {
      thicknessList = [];
      selectedThickness = null;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(client);

    final data = {
      "values": selectedBrand,
      "id": "3",
      "inputname": "color",
      "setgetvalue": color,
      "product_value": [selectedBrand, color, null, null],
      "category_value": ["brand", "color", "thickness", "coating_mass"]
    };

    final url = 'http://demo.zaron.in:8181/index.php/order/select_base_product';
    final body = jsonEncode(data);

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey("thickness")) {
          final thicknessData = responseData["thickness"];
          if (thicknessData is List && thicknessData.isNotEmpty) {
            setState(() {
              thicknessList = List<String>.from(thicknessData);
            });
          }
        }
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> _fetchCoatingMass(String thickness) async {
    setState(() {
      coatingMassList = [];
      selectedCoatingMass = null;
    });

    HttpClient client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(client);

    final data = {
      "values": "$selectedBrand $selectedColor $thickness",
      "id": "3",
      "inputname": "thickness",
      "setgetvalue": thickness,
      "product_value": [selectedBrand, selectedColor, thickness, null],
      "category_value": ["brand", "color", "thickness", "coating_mass"]
    };

    final url = 'http://demo.zaron.in:8181/index.php/order/select_base_product';
    final body = jsonEncode(data);

    try {
      final response = await ioClient.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey("coating_mass")) {
          final coatingMassData = responseData["coating_mass"];
          if (coatingMassData is List && coatingMassData.isNotEmpty) {
            setState(() {
              coatingMassList = List<String>.from(coatingMassData);
            });
          }
        }
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void _submitData() {
    if (selectedAccessory == null ||
        selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null ||
        selectedCoatingMass == null) {
      // Show elegant error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incomplete Form'),
          content: Text('Please fill all required fields to add a product.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), child: Text('OK'),
              ),
          ],
        ),
      );
      return;
    }

    setState(() {
      submittedData.add({
        "Product": selectedAccessory!,
        "UOM": "Feet",
        "Length": "0",
        "Nos": "1",
        "Basic Rate": "0",
        "SQ": "0",
        "Amount": "0",
        "Base Product": "$selectedBrand, $selectedColor, $selectedThickness, $selectedCoatingMass",
      });


      selectedAccessory = null;
      selectedBrand = null;
      selectedColor = null;
      selectedThickness = null;
      selectedCoatingMass = null;

      brandsList = [];
      colorsList = [];
      thicknessList = [];
      coatingMassList = [];
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   MyText(text: data["Product"] ?? "", weight: FontWeight.w500, color: Colors.black),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          submittedData.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
                // SizedBox(height: 1),
                _buildProductDetailInRows(data),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // New method that organizes fields in rows, two fields per row
  Widget _buildProductDetailInRows(Map<String, dynamic> data) {
    return Column(
      children: [
        // Row 1: Product & UOM
        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildDetailItem("Product", Text(data["Product"] ?? "")),
        //     ),
        //     SizedBox(width: 16),
        //
        //   ],
        // ),
        SizedBox(height: 16),

        // Row 2: Length & Nos
        Row(
          children: [
            Expanded(
              child: _buildDetailItem("UOM", _uomDropdown(data)),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: _buildDetailItem("Length", _editableTextField(data, "Length")),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem("Nos", _editableTextField(data, "Nos")),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Row 3: Basic Rate & SQ
        Row(
          children: [
            Expanded(
              child: _buildDetailItem("Basic Rate", _editableTextField(data, "Basic Rate")),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDetailItem("SQ", _editableTextField(data, "SQ")),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: _buildDetailItem("Amount", _editableTextField(data, "Amount")),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Row 4: Amount & Base Product
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem("Base Product", _baseProductField(data)),
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
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _editableTextField(Map<String, dynamic> data, String key) {
    return Container(
      height: 40,
      child: TextField(
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
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }


  Widget _baseProductField(Map<String, dynamic> data) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: TextEditingController(text: data["Base Product"]),
        onChanged: (val) => data["Base Product"] = val,
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
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        readOnly: true,
      ),
    );
  }

  Widget _uomDropdown(Map<String, dynamic> data) {
    List<String> uomOptions = ["Feet", "mm", "cm"];
    return Container(
      height: 40,
      child: DropdownButtonFormField<String>(
        value: data["UOM"],
        items: uomOptions
            .map((uom) => DropdownMenuItem(value: uom, child: Text(uom)))
            .toList(),
        onChanged: (val) {
          setState(() {
            data["UOM"] = val!;
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
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged,
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
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
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
    List<String> accessoriesList = List<String>.from(widget.data["accessories_name"] ?? []);
    return Scaffold(
      appBar: AppBar(
        title: Subhead(text: 'Accessories', weight: FontWeight.w500, color: Colors.black,),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white
        ,
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
                          Subhead(text: "Add New Product", weight: FontWeight.w600, color: Colors.black),

                          SizedBox(height: 16),
                          _buildDropdown(accessoriesList, selectedAccessory, (value) {
                            setState(() {
                              selectedAccessory = value;
                            });
                            _fetchBrands(value!);
                          }, label: "Accessories Name"),
                          _buildDropdown(brandsList, selectedBrand, (value) {
                            setState(() {
                              selectedBrand = value;
                            });
                            _fetchColors(value!);
                          }, enabled: brandsList.isNotEmpty, label: "Brand"),
                          _buildDropdown(colorsList, selectedColor, (value) {
                            setState(() {
                              selectedColor = value;
                            });
                            _fetchThickness(value!);
                          }, enabled: colorsList.isNotEmpty, label: "Color"),
                          _buildDropdown(thicknessList, selectedThickness, (value) {
                            setState(() {
                              selectedThickness = value;
                            });
                            _fetchCoatingMass(value!);
                          }, enabled: thicknessList.isNotEmpty, label: "Thickness"),
                          _buildDropdown(coatingMassList, selectedCoatingMass, (value) {
                            setState(() {
                              selectedCoatingMass = value;
                            });
                          }, enabled: coatingMassList.isNotEmpty, label: "Coating Mass"),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitData,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: MyText(text: "Add Bag", weight: FontWeight.w600, color: Colors.white),

                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                if (submittedData.isNotEmpty)
                  Subhead(text: "   Added Products", weight: FontWeight.w600, color: Colors.black),

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