class AppUrls {
  AppUrls._();

  //static const String _baseUrl = 'http://10.0.20.64:5010/api/v1';
  static const String _baseUrl = 'https://fidden-service-provider.onrender.com';
  static const String createAccount = '$_baseUrl/accounts/register/';
  static const String forgotEmail = '$_baseUrl/accounts/request-reset/';
  static const String verifyOtp = '$_baseUrl/accounts/verify-otp/';
  static const String changePassword = '$_baseUrl/accounts/reset-password/';

  static const String login = '$_baseUrl/accounts/login/';
  static const String socialLogin = '$_baseUrl/accounts/login/google/';

  // User
  static const String getMyProfile = '$_baseUrl/users/me';
  static const String updateProfile = '$_baseUrl/users/update-profile';
  static const String activeBooking = '$_baseUrl/booking/users?status=pending';
  static const String completeBooking =
      '$_baseUrl/booking/users?status=completed';
  static const String createReview = '$_baseUrl/review/create';

  // User
  static getNearByService({required String lat, required String lon}) =>
      '$_baseUrl/find-near-by?myLat=$lat&myLon=$lon';

  // Seller
  static const String getMyService = '$_baseUrl/service/my-service';
  static const String getMBusinessProfile =
      '$_baseUrl/business-profile/my-business';
  static const String getAllMostRecommendedBusinessProfile =
      '$_baseUrl/business-profile?rate=4';
  static const String businessProfile = '$_baseUrl/business-profile/create';
  static editBusinessProfile(String id) => '$_baseUrl/business-profile/$id';
  static getSingleService(String id) => '$_baseUrl/service/single/$id';
  static updateService(String id) => '$_baseUrl/service/$id';

  // Service
  static const String createService = '$_baseUrl/service/create';
  static const String offerService = '$_baseUrl/service/offer';
  static getCustomerForm(String bookingId) =>
      '$_baseUrl/customer-form/$bookingId';

  // booking
  static getServiceTime({required String businessId, required String date}) =>
      '$_baseUrl/available-schedule?businessId=$businessId&date=$date';
  static const String createBooking = '$_baseUrl/booking/create';
  static const String createCustomerForm = '$_baseUrl/customer-form/create';

  // payment
  static const String confirmPayment = "$_baseUrl/payment/payment";
  static const String saveCard = "$_baseUrl/payments/save-new-card";
  static String getMyCard(String customerId) =>
      '$_baseUrl/payments/$customerId';
  static String getMyCoupon(String couponCode) =>
      '$_baseUrl/coupon/check?code=$couponCode';

  // seller booking
  static const String ownerBooking = "$_baseUrl/booking/owners";

  // Add reminder
  static createReminder(String userId) =>
      "$_baseUrl/notifications/send-notification/$userId";

  static const String formCreate = "$_baseUrl/business-profile-from/create";
  static getWaiverFormCreate(String businessId) =>
      "$_baseUrl/business-profile-from/$businessId";

  // Notification
  static const String allMyNotification = "$_baseUrl/notifications";

  //search
  static searchService(String text) => "$_baseUrl/service/search?service=$text";
  static String searchBusinessProfile = "$_baseUrl/business-profile";
}
