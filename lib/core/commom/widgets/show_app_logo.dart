
import 'package:flutter/material.dart';

import '../../utils/constants/app_sizes.dart';
import '../../utils/constants/image_path.dart';

class ShowAppLogo extends StatelessWidget {
  const ShowAppLogo({
    super.key,
    this.height,
    this.width,
    this.alignment,
  });
  final double? height;
  final double? width;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.width,
      child: Container(
        // height: height ?? getHeight(40),
        // width: width ?? getWidth(245),
        alignment: alignment ?? Alignment.centerLeft,
        child: Image.asset(
          ImagePath.splashLogo,
          height: getHeight(43),
          width: getWidth(245),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
