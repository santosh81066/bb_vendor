import 'package:flutter/material.dart';

class coustText extends StatelessWidget {
  const coustText({
    super.key,
    this.sName,
    this.txtcolor,
    this.textsize,
    this.decoration,
    this.decorationcolor,
    this.overflow,
    this.align,
    this.fontweight,
    this.fontSize, // Make this OPTIONAL instead of required
  });

  final String? sName;
  final Color? txtcolor;
  final double? textsize;
  final TextDecoration? decoration;
  final Color? decorationcolor;
  final TextOverflow? overflow;
  final TextAlign? align;
  final FontWeight? fontweight;
  final double? fontSize; // Optional field - this is the key change!

  @override
  Widget build(BuildContext context) {
    // Use fontSize if provided, otherwise use textsize, otherwise default to 16.0
    final double effectiveFontSize = fontSize ?? textsize ?? 16.0;

    return Text(
      sName ?? '', // Handle null safety
      style: TextStyle(
        color: txtcolor,
        fontSize: effectiveFontSize,
        decoration: decoration,
        decorationColor: decorationcolor,
        fontWeight: fontweight,
      ),
      overflow: overflow,
      textAlign: align,
    );
  }
}