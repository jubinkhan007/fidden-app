import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fidden/features/business_owner/hairstylist/controller/hairstylist_dashboard_controller.dart';
import 'package:fidden/features/business_owner/hairstylist/data/hairstylist_models.dart';
import 'package:fidden/features/business_owner/hairstylist/presentation/screens/client_hair_profiles_screen.dart';
import 'package:fidden/features/business_owner/hairstylist/presentation/screens/product_recommendations_screen.dart';
import 'package:fidden/features/business_owner/portfolio/controller/portfolio_controller.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/reviews/state/review_controller.dart';
import 'package:fidden/features/business_owner/reviews/ui/reviews_screen.dart';
import 'package:fidden/features/business_owner/tattoo_dashboard/widgets/week_calendar_widget.dart';
import 'package:fidden/features/user/booking/presentation/api_time_format.dart';
import 'package:fidden/features/business_owner/barber/controller/daily_revenue_controller.dart';
import 'package:fidden/features/business_owner/barber/controller/today_appointments_controller.dart';
import 'package:fidden/features/business_owner/portfolio/presentation/screens/portfolio_grid_screen.dart';

/// Main dashboard content widget for Hairstylist/Loctician
class HairstylistDashboardContent extends StatelessWidget {
  const HairstylistDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final controller = Get.put(HairstylistDashboardController());
    final boController = Get.find<BusinessOwnerController>();
    final todayController = Get.put(TodayAppointmentsController());
    final revenueController = Get.put(DailyRevenueController());
    final portfolioController = Get.put(PortfolioController());
    final reviewController = Get.put(ReviewController());

    // Ensure portfolio is loaded with hair niche
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (portfolioController.currentNiche.value != 'hair' ||
          portfolioController.portfolioItems.isEmpty) {
        portfolioController.fetchPortfolioItems(niche: 'hair');
      }
    });

    // Initialize reviews for shop
    final shopIdValue = myShopId.value;
    final shopId = shopIdValue?.toString() ?? '';
    if (shopId.isNotEmpty && reviewController.reviews.isEmpty) {
      reviewController.fetchReviews(shopId);
    }

    return Obx(() {
      if (controller.isLoading.value && !controller.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.fetchAll(),
            todayController.fetchAppointments(),
            revenueController.fetchRevenue(),
            portfolioController.fetchPortfolioItems(niche: 'hair'),
            boController.fetchBusinessOwnerBooking(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),

            // === UPCOMING APPOINTMENT ===
            _buildSectionTitle('Upcoming Appointment'),
            const SizedBox(height: 8),
            _buildUpcomingAppointment(boController),

            const SizedBox(height: 20),

            // === TODAY'S SCHEDULE ===
            _buildSectionTitle(
              "Today's Schedule",
              trailing: Text(
                DateFormat('MMM d').format(DateTime.now()),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            WeekCalendarWidget(
              selectedDate: DateTime.now(),
              getConsultationsCount: (date) {
                // Use same data source as _showDayAppointments for consistency
                final bookings =
                    boController.allBusinessOwnerBookingOne.value.results;
                // Filter for hairstylist services only
                return bookings.where((b) {
                  final isCorrectDate =
                      b.slotTime.year == date.year &&
                      b.slotTime.month == date.month &&
                      b.slotTime.day == date.day;
                  final serviceTitle = b.serviceTitle.toLowerCase();
                  final isHairstylist =
                      serviceTitle.contains('hair') ||
                      serviceTitle.contains('cut') ||
                      serviceTitle.contains('loc') ||
                      serviceTitle.contains('braid') ||
                      serviceTitle.contains('style') ||
                      serviceTitle.contains('color') ||
                      serviceTitle.contains('trim');
                  return isCorrectDate && isHairstylist;
                }).length;
              },
              onDateSelected: (date) =>
                  _showDayAppointments(context, date, boController),
            ),

            const SizedBox(height: 20),

            // === REVENUE & EARNINGS ===
            _buildSectionTitle('Revenue & Earnings'),
            const SizedBox(height: 8),
            _buildRevenueCards(revenueController, controller),

            const SizedBox(height: 20),

            // === QUICK STATS ===
            _buildSectionTitle('Dashboard Services'),
            const SizedBox(height: 8),
            _buildQuickStats(controller),

            const SizedBox(height: 20),

            // === PREP NOTES PREVIEW ===
            _buildSectionTitle(
              'Prep Notes',
              trailing: GestureDetector(
                onTap: () {
                  // TODO: Navigate to full prep notes screen
                },
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
            _buildPrepNotesPreview(controller),

            const SizedBox(height: 20),

            // === PORTFOLIO PREVIEW ===
            _buildSectionTitle(
              'Portfolio',
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
            _buildPortfolioPreview(portfolioController),

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
            _buildReviewsPreview(reviewController),

            const SizedBox(height: 24),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildUpcomingAppointment(BusinessOwnerController controller) {
    return Obx(() {
      final bookings = controller.allBusinessOwnerBookingOne.value.results;
      final now = DateTime.now();
      // Filter for hairstylist services only
      final upcoming = bookings.where((b) {
        final isActive = b.status == 'active' && b.slotTime.isAfter(now);
        final serviceTitle = b.serviceTitle.toLowerCase();
        final isHairstylist =
            serviceTitle.contains('hair') ||
            serviceTitle.contains('cut') ||
            serviceTitle.contains('loc') ||
            serviceTitle.contains('braid') ||
            serviceTitle.contains('style') ||
            serviceTitle.contains('color') ||
            serviceTitle.contains('trim');
        return isActive && isHairstylist;
      }).toList()..sort((a, b) => a.slotTime.compareTo(b.slotTime));

      if (upcoming.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.event_busy, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No upcoming appointments',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'View all bookings',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        );
      }

      final next = upcoming.first;
      final timeStr = formatApiTimeInTimezone(
        next.slotTimeIso,
        next.shopTimezone ?? 'UTC',
      );

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: next.profileImage != null
                  ? NetworkImage(next.profileImage!)
                  : null,
              child: next.profileImage == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    next.userName ?? 'Client',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      );
    });
  }

  Widget _buildRevenueCards(
    DailyRevenueController revenueController,
    HairstylistDashboardController dashController,
  ) {
    return Obx(() {
      final todayRevenue =
          revenueController.revenueData.value?.totalRevenue ?? 0;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Today\'s Revenue',
              '\$${todayRevenue.toStringAsFixed(2)}',
              color: const Color(0xFFE63946),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Monthly Projection',
              '\$${(todayRevenue * 30).toStringAsFixed(2)}',
              color: const Color(0xFF2D3748),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value, {
    Color color = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(HairstylistDashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const ClientHairProfilesScreen()),
            child: _buildQuickStatCard(
              'Client Profiles',
              controller.clientProfilesCount.toString(),
              Icons.people_outline,
              Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const ProductRecommendationsScreen()),
            child: _buildQuickStatCard(
              'Recommendations',
              controller.productRecommendationsCount.toString(),
              Icons.recommend_outlined,
              Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrepNotesPreview(HairstylistDashboardController controller) {
    final items = controller.upcomingPrepNotes;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.notes_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No upcoming prep notes',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: items.map((item) => _buildPrepNoteCard(item)).toList(),
    );
  }

  Widget _buildPrepNoteCard(PrepNoteItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.sticky_note_2_outlined, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.userName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.serviceTitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (item.prepNotes.isNotEmpty)
                  Text(
                    item.prepNotes,
                    style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioPreview(PortfolioController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.portfolioItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.portfolioItems.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No portfolio items yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      final items = controller.portfolioItems.take(4).toList();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildReviewsPreview(ReviewController controller) {
    return Obx(() {
      if (controller.reviews.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'No reviews yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }

      final review = controller.reviews.first;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.author,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(' ${review.rating.toStringAsFixed(1)}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.comment,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showDayAppointments(
    BuildContext context,
    DateTime date,
    BusinessOwnerController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Obx(() {
        final allBookings = controller.allBusinessOwnerBookingOne.value.results;
        // Filter by date AND by hairstylist niche
        final appointments = allBookings.where((b) {
          final isCorrectDate =
              b.slotTime.year == date.year &&
              b.slotTime.month == date.month &&
              b.slotTime.day == date.day;
          // Filter for hairstylist services
          final serviceTitle = b.serviceTitle.toLowerCase();
          final isHairstylist =
              serviceTitle.contains('hair') ||
              serviceTitle.contains('cut') ||
              serviceTitle.contains('loc') ||
              serviceTitle.contains('braid') ||
              serviceTitle.contains('style') ||
              serviceTitle.contains('color') ||
              serviceTitle.contains('trim');
          return isCorrectDate && isHairstylist;
        }).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
                child: Text(
                  DateFormat('EEEE, MMM d').format(date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: appointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No appointments',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final apt = appointments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: apt.profileImage != null
                                      ? NetworkImage(apt.profileImage!)
                                      : null,
                                  child: apt.profileImage == null
                                      ? const Icon(Icons.person, size: 20)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        apt.userName ?? 'Client',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        apt.serviceTitle,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatApiTimeInTimezone(
                                    apt.slotTimeIso,
                                    apt.shopTimezone ?? 'UTC',
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
