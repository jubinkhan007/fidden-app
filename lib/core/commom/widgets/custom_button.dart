
import 'package:flutter/material.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.isPrimary = true,
    this.height,
    this.width,
    required this.onPressed,
    required this.child,
    this.padding,
    this.color,
    this.radious,
    this.borderColor,
  });
  final bool isPrimary;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? radious;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        padding: padding ?? EdgeInsets.all(getWidth(13)),
        decoration: BoxDecoration(
          color: color ??
              (isPrimary ? Theme.of(context).primaryColor : AppColors.white),
          borderRadius: BorderRadius.circular(radious ?? 8),
          border: Border.all(
            color: isPrimary
                ? Theme.of(context).primaryColor
                : borderColor ?? Color(0xFFCCD9D6),
            width: 1,
          ),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
