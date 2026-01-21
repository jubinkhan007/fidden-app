import 'package:fidden/features/business_owner/barber/controller/daily_revenue_controller.dart';
import 'package:fidden/features/business_owner/home/dashboard/dashboard_controller.dart';
import 'package:fidden/features/business_owner/home/dashboard/tile_registry.dart';
import 'package:fidden/features/business_owner/home/dashboard/widgets/context_chips.dart';
import 'package:fidden/features/business_owner/home/dashboard/widgets/dashboard_tile.dart';
import 'package:fidden/features/business_owner/home/layouts/default_layout.dart';
import 'package:fidden/features/business_owner/home/layouts/niche_layout_strategy.dart';
import 'package:fidden/features/business_owner/tattoo_dashboard/presentation/widgets/tattoo_artist_dashboard_content.dart';
import 'package:fidden/features/business_owner/barber/presentation/widgets/barber_dashboard_content.dart';
import 'package:fidden/features/business_owner/nailtech/presentation/widgets/nailtech_dashboard_content.dart';
import 'package:fidden/features/business_owner/mua/presentation/widgets/mua_dashboard_content.dart';
import 'package:fidden/features/business_owner/hairstylist/presentation/widgets/hairstylist_dashboard_content.dart';
import 'package:fidden/features/business_owner/esthetician/presentation/widgets/esthetician_dashboard_content.dart';
import 'package:fidden/features/business_owner/massage/presentation/widgets/massage_dashboard_content.dart';
import 'package:fidden/features/business_owner/fitness_trainer_dashboard/presentation/screens/fitness_trainer_dashboard_screen.dart';
import 'package:fidden/features/notifications/controller/notification_controller.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../ai_assistant/ai_assistant_screen.dart';
import '../controller/business_owner_controller.dart';
import '../simmer/business_owner_home_shimmer.dart';

class BusinessOwnerHomeScreen extends StatelessWidget {
  const BusinessOwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessOwnerController>();
    final profileController = Get.find<ProfileController>();
    final dashboardController = Get.put(DashboardController());
    // Register DailyRevenueController for niche-filtered revenue data
    Get.put(DailyRevenueController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: Obx(
          () => Text(
            "Hello ${profileController.profileDetails.value.data?.name ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        actions: [
          // Notification Icon
          Obx(
            () => Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Get.toNamed(AppRoute.notificationScreen);
                  },
                  icon: const Icon(Icons.notifications_none_outlined, size: 28),
                ),
                if (Get.find<NotificationController>().hasUnread.value)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshGuardsAndServices();
            await controller.fetchBusinessOwnerBooking();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              // For tablets, limit content width and center it
              final isTablet = constraints.maxWidth > 600;
              final maxContentWidth = isTablet ? 800.0 : double.infinity;

              return Column(
                children: [
                  // 1. Context Chips
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: ContextChips(),
                  ),

                  // 2. Dynamic Content (DefaultLayout for "All", Tiles for specific niches)
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const FullScreenShimmerLoader();
                          }

                          // Check selected chip and primary niche
                          final selectedChip =
                              dashboardController.selectedChip.value;
                          final niche = selectedChip == 'All'
                              ? profileController.shopNiche.value
                              : selectedChip;

                          // Use dedicated dashboard for specific niches
                          if (niche == 'tattoo_artist') {
                            return const TattooArtistDashboardContent();
                          }

                          if (niche == 'barber') {
                            return const BarberDashboardContent();
                          }

                          if (niche == 'nail_tech') {
                            return const NailTechDashboardContent();
                          }

                          if (niche == 'makeup_artist') {
                            return const MUADashboardContent();
                          }

                          if (niche == 'hairstylist') {
                            return const HairstylistDashboardContent();
                          }

                          if (niche == 'esthetician') {
                            return const EstheticianDashboardContent();
                          }

                          if (niche == 'massage_therapist') {
                            return const MassageDashboardContent();
                          }

                          if (niche == 'fitness_trainer') {
                            return FitnessTrainerDashboardScreen(
                              shopId: myShopId.value ?? 0,
                            );
                          }

                          // For other niches, use the layout strategy pattern
                          final layout = NicheLayoutFactory.getLayout(niche);
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              0,
                              16.0,
                              16.0,
                            ),
                            children: layout.buildContent(context, controller),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) {
              final height = MediaQuery.of(ctx).size.height * 0.9; // tall sheet
              return SizedBox(height: height, child: const AiAssistantScreen());
            },
          );
        },
        tooltip: 'AI Assistant',
        child: const Icon(Icons.smart_toy_outlined),
      ),
    );
  }

  Widget _buildTile(DashboardTileType type) {
    switch (type) {
      // --- Shared Tiles ---
      case DashboardTileType.dailyRevenue:
        return const DashboardTile(
          title: "Daily Revenue",
          subtitle: "Today's earnings",
          child: Text(
            "\$0.00",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case DashboardTileType.todaysAppointments:
        return const DashboardTile(
          title: "Today's Appointments",
          subtitle: "0 scheduled",
        );
      case DashboardTileType.notifications:
        return const DashboardTile(
          title: "Notifications",
          subtitle: "No new alerts",
        );

      // --- Tattoo Artist Tiles ---
      case DashboardTileType.portfolio:
        return DashboardTile(
          title: "Portfolio",
          subtitle: "Manage your work",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to Portfolio
            Get.toNamed(AppRoute.portfolioScreen);
          },
        );
      case DashboardTileType.designRequests:
        return DashboardTile(
          title: "Design Requests",
          subtitle: "0 pending",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to Design Requests
            Get.toNamed(AppRoute.designRequestsScreen);
          },
        );
      case DashboardTileType.consentForms:
        return DashboardTile(
          title: "Consent Forms",
          subtitle: "Templates & Signed",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to Consent Forms
            Get.toNamed(AppRoute.consentFormsScreen);
          },
        );
      case DashboardTileType.idVerification:
        return DashboardTile(
          title: "ID Verification",
          subtitle: "Check client IDs",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to ID Verification
            Get.toNamed(AppRoute.idVerificationScreen);
          },
        );
      case DashboardTileType.consultationCalendar:
        return DashboardTile(
          title: "Consultation Calendar",
          subtitle: "Manage consultations",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Get.toNamed(AppRoute.consultationCalendarScreen);
          },
        );
      case DashboardTileType.depositManagement:
        return DashboardTile(
          title: "Deposit Management",
          subtitle: "Track deposits",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Get.toNamed(AppRoute.depositManagementScreen);
          },
        );
      case DashboardTileType.reviews:
        return DashboardTile(
          title: "Reviews",
          subtitle: "Client feedback",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Get.toNamed(AppRoute.reviewsScreen);
          },
        );
      case DashboardTileType.noShowAlerts:
        return DashboardTile(
          title: "No-Show Alerts",
          subtitle: "Recent no-shows",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Get.toNamed(AppRoute.noShowAlertsScreen);
          },
        );
      case DashboardTileType.serviceMenu:
        return DashboardTile(
          title: "Service Menu",
          subtitle: "Manage services",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Get.toNamed(AppRoute.serviceMenuScreen);
          },
        );
    }
  }
}
