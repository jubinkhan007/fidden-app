import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/tattoo_artist_dashboard_controller.dart';
import '../../widgets/week_calendar_widget.dart';
import '../../widgets/dashboard_portfolio_grid.dart';
import '../../../portfolio/controller/portfolio_controller.dart';
import '../../../portfolio/presentation/screens/portfolio_grid_screen.dart';
import '../../../design_requests/presentation/screens/design_requests_list_screen.dart';
import '../../../design_requests/presentation/screens/design_request_detail_screen.dart';
import '../../../home/controller/business_owner_controller.dart';
import '../../../reviews/state/review_controller.dart';
import '../../../reviews/ui/reviews_screen.dart';
import '../../../nav_bar/controllers/user_nav_bar_controller.dart';
import '../../../barber/data/today_appointments_model.dart';
import '../../../shared/widgets/today_appointments_widgets.dart';
import '../../../../user/booking/presentation/api_time_format.dart';

/// Embeddable content widget for tattoo artist dashboard.
/// Matches the Figma design with Revenue, Client Progress, Portfolio, and Reviews.
class TattooArtistDashboardContent extends StatelessWidget {
  const TattooArtistDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TattooArtistDashboardController());
    final reviewController = Get.put(ReviewController());

    // Ensure portfolio is loaded with tattoo niche when this widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final portfolioController = Get.find<PortfolioController>();
      if (portfolioController.currentNiche.value != 'tattoo' ||
          portfolioController.portfolioItems.isEmpty) {
        portfolioController.fetchPortfolioItems(niche: 'tattoo');
      }
    });

    // Initialize reviews for shop
    final shopId = myShopId.value?.toString() ?? '';
    if (shopId.isNotEmpty && reviewController.reviews.isEmpty) {
      reviewController.fetchReviews(shopId);
    }

    return Obx(() {
      if (controller.isLoading && !controller.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshDashboard(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),

            // === UPCOMING APPOINTMENT (uses shared widget with proper timezone) ===
            _buildSectionTitle('Upcoming Appointment'),
            const SizedBox(height: 8),
            UpcomingAppointmentCard(
              controller: controller.todayAppointmentsController,
              serviceFilter: (a) => a.serviceNiche == 'tattoo_artist',
            ),

            const SizedBox(height: 20),

            // === TODAY'S SCHEDULE ===
            _buildSectionTitle(
              'Today\'s Schedule',
              trailing: _buildMonthLabel(),
            ),
            const SizedBox(height: 8),
            WeekCalendarWidget(
              selectedDate: DateTime.now(),
              onDateSelected: (date) => showDayAppointmentsBottomSheet(
                context,
                date,
                controller.todayAppointmentsController,
                serviceFilter: (a) => a.serviceNiche == 'tattoo_artist',
              ),
              getConsultationsCount: (date) =>
                  controller.getConsultationsCountForDate(date),
            ),

            const SizedBox(height: 20),

            // === REVENUE & EARNINGS ===
            _buildSectionTitle('Revenue & Earnings'),
            const SizedBox(height: 8),
            _buildRevenueCards(controller),

            const SizedBox(height: 12),
            _buildStatsRow(controller),

            const SizedBox(height: 20),

            // === CLIENT PROGRESS TRACKER ===
            _buildSectionTitle(
              'Design Requests',
              trailing: GestureDetector(
                onTap: () => Get.to(() => const DesignRequestsListScreen()),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildClientProgressTracker(controller),

            const SizedBox(height: 20),

            // === PORTFOLIO MANAGER ===
            _buildSectionTitle(
              'Portfolio Manager',
              trailing: GestureDetector(
                onTap: () => Get.to(() => const PortfolioGridScreen()),
                child: const Text(
                  'Open Portfolio',
                  style: TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DashboardPortfolioGrid(
              items: controller.recentPortfolioItems,
              onViewAll: () => Get.to(() => const PortfolioGridScreen()),
            ),

            const SizedBox(height: 20),

            // === REVIEWS ===
            _buildSectionTitle(
              'Reviews',
              trailing: GestureDetector(
                onTap: () => Get.to(() => ReviewsScreen(shopId: shopId)),
                child: const Text(
                  'See all reviews',
                  style: TextStyle(
                    color: Color(0xFFE63946),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildReviewsSection(reviewController),

            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildMonthLabel() {
    return Text(
      DateFormat('MMM d').format(DateTime.now()),
      style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
    );
  }

  Widget _buildUpcomingAppointment(TattooArtistDashboardController controller) {
    // Use dedicated TodayAppointmentsController data (fetched with niche=tattoo)
    final todayController = controller.todayAppointmentsController;
    final nextAppointment = todayController.nextAppointment;

    if (todayController.isLoading.value) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (nextAppointment == null) {
      return GestureDetector(
        onTap: () {
          // Navigate to bookings tab
          Get.find<BusinessOwnerNavBarController>().changeIndex(1);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No upcoming appointments',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'View all bookings',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    // Format time
    final timeText = DateFormat('hh:mm a').format(nextAppointment.startTime);

    return GestureDetector(
      onTap: () {
        // Navigate to booking details
        Get.find<BusinessOwnerNavBarController>().changeIndex(1);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextAppointment.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          nextAppointment.serviceName,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF52B788),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCards(TattooArtistDashboardController controller) {
    // Use niche-specific revenue from controller
    final total = controller.todayRevenue;
    final monthlyProjection = controller.monthlyProjection;

    return Row(
      children: [
        Expanded(
          child: _buildRevenueCard(
            label: "Today's Earnings",
            value: '\$${total.toStringAsFixed(2)}',
            valueColor: const Color(0xFFE63946),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRevenueCard(
            label: 'Monthly Projection',
            value: '\$${monthlyProjection.toStringAsFixed(2)}',
            valueColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(TattooArtistDashboardController controller) {
    // Use niche-specific booking count from revenue data
    final bookingCount = controller.todayBookingCount;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Today\'s Bookings',
            value: '$bookingCount',
            valueColor: const Color(0xFFE63946),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Avg Booking Value',
            value: '\$${controller.averageBookingValue.toStringAsFixed(2)}',
            valueColor: const Color(0xFF52B788),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientProgressTracker(
    TattooArtistDashboardController controller,
  ) {
    final requests = controller.pendingDesignRequests;

    if (requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'No design requests pending',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: requests.map((request) {
        return GestureDetector(
          onTap: () =>
              Get.to(() => DesignRequestDetailScreen(request: request)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Placeholder thumbnail (no images in model)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.design_services, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.description.length > 30
                            ? '${request.description.substring(0, 30)}...'
                            : request.description,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'By ${request.customerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: request.isPending
                        ? const Color(0xFFFFF3CD)
                        : const Color(0xFFD4EDDA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.isPending ? 'Pending' : 'Approved',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: request.isPending
                          ? const Color(0xFF856404)
                          : const Color(0xFF155724),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection(ReviewController reviewController) {
    return Obx(() {
      final reviews = reviewController.reviews;

      if (reviewController.isLoading.value && reviews.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (reviews.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Center(
            child: Text('No reviews yet', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      // Show first 2 reviews
      final displayReviews = reviews.take(2).toList();

      return Column(
        children: displayReviews.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: review.avatarUrl != null
                          ? NetworkImage(review.avatarUrl!)
                          : null,
                      child: review.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 20,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        review.author,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.comment,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  void _showDayAppointments(
    BuildContext context,
    DateTime date,
    TattooArtistDashboardController controller,
  ) {
    // Use TodayAppointmentsController data (already fetched for tattoo niche)
    final todayController = controller.todayAppointmentsController;
    final allAppointments = todayController.allAppointments;

    // Filter appointments for the selected date
    final dayAppointments = allAppointments.where((a) {
      return a.startTime.year == date.year &&
          a.startTime.month == date.month &&
          a.startTime.day == date.day;
    }).toList();

    // Sort by time
    dayAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    debugPrint(
      '📅 _showDayAppointments: ${dayAppointments.length} appointments for ${date.toIso8601String()}',
    );

    final dateLabel = DateFormat('EEEE, MMM d').format(date);
    final isToday =
        date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Today\'s Appointments' : dateLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dayAppointments.length} ${dayAppointments.length == 1 ? 'appointment' : 'appointments'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Appointments list
            Flexible(
              child: dayAppointments.isEmpty
                  ? _buildEmptyState(date)
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: dayAppointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final appointment = dayAppointments[index];
                        return _buildAppointmentCardFromTodayApi(appointment);
                      },
                    ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildEmptyState(DateTime date) {
    final isToday =
        date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;
    final isFuture = date.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isToday
                ? 'No appointments today'
                : isFuture
                ? 'No appointments scheduled'
                : 'No appointments were booked',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday || isFuture
                ? 'Your schedule is free!'
                : 'This day had no bookings',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic booking) {
    final status = booking.status.toString().toLowerCase();

    // Get status styling based on actual booking status
    Color statusBgColor;
    Color statusTextColor;
    String statusText;

    switch (status) {
      case 'completed':
      case 'confirmed':
        statusBgColor = const Color(0xFFE6F4EA);
        statusTextColor = const Color(0xFF2E7D32);
        statusText = status == 'completed' ? 'Completed' : 'Confirmed';
        break;
      case 'active':
        statusBgColor = const Color(0xFFE3F2FD);
        statusTextColor = const Color(0xFF1565C0);
        statusText = 'Active';
        break;
      case 'cancelled':
        statusBgColor = const Color(0xFFFFEBEE);
        statusTextColor = const Color(0xFFC62828);
        statusText = 'Cancelled';
        break;
      case 'pending':
      default:
        statusBgColor = const Color(0xFFFFF3E0);
        statusTextColor = const Color(0xFFF57C00);
        statusText = 'Pending';
        break;
    }

    // Use timezone-aware formatting if shop timezone is available
    final timeText = booking.shopTimezone != null
        ? formatApiTimeInTimezone(booking.slotTimeIso, booking.shopTimezone!)
        : DateFormat('hh:mm a').format(booking.slotTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE63946),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userName ?? 'Customer',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  booking.serviceTitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (booking.serviceDuration.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${booking.serviceDuration} min',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
          ),

          // Status indicator - using actual booking status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Appointment card for TodayAppointmentsController data (Appointment model)
  Widget _buildAppointmentCardFromTodayApi(Appointment appointment) {
    final status = appointment.status.toLowerCase();

    // Get status styling based on actual appointment status
    Color statusBgColor;
    Color statusTextColor;
    String statusText;

    switch (status) {
      case 'completed':
      case 'confirmed':
        statusBgColor = const Color(0xFFE6F4EA);
        statusTextColor = const Color(0xFF2E7D32);
        statusText = status == 'completed' ? 'Completed' : 'Confirmed';
        break;
      case 'active':
        statusBgColor = const Color(0xFFE3F2FD);
        statusTextColor = const Color(0xFF1565C0);
        statusText = 'Active';
        break;
      case 'cancelled':
        statusBgColor = const Color(0xFFFFEBEE);
        statusTextColor = const Color(0xFFC62828);
        statusText = 'Cancelled';
        break;
      case 'pending':
      default:
        statusBgColor = const Color(0xFFFFF3E0);
        statusTextColor = const Color(0xFFF57C00);
        statusText = 'Pending';
        break;
    }

    final timeText = DateFormat('hh:mm a').format(appointment.startTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              timeText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE63946),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.serviceName,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${appointment.serviceDuration} min',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
