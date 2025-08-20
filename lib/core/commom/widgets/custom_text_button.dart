
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_sizes.dart';
import '../styles/get_text_style.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton(
      {super.key,
      required this.onPressed,
      required this.text,
      this.decorationThickness,
      this.fontWeight,
      this.fontSize,
      this.isUnderline,
      this.color});
  final double? decorationThickness;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? isUnderline;
  final Function() onPressed;
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Text(
          text,
          style: TextStyle(
              fontWeight: fontWeight ?? FontWeight.w400,
              fontSize: fontSize ?? getWidth(12),
              color: color ?? Get.theme.primaryColor,
              decoration: isUnderline == true
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: color ?? Get.theme.primaryColor,
              decorationThickness: decorationThickness ?? 1.5),
        ));
  }
}
