
import 'package:flutter/cupertino.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';
import '../../utils/constants/app_spacers.dart';
import 'custom_button.dart';
import 'custom_text.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar(
      {super.key,
      required this.isPrimaryButton,
      this.secondaryWidget,
      this.primaryWidget,
      this.primaryText,
      required this.onTap});
  final bool isPrimaryButton;
  final VoidCallback onTap;
  final String? primaryText;
  final Widget? secondaryWidget;
  final Widget? primaryWidget;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: secondaryWidget != null
          ? AppSizes.height * 0.18
          : AppSizes.height * 0.1,
      padding: EdgeInsets.symmetric(
          horizontal: getWidth(16), vertical: getHeight(16)),
      color: AppColors.white,
      child: Column(
        mainAxisAlignment: secondaryWidget != null
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.end,
        children: [
          secondaryWidget ?? SizedBox.shrink(),
          secondaryWidget != null
              ? VerticalSpace(height: getHeight(10))
              : SizedBox.shrink(),
          isPrimaryButton
              ? CustomButton(
                  onPressed: onTap,
                  child: CustomText(
                    text: primaryText ?? "Next",
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ))
              : primaryWidget ?? SizedBox.shrink(),
          SizedBox(height: getHeight(10)),
        ],
      ),
    );
  }
}
