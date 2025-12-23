// lib/core/utils/constants/api_constants.dart

import 'dart:developer';

class AppUrls {
  AppUrls._();

  static const String _baseUrl = 'https://phase2.fidden.io';
  static String socketUrl(String accessToken) {
    log("accessToke ${accessToken}");
    return 'wss://phase2.fidden.io/ws/chat/?token=$accessToken';
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
  static String cancelBooking(int bookingId) =>
      '$_baseUrl/payments/bookings/cancel/$bookingId/';

  static String userBookings(String email, {bool excludeActive = false}) {
    final base = '$_baseUrl/payments/bookings/';
    final qp = <String, String>{
      'user_email': email,
      if (excludeActive) 'exclude_active': 'true',
    };
    return Uri.parse(base).replace(queryParameters: qp).toString();
  }

  static String userBookingDetail(int id) => '$_baseUrl/payments/bookings/$id/';

  static const String createReview = '$_baseUrl/api/reviews/';
  static const String allShops = '$_baseUrl/api/users/shops/';
  static const String serviceDetails =
      '$_baseUrl/api/shops'; // ✅ Added this line

  // transactions
  static String transactions(int shopId) =>
      '$_baseUrl/payments/transactions/?shop=$shopId';

  // Transaction aggregation for pro dashboard (V1 backend fix)
  static String transactionsAggregate(int shopId) =>
      '$_baseUrl/payments/shops/$shopId/transactions/aggregate/';

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

  // Tattoo Artist Features
  static const String portfolio = '$_baseUrl/api/portfolio/';
  static const String designRequests = '$_baseUrl/api/design-requests/';
  static const String signedConsents = '$_baseUrl/api/consent-forms/signed/';
  static const String idVerification = '$_baseUrl/api/id-verification/';
  static const String consultations = '$_baseUrl/api/consultations/';

  // Barber Dashboard Features
  static const String todayAppointments =
      '$_baseUrl/api/barber/today-appointments/';
  static const String dailyRevenue = '$_baseUrl/api/barber/daily-revenue/';
  static const String noShowAlerts = '$_baseUrl/api/barber/no-show-alerts/';

  // Walk-In Queue
  static const String walkIns = '$_baseUrl/api/barber/walk-ins/';
  static String walkInDetail(int id) => '$_baseUrl/api/barber/walk-ins/$id/';

  // Loyalty Program
  static const String loyaltyProgram = '$_baseUrl/api/barber/loyalty/program/';
  static const String loyaltyCustomers =
      '$_baseUrl/api/barber/loyalty/customers/';
  static const String loyaltyAddPoints =
      '$_baseUrl/api/barber/loyalty/add-points/';
  static const String loyaltyRedeem = '$_baseUrl/api/barber/loyalty/redeem/';

  // Nail Tech Dashboard
  static const String nailtechDashboard = '$_baseUrl/api/nailtech/dashboard/';
  static const String styleRequests = '$_baseUrl/api/nailtech/style-requests/';
  static String styleRequestDetail(int id) =>
      '$_baseUrl/api/nailtech/style-requests/$id/';
  static const String nailtechLookbook = '$_baseUrl/api/nailtech/lookbook/';
  static const String bookingsByStyle =
      '$_baseUrl/api/nailtech/bookings-by-style/';
  static const String tipSummary = '$_baseUrl/api/nailtech/tip-summary/';

  // MUA Dashboard 💄
  static const String muaDashboard = '$_baseUrl/api/mua/dashboard/';
  static const String muaFaceCharts = '$_baseUrl/api/mua/face-charts/';
  static const String muaClientProfiles = '$_baseUrl/api/mua/client-profiles/';
  static String muaClientProfileDetail(int id) =>
      '$_baseUrl/api/mua/client-profiles/$id/';
  static const String muaProductKit = '$_baseUrl/api/mua/product-kit/';
  static String muaProductKitDetail(int id) =>
      '$_baseUrl/api/mua/product-kit/$id/';

  // Hairstylist Dashboard 💇‍♀️
  static const String hairstylistDashboard =
      '$_baseUrl/api/hairstylist/dashboard/';
  static const String hairstylistWeeklySchedule =
      '$_baseUrl/api/hairstylist/weekly-schedule/';
  static const String hairstylistPrepNotes =
      '$_baseUrl/api/hairstylist/prep-notes/';
  static const String hairstylistClientProfiles =
      '$_baseUrl/api/hairstylist/client-profiles/';
  static String hairstylistClientProfileDetail(int id) =>
      '$_baseUrl/api/hairstylist/client-profiles/$id/';
  static const String hairstylistRecommendations =
      '$_baseUrl/api/hairstylist/recommendations/';
  static String hairstylistRecommendationDetail(int id) =>
      '$_baseUrl/api/hairstylist/recommendations/$id/';

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

  // subscription

  static const String subscriptionPlans = '$_baseUrl/subscriptions/plans/';
  static const String subscriptionDetails = '$_baseUrl/subscriptions/details/';
  static const String createCheckoutSession =
      '$_baseUrl/subscriptions/create-checkout-session/';
  static const String cancelSubscription =
      '$_baseUrl/subscriptions/cancel-subscription/';

  // Owner PayPal Subscription
  static const String createPayPalSubOrder =
      '$_baseUrl/payments/paypal/subscription/create-order/';
  static const String capturePayPalSubOrder =
      '$_baseUrl/payments/paypal/subscription/capture-order/';

  // Owner PayPal AI Add-on
  static const String createPayPalAiOrder =
      '$_baseUrl/payments/paypal/ai-addon/create-order/';
  static const String capturePayPalAiOrder =
      '$_baseUrl/payments/paypal/ai-addon/capture-order/';

  static String ownerSlots({
    required int shopId,
    required int serviceId,
    required String date,
  }) => '${_baseUrl}/api/shops/$shopId/slots/?service=$serviceId&date=$date';
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

  // Checkout (Fidden Pay)
  static String initiateCheckout(int bookingId) =>
      '$_baseUrl/payments/initiate-checkout/$bookingId/';
  static String checkoutDetails(int bookingId) =>
      '$_baseUrl/payments/checkout-details/$bookingId/';
  static String completeCheckout(int bookingId) =>
      '$_baseUrl/payments/complete-checkout/$bookingId/';

  static String getMyCoupon(String couponCode) =>
      '$_baseUrl/coupon/check?code=$couponCode';
  static const String getOwnerCoupons = '$_baseUrl/api/coupons/';
  static String updateCoupon(int id) => '$_baseUrl/api/coupons/$id/';

  // user coupons
  static String UserCoupon(int shopId, int serviceId) =>
      '${_baseUrl}/api/users/coupons/?shop_id=$shopId&service_id=$serviceId';
  // seller booking
  static String ownerBooking(String shop_id) =>
      '$_baseUrl/payments/bookings/?shop_id=$shop_id';

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

  //analytics
  static const analytics = '$_baseUrl/api/analytics';

  // ai

  static const String aiReport = '$_baseUrl/api/weekly-summary/latest/';
  static const String generateContent = '$_baseUrl/api/weekly-summary/';
  static const String checkoutAiAddon =
      '$_baseUrl/subscriptions/create-ai-addon-checkout-session/';
  static const cancelAiAddon = '$_baseUrl/subscriptions/cancel-ai-addon/';

  static String markNoShow(int bookingId) =>
      '$_baseUrl/payments/bookings/$bookingId/mark-no-show/';

  static String ownerCancelBooking(int bookingId) =>
      '${_baseUrl}/payments/bookings/cancel/$bookingId/';

  // PayPal Endpoints
  static String createPayPalOrder(String slotId) =>
      '$_baseUrl/payments/paypal/create-order/$slotId/';

  static const String capturePayPalOrder =
      '$_baseUrl/payments/paypal/capture-order/';

  // ========== Niche-Specific Endpoints ==========

  // Tattoo Artist - Portfolio
  static const String portfolioList = '$_baseUrl/api/portfolio/';
  static String portfolioItem(int id) => '$_baseUrl/api/portfolio/$id/';

  // Gallery (Universal for all niches)
  static const String galleryList = '$_baseUrl/api/gallery/';
  static String galleryItem(int id) => '$_baseUrl/api/gallery/$id/';
  static String shopGallery(int shopId, {int page = 1}) =>
      '$_baseUrl/api/shops/$shopId/gallery/?page=$page';

  // Tattoo Artist - Design Requests
  static String designRequest(int id) => '$_baseUrl/api/design-requests/$id/';
  static String designRequestImages(int id) =>
      '$_baseUrl/api/design-requests/$id/images/';

  // Tattoo Artist - Consent Forms
  static const String consentTemplates =
      '$_baseUrl/api/consent-forms/templates/';
  static String consentTemplate(int id) =>
      '$_baseUrl/api/consent-forms/templates/$id/';
  static const String signedConsentForms =
      '$_baseUrl/api/consent-forms/signed/';
  static String signedConsentForm(int id) =>
      '$_baseUrl/api/consent-forms/signed/$id/';

  // Tattoo Artist - ID Verification
  static const String idVerificationList = '$_baseUrl/api/id-verification/';
  static String idVerificationItem(int id) =>
      '$_baseUrl/api/id-verification/$id/';

  // ========== Esthetician Endpoints 🧖 ==========
  static const String estheticianDashboard =
      '$_baseUrl/api/esthetician/dashboard/';
  static const String estheticianClientProfiles =
      '$_baseUrl/api/esthetician/client-profiles/';
  static String estheticianClientProfileDetail(int id) =>
      '$_baseUrl/api/esthetician/client-profiles/$id/';
  static const String estheticianHealthDisclosures =
      '$_baseUrl/api/esthetician/health-disclosures/';
  static String estheticianHealthDisclosureDetail(int id) =>
      '$_baseUrl/api/esthetician/health-disclosures/$id/';
  static const String estheticianTreatmentNotes =
      '$_baseUrl/api/esthetician/treatment-notes/';
  static String estheticianTreatmentNoteDetail(int id) =>
      '$_baseUrl/api/esthetician/treatment-notes/$id/';
  static const String estheticianRetailProducts =
      '$_baseUrl/api/esthetician/retail-products/';
  static String estheticianRetailProductDetail(int id) =>
      '$_baseUrl/api/esthetician/retail-products/$id/';

  // ========== Massage Therapist Endpoints 💆 ==========
  static const String massageDashboard = '$_baseUrl/api/massage/dashboard/';
  static const String massageClientProfiles =
      '$_baseUrl/api/massage/client-profiles/';
  static String massageClientProfileDetail(int id) =>
      '$_baseUrl/api/massage/client-profiles/$id/';
  static const String massageHealthDisclosures =
      '$_baseUrl/api/massage/health-disclosures/';
  static String massageHealthDisclosureDetail(int id) =>
      '$_baseUrl/api/massage/health-disclosures/$id/';
  static const String massageTreatmentNotes =
      '$_baseUrl/api/massage/treatment-notes/';
  static String massageTreatmentNoteDetail(int id) =>
      '$_baseUrl/api/massage/treatment-notes/$id/';

  // ========== Client Self-Service (Skin/Health) ==========
  static const String mySkinProfile = '$_baseUrl/api/my-skin-profile/';
  static const String myHealthDisclosure =
      '$_baseUrl/api/my-health-disclosure/';
}
