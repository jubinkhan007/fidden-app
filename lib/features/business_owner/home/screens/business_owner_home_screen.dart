import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/business_owner/booking/screen/booking_screen.dart';
import 'package:fidden/features/business_owner/home/screens/add_service_screen.dart';
import 'package:fidden/features/business_owner/home/screens/edit_service_screen.dart';
import 'package:fidden/features/business_owner/home/screens/reminder_screen.dart';
import 'package:fidden/features/business_owner/home/widgets/myService_row.dart';
import 'package:fidden/features/business_owner/nav_bar/controllers/user_nav_bar_controller.dart';
import 'package:fidden/features/business_owner/profile/screens/add_business_owner_profile_screen.dart';
import 'package:fidden/features/notifications/controller/notification_controller.dart';
import 'package:fidden/features/splash/controller/splash_controller.dart';
import 'package:fidden/features/user/booking/presentation/screens/view_waiver_form_screen.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/all_services_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../routes/app_routes.dart';
import '../controller/business_owner_controller.dart';
import '../simmer/business_owner_home_shimmer.dart';
import 'all_booking_list_screen.dart';
import 'all_service_screen.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/booking_stats.dart';
import '../widgets/growth_suggestion_card.dart';

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
              padding: const EdgeInsets.fromLTRB(16.0,0,16.0,16.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const FullScreenShimmerLoader();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "My Services",
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff111827),
                          fontSize: getWidth(18),
                        ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Add service',
                              onPressed: controller.canAddService
                                  ? () => Get.to(() => AddServiceScreen())
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(() => AllServiceScreen()),
                              child: CustomText(
                                text: "See All",
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff898989),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ── My Services content (uses your controller flags) ──────────────────────────
                    Obx(() {
                      // 1) loading state (controller.isLoading toggles during fetchAllMyService)
                      if (controller.isLoading.value) {
                        return const ServicesShimmerRow();
                      }

                      // 2) guard: user must create a shop
                      if (controller.shopMissing.value) {
                        return ServicesGuardBanner(
                          message:
                              controller.shopMissingMessage.value.isNotEmpty
                              ? controller.shopMissingMessage.value
                              : 'You must create a shop before accessing services.',
                          actionLabel: 'Create Shop',
                          onAction: () =>
                              Get.to(const AddBusinessOwnerProfileScreen()),
                        );
                      }

                      // 3) empty state
                      if (controller.allServiceList.isEmpty) {
                        return ServicesEmpty(
                          onCreate: controller.canAddService
                              ? () => Get.to(() => AddServiceScreen())
                              : null,
                        );
                      }

                      // 4) data
                      return ServicesRow(
                        items: controller.allServiceList.take(12).toList(),
                        onEdit: (id) => Get.to(() => EditServiceScreen(id: id)),
                      );
                    }),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Dashboard"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        DashboardStatsCard(
                          title: "Revenue",
                          value: "\$${controller.totalRevenue}",
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                        SizedBox(width: 16),
                        DashboardStatsCard(
                          title: "New Bookings",
                          value: "${controller.allBusinessOwnerBookingOne.value.stats?.newBookings ?? 0}",
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Weekly Revenue"),
                    const SizedBox(height: 16),
                    Obx(
                      () => RevenueChart(data: controller.revenue7d.toList()),
                    ),

                    SizedBox(height: getHeight(24)),
                    _buildSectionTitle("Booking Stats"),
                    const SizedBox(height: 16),
                    const BookingStats(),
                    const SizedBox(height: 24),
                    Obx(() {
                      final items = controller.growthSuggestions;
                      if (items.isEmpty) return const SizedBox.shrink(); // hide section entirely

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Growth Suggestions"),
                          const SizedBox(height: 8),
                          ...List.generate(items.length, (i) {
                            final s = items[i];
                            final icon = controller.iconForSuggestionCategory(s.category);
                            return Padding(
                              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 4),
                              child: GrowthSuggestionCard(
                                title: s.suggestionTitle,
                                subtitle: s.shortDescription,
                                icon: icon,
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildSectionTitle(
                      "Recent Bookings",
                      seeAll: () => Get.find<BusinessOwnerNavBarController>().changeIndex(1),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentBookings(controller),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? seeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (seeAll != null)
          InkWell(
            onTap: seeAll,
            child: const Text(
              "See All",
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentBookings(BusinessOwnerController controller) {
  final results = controller.allBusinessOwnerBookingOne.value.results; // NEW

  final count = results.length > 3 ? 3 : results.length; // show max 3

  if (count == 0) {
    return const Text(
      "No recent bookings",
      style: TextStyle(color: Color(0xFF6B7280)),
    );
  }

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: count,
    separatorBuilder: (context, index) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final booking = results[index]; // OwnerBookingItem

      final displayName =
          (booking.userName?.trim().isNotEmpty == true)
              ? booking.userName!.trim()
              : booking.userEmail;

      final when =
          "${DateFormat('hh:mm a').format(booking.slotTime)} at ${DateFormat('d MMM yyyy').format(booking.slotTime)}";

      final ImageProvider avatar = (booking.profileImage != null &&
              booking.profileImage!.trim().isNotEmpty)
          ? NetworkImage(booking.profileImage!)
          : const AssetImage(ImagePath.profileImage);

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: CircleAvatar(backgroundImage: avatar),
          title: Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "${booking.serviceTitle} • $when",
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
  Get.toNamed('/owner-booking-details', arguments: booking);
},
        ),
      );
    },
  );
}
}
