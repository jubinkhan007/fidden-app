import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextAlign? textAlign;
  const CustomText({
    super.key,
    required this.text,
    this.maxLines,
    this.textOverflow,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.decoration,
    this.decorationColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        decorationColor: decorationColor ?? AppColors.textPrimary,
        fontSize: fontSize ?? getWidth(16),
        //color: color ?? AppColors.textPrimary,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      ),
      overflow: textOverflow,
      maxLines: maxLines,
    );
  }
}
