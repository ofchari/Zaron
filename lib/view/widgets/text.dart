import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText extends StatefulWidget {
  const MyText({super.key, required this.text, required this.weight, required this.color});
  final String text;
  final FontWeight weight;
  final Color color;


  @override
  State<MyText> createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text,style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 14.5.sp,fontWeight: widget.weight,color: widget.color)),);
  }
}
