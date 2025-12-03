import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/tattoo_artist_dashboard_controller.dart';
import '../../widgets/week_calendar_widget.dart';
import '../../widgets/upcoming_consultation_card.dart';
import '../../widgets/quick_action_button.dart';
import '../../widgets/activity_stat_card.dart';
import '../../widgets/dashboard_design_request_card.dart';
import '../../widgets/dashboard_portfolio_grid.dart';
import '../../widgets/dashboard_id_verification_card.dart';
import '../../../portfolio/presentation/screens/portfolio_upload_screen.dart';
import '../../../consultation/presentation/screens/consultation_create_screen.dart';
import '../../../design_requests/presentation/screens/design_requests_list_screen.dart';
import '../../../id_verification/presentation/screens/id_verification_queue_screen.dart';
import '../../../portfolio/presentation/screens/portfolio_grid_screen.dart';
import '../../../consultation/presentation/screens/consultation_detail_screen.dart';
import '../../../design_requests/presentation/screens/design_request_detail_screen.dart';
import '../../../id_verification/presentation/screens/id_verification_detail_screen.dart';

class TattooArtistDashboardScreen extends StatelessWidget {
  const TattooArtistDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TattooArtistDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.isLoading && !controller.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshDashboard(),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                floating: true,
                backgroundColor: const Color(0xFFE63946),
                title: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFFE63946)),
                    ),
                    const SizedBox(width: 12),
                    Text(_getGreeting(), style: const TextStyle(fontSize: 18)),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C757D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Upcoming Consultation
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        'Upcoming Consultation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                    UpcomingConsultationCard(
                      consultation: controller.nextUpcomingConsultation,
                      onTap: controller.nextUpcomingConsultation != null
                          ? () => Get.to(() => ConsultationDetailScreen(
                                consultation: controller.nextUpcomingConsultation!,
                              ))
                          : null,
                    ),

                    // Week Calendar
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Today\'s Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                    WeekCalendarWidget(
                      selectedDate: DateTime.now(),
                      onDateSelected: (date) {
                        // Could navigate to consultations filtered by date
                      },
                      getConsultationsCount: (date) =>
                          controller.getConsultationsCountForDate(date),
                    ),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          QuickActionButton(
                            icon: Icons.photo_library,
                            label: 'Upload Portfolio',
                            color: const Color(0xFFE63946),
                            onTap: () => Get.to(() => const PortfolioUploadScreen()),
                          ),
                          QuickActionButton(
                            icon: Icons.calendar_month,
                            label: 'New Consultation',
                            color: const Color(0xFF52B788),
                            onTap: () => Get.to(() => const ConsultationCreateScreen()),
                          ),
                          QuickActionButton(
                            icon: Icons.design_services,
                            label: 'View Requests',
                            color: const Color(0xFFFB8500),
                            onTap: () => Get.to(() => const DesignRequestsListScreen()),
                          ),
                          QuickActionButton(
                            icon: Icons.badge,
                            label: 'ID Verifications',
                            color: const Color(0xFF3A86FF),
                            onTap: () => Get.to(() => const IDVerificationQueueScreen()),
                          ),
                        ],
                      ),
                    ),

                    // Activity Stats
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Activity Stats',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          ActivityStatCard(
                            label: 'Pending Requests',
                            count: controller.pendingDesignRequestsCount,
                            icon: Icons.pending_actions,
                            color: const Color(0xFFFB8500),
                            onTap: () => Get.to(() => const DesignRequestsListScreen()),
                          ),
                          ActivityStatCard(
                            label: 'ID Verifications',
                            count: controller.pendingIDVerificationsCount,
                            icon: Icons.verified_user,
                            color: const Color(0xFF3A86FF),
                            onTap: () => Get.to(() => const IDVerificationQueueScreen()),
                          ),
                          ActivityStatCard(
                            label: 'Upcoming (7 days)',
                            count: controller.upcomingConsultationsCount,
                            icon: Icons.event,
                            color: const Color(0xFF52B788),
                          ),
                          ActivityStatCard(
                            label: 'Portfolio Items',
                            count: controller.portfolioItemsCount,
                            icon: Icons.collections,
                            color: const Color(0xFFE63946),
                            onTap: () => Get.to(() => const PortfolioGridScreen()),
                          ),
                        ],
                      ),
                    ),

                    // Design Requests Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Design Requests',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.to(() => const DesignRequestsListScreen()),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: controller.pendingDesignRequests.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No pending design requests',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          : Column(
                              children: controller.pendingDesignRequests
                                  .map((request) => DashboardDesignRequestCard(
                                        request: request,
                                        onTap: () => Get.to(() =>
                                            DesignRequestDetailScreen(request: request)),
                                      ))
                                  .toList(),
                            ),
                    ),

                    // Portfolio Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Portfolio Manager',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.to(() => const PortfolioGridScreen()),
                            child: const Text('Open Portfolio'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DashboardPortfolioGrid(
                        items: controller.recentPortfolioItems,
                        onViewAll: () => Get.to(() => const PortfolioGridScreen()),
                      ),
                    ),

                    // ID Verifications Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ID Verifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.to(() => const IDVerificationQueueScreen()),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: controller.pendingIDVerifications.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No pending ID verifications',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          : Column(
                              children: controller.pendingIDVerifications
                                  .map((verification) => DashboardIDVerificationCard(
                                        verification: verification,
                                        onTap: () => Get.to(() =>
                                            IDVerificationDetailScreen(
                                                verification: verification)),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
