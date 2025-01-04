import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StackWidget extends StatelessWidget {
  final String? hintText;
  final IconData? arrow;
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? tabArrow;

  const StackWidget({
    super.key,
    this.hintText,
    this.arrow,
    required this.text,
    this.onTap,
    this.tabArrow,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: screenHeight * 0.10,
              width: screenWidth,
              color: const Color(0xFFFFFFFF), // Set background color to white
            ),
          ],
        ),
        Positioned(
          child: Stack(
            children: [
              Container(
                height: screenHeight * 0.22,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
              // Add Circle Icon
              Positioned(
                top: 50,
                right: 20,
                child: InkWell(
                  onTap: onTap,
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
