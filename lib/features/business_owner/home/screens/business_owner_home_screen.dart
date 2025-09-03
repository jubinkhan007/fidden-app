import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/business_owner/home/screens/add_service_screen.dart';
import 'package:fidden/features/business_owner/home/screens/edit_service_screen.dart';
import 'package:fidden/features/business_owner/home/screens/reminder_screen.dart';
import 'package:fidden/features/business_owner/home/widgets/myService_row.dart';
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
            "Hello, ${profileController.profileDetails.value.data?.name ?? ''}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoute.notificationScreen),
            icon: const Icon(Icons.notifications_none, size: 28),
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
              padding: const EdgeInsets.all(16.0),
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
                          onAction: () => Get.toNamed('/add-business-profile'),
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
                    const Row(
                      children: [
                        DashboardStatsCard(
                          title: "Revenue",
                          value: "\$1,250",
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                        SizedBox(width: 16),
                        DashboardStatsCard(
                          title: "New Bookings",
                          value: "12",
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Weekly Revenue"),
                    const SizedBox(height: 16),
                    const RevenueChart(),

                    SizedBox(height: getHeight(24)),
                    _buildSectionTitle("Booking Stats"),
                    const SizedBox(height: 16),
                    const BookingStats(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Growth Suggestions"),
                    const SizedBox(height: 16),
                    const GrowthSuggestionCard(
                      title: "Offer a 10% discount",
                      subtitle:
                          "Create a special offer for your services to attract more customers.",
                      icon: Icons.local_offer,
                    ),
                    const SizedBox(height: 12),
                    const GrowthSuggestionCard(
                      title: "Run a social media campaign",
                      subtitle:
                          "Promote your services on social media to reach a wider audience.",
                      icon: Icons.campaign,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      "Recent Bookings",
                      seeAll: () => Get.to(() => const AllBookingListScreen()),
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:
          (controller.allBusinessOwnerBookingOne.value.data?.length ?? 0) > 3
          ? 3
          : (controller.allBusinessOwnerBookingOne.value.data?.length ?? 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking =
            controller.allBusinessOwnerBookingOne.value.data?[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: booking?.serviceImage != null
                  ? NetworkImage(booking!.serviceImage!)
                  : const AssetImage(ImagePath.profileImage) as ImageProvider,
            ),
            title: Text(
              (booking?.customerForm != null &&
                      booking!.customerForm!.isNotEmpty)
                  ? "${booking.customerForm!.first.firstName ?? ''} ${booking.customerForm!.first.lastName ?? ''}"
                  : 'N/A',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${booking?.serviceName ?? ""} at ${booking?.bookingTime ?? ''}",
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.to(() => ViewWaiverFormScreen(bookingId: booking?.id ?? ''));
            },
          ),
        );
      },
    );
  }
}
