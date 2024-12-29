import 'package:flutter/material.dart';

class coustText extends StatelessWidget {
  const coustText(  {super.key, this.sName, this.txtcolor, this.textsize,this.decoration,this.decorationcolor,this.overflow,this.align ,this.fontweight});
  final String? sName;
  final Color? txtcolor;
  final double? textsize;
  final TextDecoration? decoration;
  final Color? decorationcolor;
  final TextOverflow? overflow;
  final TextAlign? align;
  final FontWeight? fontweight;

  @override
  Widget build(BuildContext context) {
    return Text(
      sName!,
      style: TextStyle(color: txtcolor, fontSize: textsize,decoration:decoration,decorationColor: decorationcolor,fontWeight: fontweight),
      overflow: overflow,
      textAlign:align ,
    );
  }
}
