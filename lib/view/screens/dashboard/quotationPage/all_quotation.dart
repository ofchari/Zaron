import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zaron/view/screens/dashboard/quotationPage/cancel_quotation.dart';

import '../../../widgets/text.dart';
import 'quotation.dart';

class AllQuotation extends StatefulWidget {
  const AllQuotation({super.key});

  @override
  State<AllQuotation> createState() => _AllQuotationState();
}

class _AllQuotationState extends State<AllQuotation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> dashboardItems = [
    {
      "title": "Total Quotation",
      "icon": FontAwesomeIcons.fileInvoice,
      "color": const Color(0xFF1565C0),
      "route": QuotationPage(),
      "gradient": [Color(0xFF1565C0), Color(0xFF42A5F5)],
    },
    {
      "title": "Open Quotations",
      "icon": FontAwesomeIcons.solidFolderOpen,
      "color": Colors.green,
      "route": null,
      "gradient": [Colors.green, Colors.green.shade200],
    },
    {
      "title": "Cancelled Quotations",
      "icon": FontAwesomeIcons.circleXmark,
      "color": const Color(0xFFD32F2F),
      "route": CancelQuotation(),
      "gradient": [Color(0xFFD32F2F), Color(0xFFEF5350)],
    },
    {
      "title": "Missed Quotations",
      "icon": FontAwesomeIcons.triangleExclamation,
      "color": Colors.yellow,
      "route": null,
      "gradient": [Colors.orangeAccent.shade700, Colors.yellow],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildCard(String title, IconData icon, Color bgColor, Widget? route,
      List<Color> gradient, int index) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
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
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: bgColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 26.w,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: MyText(
                      text: title,
                      weight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Quotations',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.w),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: GridView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: dashboardItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final item = dashboardItems[index];
              return _buildCard(
                item['title'],
                item["icon"],
                item["color"],
                item["route"],
                item["gradient"],
                index,
              );
            },
          ),
        ),
      ),
    );
  }
}
