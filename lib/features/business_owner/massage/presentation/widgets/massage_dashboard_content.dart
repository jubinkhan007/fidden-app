import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/barber/controller/today_appointments_controller.dart';
import 'package:fidden/features/business_owner/barber/controller/daily_revenue_controller.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/portfolio/controller/portfolio_controller.dart';
import 'package:fidden/features/business_owner/reviews/state/review_controller.dart';
import 'package:fidden/features/business_owner/tattoo_dashboard/widgets/week_calendar_widget.dart';
import 'package:fidden/features/business_owner/tattoo_dashboard/widgets/dashboard_portfolio_grid.dart';
import 'package:fidden/features/business_owner/portfolio/presentation/screens/portfolio_grid_screen.dart';
import 'package:fidden/features/business_owner/reviews/ui/reviews_screen.dart';
import 'package:fidden/features/business_owner/shared/widgets/today_appointments_widgets.dart';
import '../../controller/massage_dashboard_controller.dart';
import '../../data/massage_models.dart';
import '../screens/massage_client_profiles_screen.dart';
import '../screens/massage_health_disclosures_screen.dart';
import '../screens/massage_treatment_notes_screen.dart';

/// Massage Therapist Dashboard Content Widget 💆
class MassageDashboardContent extends StatefulWidget {
  const MassageDashboardContent({super.key});

  @override
  State<MassageDashboardContent> createState() =>
      _MassageDashboardContentState();
}

class _MassageDashboardContentState extends State<MassageDashboardContent> {
  late final MassageDashboardController dashboardController;
  late final TodayAppointmentsController todayController;
  late final DailyRevenueController revenueController;
  late final BusinessOwnerController boController;
  late final PortfolioController portfolioController;
  late final ReviewController reviewController;

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    dashboardController = Get.put(MassageDashboardController());
    todayController = Get.put(TodayAppointmentsController());
    // Fetch today's appointments for massage niche
    todayController.fetchAppointments(niche: 'massage');
    revenueController = Get.put(DailyRevenueController());
    revenueController.niche = 'massage'; // Set niche for revenue filtering
    revenueController.fetchRevenue(); // Fetch with niche filter
    boController = Get.find<BusinessOwnerController>();
    portfolioController = Get.put(PortfolioController());
    reviewController = Get.put(ReviewController());

    final shopId = myShopId.value;
    if (shopId != null && shopId > 0) {
      reviewController.initForShop(shopId.toString());
      portfolioController.fetchPortfolioItems(niche: 'massage_therapist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week Calendar
            _buildSection(
              title: 'Schedule',
              child: WeekCalendarWidget(
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                  showDayAppointmentsBottomSheet(
                    context,
                    date,
                    todayController,
                  );
                },
                getConsultationsCount: (date) {
                  // Use TodayAppointmentsController for consistency
                  return todayController.allAppointments
                      .where(
                        (a) =>
                            a.startTime.year == date.year &&
                            a.startTime.month == date.month &&
                            a.startTime.day == date.day,
                      )
                      .length;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Revenue & Stats Row
            Row(
              children: [
                Expanded(child: _buildRevenueCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickStatsCard()),
              ],
            ),

            const SizedBox(height: 16),

            // Disclosure Alerts Card
            _buildDisclosureAlertsCard(),

            const SizedBox(height: 16),

            // Quick Links
            _buildSection(title: 'Quick Links', child: _buildQuickLinksGrid()),

            const SizedBox(height: 16),

            // Recent Treatment Notes
            _buildRecentTreatmentNotes(),

            const SizedBox(height: 16),

            // Portfolio Manager
            _buildSection(
              title: 'Portfolio Manager',
              action: 'Open Portfolio',
              onAction: () => Get.to(() => const PortfolioGridScreen()),
              child: Obx(
                () => DashboardPortfolioGrid(
                  items: portfolioController.portfolioItems.take(6).toList(),
                  onViewAll: () => Get.to(() => const PortfolioGridScreen()),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reviews Preview
            _buildSection(
              title: 'Reviews',
              action: 'See All',
              onAction: () {
                final shopId = myShopId.value;
                if (shopId != null && shopId > 0) {
                  Get.to(() => ReviewsScreen(shopId: shopId.toString()));
                }
              },
              child: _buildReviewsPreview(),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      dashboardController.fetchDashboard(),
      todayController.fetchAppointments(),
      revenueController.fetchRevenue(forNiche: 'massage'),
    ]);
  }

  Widget _buildSection({
    required String title,
    String? action,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (action != null)
              TextButton(onPressed: onAction, child: Text(action)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildRevenueCard() {
    return Obx(() {
      final revenue = revenueController.revenueData.value?.totalRevenue ?? 0;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[400]!, Colors.indigo[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Revenue",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${revenue.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickStatsCard() {
    return Obx(() {
      final dashboard = dashboardController.dashboard.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${dashboard?.clientProfilesCount ?? 0} Clients',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${dashboard?.todayBookingsCount ?? 0} Today',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDisclosureAlertsCard() {
    return Obx(() {
      final alerts = dashboardController.topAlerts;
      final count = dashboardController.alertCount;

      if (count == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[100]!),
          boxShadow: [
            BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Health Disclosure Alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertItem(alert)),
            if (count > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Get.to(() => const MassageHealthDisclosuresScreen()),
                  child: Text(
                    'View All ($count)',
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAlertItem(DisclosureAlert alert) {
    return InkWell(
      onTap: () => Get.to(() => const MassageHealthDisclosuresScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.red[50],
              child: Text(
                alert.clientName.isNotEmpty
                    ? alert.clientName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.clientName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      if (alert.hasConditions)
                        _buildAlertTag('Conditions', Colors.orange),
                      if (alert.pregnantOrNursing)
                        _buildAlertTag('Pregnant/Nursing', Colors.pink),
                      if (alert.areasToAvoid != null &&
                          alert.areasToAvoid!.isNotEmpty)
                        _buildAlertTag('Areas to Avoid', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickLinksGrid() {
    final links = [
      _QuickLink(
        Icons.person,
        'Client Profiles',
        Colors.indigo,
        () => Get.to(() => const MassageClientProfilesScreen()),
      ),
      _QuickLink(
        Icons.medical_services,
        'Disclosures',
        Colors.red,
        () => Get.to(() => const MassageHealthDisclosuresScreen()),
      ),
      _QuickLink(
        Icons.edit_note,
        'Treatment Notes',
        Colors.blue,
        () => Get.to(() => const MassageTreatmentNotesScreen()),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: links
          .map((l) => _buildQuickLinkItem(l.icon, l.label, l.color, l.onTap))
          .toList(),
    );
  }

  Widget _buildQuickLinkItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTreatmentNotes() {
    return Obx(() {
      final notes = dashboardController.recentTreatmentNotes;
      if (notes.isEmpty) return const SizedBox.shrink();

      return _buildSection(
        title: 'Recent Treatment Notes',
        action: 'View All',
        onAction: () => Get.to(() => const MassageTreatmentNotesScreen()),
        child: Column(
          children: notes
              .take(3)
              .map(
                (note) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.spa,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.clientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              note.treatmentTypeDisplay ?? note.treatmentType,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Widget _buildPortfolioPreview() {
    return Obx(() {
      final items = portfolioController.portfolioItems.take(4).toList();
      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('No portfolio items yet')),
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
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: item.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[200],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildReviewsPreview() {
    return Obx(() {
      final reviewsList = reviewController.reviews.take(2).toList();
      if (reviewsList.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('No reviews yet')),
        );
      }

      return Column(
        children: reviewsList
            .map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.indigo[100],
                      child: Text(
                        r.author.isNotEmpty ? r.author[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                r.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(' ${r.rating}'),
                            ],
                          ),
                          if (r.comment.isNotEmpty)
                            Text(
                              r.comment,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    });
  }

  void _showDayAppointments(DateTime date) {
    // Filter by date AND by massage therapist niche
    final bookings = boController.allBusinessOwnerBookingOne.value.results
        .where((b) {
          final isCorrectDate =
              b.slotTime.year == date.year &&
              b.slotTime.month == date.month &&
              b.slotTime.day == date.day;
          final serviceTitle = b.serviceTitle.toLowerCase();
          final isMassage =
              serviceTitle.contains('massage') ||
              serviceTitle.contains('body') ||
              serviceTitle.contains('spa') ||
              serviceTitle.contains('therapy') ||
              serviceTitle.contains('relaxation') ||
              serviceTitle.contains('deep tissue') ||
              serviceTitle.contains('swedish');
          return isCorrectDate && isMassage;
        })
        .toList();

    if (bookings.isEmpty) {
      Get.snackbar('No Appointments', 'No appointments for this date');
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments for ${date.day}/${date.month}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...bookings
                .take(5)
                .map(
                  (b) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: Text(
                        (b.userName ?? 'C')[0].toUpperCase(),
                        style: TextStyle(color: Colors.indigo[800]),
                      ),
                    ),
                    title: Text(b.userName ?? b.userEmail),
                    subtitle: Text(b.serviceTitle),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _QuickLink {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickLink(this.icon, this.label, this.color, this.onTap);
}
