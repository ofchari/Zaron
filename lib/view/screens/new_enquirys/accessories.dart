import 'dart:convert';
import 'dart:io';
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
  final TextEditingController coatingMassController = TextEditingController();

  List<String> brandsList = [];
  List<String> colorsList = [];
  List<String> thicknessList = [];
  List<Map<String, String>> submittedData = [];

  final Map<String, List<String>> colorsMap = {
    "BrandA": ["Red", "Blue", "Green"],
    "BrandB": ["Yellow", "Black", "White"],
    "BrandC": ["Pink", "Purple", "Grey"],
  };

  final Map<String, List<String>> thicknessMap = {
    "Red": ["Thin", "Thick"],
    "Blue": ["Ultra Thin", "Medium"],
    "Green": ["Medium", "Thick"],
    "Black": ["Thin", "Thick"],
    "White": ["Ultra Thin", "Medium"],
  };

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


  void _submitData() {
    if (selectedAccessory == null ||
        selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null ||
        coatingMassController.text.isEmpty) {
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
        "Coating Mass": coatingMassController.text,
      });

      selectedAccessory = null;
      selectedBrand = null;
      selectedColor = null;
      selectedThickness = null;
      coatingMassController.clear();
      brandsList = [];
      colorsList = [];
      thicknessList = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data Submitted Successfully"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> accessoriesList = List<String>.from(widget.data["accessories_name"] ?? []);

    return Scaffold(
      appBar: AppBar(title: Text("Accessories"), centerTitle: true),
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
                });
                _fetchBrands(value!);
              }),

              _buildLabel("Brand:"),
              _buildDropdown(brandsList, selectedBrand, (value) {
                setState(() {
                  selectedBrand = value;
                  colorsList = colorsMap[value!] ?? [];
                  thicknessList = [];
                  selectedColor = null;
                  selectedThickness = null;
                });
              }, enabled: brandsList.isNotEmpty),

              _buildLabel("Color:"),
              _buildDropdown(colorsList, selectedColor, (value) {
                setState(() {
                  selectedColor = value;
                  thicknessList = thicknessMap[value!] ?? [];
                  selectedThickness = null;
                });
              }, enabled: colorsList.isNotEmpty),

              _buildLabel("Thickness:"),
              _buildDropdown(thicknessList, selectedThickness, (value) {
                setState(() {
                  selectedThickness = value;
                });
              }, enabled: thicknessList.isNotEmpty),

              _buildLabel("Coating Mass:"),
              _buildTextField("Enter Coating Mass", coatingMassController, Icons.category),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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

  Widget _buildDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: enabled ? onChanged : null,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        decoration: InputDecoration(
          labelText: "Select",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        disabledHint: Text("Select Previous First"),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black)),
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

  Widget _emptyMessage() {
    return Center(child: Text("No submissions yet."));
  }
}
