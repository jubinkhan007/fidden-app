import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_sizes.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.decorationThickness,
    this.fontWeight,
    this.fontSize,
    this.isUnderline,
    this.color,
    this.overflow, // ✅ added
  });

  final double? decorationThickness;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? isUnderline;
  final Function() onPressed;
  final String text;
  final Color? color;
  final TextOverflow? overflow; // ✅ added

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        overflow: overflow, // ✅ apply overflow here
        style: TextStyle(
          fontWeight: fontWeight ?? FontWeight.w400,
          fontSize: fontSize ?? getWidth(12),
          color: color ?? Get.theme.primaryColor,
          decoration: isUnderline == true
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: color ?? Get.theme.primaryColor,
          decorationThickness: decorationThickness ?? 1.5,
        ),
      ),
    );
  }
}
