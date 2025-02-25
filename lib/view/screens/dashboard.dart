import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zaron/view/widgets/text.dart';


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
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: MyText(text: "Dashboard", weight: FontWeight.w500, color: Colors.black),
        centerTitle: true,
      ),
      body: SizedBox(
        width: width.w,
        child: Column(
          children: [
            Container(
              height: height/7.h,
              width: width/3.w,
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                borderRadius: BorderRadius.circular(20.r)
              ),
              child: Center(child: MyText(text: "New Enquiry", weight: FontWeight.w500, color: Colors.white)),
            )

          ],
        ),
      ),
    );
  }

}
