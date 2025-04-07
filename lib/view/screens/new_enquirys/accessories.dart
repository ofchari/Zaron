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
  final TextEditingController sqFeetController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController uomController = TextEditingController();
  final TextEditingController nosController = TextEditingController();

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<String> coatingMassList = [];

  List<Map<String, dynamic>> submittedData = [];

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
        "Sq. Feet": sqFeetController.text,
        "Length": lengthController.text,
        "UOM": uomController.text,
        "Nos": nosController.text,
      });

      selectedAccessory = null;
      selectedBrand = null;
      selectedColor = null;
      selectedThickness = null;
      selectedCoatingMass = null;

      coatingMassController.clear();
      sqFeetController.clear();
      lengthController.clear();
      uomController.clear();
      nosController.clear();

      brandsList = [];
      colorsList = [];
      thicknessList = [];
      coatingMassList = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data Submitted Successfully"), backgroundColor: Colors.green),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
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
              children: data.entries.map((entry) {
                if (["Sq. Feet", "Length", "UOM", "Nos"].contains(entry.key)) {
                  return TextField(
                    decoration: InputDecoration(
                      labelText: entry.key,
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: entry.value.toString()),
                    onChanged: (newVal) {
                      data[entry.key] = newVal;
                    },
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(entry.value.toString(), style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  );
                }
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
      ),
    );
  }

  Widget _emptyMessage() {
    return Center(child: Text("No submissions yet."));
  }

  @override
  Widget build(BuildContext context) {
    List<String> accessoriesList = List<String>.from(widget.data["accessories_name"] ?? []);
    return Scaffold(
      appBar: AppBar(
        title: Text("Accessories"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildLabel("Accessories Name:"),
              _buildDropdown(accessoriesList, selectedAccessory, (value) {
                setState(() {
                  selectedAccessory = value;
                });
                _fetchBrands(value!);
              }),
              _buildLabel("Brand:"),
              _buildDropdown(brandsList, selectedBrand, (value) {
                setState(() {
                  selectedBrand = value;
                });
                _fetchColors(value!);
              }, enabled: brandsList.isNotEmpty),
              _buildLabel("Color:"),
              _buildDropdown(colorsList, selectedColor, (value) {
                setState(() {
                  selectedColor = value;
                });
                _fetchThickness(value!);
              }, enabled: colorsList.isNotEmpty),
              _buildLabel("Thickness:"),
              _buildDropdown(thicknessList, selectedThickness, (value) {
                setState(() {
                  selectedThickness = value;
                });
                _fetchCoatingMass(value!);
              }, enabled: thicknessList.isNotEmpty),
              _buildLabel("Coating Mass:"),
              _buildDropdown(coatingMassList, selectedCoatingMass, (value) {
                setState(() {
                  selectedCoatingMass = value;
                });
              }, enabled: coatingMassList.isNotEmpty),
              _buildTextField("Sq. Feet", sqFeetController),
              _buildTextField("Length", lengthController),
              _buildTextField("UOM", uomController),
              _buildTextField("Nos", nosController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
              submittedData.isEmpty ? _emptyMessage() : _buildSubmittedData(),
            ],
          ),
        ),
      ),
    );
  }
}
