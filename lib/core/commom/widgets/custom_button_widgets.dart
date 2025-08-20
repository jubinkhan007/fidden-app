import 'package:flutter/material.dart';


import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';

class CustomButtonV2 extends StatelessWidget {
  const CustomButtonV2({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
    this.height,
    this.width,
    this.radius,
  });
  final Function() onTap;
  final double? height;
  final double? width;
  final double? radius;
  final Widget child;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 38,
        width: width ?? AppSizes.width,
        decoration: BoxDecoration(
            color: color ?? AppColors.primaryColor,
            borderRadius: BorderRadius.circular(radius ?? 6)),
        child: Center(child: child),
      ),
    );
  }
}
