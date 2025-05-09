import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zaron/view/screens/login.dart';
import 'package:zaron/view/widgets/buttons.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
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
                    color: Colors.teal,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(60),
                        bottomLeft: Radius.circular(60))),
              ),
            ],
          ),
          Positioned(
            bottom: 250,
            right: 104,
            child: Container(
              height: height / 4.h,
              width: width / 2.w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/login.png"),
                      fit: BoxFit.cover)),
            ),
          ),
          Positioned(
              bottom: 160,
              right: 50,
              child: GestureDetector(
                  onTap: () {
                    Get.off(Login());
                  },
                  child: Buttons(
                      text: "Get Started here ✈",
                      weight: FontWeight.w500,
                      color: Colors.blueGrey,
                      height: height / 16.h,
                      width: width / 1.3.w,
                      radius: BorderRadius.circular(26.r))))
        ],
      ),
    );
  }
}
