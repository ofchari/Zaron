import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

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
  final TextEditingController coatingMassController = TextEditingController();

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<String> coatingMassList = [];
  List<Map<String, String>> submittedData = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchBrands(String s) async {
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
        final responseBody = response.body;
        print("API Response: $responseBody"); // Debugging

        final responseData = jsonDecode(responseBody);

        if (responseData is Map && responseData.containsKey("brand")) {
          final brandData = responseData["brand"];

          if (brandData is List && brandData.isNotEmpty) {
            setState(() {
              brandsList = List<String>.from(brandData);
              selectedBrand = null;
            });
          } else {
            print("No brands found in API response.");
          }
        } else {
          print("Invalid API response format.");
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
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
        final responseBody = response.body;
        print("Color API Response: $responseBody"); // Debugging

        final responseData = jsonDecode(responseBody);

        if (responseData is Map && responseData.containsKey("color")) {
          final colorData = responseData["color"];

          if (colorData is List && colorData.isNotEmpty) {
            setState(() {
              colorsList = List<String>.from(colorData);
              selectedColor = null;
            });
          } else {
            print("No colors found in API response.");
          }
        } else {
          print("Invalid API response format.");
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
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
        final responseBody = response.body;
        print("Thickness API Response: $responseBody"); // Debugging

        final responseData = jsonDecode(responseBody);

        if (responseData is Map && responseData.containsKey("thickness")) {
          final thicknessData = responseData["thickness"];

          if (thicknessData is List && thicknessData.isNotEmpty) {
            setState(() {
              thicknessList = List<String>.from(thicknessData);
              selectedThickness = null;
            });
          } else {
            print("No thickness options found in API response.");
          }
        } else {
          print("Invalid API response format for thickness.");
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception in fetching thickness: $e");
    }
  }

  Future<void> _fetchCoatingMass(String thickness) async {
    setState(() {
      coatingMassList = [];
      selectedCoatingMass = null;
      coatingMassController.clear();
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
        final responseBody = response.body;
        print("Coating Mass API Response: $responseBody"); // Debugging

        final responseData = jsonDecode(responseBody);

        if (responseData is Map && responseData.containsKey("coating_mass")) {
          final coatingMassData = responseData["coating_mass"];

          if (coatingMassData is List && coatingMassData.isNotEmpty) {
            setState(() {
              coatingMassList = List<String>.from(coatingMassData);
              selectedCoatingMass = null;
            });
          } else {
            print("No coating mass options found in API response.");
          }
        } else {
          print("Invalid API response format for coating mass.");
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception in fetching coating mass: $e");
    }
  }

  void _submitData() {
    if (selectedAccessory == null ||
        selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null ||
        selectedCoatingMass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      submittedData.add({
        "Accessory": selectedAccessory!,
        "Brand": selectedBrand!,
        "Color": selectedColor!,
        "Thickness": selectedThickness!,
        "Coating Mass": selectedCoatingMass!,
      });

      selectedAccessory = null;
      selectedBrand = null;
      selectedColor = null;
      selectedThickness = null;
      selectedCoatingMass = null;
      coatingMassController.clear();
      brandsList = [];
      colorsList = [];
      thicknessList = [];
      coatingMassList = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data Submitted Successfully"), backgroundColor: Colors.green),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<String> accessoriesList = List<String>.from(widget.data["accessories_name"] ?? []);
    return Scaffold(
      appBar: AppBar(
          title: Text("Accessories"),
          centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Accessories Name:"),
              _buildDropdown(accessoriesList, selectedAccessory, (value) {
                setState(() {
                  selectedAccessory = value;
                  brandsList = [];
                  colorsList = [];
                  thicknessList = [];
                  coatingMassList = [];
                });
                _fetchBrands(value!);
              }),

              _buildLabel("Brand:"),
              _buildDropdown(brandsList, selectedBrand, (value) {
                setState(() {
                  selectedBrand = value;
                  colorsList = [];
                  thicknessList = [];
                  coatingMassList = [];
                  selectedColor = null;
                  selectedThickness = null;
                  selectedCoatingMass = null;
                });
                _fetchColors(value!);
              }, enabled: brandsList.isNotEmpty),

              _buildLabel("Color:"),
              _buildDropdown(colorsList, selectedColor, (value) {
                setState(() {
                  selectedColor = value;
                  thicknessList = [];
                  coatingMassList = [];
                  selectedThickness = null;
                  selectedCoatingMass = null;
                });
                _fetchThickness(value!);
              }, enabled: colorsList.isNotEmpty),

              _buildLabel("Thickness:"),
              _buildDropdown(thicknessList, selectedThickness, (value) {
                setState(() {
                  selectedThickness = value;
                  coatingMassList = [];
                  selectedCoatingMass = null;
                });
                _fetchCoatingMass(value!);
              }, enabled: thicknessList.isNotEmpty),

              _buildLabel("Coating Mass:"),
              _buildDropdown(coatingMassList, selectedCoatingMass, (value) {
                setState(() {
                  selectedCoatingMass = value;
                });
              }, enabled: coatingMassList.isNotEmpty),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),

                  child: Text("Submit"),
                ),
              ),

              SizedBox(height: 20),
              submittedData.isEmpty ? _emptyMessage() : _buildSubmittedData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyMessage() {
    return Center(child: Text("No submissions yet."));
  }


  Widget _buildSubmittedData() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: submittedData.length,
      itemBuilder: (context, index) {
        final data = submittedData[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(entry.value, style: TextStyle(color: Colors.black54)),
                    Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),
      ),
    );
  }

               ///  Replace the existing _buildDropdown with this ///

  Widget _buildDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownSearch<String>(
        items: items,
        selectedItem: selectedValue,
        onChanged: enabled ? onChanged : null,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: "Select",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        enabled: enabled,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Search...",
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        dropdownButtonProps: DropdownButtonProps(
          isVisible: true,
        ),
      ),
    );
  }
}

