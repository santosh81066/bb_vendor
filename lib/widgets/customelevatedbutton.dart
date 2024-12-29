import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double borderRadius;
  final Color? color;
  final Color? foreGroundColor;
  final Color? backGroundColor;
  final Color? borderColor; // Parameter for border color
  final double? borderWidth; // Parameter for border width
  final bool? isLoading;

  const CustomElevatedButton({
    super.key,
    this.borderColor, // It's nullable so it may not be passed
    this.borderWidth = 1, // Default width is 1 if not passed
    required this.text,
    required this.borderRadius,
    this.onPressed,
    this.width,
    this.color,
    this.foreGroundColor,
    this.backGroundColor,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading == true ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(backGroundColor!),
          foregroundColor: foreGroundColor == null
              ? WidgetStateProperty.all<Color>(Colors.white)
              : WidgetStateProperty.all<Color>(foreGroundColor!),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: borderColor ?? Colors.white, // Border color
                width: 1.0, // Border width
              ),
            ),
          ),
        ),
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: backGroundColor,
        //   foregroundColor: foreGroundColor ?? Colors.white,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(15),
        //     // Use the borderColor if it's not null, otherwise use a default color
        //     side: BorderSide(
        //       color: borderColor ??
        //           Colors
        //               .white, // Default to blue if borderColor is not provided
        //       width: borderWidth ??
        //           1, // Use the provided borderWidth or default to 1
        //     ),
        //   ),
        // ),
        child: isLoading == true
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white, // Adjust color to match your design
                ),
              )
            : Text(text),
      ),
    );
  }
}
