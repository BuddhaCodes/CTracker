import 'package:ctracker/constant/color_palette.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String text;
  bool isSelected;
  final VoidCallback onTap;
  MenuItem({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 15.0),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color:
                    ColorP.cardBackground, // You can change the color as needed
              )
            : null,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: ColorP.textColorSubtitle,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
