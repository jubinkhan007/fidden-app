import 'package:fidden/features/business_owner/home/screens/all_service_screen.dart';
import 'package:fidden/features/user/profile/presentation/screens/edit_profile_screen.dart';
import 'package:fidden/features/user/profile/presentation/screens/notification_screen.dart';
import 'package:fidden/features/user/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:get/get.dart';
import '../features/auth/presentation/screens/login/forget_email_screen.dart';
import '../features/auth/presentation/screens/login/login_screen.dart';
import '../features/auth/presentation/screens/login/new_password_screen.dart';
import '../features/auth/presentation/screens/login/password_change_successful_screen.dart';
import '../features/auth/presentation/screens/login/verify_otp_screen.dart';
import '../features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import '../features/auth/presentation/screens/sign_up/sign_up_verify_otp_screen.dart';
import '../features/auth/presentation/screens/sign_up/verification_successfull_screen.dart';
import '../features/splash/presentation/screens/on_boarding_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
// import '../features/user/booking/presentation/screens/aggrement_screen.dart';
// import '../features/user/home/controller/book_confirm_screen.dart';
// import '../features/user/home/presentation/screens/search_result_screen.dart';
// import '../features/user/profile/presentation/screens/edit_profile_screen.dart';
// import '../features/user/profile/presentation/screens/notification_screen.dart';
// import '../features/user/profile/presentation/screens/terms_and_condition_screen.dart';

class AppRoute {
  static String init = "/";
  static String onboarding = "/onboarding";

  static String landingScreen = "/landingScreen";
  static String wishListScreen = "/wishListScreen";

  static String loginScreen = "/loginScreen";
  static String signUpScreen = "/signUpScreen";
  static String forgetEmailScreen = "/forgetEmailScreen";
  static String verifyOTPScreen = "/verifyOTPScreen";
  static String signUpVerifyOTPScreen = "/signUpVerifyOTPScreen";
  static String newPasswordScreen = "/newPasswordScreen";
  static String passwordChangeSuccessfulScreen =
      "/passwordChangeSuccessfulScreen";
  static String verificationSuccessfulScreen = "/verificationSuccessfulScreen";
  static String editProfileScreen = "/editProfileScreen";
  static String termsAndConditionScreen = "/termsAndConditionScreen";
  static String notificationScreen = "/notificationScreen";
  static String searchResultScreen = "/searchResultScreen";
  static String bookingSuccessFullScreen = "/bookingSuccessFullScreen";

  static List<GetPage> routes = [
    //Splash Screen: initial screen
    GetPage(name: init, page: () => SplashScreen()),
    //GetPage(name: init, page: () => AgreementScreen()),
    GetPage(name: onboarding, page: () => OnBoardingThreeScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: forgetEmailScreen, page: () => ForgetEmailScreen()),
    GetPage(name: wishListScreen, page: () => const WishlistScreen()),
    //GetPage(name: verifyOTPScreen, page: () => VerifyOtpScreen()),
    //GetPage(name: newPasswordScreen, page: () => NewPasswordScreen()),
    GetPage(
      name: passwordChangeSuccessfulScreen,
      page: () => PasswordChangeSuccessfulScreen(),
    ),
    GetPage(name: signUpScreen, page: () => SignUpScreen()),
    //GetPage(name: signUpVerifyOTPScreen, page: () => SignUpVerifyOtpScreen()),
    GetPage(
      name: verificationSuccessfulScreen,
      page: () => VerificationSuccessFullScreen(),
    ),

    GetPage(name: editProfileScreen, page: () => EditProfileScreen()),
    GetPage(name: '/all-services', page: () => const AllServiceScreen()),
    // GetPage(name: termsAndConditionScreen, page: () => TermsAndConditionScreen()),
    GetPage(name: notificationScreen, page: () => NotificationScreen()),
    // GetPage(name: searchResultScreen, page: () => SearchResultScreen()),
    // GetPage(name: bookingSuccessFullScreen, page: () => BookingSuccessfulScreen ()),
  ];
}
