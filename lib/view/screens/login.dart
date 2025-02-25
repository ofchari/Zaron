import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zaron/view/screens/dashboard.dart';
import 'package:zaron/view/widgets/buttons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late double height;
  late double width;
  @override
  Widget build(BuildContext context) {
    /// Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      if(width<=450){
        return _smallBuildLayout();
      }
      else{
        return Text("Please make Sure your device is in portrait view");
      }
    },);
  }
  Widget _smallBuildLayout(){
    return Scaffold(
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            SizedBox(height: 80.h,),
            Container(
              height: height/5.h,
              width: width/2.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/login.png"),fit: BoxFit.cover
                  )
                ),
           ),
            SizedBox(height: 10.h,),
            GestureDetector(
              onTap: (){
                Get.to(Dashboard());
              },
                child: Buttons(text: "Get Started here ✈", weight: FontWeight.w500, color: Colors.blueGrey, height: height/16.h, width: width/1.5.w, radius: BorderRadius.circular(26.r)))

          ],
        ),
      ),

    );
  }

}
