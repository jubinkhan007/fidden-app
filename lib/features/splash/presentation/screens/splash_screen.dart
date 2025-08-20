import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constants/app_colors.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../core/utils/constants/image_path.dart';
import '../../controller/splash_controller.dart';


class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final SplashController splashController = Get.find<SplashController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: getWidth(66)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: getHeight(180),),
              Image.asset(
                ImagePath.splashLogo ,
                height: getHeight(160),
                width: getWidth(234),
              ),
              SizedBox(height: getHeight(280),),

              Center(
                child: SpinKitFadingCircle(
                  color: AppColors.primaryColor,
                  size: getWidth(60),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
