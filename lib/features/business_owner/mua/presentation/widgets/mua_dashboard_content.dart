import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fidden/features/business_owner/barber/controller/today_appointments_controller.dart';
import 'package:fidden/features/business_owner/barber/controller/daily_revenue_controller.dart';
import 'package:fidden/features/business_owner/tattoo_dashboard/widgets/week_calendar_widget.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/reviews/state/review_controller.dart';
import 'package:fidden/features/business_owner/reviews/ui/reviews_screen.dart';
import 'package:fidden/features/business_owner/mua/controller/mua_dashboard_controller.dart';
import 'package:fidden/features/business_owner/mua/controller/face_chart_controller.dart';
import 'package:fidden/features/business_owner/mua/controller/product_kit_controller.dart';
import 'package:fidden/features/business_owner/mua/presentation/screens/face_charts_screen.dart';
import 'package:fidden/features/business_owner/mua/presentation/screens/product_kit_screen.dart';
import 'package:fidden/features/user/booking/presentation/api_time_format.dart';

/// Embeddable content widget for MUA dashboard.
class MUADashboardContent extends StatelessWidget {
  const MUADashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final boController = Get.find<BusinessOwnerController>();
    final todayController = Get.put(TodayAppointmentsController());
    final revenueController = Get.put(DailyRevenueController());
    final muaDashboardController = Get.put(MUADashboardController());
    final faceChartController = Get.put(FaceChartController());
    final productKitController = Get.put(ProductKitController());

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
        muaDashboardController.fetchDashboard();
        faceChartController.fetchFaceCharts();
        productKitController.fetchItems();
        boController.fetchBusinessOwnerBooking();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === GREETING ===
          _buildGreeting(),
          const SizedBox(height: 16),

          // === NEXT APPOINTMENT + TODAY REVENUE ===
          Row(
            children: [
              Expanded(child: _buildNextAppointmentCard(boController)),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRevenueCard(
                  revenueController,
                  muaDashboardController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // === TODAY'S SCHEDULE ===
          _buildSectionTitle(
            "Today's Schedule",
            trailing: _buildViewAllButton(() {}),
          ),
          const SizedBox(height: 8),
          WeekCalendarWidget(
            selectedDate: DateTime.now(),
            onDateSelected: (date) =>
                _showDayAppointments(context, date, boController),
            getConsultationsCount: (date) {
              // Use same data source as _showDayAppointments for consistency
              final bookings =
                  boController.allBusinessOwnerBookingOne.value.results;
              // Filter for makeup artist services only
              return bookings.where((b) {
                final isCorrectDate =
                    b.slotTime.year == date.year &&
                    b.slotTime.month == date.month &&
                    b.slotTime.day == date.day;
                final serviceTitle = b.serviceTitle.toLowerCase();
                final isMUA =
                    serviceTitle.contains('makeup') ||
                    serviceTitle.contains('make up') ||
                    serviceTitle.contains('bridal') ||
                    serviceTitle.contains('glam') ||
                    serviceTitle.contains('cosmetic') ||
                    serviceTitle.contains('contour') ||
                    serviceTitle.contains('foundation');
                return isCorrectDate && isMUA;
              }).length;
            },
          ),
          const SizedBox(height: 20),

          // === QUICK STATS ===
          _buildSectionTitle('Quick Stats'),
          const SizedBox(height: 8),
          _buildQuickStats(muaDashboardController),
          const SizedBox(height: 20),

          // === FACE CHARTS ===
          _buildSectionTitle(
            'Face Charts',
            trailing: _buildViewAllButton(() {
              Get.to(() => const FaceChartsScreen());
            }),
          ),
          const SizedBox(height: 8),
          _buildFaceChartsPreview(faceChartController),
          const SizedBox(height: 20),

          // === PRODUCT KIT ===
          _buildSectionTitle(
            'Product Kit Checklist',
            trailing: _buildViewAllButton(() {
              Get.to(() => const ProductKitScreen());
            }),
          ),
          const SizedBox(height: 8),
          _buildProductKitPreview(productKitController),
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
          _buildReviewsPreview(shopId),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==================
  // GREETING
  // ==================
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting 💄',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Makeup Artist Dashboard',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ==================
  // SECTION TITLE
  // ==================
  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildViewAllButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: const Text(
        'View All',
        style: TextStyle(color: Color(0xFFB8192E), fontWeight: FontWeight.w500),
      ),
    );
  }

  // ==================
  // NEXT APPOINTMENT CARD
  // ==================
  Widget _buildNextAppointmentCard(BusinessOwnerController controller) {
    return Obx(() {
      final bookings = controller.allBusinessOwnerBookingOne.value.results;
      final now = DateTime.now();

      // Filter for MUA services and upcoming appointments
      final upcomingMUA = bookings.where((b) {
        final isUpcoming = b.status == 'active' && b.slotTime.isAfter(now);
        final serviceTitle = b.serviceTitle.toLowerCase();
        final isMUA =
            serviceTitle.contains('makeup') ||
            serviceTitle.contains('make up') ||
            serviceTitle.contains('bridal') ||
            serviceTitle.contains('glam') ||
            serviceTitle.contains('cosmetic') ||
            serviceTitle.contains('contour') ||
            serviceTitle.contains('foundation');
        return isUpcoming && isMUA;
      }).toList()..sort((a, b) => a.slotTime.compareTo(b.slotTime));

      final next = upcomingMUA.isNotEmpty ? upcomingMUA.first : null;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFFB8192E),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Next Appointment',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (next != null) ...[
              Text(
                formatApiTimeInTimezone(
                  next.slotTimeIso,
                  next.shopTimezone ?? 'UTC',
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8192E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                next.userName ?? 'Client',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ] else
              Text(
                'No upcoming appointments',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      );
    });
  }

  // ==================
  // REVENUE CARD
  // ==================
  Widget _buildRevenueCard(
    DailyRevenueController revenueController,
    MUADashboardController muaController,
  ) {
    return Obx(() {
      final revenue = revenueController.revenueData.value?.totalRevenue ?? 0.0;
      final mobile = muaController.mobileServicesCount;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Today's Revenue",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '\$${revenue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Mobile: $mobile',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ==================
  // QUICK STATS
  // ==================
  Widget _buildQuickStats(MUADashboardController controller) {
    return Obx(() {
      return Row(
        children: [
          _buildStatBox(
            Icons.person_outline,
            controller.clientProfilesCount,
            'Clients',
          ),
          const SizedBox(width: 12),
          _buildStatBox(
            Icons.palette_outlined,
            controller.faceChartsCount,
            'Charts',
          ),
          const SizedBox(width: 12),
          _buildStatBox(
            Icons.inventory_2_outlined,
            controller.productKitCount,
            'Kit Items',
          ),
        ],
      );
    });
  }

  Widget _buildStatBox(IconData icon, int count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFB8192E)),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ==================
  // FACE CHARTS PREVIEW
  // ==================
  Widget _buildFaceChartsPreview(FaceChartController controller) {
    return Obx(() {
      final charts = controller.faceCharts.take(4).toList();

      if (charts.isEmpty) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No face charts yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: charts.length,
          itemBuilder: (context, index) {
            final chart = charts[index];
            return Container(
              margin: EdgeInsets.only(right: index < charts.length - 1 ? 8 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  chart.thumbnailUrl ?? chart.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.palette, color: Colors.grey),
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
  // PRODUCT KIT PREVIEW
  // ==================
  Widget _buildProductKitPreview(ProductKitController controller) {
    return Obx(() {
      final items = controller.items.take(3).toList();

      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No items in your kit',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    item.isPacked
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: item.isPacked
                        ? const Color(0xFF4CAF50)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item.brand != null ? "${item.brand} " : ""}${item.name}',
                      style: TextStyle(
                        decoration: item.isPacked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isPacked ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  if (item.quantity > 1)
                    Text(
                      '(${item.quantity})',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // ==================
  // REVIEWS PREVIEW
  // ==================
  Widget _buildReviewsPreview(String shopId) {
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

    return Obx(() {
      final reviewController = Get.find<ReviewController>();
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    review.author[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.author,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (review.comment.isNotEmpty)
                        Text(
                          review.comment,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      '${review.rating}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
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

    // Filter bookings for the selected date AND by makeup artist niche
    final dayBookings = bookings.where((b) {
      final isCorrectDate =
          b.slotTime.year == date.year &&
          b.slotTime.month == date.month &&
          b.slotTime.day == date.day;
      final serviceTitle = b.serviceTitle.toLowerCase();
      final isMUA =
          serviceTitle.contains('makeup') ||
          serviceTitle.contains('make up') ||
          serviceTitle.contains('bridal') ||
          serviceTitle.contains('glam') ||
          serviceTitle.contains('cosmetic') ||
          serviceTitle.contains('contour') ||
          serviceTitle.contains('foundation');
      return isCorrectDate && isMUA;
    }).toList();

    // Sort by time
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
                        isToday ? "Today's Appointments" : dateLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dayBookings.length} ${dayBookings.length == 1 ? 'appointment' : 'appointments'}',
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
              child: dayBookings.isEmpty
                  ? _buildEmptyState(date)
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: dayBookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final booking = dayBookings[index];
                        return _buildAppointmentCard(booking);
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
                color: Color(0xFFB8192E),
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
