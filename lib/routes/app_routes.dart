// lib/routes/app_routes.dart


import 'package:fidden/features/business_owner/booking/screen/booking_details_screen.dart';
import 'package:fidden/features/business_owner/coupons/screens/add_edit_coupon_screen.dart';
import 'package:fidden/features/business_owner/coupons/screens/all_coupons_screen.dart';
import 'package:fidden/features/business_owner/home/screens/all_service_screen.dart';
import 'package:fidden/features/business_owner/transactions/screens/transactions_screen.dart';
import 'package:fidden/features/notifications/presentation/screens/notification_screen.dart';
import 'package:fidden/features/user/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:fidden/features/user/booking/presentation/screens/booking_summary_screen.dart';
import 'package:fidden/features/user/coupons/presentation/screens/select_coupon_screen.dart';
import 'package:fidden/features/user/profile/presentation/screens/account_settings_screen.dart';
import 'package:fidden/features/user/profile/presentation/screens/edit_profile_screen.dart';
import 'package:fidden/features/user/profile/presentation/screens/notification_screen.dart';
import 'package:fidden/features/user/profile/presentation/screens/terms_and_condition_screen.dart';
import 'package:fidden/features/user/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/auth/presentation/screens/login/forget_email_screen.dart';
import '../features/auth/presentation/screens/login/login_screen.dart';
import '../features/auth/presentation/screens/login/new_password_screen.dart';
import '../features/auth/presentation/screens/login/password_change_successful_screen.dart';
import '../features/auth/presentation/screens/login/verify_otp_screen.dart';
import '../features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import '../features/auth/presentation/screens/sign_up/sign_up_verify_otp_screen.dart';
import '../features/auth/presentation/screens/sign_up/verification_successfull_screen.dart';
import '../features/business_owner/analytics/performance_analytics_screen.dart';
import '../features/business_owner/subscription/presentation/screens/subscription_screen.dart';
import '../features/splash/presentation/screens/on_boarding_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/user/shops/presentation/screens/shop_details_screen.dart';
import '../features/user/shops/services/presentation/screens/service_details_screen.dart';
// import '../features/user/booking/presentation/screens/aggrement_screen.dart';
// import '../features/user/home/controller/book_confirm_screen.dart';
// import '../features/user/home/presentation/screens/search_result_screen.dart';
// import '../features/user/profile/presentation/screens/edit_profile_screen.dart';
// import '../features/user/profile/presentation/screens/notification_screen.dart';
// import '../features/user/profile/presentation/screens/terms_and_condition_screen.dart';
import 'package:fidden/features/business_owner/consent_forms/presentation/screens/consent_forms_list_screen.dart';
import 'package:fidden/features/business_owner/design_requests/presentation/screens/design_requests_list_screen.dart';
import 'package:fidden/features/business_owner/id_verification/presentation/screens/id_verification_queue_screen.dart';
import 'package:fidden/features/business_owner/portfolio/presentation/screens/portfolio_grid_screen.dart';
import 'package:fidden/features/business_owner/consultation/presentation/screens/consultation_calendar_screen.dart';
import 'package:fidden/features/business_owner/home/screens/deposit_management_screen.dart';
import 'package:fidden/features/business_owner/home/screens/reviews_screen.dart';
import 'package:fidden/features/business_owner/barber/presentation/screens/no_show_alerts_screen.dart';
import 'package:fidden/features/business_owner/barber/presentation/screens/service_menu_screen.dart';
import 'package:fidden/features/business_owner/barber/presentation/screens/today_appointments_screen.dart';
import 'package:fidden/features/business_owner/barber/presentation/screens/daily_revenue_screen.dart';

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
  static String bookingSummaryScreen = "/bookingSummaryScreen";
  static String bookingConfirmScreen = "/booking-confirmation";
  static String accountSettingsScreen = "/account-settings";
  static String termsAndCondition = "/terms-and-conditions";
  static const String transactionsScreen = '/transactions';
    static const String allCouponsScreen = '/all-coupons';
  static const String addCouponScreen = '/add-coupon';
  static const String editCouponScreen = '/edit-coupon';
  static const String performanceAnalytics = '/performance-analytics';
  static const String subscriptionScreen = '/subscription';
  static const String serviceDetailsScreen = '/userServiceDetails';
  static const String shopDetailsScreen = '/shopDetailsScreen';

  // Niche Routes
  static const String portfolioScreen = '/portfolio';
  static const String designRequestsScreen = '/design-requests';
  static const String consentFormsScreen = '/consent-forms';
  static const String idVerificationScreen = '/id-verification';
  static const String consultationCalendarScreen = '/consultation-calendar';
  static const String depositManagementScreen = '/deposit-management';
  static const String reviewsScreen = '/reviews';
  static const String noShowAlertsScreen = '/no-show-alerts';
  static const String serviceMenuScreen = '/service-menu';


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
    GetPage(name: termsAndConditionScreen, page: () => TermsAndConditionScreen()),
    GetPage(name: notificationScreen, page: () => NotificationScreen()),
    GetPage(name: bookingSummaryScreen, page: () => BookingSummaryScreen()),
    GetPage(name: accountSettingsScreen, page: () => AccountSettingsScreen()),
    GetPage(name: termsAndCondition, page: () => TermsAndConditionScreen()),
    GetPage(
      name: transactionsScreen,
      page: () => const TransactionsScreen(),
    ),
    GetPage(
      name: bookingConfirmScreen,
      page: () => BookingConfirmationScreen(),
    ),

    GetPage(
      name: allCouponsScreen,
      page: () => const AllCouponsScreen(),
    ),
    GetPage(
      name: addCouponScreen,
      page: () => const AddEditCouponScreen(),
    ),
    GetPage(
      name: editCouponScreen,
      page: () => const AddEditCouponScreen(),
    ),
    GetPage(
  name: '/select-coupon',
  page: () => const SelectCouponScreen(),
),
GetPage(
  name: '/owner-booking-details',
  page: () => const BookingDetailsScreen(),
),
    // GetPage(name: searchResultScreen, page: () => SearchResultScreen()),
    // GetPage(name: bookingSuccessFullScreen, page: () => BookingSuccessfulScreen ()),

    GetPage(
      name: performanceAnalytics,
      page: () => const PerformanceAnalyticsScreen(),
    ),

    GetPage(
      name: subscriptionScreen,
      page: () => const SubscriptionScreen(),
    ),
    GetPage(
      name: serviceDetailsScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? const {};
        final int? serviceId = args['serviceId'] as int?;
        if (serviceId == null) {
          // Defensive: show a tiny placeholder if someone forgot the arg
          return const Scaffold(
            body: Center(child: Text('Missing serviceId')),
          );
        }
        return ServiceDetailsScreen(serviceId: serviceId);
      },
    ),

    GetPage(
      name: shopDetailsScreen,
      page: () => ShopDetailsScreen(id: Get.arguments['shopId']),
    ),

    // --- Niche Routes ---
    GetPage(name: portfolioScreen, page: () => const PortfolioGridScreen()),
    GetPage(name: designRequestsScreen, page: () => const DesignRequestsListScreen()),
    GetPage(name: consentFormsScreen, page: () => const ConsentFormsListScreen()),
    GetPage(name: idVerificationScreen, page: () => const IDVerificationQueueScreen()),
    GetPage(name: consultationCalendarScreen, page: () => const ConsultationCalendarScreen()),
    GetPage(name: depositManagementScreen, page: () => const DepositManagementScreen()),
    GetPage(name: reviewsScreen, page: () => const ReviewsScreen()),
    GetPage(name: noShowAlertsScreen, page: () => const NoShowAlertsScreen()),
    GetPage(name: serviceMenuScreen, page: () => const ServiceMenuScreen()),
  ];
}
