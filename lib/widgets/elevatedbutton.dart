
import 'package:flutter/material.dart';

class CoustElevatedButton extends StatelessWidget {
  const CoustElevatedButton(
      {super.key,
      this.onPressed,
      this.buttonName,
      this.bgColor,
      this.width,
      this.radius,
      this.textColor,
      this.FontSize,
      this.isLoading});
  final VoidCallback? onPressed;
  final String? buttonName;
  final Color? bgColor;
  final double? width;
  final double? radius;
  final Color? textColor;
  final double? FontSize;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: isLoading == true
          ? const SizedBox(
              height: 20, width: 20, child: CircularProgressIndicator())
          : Text(
              buttonName!,
              style: TextStyle(color: textColor, fontSize: FontSize),
            ),
      style:  ElevatedButton.styleFrom(
        backgroundColor: bgColor,

          maximumSize: Size.fromWidth(width!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius!)))),
          // shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(radius!))))),
    );
  }
}
