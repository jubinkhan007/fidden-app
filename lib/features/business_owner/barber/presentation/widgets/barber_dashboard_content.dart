import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fidden/core/utils/timezone_helper.dart';
import '../../controller/today_appointments_controller.dart';
import '../../controller/daily_revenue_controller.dart';
import '../../controller/no_show_alerts_controller.dart';
import '../../controller/walk_in_controller.dart';
import '../../controller/loyalty_controller.dart';
import '../../../tattoo_dashboard/widgets/week_calendar_widget.dart';
import '../../../home/controller/business_owner_controller.dart';
import '../../../reviews/state/review_controller.dart';
import '../../../reviews/ui/reviews_screen.dart';
import '../../../nav_bar/controllers/user_nav_bar_controller.dart';
import '../../../../user/booking/presentation/api_time_format.dart';
import '../screens/walk_in_queue_screen.dart';
import '../screens/loyalty_program_screen.dart';
import '../screens/no_show_alerts_screen.dart';

/// Embeddable content widget for barber dashboard.
/// Matches the Figma design with modifications per spec.
class BarberDashboardContent extends StatelessWidget {
  const BarberDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final boController = Get.find<BusinessOwnerController>();
    final todayController = Get.put(TodayAppointmentsController());
    final revenueController = Get.put(DailyRevenueController());
    final noShowController = Get.put(NoShowAlertsController());
    final walkInController = Get.put(WalkInController());
    final loyaltyController = Get.put(LoyaltyController());
    
    // Get shop ID for reviews - use the non-reactive value to avoid GetX issues
    final shopIdValue = myShopId.value;
    final shopId = shopIdValue?.toString() ?? '';
    
    if (shopId.isNotEmpty) {
      Get.put(ReviewController())..fetchReviews(shopId);
    }

    return RefreshIndicator(
      onRefresh: () async {
        todayController.fetchAppointments();
        revenueController.fetchRevenue();
        noShowController.fetchAlerts();
        walkInController.fetchQueue();
        loyaltyController.fetchProgram();
        loyaltyController.fetchCustomers();
        boController.fetchBusinessOwnerBooking();
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
          _buildSectionTitle('Today\'s Schedule', trailing: _buildMonthLabel()),
          const SizedBox(height: 8),
          WeekCalendarWidget(
            selectedDate: DateTime.now(),
            onDateSelected: (date) => _showDayAppointments(context, date, boController),
            getConsultationsCount: (date) {
              // Using non-reactive access for the callback
              final appointments = todayController.appointmentsData.value?.appointments ?? [];
              return appointments.where((a) =>
                a.startTime.year == date.year &&
                a.startTime.month == date.month &&
                a.startTime.day == date.day
              ).length;
            },
          ),

          const SizedBox(height: 20),

          // === REVENUE TODAY & WALK-INS (Side by Side) ===
          Row(
            children: [
              Expanded(child: _buildRevenueCard(revenueController)),
              const SizedBox(width: 12),
              Expanded(child: _buildWalkInCard(walkInController)),
            ],
          ),

          const SizedBox(height: 20),

          // === NO-SHOW ALERTS ===
          _buildNoShowAlertsSection(noShowController),

          const SizedBox(height: 20),

          // === LOYALTY MEMBERS ===
          _buildLoyaltySection(loyaltyController),

          const SizedBox(height: 20),

          // === REVIEWS ===
          _buildSectionTitle(
            'Reviews',
            trailing: shopId.isNotEmpty
                ? _buildViewAllButton(() => Get.to(() => ReviewsScreen(shopId: shopId)))
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
      final now = DateTime.now();
      final bookings = boController.allBusinessOwnerBookingOne.value.results;
      
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
        final isToday = shopSlot.year == shopNow.year && 
                        shopSlot.month == shopNow.month && 
                        shopSlot.day == shopNow.day;
        final isActive = b.status.toLowerCase() == 'active' || 
                         b.status.toLowerCase() == 'confirmed';
        
        return isFuture || (isToday && isActive);
      }).toList();
      
      upcomingBookings.sort((a, b) => a.slotTime.compareTo(b.slotTime));
      final nextBooking = upcomingBookings.isNotEmpty ? upcomingBookings.first : null;

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
                  child: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No upcoming appointments', 
                        style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('View all bookings', 
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          ? formatApiTimeInTimezone(nextBooking.slotTimeIso, nextBooking.shopTimezone!)
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
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            nextBooking.serviceTitle,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                  color: Color(0xFFE63946),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ==================
  // WALK-IN CARD
  // ==================
  Widget _buildWalkInCard(WalkInController controller) {
    return Obx(() {
      final waiting = controller.waitingCount;
      final isLoading = controller.isLoading.value;
      
      return GestureDetector(
        onTap: () => Get.to(() => const WalkInQueueScreen()),
        child: Container(
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
                    'Walk-Ins',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.groups, size: 16, color: Colors.grey),
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
                Row(
                  children: [
                    Text(
                      '$waiting',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'waiting',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  // ==================
  // NO-SHOW ALERTS
  // ==================
  Widget _buildNoShowAlertsSection(NoShowAlertsController controller) {
    return Obx(() {
      final count = controller.alertsData.value?.count ?? 0;
      final isLoading = controller.isLoading.value;
      
      if (isLoading) {
        return const SizedBox.shrink();
      }
      
      if (count == 0) {
        return const SizedBox.shrink();
      }
      
      return GestureDetector(
        onTap: () => Get.to(() => const NoShowAlertsScreen()),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC62828).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No-Show Alerts',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC62828),
                      ),
                    ),
                    Text(
                      '$count no-shows this week',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFC62828)),
            ],
          ),
        ),
      );
    });
  }

  // ==================
  // BOOKING REQUESTS
  // ==================
  Widget _buildBookingRequests(BusinessOwnerController boController) {
    return Obx(() {
      final bookings = boController.allBusinessOwnerBookingOne.value.results;
      final pendingBookings = bookings.where((b) => 
        b.status.toLowerCase() == 'pending'
      ).take(2).toList();
      
      if (pendingBookings.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No pending requests',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      
      return Column(
        children: pendingBookings.map((booking) {
          final timeText = booking.shopTimezone != null
              ? formatApiTimeInTimezone(booking.slotTimeIso, booking.shopTimezone!)
              : DateFormat('hh:mm a').format(booking.slotTime);
          
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: booking.profileImage != null 
                      ? NetworkImage(booking.profileImage!) 
                      : null,
                  child: booking.profileImage == null 
                      ? const Icon(Icons.person, size: 20, color: Colors.grey) 
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${booking.userName ?? "Customer"} • $timeText',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        }).toList(),
      );
    });
  }

  // ==================
  // LOYALTY SECTION
  // ==================
  Widget _buildLoyaltySection(LoyaltyController controller) {
    return Obx(() {
      final program = controller.program.value;
      final count = controller.customerCount;
      final redeemable = controller.redeemableCount;
      final isLoading = controller.isLoading.value;
      
      if (isLoading && program == null) {
        return const SizedBox.shrink();
      }
      
      return GestureDetector(
        onTap: () => Get.to(() => const LoyaltyProgramScreen()),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF52B788).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard, color: Color(0xFF52B788)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Loyalty Members',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (program != null && !program.isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OFF',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$count customers${redeemable > 0 ? ' • $redeemable can redeem' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          child: Text(
            'No reviews yet',
            style: TextStyle(color: Colors.grey),
          ),
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
            child: Text(
              'No reviews yet',
              style: TextStyle(color: Colors.grey),
            ),
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
                          ? const Icon(Icons.person, size: 18, color: Colors.grey)
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
  void _showDayAppointments(BuildContext context, DateTime date, BusinessOwnerController boController) {
    final bookings = boController.allBusinessOwnerBookingOne.value.results;
    
    final dayBookings = bookings.where((b) {
      return b.slotTime.year == date.year &&
             b.slotTime.month == date.month &&
             b.slotTime.day == date.day;
    }).toList();
    
    dayBookings.sort((a, b) => a.slotTime.compareTo(b.slotTime));
    
    final dateLabel = DateFormat('EEEE, MMM d').format(date);
    final isToday = date.day == DateTime.now().day && 
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Flexible(
              child: dayBookings.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: dayBookings.length,
                      itemBuilder: (context, index) {
                        final booking = dayBookings[index];
                        final timeText = booking.shopTimezone != null
                            ? formatApiTimeInTimezone(booking.slotTimeIso, booking.shopTimezone!)
                            : DateFormat('hh:mm a').format(booking.slotTime);
                        
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE5E7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  timeText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE63946),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.userName ?? 'Customer',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      booking.serviceTitle,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
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
      ),
      isScrollControlled: true,
    );
  }
}
