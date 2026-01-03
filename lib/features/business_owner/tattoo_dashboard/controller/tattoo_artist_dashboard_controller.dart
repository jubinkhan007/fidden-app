import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../consultation/controller/consultation_controller.dart';
import '../../design_requests/controller/design_request_controller.dart';
import '../../portfolio/controller/portfolio_controller.dart';
import '../../id_verification/controller/id_verification_controller.dart';
import '../../consultation/data/consultation_model.dart';
import '../../design_requests/data/design_request_model.dart';
import '../../portfolio/data/portfolio_item_model.dart';
import '../../id_verification/data/id_verification_model.dart';
import '../../barber/services/barber_dashboard_service.dart';
import '../../barber/data/daily_revenue_model.dart';
import '../../barber/controller/today_appointments_controller.dart';

/// Lightweight coordinator controller for Tattoo Artist Dashboard
/// Reuses all existing feature controllers - no new API calls
class TattooArtistDashboardController extends GetxController {
  // Get existing controllers
  ConsultationController get consultationController =>
      Get.find<ConsultationController>();
  DesignRequestController get designRequestController =>
      Get.find<DesignRequestController>();
  PortfolioController get portfolioController =>
      Get.find<PortfolioController>();
  IDVerificationController get idVerificationController =>
      Get.find<IDVerificationController>();
  TodayAppointmentsController get todayAppointmentsController =>
      Get.find<TodayAppointmentsController>();

  final RxBool isRefreshing = false.obs;

  // Niche-specific revenue data
  final BarberDashboardService _revenueService = BarberDashboardService();
  final Rx<DailyRevenueResponse?> dailyRevenue = Rx<DailyRevenueResponse?>(
    null,
  );
  final RxBool isRevenueLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🎨 TattooArtistDashboardController: onInit');
    // Initialize all feature controllers if not already initialized
    _initializeControllers();
    // Fetch tattoo-specific revenue
    fetchNicheRevenue();
    // Fetch today's tattoo appointments
    _fetchTodayTattooAppointments();
  }

  Future<void> _fetchTodayTattooAppointments() async {
    debugPrint(
      '🎨 TattooArtistDashboardController: fetching today\'s tattoo appointments',
    );
    await todayAppointmentsController.fetchAppointments(niche: 'tattoo');
  }

  void _initializeControllers() {
    // Put controllers in GetX if they don't exist
    if (!Get.isRegistered<ConsultationController>()) {
      Get.put(ConsultationController());
    }
    if (!Get.isRegistered<DesignRequestController>()) {
      Get.put(DesignRequestController());
    }
    if (!Get.isRegistered<PortfolioController>()) {
      Get.put(PortfolioController());
    }
    if (!Get.isRegistered<IDVerificationController>()) {
      Get.put(IDVerificationController());
    }
    if (!Get.isRegistered<TodayAppointmentsController>()) {
      Get.put(TodayAppointmentsController());
    }

    // Always fetch portfolio with tattoo niche on dashboard init
    if (portfolioController.currentNiche.value != 'tattoo' ||
        portfolioController.portfolioItems.isEmpty) {
      portfolioController.fetchPortfolioItems(niche: 'tattoo');
    }
  }

  /// Fetch tattoo-specific revenue
  Future<void> fetchNicheRevenue() async {
    try {
      isRevenueLoading.value = true;
      dailyRevenue.value = await _revenueService.getDailyRevenue(
        niche: 'tattoo',
      );
    } catch (e) {
      // Silently fail, show 0 revenue
      dailyRevenue.value = null;
    } finally {
      isRevenueLoading.value = false;
    }
  }

  // Revenue getters
  double get todayRevenue => dailyRevenue.value?.totalRevenue ?? 0.0;
  int get todayBookingCount => dailyRevenue.value?.bookingCount ?? 0;
  double get averageBookingValue =>
      dailyRevenue.value?.averageBookingValue ?? 0.0;
  double get monthlyProjection => todayRevenue * 30; // Simple projection

  /// Refresh all dashboard data
  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await Future.wait([
        consultationController.fetchConsultations(),
        designRequestController.fetchDesignRequests(),
        portfolioController.fetchPortfolioItems(niche: 'tattoo'),
        idVerificationController.fetchIDVerifications(),
        fetchNicheRevenue(),
        _fetchTodayTattooAppointments(),
      ]);
    } finally {
      isRefreshing.value = false;
    }
  }

  // === COMPUTED GETTERS (No new APIs, just filter existing data) ===

  /// Get next upcoming consultation
  Consultation? get nextUpcomingConsultation {
    final now = DateTime.now();
    final upcomingConsultations =
        consultationController.consultations
            .where(
              (c) => c.dateTime.isAfter(now) && !c.isCancelled && !c.isNoShow,
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return upcomingConsultations.isEmpty ? null : upcomingConsultations.first;
  }

  /// Get consultations for current week (7 days from today)
  List<Consultation> get weekConsultations {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    return consultationController.consultations
        .where(
          (c) =>
              c.dateTime.isAfter(now) &&
              c.dateTime.isBefore(weekEnd) &&
              !c.isCancelled &&
              !c.isNoShow,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Get consultations count for a specific date
  int getConsultationsCountForDate(DateTime date) {
    return consultationController.consultations
        .where(
          (c) =>
              c.dateTime.year == date.year &&
              c.dateTime.month == date.month &&
              c.dateTime.day == date.day,
        )
        .length;
  }

  /// Get pending design requests (max 3 for dashboard, filtered for tattoo_artist niche)
  List<DesignRequest> get pendingDesignRequests {
    final pending =
        designRequestController.requests
            .where(
              (r) =>
                  r.isPending &&
                  (r.serviceNiche == 'tattoo_artist' || r.serviceNiche == null),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return pending.take(3).toList();
  }

  /// Get recent portfolio items (max 6 for dashboard)
  /// Backend already filters by niche via fetchPortfolioItems(niche: 'tattoo')
  List<PortfolioItem> get recentPortfolioItems {
    final items = portfolioController.portfolioItems.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items.take(6).toList();
  }

  /// Get pending ID verifications (max 3 for dashboard)
  List<IDVerificationRequest> get pendingIDVerifications {
    final pending =
        idVerificationController.verifications
            .where((v) => v.isUnderReview)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return pending.take(3).toList();
  }

  // === ACTIVITY STATS ===

  int get pendingDesignRequestsCount {
    return designRequestController.requests
        .where(
          (r) =>
              r.isPending &&
              (r.serviceNiche == 'tattoo_artist' || r.serviceNiche == null),
        )
        .length;
  }

  int get pendingIDVerificationsCount {
    return idVerificationController.verifications
        .where((v) => v.isUnderReview)
        .length;
  }

  int get upcomingConsultationsCount {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    return consultationController.consultations
        .where(
          (c) =>
              c.dateTime.isAfter(now) &&
              c.dateTime.isBefore(weekEnd) &&
              !c.isCancelled &&
              !c.isNoShow,
        )
        .length;
  }

  int get portfolioItemsCount {
    return portfolioController.portfolioItems.length;
  }

  // === LOADING STATES ===

  bool get isLoading {
    return consultationController.isLoading.value ||
        designRequestController.isLoading.value ||
        portfolioController.isLoading.value ||
        idVerificationController.isLoading.value;
  }

  bool get hasData {
    return consultationController.consultations.isNotEmpty ||
        designRequestController.requests.isNotEmpty ||
        portfolioController.portfolioItems.isNotEmpty ||
        idVerificationController.verifications.isNotEmpty;
  }
}
