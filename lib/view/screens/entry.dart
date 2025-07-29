import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zaron/view/screens/login.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  late double height;
  late double width;
  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  Widget build(BuildContext context) {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        if (width <= 450) {
          return _smallBuildLayout();
        } else {
          return Text("Please make Sure your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            height: 27.h,
          ),
          Column(
            children: [
              Container(
                height: height / 1.8.h,
                width: width.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange, Colors.orange[50]!],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                  ),
                ),
              ),
            ],
          ),
          // Perfectly centered image using Center widget
          Positioned.fill(
            top: 220.h, // Adjust this to position within the orange container
            bottom: 200.h, // Adjust this to leave space for button
            child: Center(
              child: Container(
                height: height / 4.h,
                width: width / 2.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/login.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Alternative method - using specific positioning for exact center
          // Positioned(
          //   top: (height / 1.8.h - height / 4.h) / 2 + 80.h, // Center vertically in orange area
          //   left: (width.w - width / 2.w) / 2, // Center horizontally
          //   child: Container(
          //     height: height / 4.h,
          //     width: width / 2.w,
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage("assets/login.png"),
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          // ),
          // Clean button design
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Get.off(Login());
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: height / 16.h,
                  width: width / 1.25.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade200,
                        Colors.orange.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
