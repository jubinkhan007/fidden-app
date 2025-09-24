import 'dart:developer';

class AppUrls {
  AppUrls._();

  //static const String _baseUrl = 'http://10.0.20.64:5010/api/v1';
  static const String _baseUrl =
      'https://fidden-service-provider-1.onrender.com';
  static String socketUrl(String accessToken) {
    log("accessToke ${accessToken}");
    return 'wss://fidden-service-provider-1.onrender.com/ws/chat/?token=$accessToken';
  }

  static String sendToShop(int shopId) => '$_baseUrl/api/threads/$shopId/send/';
  static String replyInThread(int threadId) =>
      '$_baseUrl/api/threads/$threadId/reply/';

  static const String createAccount = '$_baseUrl/accounts/register/';
  static const String forgotEmail = '$_baseUrl/accounts/request-reset/';
  static const String verifyOtp = '$_baseUrl/accounts/verify-otp/';
  static const String resetPassword = '$_baseUrl/accounts/reset-password/';
  static const String changePassword = '$_baseUrl/accounts/change-password/';

  static const String login = '$_baseUrl/accounts/login/';
  static const String socialLogin = '$_baseUrl/accounts/login/google/';
  static const String refreshToken = '$_baseUrl/accounts/token/refresh/';

  // User-booking
  static const String getMyProfile = '$_baseUrl/accounts/profile/';
  static const String updateProfile = '$_baseUrl/accounts/profile/';
  static const String activeBooking = '$_baseUrl/booking/users?status=pending';
  static const String completeBooking =
      '$_baseUrl/booking/users?status=completed';
  static String cancelBooking(int bookingId) => '$_baseUrl/payments/bookings/cancel/$bookingId/';

      static String userBookings(String email) => '$_baseUrl/payments/bookings/?user_email=$email';
  static const String createReview = '$_baseUrl/api/reviews/';
  static const String allShops = '$_baseUrl/api/users/shops/';
  static const String serviceDetails =
      '$_baseUrl/api/shops'; // ✅ Added this line


// transactions
  static String transactions (int shopId) => '$_baseUrl/payments/transactions/?shop=$shopId';

// owner-booking
  

  //inbox-messaging
  static const String threads = '$_baseUrl/api/threads/';

  // owner-Review
  static String shopReviews(String shopId) =>
      '${AppUrls._baseUrl}/api/shops/rating-reviews/$shopId/';
  static String replyReviews(String reviewId) =>
      '${AppUrls._baseUrl}/api/create-reply/$reviewId/';

  static const String promoOffers = '$_baseUrl/promo-offers';

  //wishList
  static const String shopWishlist = '$_baseUrl/api/users/favorite-shop/';
  static const String serviceWishlist = '$_baseUrl/api/users/service-wishlist/';
  // User
  static getNearByService({required String lat, required String lon}) =>
      '$_baseUrl/find-near-by?myLat=$lat&myLon=$lon';

  //Global Search
  static String globalSearch(String q) => '${_baseUrl}/api/global-search/?q=$q';

  // register-device
  static String registerDevice = '${_baseUrl}/api/register-device/';
  // Seller
  static const String getMyService = '$_baseUrl/api/services/';
  static const String getMBusinessProfile = '$_baseUrl/api/shop/';
  static const String getAllMostRecommendedBusinessProfile =
      '$_baseUrl/business-profile?rate=4';
  static const String businessProfile = '$_baseUrl/api/shop/';
  static editBusinessProfile(String id) => '$_baseUrl/api/shop/$id/';
  static deleteShop(String id) => '$_baseUrl/api/shop/$id/';
  static getSingleService(String id) => '$_baseUrl/api/services/$id/';  
  static updateService(String id) => '$_baseUrl/api/services/$id/';

  // Service
  static const String createService = '$_baseUrl/api/services/';
  static const String offerService = '$_baseUrl/service/offer';
  static getCustomerForm(String bookingId) =>
      '$_baseUrl/customer-form/$bookingId';
  static deleteService(String id) => '$_baseUrl/api/services/$id/';

  static String shopDetails(String id) =>
      '$_baseUrl/api/users/shops/details/$id';

  // owner-dashboard
  // NEW: 7-day revenue for a shop
  static String shopRevenues(int shopId, {int day = 7}) =>
      '$_baseUrl/api/shop/$shopId/revenues/?day=$day';
  static String growthSuggestions(String shopId) =>
      '$_baseUrl/api/growth-suggestions/?shop_id=$shopId';

  //categories
  static const String getCategories = '$_baseUrl/api/categories/';
  static const String allServices = '$_baseUrl/api/users/services/';

  //User-Home_Screen
  static const String promotions = '$_baseUrl/api/promotions/';
  static const String trendingServices = '$_baseUrl/api/users/services/?top=5';
  static const String popularShops = '$_baseUrl/api/users/shops/?top=5';
  static const String categories = '$_baseUrl/api/categories/';

  // booking
  static getServiceTime({required String businessId, required String date}) =>
      '$_baseUrl/available-schedule?businessId=$businessId&date=$date';
  static const String createBooking = '$_baseUrl/booking/create';
  static const String slotBooking = '$_baseUrl/api/slot-booking/';
  static const String createCustomerForm = '$_baseUrl/customer-form/create';
  static String cancelSlotBooking(int bookingId) =>
      '$_baseUrl/api/slot-booking/$bookingId/cancel/';
  static String getSlotsForShop(int shopId) =>
      '/api/shop-details/$shopId/slots/';
  // payment
  static String paymentIntent(int bookingId) =>
      '$_baseUrl/payments/payment-intent/$bookingId/';
  static String stripeOnborading(int shopId) =>
      '$_baseUrl/payments/shop-onboarding/${shopId}/';
  static String verifyOnborading(int shopId) =>
      '$_baseUrl/payments/shops/verify-onboarding/${shopId}';
  static const String confirmPayment = "$_baseUrl/payment/payment";
  static const String saveCard = "$_baseUrl/payments/save-new-card";
  static String getMyCard(String customerId) =>
      '$_baseUrl/payments/$customerId';
  static String getMyCoupon(String couponCode) =>
      '$_baseUrl/coupon/check?code=$couponCode';
  static const String getOwnerCoupons = '$_baseUrl/api/coupons/';
  static String updateCoupon(int id) => '$_baseUrl/api/coupons/$id/';

// user coupons
static String UserCoupon(int shopId, int serviceId) => '${_baseUrl}/api/users/coupons/?shop_id=$shopId&service_id=$serviceId';
  // seller booking
  static String ownerBooking (String shop_id) => '$_baseUrl/payments/bookings/?shop_id=$shop_id';

  // Add reminder
  static createReminder(String userId) =>
      "$_baseUrl/notifications/send-notification/$userId";

  static const String formCreate = "$_baseUrl/business-profile-from/create";
  static getWaiverFormCreate(String businessId) =>
      "$_baseUrl/business-profile-from/$businessId";

  // Notification
  static const String notifications = "$_baseUrl/api/notifications/";
  static String markNotificationAsRead(int notificationId) =>
      '$_baseUrl/api/notifications/$notificationId/';

  //search
  static searchService(String text) => "$_baseUrl/service/search?service=$text";
  static String searchBusinessProfile = "$_baseUrl/business-profile";
}
