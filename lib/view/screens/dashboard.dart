import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zaron/view/screens/cancel_quotation.dart';
import 'package:zaron/view/screens/login.dart';
import 'package:zaron/view/screens/new_enquirys/new_enquiry.dart';
import 'package:zaron/view/screens/quotation.dart';
import 'package:zaron/view/screens/total_enquiry.dart';
import 'package:zaron/view/widgets/subhead.dart';
import 'package:zaron/view/widgets/text.dart';

import 'cancel_enquiry.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.userid});
  final String userid;

  @override
  State<Dashboard> createState() => _DashboardState();
}

///Here's your modified Dashboard code with professional UI improvements while maintaining the same structure:

class _DashboardState extends State<Dashboard> {
  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
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

  @override
  void initState() {
    super.initState();
  }

  Widget _landscapeView() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Please switch to portrait mode for a better experience.",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _smallBuildLayout() {
    final List<Map<String, dynamic>> dashboardItems = [
      {
        "title": "New Enquiry",
        "icon": FontAwesomeIcons.plus,
        "color": Colors.green,
        "route": NewEnquiry()
      },
      {
        "title": "Total Enquiry",
        "icon": FontAwesomeIcons.list,
        "color": const Color(0xFF2196F3),
        "route": TotalEnquiryPage()
      },
      {
        "title": "Total Quotations",
        "icon": FontAwesomeIcons.fileInvoiceDollar,
        "color": const Color(0xFF9C27B0),
        "route": QuotationPage()
      },
      {
        "title": "Cancelled Enquiry",
        "icon": FontAwesomeIcons.cancel,
        "color": Colors.redAccent.shade400,
        "route": CancelEnquiry()
      },
      {
        "title": "Cancelled Quotation",
        "icon": FontAwesomeIcons.times,
        "color": Colors.redAccent.shade700,
        "route": CancelQuotation()
      },
      {
        "title": "Missed Enquiry",
        "icon": FontAwesomeIcons.exclamationTriangle,
        "color": const Color(0xFF212121),
        "route": null
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.offAll(Login());
            },
            icon: const Icon(Icons.logout, color: Colors.black)),
        title: Subhead(
            text: "Dashboard", weight: FontWeight.w600, color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        actions: [
          Image.asset(
            "assets/login.png",
            width: 60.w,
            height: 50.h,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: height * 0.28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.black, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // image: DecorationImage(
                  //     image: AssetImage("assets/scale_bg.jpg"),
                  //     fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Stack(
                  clipBehavior: Clip.none, // Allows image to overflow
                  children: [
                    Positioned(
                      right: -28.w, // Adjusted for better positioning
                      bottom: 10.h, // Position from bottom
                      child: Transform.rotate(
                        angle: 0.03, // Slight rotation for dynamic look
                        child: Image.asset(
                          "assets/roofing-sheets.png",
                          width: width * 0.60, // Increased width
                          height: height * 0.20, // Match container height
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back!",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Manage your enquiries and quotations",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Subhead(
                text: "Quick Actions",
                weight: FontWeight.w600,
                color: const Color(0xFF212121),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return _buildCard(
                    item["title"]!,
                    item["icon"]!,
                    item["color"]!,
                    item["route"],
                  );
                },
              ),
              Gap(8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color bgColor, Widget? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Get.to(route);
        } else {
          Get.snackbar(
            "Error",
            "No route defined for $title",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: bgColor,
                size: 24.w,
              ),
            ),
            SizedBox(height: 12.h),
            MyText(
              text: title,
              weight: FontWeight.w400,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
