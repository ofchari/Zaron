import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Subhead extends StatefulWidget {
  const Subhead({super.key, required this.text, required this.weight, required this.color});
  final String text;
  final FontWeight weight;
  final Color color;


  @override
  State<Subhead> createState() => _SubheadState();
}

class _SubheadState extends State<Subhead> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text,style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 17.sp,fontWeight: widget.weight,color: widget.color)),);
  }
}
