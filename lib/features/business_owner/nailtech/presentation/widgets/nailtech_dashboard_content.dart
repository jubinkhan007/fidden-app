import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fidden/core/utils/timezone_helper.dart';
import 'package:fidden/features/business_owner/barber/controller/today_appointments_controller.dart';
import 'package:fidden/features/business_owner/barber/controller/daily_revenue_controller.dart';
import 'package:fidden/features/business_owner/nailtech/controller/style_request_controller.dart';
import 'package:fidden/features/business_owner/nailtech/controller/nailtech_dashboard_controller.dart';
import 'package:fidden/features/business_owner/portfolio/controller/portfolio_controller.dart';
import 'package:fidden/features/business_owner/tattoo_dashboard/widgets/week_calendar_widget.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/reviews/state/review_controller.dart';
import 'package:fidden/features/business_owner/reviews/ui/reviews_screen.dart';
import 'package:fidden/features/business_owner/nav_bar/controllers/user_nav_bar_controller.dart';
import 'package:fidden/features/user/booking/presentation/api_time_format.dart';
import 'package:fidden/features/business_owner/nailtech/presentation/screens/style_requests_screen.dart';
import 'package:fidden/features/business_owner/nailtech/presentation/screens/nailtech_lookbook_screen.dart';
import 'package:fidden/features/business_owner/shared/widgets/today_appointments_widgets.dart';
import 'package:fidden/features/business_owner/barber/data/today_appointments_model.dart';

/// Filter function to check if an appointment is nail-related.
/// Matches services containing: nail, manicure, pedicure, gel, acrylic, polish
bool _isNailRelatedService(Appointment a) {
  final serviceName = a.serviceName.toLowerCase();
  return serviceName.contains('nail') ||
      serviceName.contains('manicure') ||
      serviceName.contains('pedicure') ||
      serviceName.contains('gel') ||
      serviceName.contains('acrylic') ||
      serviceName.contains('polish');
}

/// Embeddable content widget for nail tech dashboard.
/// Matches the Figma design with modifications per spec.
class NailTechDashboardContent extends StatelessWidget {
  const NailTechDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final boController = Get.find<BusinessOwnerController>();
    final todayController = Get.put(TodayAppointmentsController());
    // Fetch all appointments (client-side filtering with _isNailRelatedService)
    todayController.fetchAppointments();
    final revenueController = Get.put(DailyRevenueController());
    final styleRequestController = Get.put(StyleRequestController());
    final dashboardController = Get.put(NailTechDashboardController());
    final portfolioController = Get.put(PortfolioController());

    // Always fetch portfolio with nail niche when dashboard loads
    // Use WidgetsBinding to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (portfolioController.currentNiche.value != 'nail' ||
          portfolioController.portfolioItems.isEmpty) {
        portfolioController.fetchPortfolioItems(niche: 'nail');
      }
    });

    // Get shop ID for reviews
    final shopIdValue = myShopId.value;
    final shopId = shopIdValue?.toString() ?? '';

    if (shopId.isNotEmpty) {
      Get.put(ReviewController())..fetchReviews(shopId);
    }

    return RefreshIndicator(
      onRefresh: () async {
        todayController.fetchAppointments();
        revenueController.fetchRevenue();
        styleRequestController.fetchStyleRequests();
        dashboardController.fetchAll();
        portfolioController.fetchPortfolioItems(niche: 'nail');
        boController.fetchBusinessOwnerBooking();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),

          // === UPCOMING APPOINTMENT (uses shared widget with nail filter) ===
          _buildSectionTitle('Upcoming Appointment'),
          const SizedBox(height: 8),
          UpcomingAppointmentCard(
            controller: todayController,
            serviceFilter: _isNailRelatedService,
          ),

          const SizedBox(height: 20),

          // === TODAY'S SCHEDULE ===
          _buildSectionTitle('Today\'s Schedule', trailing: _buildMonthLabel()),
          const SizedBox(height: 8),
          WeekCalendarWidget(
            selectedDate: DateTime.now(),
            onDateSelected: (date) => showDayAppointmentsBottomSheet(
              context,
              date,
              todayController,
              serviceFilter: _isNailRelatedService,
            ),
            getConsultationsCount: (date) {
              // Use TodayAppointmentsController with nail filter
              return todayController.allAppointments
                  .where(_isNailRelatedService)
                  .where(
                    (a) =>
                        a.startTime.year == date.year &&
                        a.startTime.month == date.month &&
                        a.startTime.day == date.day,
                  )
                  .length;
            },
          ),

          const SizedBox(height: 20),

          // === REVENUE & TIPS (Side by Side) ===
          Row(
            children: [
              Expanded(child: _buildRevenueCard(revenueController)),
              const SizedBox(width: 12),
              Expanded(child: _buildTipsCard(dashboardController)),
            ],
          ),

          const SizedBox(height: 20),

          // === STYLE REQUESTS ===
          _buildSectionTitle(
            'Style Requests',
            trailing: _buildViewAllButton(() {
              Get.to(() => const StyleRequestsScreen());
            }),
          ),
          const SizedBox(height: 8),
          _buildStyleRequestsPreview(styleRequestController),

          const SizedBox(height: 20),

          // === LOOK-BOOK ===
          _buildSectionTitle(
            'Look-book',
            trailing: _buildViewAllButton(() {
              Get.to(() => const NailTechLookbookScreen());
            }),
          ),
          const SizedBox(height: 8),
          _buildLookbookPreview(portfolioController),

          const SizedBox(height: 20),

          // === REVIEWS ===
          _buildSectionTitle(
            'Reviews',
            trailing: shopId.isNotEmpty
                ? _buildViewAllButton(
                    () => Get.to(() => ReviewsScreen(shopId: shopId)),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _buildReviewsSection(shopId),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildMonthLabel() {
    return Text(
      DateFormat('MMM d').format(DateTime.now()),
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }

  Widget _buildViewAllButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: const Text(
        'View All',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFFE63946),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ==================
  // UPCOMING APPOINTMENT
  // ==================
  Widget _buildUpcomingAppointment(BusinessOwnerController boController) {
    return Obx(() {
      final bookings = boController.allBusinessOwnerBookingOne.value.results;

      // Filter for nail tech services
      final upcomingBookings = bookings.where((b) {
        final shopTz = b.shopTimezone ?? 'America/New_York';
        final nowUtc = DateTime.now().toUtc();
        DateTime slotTimeUtc;
        try {
          slotTimeUtc = DateTime.parse(b.slotTimeIso).toUtc();
        } catch (_) {
          slotTimeUtc = b.slotTime.toUtc();
        }

        final isFuture = slotTimeUtc.isAfter(nowUtc);
        final shopNow = TimezoneHelper.toTimezone(nowUtc, shopTz);
        final shopSlot = TimezoneHelper.toTimezone(slotTimeUtc, shopTz);
        final isToday =
            shopSlot.year == shopNow.year &&
            shopSlot.month == shopNow.month &&
            shopSlot.day == shopNow.day;
        final isActive =
            b.status.toLowerCase() == 'active' ||
            b.status.toLowerCase() == 'confirmed';

        // Check if nail tech service
        final serviceTitle = b.serviceTitle.toLowerCase();
        final isNailTech =
            serviceTitle.contains('nail') ||
            serviceTitle.contains('manicure') ||
            serviceTitle.contains('pedicure') ||
            serviceTitle.contains('gel') ||
            serviceTitle.contains('acrylic') ||
            serviceTitle.contains('polish');

        return (isFuture || (isToday && isActive)) && isNailTech;
      }).toList();

      upcomingBookings.sort((a, b) => a.slotTime.compareTo(b.slotTime));
      final nextBooking = upcomingBookings.isNotEmpty
          ? upcomingBookings.first
          : null;

      if (nextBooking == null) {
        return GestureDetector(
          onTap: () => Get.find<BusinessOwnerNavBarController>().changeIndex(1),
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
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
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

      final timeText = nextBooking.shopTimezone != null
          ? formatApiTimeInTimezone(
              nextBooking.slotTimeIso,
              nextBooking.shopTimezone!,
            )
          : DateFormat('hh:mm a').format(nextBooking.slotTime);

      return GestureDetector(
        onTap: () => Get.find<BusinessOwnerNavBarController>().changeIndex(1),
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
                backgroundImage: nextBooking.profileImage != null
                    ? NetworkImage(nextBooking.profileImage!)
                    : null,
                child: nextBooking.profileImage == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextBooking.userName ?? 'Customer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nextBooking.serviceTitle,
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
                            color: Color(0xFFE91E8C),
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
    });
  }

  // ==================
  // REVENUE CARD
  // ==================
  Widget _buildRevenueCard(DailyRevenueController controller) {
    return Obx(() {
      final revenue = controller.revenueData.value;
      final isLoading = controller.isLoading.value;

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
            Text(
              'Today\'s Earnings',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '\$${(revenue?.totalRevenue ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E8C),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ==================
  // TIPS CARD
  // ==================
  Widget _buildTipsCard(NailTechDashboardController controller) {
    return Obx(() {
      final tips = controller.weeklyTips;
      final isLoading = controller.isLoading.value;

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
            Row(
              children: [
                Text(
                  'Weekly Tips',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.volunteer_activism,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '\$${tips.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF52B788),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ==================
  // STYLE REQUESTS PREVIEW
  // ==================
  Widget _buildStyleRequestsPreview(StyleRequestController controller) {
    return Obx(() {
      final pendingStyle = controller.pendingRequests.take(2).toList();
      final pendingDesign = controller.pendingDesignRequests.take(2).toList();

      if (pendingStyle.isEmpty && pendingDesign.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No pending style requests',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Column(
        children: [
          // Style Requests
          ...pendingStyle.map((request) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: request.previewImageUrl != null
                        ? Image.network(
                            request.previewImageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultStyleIcon(),
                          )
                        : _defaultStyleIcon(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${request.userName ?? "Client"} • ${request.nailStyleTypeDisplay ?? ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Design Requests from booking
          ...pendingDesign.map((request) {
            final imageUrl = request.images.isNotEmpty
                ? request.images.first.imageUrl
                : null;
            return GestureDetector(
              onTap: () => Get.to(() => const StyleRequestsScreen()),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE91E8C).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Image preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _defaultDesignIcon(),
                            )
                          : _defaultDesignIcon(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.description.length > 30
                                ? '${request.description.substring(0, 30)}...'
                                : request.description,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${request.userName} • ${request.placement.isNotEmpty ? request.placement : "Design Request"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Design',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE91E8C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _defaultDesignIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.auto_awesome, color: Color(0xFFE91E8C)),
    );
  }

  Widget _defaultStyleIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.brush, color: Color(0xFFE91E8C)),
    );
  }

  // ==================
  // LOOKBOOK PREVIEW
  // ==================
  Widget _buildLookbookPreview(PortfolioController controller) {
    return Obx(() {
      final items = controller.portfolioItems.take(4).toList();

      if (items.isEmpty) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No lookbook items yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: EdgeInsets.only(right: index < items.length - 1 ? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ==================
  // REVIEWS SECTION
  // ==================
  Widget _buildReviewsSection(String shopId) {
    if (shopId.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No reviews yet', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final reviewController = Get.find<ReviewController>();

    return Obx(() {
      if (reviewController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final reviews = reviewController.reviews.take(2).toList();

      if (reviews.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('No reviews yet', style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      return Column(
        children: reviews.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
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
                      radius: 18,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: review.avatarUrl?.isNotEmpty == true
                          ? NetworkImage(review.avatarUrl!)
                          : null,
                      child: review.avatarUrl?.isNotEmpty != true
                          ? const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review.author,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // ==================
  // DAY APPOINTMENTS BOTTOM SHEET
  // ==================
  void _showDayAppointments(
    BuildContext context,
    DateTime date,
    BusinessOwnerController boController,
  ) {
    final bookings = boController.allBusinessOwnerBookingOne.value.results;

    // Filter by date AND by nail tech niche
    final dayBookings = bookings.where((b) {
      final isCorrectDate =
          b.slotTime.year == date.year &&
          b.slotTime.month == date.month &&
          b.slotTime.day == date.day;
      final serviceTitle = b.serviceTitle.toLowerCase();
      final isNailTech =
          serviceTitle.contains('nail') ||
          serviceTitle.contains('manicure') ||
          serviceTitle.contains('pedicure') ||
          serviceTitle.contains('gel') ||
          serviceTitle.contains('acrylic') ||
          serviceTitle.contains('polish');
      return isCorrectDate && isNailTech;
    }).toList();

    dayBookings.sort((a, b) => a.slotTime.compareTo(b.slotTime));

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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
                        '${dayBookings.length} appointment${dayBookings.length == 1 ? '' : 's'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: dayBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No appointments',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: dayBookings.length,
                      itemBuilder: (context, index) {
                        final booking = dayBookings[index];
                        final timeText = booking.shopTimezone != null
                            ? formatApiTimeInTimezone(
                                booking.slotTimeIso,
                                booking.shopTimezone!,
                              )
                            : DateFormat('hh:mm a').format(booking.slotTime);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: booking.profileImage != null
                                    ? NetworkImage(booking.profileImage!)
                                    : null,
                                child: booking.profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.userName ?? 'Customer',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${booking.serviceTitle} • $timeText',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'Done';
        break;
      case 'active':
      case 'confirmed':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = 'Active';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'Cancelled';
        break;
      default:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
