
import 'package:flutter/material.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
          color: AppColors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.black,
          size: getWidth(30),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
