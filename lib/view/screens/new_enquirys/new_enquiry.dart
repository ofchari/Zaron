import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zaron/view/screens/new_enquirys/iron_steels.dart';
import 'package:zaron/view/screens/new_enquirys/linear_sheets.dart';
import 'package:zaron/view/widgets/subhead.dart';
import '../../widgets/text.dart';
import 'accessories.dart';
import 'aluminum.dart';
import 'decking_sheets.dart';
import 'gl_gutter.dart';
import 'gl_stiffner.dart';
import 'length_sheets.dart';

class NewEnquiry extends StatefulWidget {
  const NewEnquiry({super.key});

  @override
  State<NewEnquiry> createState() => _NewEnquiryState();
}

class _NewEnquiryState extends State<NewEnquiry> {
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        return width <= 450 ? _smallBuildLayout() : _landscapeView();
      },
    );
  }

  /// Show Message for Larger Screens (Landscape Mode)
  Widget _landscapeView() {
    return const Scaffold(
      body: Center(
        child: Text(
          "Please switch to portrait mode for a better experience.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Mobile Layout
  Widget _smallBuildLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(text: "New Enquiry", weight: FontWeight.w600, color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.55,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(
              category["name"]!,
              category["imagePath"]!,
              category["route"],
            );
          },
        ),
      ),
    );
  }

  /// List of Categories (Dynamic Data)
  final List<Map<String, dynamic>> categories = [
    {"name": "Accessories", "imagePath": "assets/accessories.png", "route": Accessories()},
    {"name": "Aluminum", "imagePath": "assets/aluminum.png", "route": Aluminum()},
    {"name": "Cut to Length Sheets", "imagePath": "assets/lenght sheets.png", "route": LengthSheets()},
    {"name": "Decking Sheet", "imagePath": "assets/deckingsheets.png", "route": DeckingSheets()},
    {"name": "GI Gutter", "imagePath": "assets/gi_gitter.png", "route": Glgutter()},
    {"name": "GI Stiffner", "imagePath": "assets/gi_stiffner.png", "route": GlStiffnner()},
    {"name": "Iron & Steel", "imagePath": "assets/iron&steel.jpg", "route": IronSteel()},
    {"name": "Liner sheets", "imagePath": "assets/linearsheets.jpg", "route": Linearsheets()},
  ];

  /// Improved Category Card Design
  Widget _buildCategoryCard(String name, String imagePath, Widget route) {
    return GestureDetector(
      onTap: () => Get.to(route),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: MyText(text: name, weight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
