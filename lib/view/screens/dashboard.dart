import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zaron/view/screens/new_enquirys/new_enquiry.dart';
import 'package:zaron/view/widgets/text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/subhead.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
           /// Define Sizes ///
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

  /// Landscape Mode Warning ///
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

  Widget _smallBuildLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Subhead(text: "Dashboard", weight: FontWeight.w600, color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Dashboard Image Banner
              Container(
                height: height / 3.2.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage("assets/Construction.png"), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(12.r),
                  // boxShadow: [
                  //   BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
                  // ],
                ),
              ),
              SizedBox(height: 5.h),

              /// Cards Section
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.1,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return _buildCard(item["title"]!, item["icon"]!, item["color"]!, item["route"]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

            /// List of Dashboard Cards
  final List<Map<String, dynamic>> dashboardItems = [
    {"title": "New Enquiry", "icon": FontAwesomeIcons.plus, "color": Colors.green, "route": NewEnquiry()},
    {"title": "Total Enquiry", "icon": FontAwesomeIcons.list, "color": Colors.blue, "route": null},
    {"title": "Open Enquiry", "icon": FontAwesomeIcons.folderOpen, "color": Colors.orange, "route": null},
    {"title": "Quotations", "icon": FontAwesomeIcons.fileInvoiceDollar, "color": Colors.purple, "route": null},
    {"title": "Cancelled", "icon": FontAwesomeIcons.times, "color": Colors.redAccent, "route": null},
    {"title": "Missed Enquiry", "icon": FontAwesomeIcons.exclamationTriangle, "color": Colors.black, "route": null},
  ];

  /// Improved Card Design with Icons
  Widget _buildCard(String title, IconData icon, Color bgColor, Widget? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) Get.to(route);
      },
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        color: bgColor.withOpacity(0.9),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.w),
              SizedBox(height: 8.h),
              MyText(text: title, weight: FontWeight.w600, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
