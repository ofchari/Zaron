import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/widgets/buttons.dart';
import '../../widgets/subhead.dart';
import '../../widgets/text.dart';

class LengthSheets extends StatefulWidget {
  const LengthSheets({super.key});

  @override
  State<LengthSheets> createState() => _LengthSheetsState();
}

class _LengthSheetsState extends State<LengthSheets> {
  late double height;
  late double width;

  final TextEditingController materialController = TextEditingController(); // Changed from materialTypeController
  final TextEditingController brandController = TextEditingController();
  final TextEditingController coatingController = TextEditingController();
  final TextEditingController thicknessController = TextEditingController(); // Changed from thicknessController
  final TextEditingController coatingMassController = TextEditingController();
  final TextEditingController yieldController = TextEditingController();
  final TextEditingController productController = TextEditingController();

  List<Map<String, String>> submittedData = [];

  @override
  Widget build(BuildContext context) {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;


    return Scaffold(
      appBar: AppBar(
        title: Subhead(text: "Cut Length Sheets", weight: FontWeight.w500, color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(text: "Product Name:", weight: FontWeight.w500, color: Colors.black),
                ),
              ),
              _buildTextField("Select Product Name", productController, Icons.miscellaneous_services),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(text: "Select Base Product:", weight: FontWeight.w500, color: Colors.black),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: MyText(text: "Material Type:", weight: FontWeight.w500, color: Colors.black),
              ),
              _buildTextField("Select Material Type", materialController, Icons.business),
              SizedBox(height: 5.h),
              Align(
                alignment: Alignment.centerLeft,
                child: MyText(text: "Coating:", weight: FontWeight.w500, color: Colors.black),
              ),
              _buildTextField("Coating", coatingController, Icons.color_lens),
              SizedBox(height: 5.h),

              Align(
                alignment: Alignment.centerLeft,
                child: MyText(text: "Thickness:", weight: FontWeight.w500, color: Colors.black),
              ),
              _buildTextField("thickness", thicknessController, Icons.straighten),

              SizedBox(height: 5.h),
              Align(
                alignment: Alignment.centerLeft,
                child: MyText(text: "Yield Strength:", weight: FontWeight.w500, color: Colors.black),
              ),
              _buildTextField("yield strength", yieldController, Icons.follow_the_signs),
              SizedBox(height: 5.h),
              Align(
                alignment: Alignment.centerLeft,
                child: MyText(text: "Brand:", weight: FontWeight.w500, color: Colors.black),
              ),
              _buildTextField("brand", brandController, Icons.circle_notifications),

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
    if (productController.text.isEmpty || materialController.text.isEmpty ||
        brandController.text.isEmpty ||
        coatingController.text.isEmpty ||
        thicknessController.text.isEmpty ||
        yieldController.text.isEmpty) {
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
        "Product Name": productController.text,
        "Material": materialController.text,
        "Brand": brandController.text,
        "Coating": coatingController.text,
        "Thickness": thicknessController.text,
        "Yield Strength": yieldController.text,
      });

      productController.clear();
      materialController.clear();
      brandController.clear();
      coatingController.clear();
      thicknessController.clear();
      yieldController.clear();
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
          margin: EdgeInsets.only(bottom: 15.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...data.entries.map((entry) {
                  return Padding(
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
                  );
                }).toList(),

                /// ✅ Delete Button
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
      case "Material":
        return Icons.miscellaneous_services;
      case "Brand":
        return Icons.business;
      case "Color":
        return Icons.color_lens;
      case "Thickness":
        return Icons.straighten;
    case "Yield Strength":
      return Icons.follow_the_signs;
      default:
        return Icons.info;
    }
  }
}
