import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatefulWidget {
  const Buttons({super.key, required this.text, required this.weight, required this.color, required this.height, required this.width, required this.radius});
  final double height;
  final double width;
  final BorderRadius radius;
  final String text;
  final FontWeight weight;
  final Color color;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: widget.radius
      ),
      child: Center(child: Text(widget.text,style: GoogleFonts.figtree(textStyle: TextStyle(fontSize: 14.5.sp,fontWeight: widget.weight,color: Colors.white)),)),
    );
  }
}
