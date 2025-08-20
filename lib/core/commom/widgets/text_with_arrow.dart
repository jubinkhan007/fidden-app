import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';
import 'custom_text.dart'; // Import your CustomText widget

class TextWithArrow extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final TextOverflow? textOverflow;
  final Color? color;
  final FontWeight? fontWeight;
  final VoidCallback? onTap;

  const TextWithArrow({
    super.key,
    this.text,
    this.fontSize,
    this.textOverflow = TextOverflow.ellipsis,
    this.color,
    this.fontWeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // CustomText Widget
          CustomText(
              text: text ?? '',
              fontSize: fontSize ?? getWidth(14),
              maxLines: 1,
              textOverflow: textOverflow,
              color: AppColors.primaryColor,
              fontWeight: fontWeight ?? FontWeight.w400),
          SizedBox(width: getWidth(8)),
          // Arrow Icon
          Icon(
            Icons.arrow_forward_ios,
            size: getWidth(16),
            color: AppColors.textGrey,
          ),
        ],
      ),
    );
  }
}
