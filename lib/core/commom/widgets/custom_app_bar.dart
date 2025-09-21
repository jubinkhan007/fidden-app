import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';
import '../../utils/constants/icon_path.dart';
import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key, required this.firstText, required this.secondText, this.width,
  });

  final String firstText,secondText;
  final double? width;

  @override
  Size get preferredSize => Size.fromHeight(getHeight(56));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(

          children: [
            GestureDetector(
              onTap: (){
                Get.back();
              },
                child: Image.asset(IconPath.backArrow,width: getWidth(24),height: getHeight(24),)),
            SizedBox(width: getWidth(14),),
            CustomText(text: firstText,fontSize: getWidth(17),fontWeight: FontWeight.w700,color: AppColors.black,),
          ],
        ),
        SizedBox(height: getHeight(6),),
        Row(
          children: [
            SizedBox(width: getWidth(40),),
            SizedBox(
                width: width??getWidth(250),
                child: CustomText(text: secondText,color: Color(0xff616161),fontSize: getWidth(14),)),
          ],
        ),
      ],
    );
  }
}