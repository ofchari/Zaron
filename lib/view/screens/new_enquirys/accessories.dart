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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController thicknessController = TextEditingController();
  final TextEditingController materialTypeController = TextEditingController();

  List<Map<String, String>> submittedData = [];

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
              _buildTextField("Select Accessories", nameController, Icons.settings),
              _buildLabel("Select Base Product:"),
              _buildLabel("Brand:"),
              _buildTextField("Brand", brandController, Icons.business),
              _buildLabel("Color:"),
              _buildTextField("Color", colorController, Icons.color_lens),
              _buildLabel("Thickness:"),
              _buildTextField("Thickness", thicknessController, Icons.layers),
              _buildLabel("Coating Mass:"),
              _buildTextField("Coating Mass", materialTypeController, Icons.category),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: MyText(text: text, weight: FontWeight.w500, color: Colors.black),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.figtree(
            textStyle: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        ),
      ),
    );
  }

  void _submitData() {
    if (nameController.text.isEmpty ||
        brandController.text.isEmpty ||
        colorController.text.isEmpty ||
        thicknessController.text.isEmpty ||
        materialTypeController.text.isEmpty) {
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
        "Name": nameController.text,
        "Brand": brandController.text,
        "Color": colorController.text,
        "Thickness": thicknessController.text,
        "Coating Mass": materialTypeController.text,
      });

      nameController.clear();
      brandController.clear();
      colorController.clear();
      thicknessController.clear();
      materialTypeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data Submitted Successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteData(int index) {
    setState(() {
      submittedData.removeAt(index);
    });

    // ✅ Show success Snackbar when data is deleted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data deleted successfully!"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Widget _buildSubmittedData() {
    return Column(
      children: submittedData.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, String> data = entry.value;

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...data.entries.map((entry) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    children: [
                      Icon(_getIcon(entry.key), color: Colors.blueAccent, size: 20.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: MyText(
                          text: "${entry.key}: ${entry.value}",
                          weight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteData(index),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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

  IconData _getIcon(String key) {
    switch (key) {
      case "Name":
        return Icons.settings;
      case "Brand":
        return Icons.business;
      case "Color":
        return Icons.color_lens;
      case "Thickness":
        return Icons.layers;
      case "Coating Mass":
        return Icons.category;
      default:
        return Icons.info;
    }
  }
}
