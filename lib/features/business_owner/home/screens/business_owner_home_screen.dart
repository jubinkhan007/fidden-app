import 'package:fidden/features/business_owner/home/layouts/default_layout.dart'; // Added for fallback
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
          // Niche Dropdown
          // Niche Dropdown (Commented out as per request)
          /*
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: NicheDropdown(
              availableNiches: profileController.shopNiches,
              selectedNiche: profileController.shopNiche.value,
              onNicheChanged: (niche) {
                profileController.setPrimaryNiche(niche);
              },
            ),
          )),
          */
          
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const FullScreenShimmerLoader();
                }
                
                // Get the correct layout strategy based on selected niche
                /*
                final niche = profileController.shopNiche.value;
                final layoutStrategy = NicheLayoutFactory.getLayout(niche);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: layoutStrategy.buildContent(context, controller),
                );
                */

                // Fallback to DefaultLayout directly
                final layoutStrategy = DefaultLayout();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: layoutStrategy.buildContent(context, controller),
                );
              }),
            ),
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

}

