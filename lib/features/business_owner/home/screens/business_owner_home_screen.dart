import 'package:fidden/features/business_owner/home/dashboard/dashboard_controller.dart';
import 'package:fidden/features/business_owner/home/dashboard/tile_registry.dart';
import 'package:fidden/features/business_owner/home/dashboard/widgets/context_chips.dart';
import 'package:fidden/features/business_owner/home/dashboard/widgets/dashboard_tile.dart';
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
          child: Column(
            children: [
              // 1. Context Chips
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: ContextChips(),
              ),

              // 2. Dynamic Tiles
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const FullScreenShimmerLoader();
                  }

                  final tiles = dashboardController.visibleTiles;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    itemCount: tiles.length,
                    itemBuilder: (context, index) {
                      final tileType = tiles[index];
                      return _buildTile(tileType);
                    },
                  );
                }),
              ),
            ],
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
              return SizedBox(
                height: height,
                child: const AiAssistantScreen(),
              );
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
          child: Text("\$0.00", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          },
        );
      case DashboardTileType.consentForms:
        return DashboardTile(
          title: "Consent Forms",
          subtitle: "Templates & Signed",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to Consent Forms
          },
        );
      case DashboardTileType.idVerification:
        return DashboardTile(
          title: "ID Verification",
          subtitle: "Check client IDs",
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to ID Verification
          },
        );
      

    }
  }
}


