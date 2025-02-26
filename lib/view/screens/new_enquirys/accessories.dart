import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/widgets/buttons.dart';
import '../../widgets/subhead.dart';
import '../../widgets/text.dart';

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
    /// Define Sizes //
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
              Align(
                alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyText(text: "Accessories Name :", weight: FontWeight.w500, color: Colors.black),
                  )),
              _buildTextField("Select Accessories", nameController, Icons.person),
              SizedBox(height: 10.h,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: MyText(text: " Select Base Product:", weight: FontWeight.w500, color: Colors.black)),
              SizedBox(height: 5.h,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: MyText(text: "Brand :", weight: FontWeight.w500, color: Colors.black)),
              _buildTextField("Brand", brandController,Icons.business),
              SizedBox(height: 5.h,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: MyText(text: "Color :", weight: FontWeight.w500, color: Colors.black)),
              _buildTextField("Color", colorController,Icons.color_lens),
              SizedBox(height: 5.h,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: MyText(text: "Thickness :", weight: FontWeight.w500, color: Colors.black)),
              _buildTextField("Thickness", thicknessController,  Icons.layers),
              SizedBox(height: 5.h,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: MyText(text: "Coating Mass :", weight: FontWeight.w500, color: Colors.black)),
              _buildTextField("Coating Mass", materialTypeController, Icons.category),
              SizedBox(height: 20.h),
              Center(
                child: GestureDetector(
                  onTap: (){
                    _submitData();
                  },
                    child: Buttons(text: "Submit", weight: FontWeight.w500, color: Colors.blue, height: height/17.h, width: width/3.5.w, radius: BorderRadius.circular(10.r)))
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
          labelStyle: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 14.5.sp,fontWeight: FontWeight.w500,color: Colors.grey)),
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
  }

  Widget _buildSubmittedData() {
    return Column(
      children: submittedData.map((data) {
        return Card(
          margin: EdgeInsets.only(bottom: 15.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 4,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.map((entry) {
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
        return Icons.person;
      case "Brand":
        return Icons.business;
      case "Color":
        return Icons.color_lens;
      case "Thickness":
        return Icons.layers;
      case "Material Type":
        return Icons.category;
      default:
        return Icons.info;
    }
  }
}
