import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/subhead.dart';
import '../../widgets/text.dart';
import '../../widgets/buttons.dart';

class Accessories extends StatefulWidget {
  const Accessories({super.key});

  @override
  State<Accessories> createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
  late double height;
  late double width;

  String? selectedAccessory;
  String? selectedBrand;
  String? selectedColor;
  String? selectedThickness;
  final TextEditingController coatingMassController = TextEditingController();

  List<Map<String, String>> submittedData = [];

  final List<String> accessoriesList = ["Gloves", "Helmet", "Goggles"];
  final Map<String, List<String>> brandsMap = {
    "Gloves": ["Nike", "Adidas", "Puma"],
    "Helmet": ["Steelbird", "Vega", "Studds"],
    "Goggles": ["RayBan", "Oakley", "Fastrack"]
  };

  final Map<String, List<String>> colorsMap = {
    "Nike": ["Black", "Red", "Blue"],
    "Adidas": ["White", "Grey", "Green"],
    "Puma": ["Yellow", "Pink", "Purple"],
    "Steelbird": ["Black", "White"],
    "Vega": ["Blue", "Red"],
    "Studds": ["Green", "Black"],
    "RayBan": ["Brown", "Black"],
    "Oakley": ["Silver", "Blue"],
    "Fastrack": ["Red", "Grey"]
  };

  final Map<String, List<String>> thicknessMap = {
    "Black": ["Thin", "Medium", "Thick"],
    "Red": ["Ultra Thin", "Thin"],
    "Blue": ["Medium", "Thick"],
    "White": ["Thin", "Thick"],
    "Grey": ["Ultra Thin", "Medium"],
    "Green": ["Thin", "Medium"],
    "Yellow": ["Medium", "Thick"],
    "Pink": ["Ultra Thin", "Thin"],
    "Purple": ["Medium", "Thick"],
    "Brown": ["Thin", "Medium"],
    "Silver": ["Ultra Thin", "Medium"]
  };

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Subhead(text: "Accessories", weight: FontWeight.w500, color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Accessories Name:"),
              _buildDropdown(accessoriesList, selectedAccessory, (value) {
                setState(() {
                  selectedAccessory = value;
                  selectedBrand = null;
                  selectedColor = null;
                  selectedThickness = null;
                });
              }),

              _buildLabel("Brand:"),
              _buildDropdown(selectedAccessory != null ? brandsMap[selectedAccessory!] ?? [] : [], selectedBrand, (value) {
                setState(() {
                  selectedBrand = value;
                  selectedColor = null;
                  selectedThickness = null;
                });
              }, enabled: selectedAccessory != null),

              _buildLabel("Color:"),
              _buildDropdown(selectedBrand != null ? colorsMap[selectedBrand!] ?? [] : [], selectedColor, (value) {
                setState(() {
                  selectedColor = value;
                  selectedThickness = null;
                });
              }, enabled: selectedBrand != null),

              _buildLabel("Thickness:"),
              _buildDropdown(selectedColor != null ? thicknessMap[selectedColor!] ?? [] : [], selectedThickness, (value) {
                setState(() {
                  selectedThickness = value;
                });
              }, enabled: selectedColor != null),

              _buildLabel("Coating Mass:"),
              _buildTextField("Enter Coating Mass", coatingMassController, Icons.category),

              SizedBox(height: 20.h),
              Center(
                child: GestureDetector(
                  onTap: _submitData,
                  child: Buttons(
                    text: "Submit",
                    weight: FontWeight.w500,
                    color: Colors.blue,
                    height: height / 17.h,
                    width: width / 3.5.w,
                    radius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              submittedData.isEmpty ? _emptyMessage() : _buildSubmittedData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: enabled ? onChanged : null,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        decoration: InputDecoration(
          labelText: "Select",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        ),
        disabledHint: Text("Select Previous First"),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp, color: Colors.black),
      ),
    );
  }

  void _submitData() {
    if (selectedAccessory == null ||
        selectedBrand == null ||
        selectedColor == null ||
        selectedThickness == null ||
        coatingMassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data Submitted Successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSubmittedData() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: submittedData.length,
        itemBuilder: (context, index) {
          final data = submittedData[index];

          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 5,
            shadowColor: Colors.black26,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      if (entry != data.entries.last)
                        Divider(thickness: 1, color: Colors.grey.shade300),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyMessage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          "No submissions yet. Fill the form and click submit.",
          style: TextStyle(fontSize: 16.sp, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
