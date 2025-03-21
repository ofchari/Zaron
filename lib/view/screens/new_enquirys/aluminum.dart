import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/widgets/buttons.dart';
import '../../widgets/subhead.dart';
import '../../widgets/text.dart';

class Aluminum extends StatefulWidget {
  const Aluminum({super.key});

  @override
  State<Aluminum> createState() => _AluminumState();
}

class _AluminumState extends State<Aluminum> {
  late double height;
  late double width;

  final TextEditingController aluminumController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController thicknessController = TextEditingController();

  List<Map<String, String>> submittedData = [];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Subhead(text: "Aluminum", weight: FontWeight.w500, color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Aluminum:"),
              _buildTextField("Select Aluminum", aluminumController, Icons.miscellaneous_services),
              SizedBox(height: 10.h),

              _buildLabel("Brand:"),
              _buildTextField("Brand", brandController, Icons.business),
              SizedBox(height: 5.h),

              _buildLabel("Color:"),
              _buildTextField("Color", colorController, Icons.color_lens),
              SizedBox(height: 5.h),

              _buildLabel("Thickness:"),
              _buildTextField("Thickness", thicknessController, Icons.straighten),
              SizedBox(height: 10.h),

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
              _buildSubmittedData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: MyText(text: text, weight: FontWeight.w500, color: Colors.black),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w500, color: Colors.grey)),
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
    if (aluminumController.text.isEmpty ||
        brandController.text.isEmpty ||
        colorController.text.isEmpty ||
        thicknessController.text.isEmpty) {
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
        "Aluminum": aluminumController.text,
        "Brand": brandController.text,
        "Color": colorController.text,
        "Thickness": thicknessController.text,
      });

      aluminumController.clear();
      brandController.clear();
      colorController.clear();
      thicknessController.clear();
    });

    // ✅ Show success Snackbar when data is added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Data added successfully!"),
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

  IconData _getIcon(String key) {
    switch (key) {
      case "Aluminum":
        return Icons.miscellaneous_services;
      case "Brand":
        return Icons.business;
      case "Color":
        return Icons.color_lens;
      case "Thickness":
        return Icons.straighten;
      default:
        return Icons.info;
    }
  }
}
