
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';
import 'custom_text.dart';

successSnakbr({String? successMessage}) {
  return Get.snackbar(
    "Success",
    successMessage ?? "",
    backgroundColor: AppColors.success,
    snackPosition: SnackPosition.TOP,
    colorText: AppColors.white,
    margin: EdgeInsets.all(10),
    borderRadius: 10,
    duration: Duration(seconds: 3),
    messageText: CustomText(
      text: successMessage ?? "Operation Successful",
      color: AppColors.white,
      fontSize: getWidth(16),
      fontWeight: FontWeight.w500,
    ),
  );
}
