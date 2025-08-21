import 'package:get/get.dart';

import '../../features/auth/controller/login_controller.dart';
//import '../../features/business_owner/home/controller/business_owner_controller.dart';
import '../../features/business_owner/nav_bar/controllers/user_nav_bar_controller.dart';
import '../../features/splash/controller/splash_controller.dart';
//import '../../features/user/booking/controller/booking_controller.dart';
//import '../../features/user/home/controller/home_controller.dart';
import '../../features/user/nav_bar/controllers/user_nav_bar_controller.dart';
import '../../features/user/profile/controller/profile_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // LoginController
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);

    Get.lazyPut<UserNavBarController>(
      () => UserNavBarController(),
      fenix: true,
    );
    Get.lazyPut<BusinessOwnerNavBarController>(
      () => BusinessOwnerNavBarController(),
      fenix: true,
    );
    // Get.lazyPut<BusinessOwnerController >(
    //       () => BusinessOwnerController (),
    //   fenix: true,
    // );
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    // Get.lazyPut<BusinessOwnerController >(
    //       () => BusinessOwnerController (),
    //   fenix: true,
    // );

    // Get.lazyPut<HomeController>(
    //       () => HomeController(),
    //   fenix: true,
    // );
    // Get.lazyPut<BookingController>(
    //       () => BookingController(),
    //   fenix: true,
    // );

    // Get.lazyPut<BusinessOwnerController>(
    //   () => BusinessOwnerController(),
    //   fenix: true,
    // );
  }
}
