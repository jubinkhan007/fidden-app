import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/business_owner_controller.dart';
import 'niche_layout_strategy.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/booking_stats.dart';
import '../widgets/growth_suggestion_card.dart';
import '../widgets/myService_row.dart';
import '../screens/add_service_screen.dart';
import '../screens/edit_service_screen.dart';
import '../screens/all_service_screen.dart';
import '../../analytics/performance_analytics_screen.dart';
import '../../nav_bar/controllers/user_nav_bar_controller.dart';
import '../../profile/screens/add_business_owner_profile_screen.dart';
import '../../../../core/commom/widgets/custom_text.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../core/utils/constants/image_path.dart';
import '../../../user/booking/presentation/api_time_format.dart';
import 'package:intl/intl.dart';
import '../../calendar/presentation/calendar_screen.dart';

class DefaultLayout implements NicheLayoutStrategy {
  @override
  List<Widget> buildContent(
    BuildContext context,
    BusinessOwnerController controller,
  ) {
    return [
      // 1. My Services Section
      _buildServicesSection(controller),

      const SizedBox(height: 24),

      // NEW: Calendar Section
      _buildCalendarSection(context),

      const SizedBox(height: 24),

      // 2. Dashboard Analytics Link
      _buildSectionTitle(
        "Dashboard",
        actionLabel: "Analytics",
        onAction: () => Get.to(() => const PerformanceAnalyticsScreen()),
      ),
      const SizedBox(height: 16),

      // 3. Key Stats Cards
      Row(
        children: [
          DashboardStatsCard(
            title: "Revenue",
            value: "\$${controller.totalRevenue.value.toStringAsFixed(2)}",
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          DashboardStatsCard(
            title: "New Bookings",
            value:
                "${controller.allBusinessOwnerBookingOne.value.stats?.newBookings ?? 0}",
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ],
      ),

      const SizedBox(height: 24),

      // 4. Weekly Revenue Chart
      _buildSectionTitle("Weekly Revenue"),
      const SizedBox(height: 16),
      Obx(() => RevenueChart(data: controller.revenue7d.toList())),

      SizedBox(height: getHeight(24)),

      // 5. Booking Stats
      _buildSectionTitle("Booking Stats"),
      const SizedBox(height: 16),
      const BookingStats(),

      const SizedBox(height: 24),

      // 6. Growth Suggestions
      Obx(() {
        final items = controller.growthSuggestions;
        if (items.isEmpty) return const SizedBox.shrink();

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

      // 7. Recent Bookings
      _buildSectionTitle(
        "Recent Bookings",
        seeAll: () => Get.find<BusinessOwnerNavBarController>().changeIndex(1),
      ),
      const SizedBox(height: 16),
      _buildRecentBookings(controller),
    ];
  }

  Widget _buildCalendarSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                "Unified Calendar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Manage bookings, blocked times, and provider shedules.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (myShopId.value != null && myShopId.value! > 0) {
                  Get.to(() => CalendarScreen(shopId: myShopId.value!));
                } else {
                  Get.snackbar(
                    "Error",
                    "Shop ID not found. Please ensure you have a shop created.",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Open Calendar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BusinessOwnerController controller) {
    return Column(
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
        Obx(() {
          if (controller.isLoading.value) {
            return const ServicesShimmerRow();
          }
          if (controller.shopMissing.value) {
            return ServicesGuardBanner(
              message: controller.shopMissingMessage.value.isNotEmpty
                  ? controller.shopMissingMessage.value
                  : 'You must create a shop before accessing services.',
              actionLabel: 'Create Shop',
              onAction: () => Get.to(const AddBusinessOwnerProfileScreen()),
            );
          }
          if (controller.allServiceList.isEmpty) {
            return ServicesEmpty(
              onCreate: controller.canAddService
                  ? () => Get.to(() => AddServiceScreen())
                  : null,
            );
          }
          return ServicesRow(
            items: controller.allServiceList.take(12).toList(),
            onEdit: (id) => Get.to(() => EditServiceScreen(id: id)),
          );
        }),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title, {
    VoidCallback? seeAll,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (seeAll != null)
              InkWell(
                onTap: seeAll,
                child: const Text(
                  "See All",
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                ),
              ),
            if (seeAll != null && actionLabel != null)
              const SizedBox(width: 12),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(actionLabel, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookings(BusinessOwnerController controller) {
    final results = controller.allBusinessOwnerBookingOne.value.results;
    final count = results.length > 3 ? 3 : results.length;

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
        final booking = results[index];
        final displayName = (booking.userName?.trim().isNotEmpty == true)
            ? booking.userName!.trim()
            : booking.userEmail;
        // Use timezone-aware formatting for correct time display
        final timeStr = booking.shopTimezone != null
            ? formatApiTimeInTimezone(
                booking.slotTimeIso,
                booking.shopTimezone!,
              )
            : DateFormat('hh:mm a').format(booking.slotTime);
        final dateStr = booking.shopTimezone != null
            ? formatApiDateInTimezone(
                booking.slotTimeIso,
                booking.shopTimezone!,
              )
            : DateFormat('d MMM yyyy').format(booking.slotTime);
        final when = "$timeStr at $dateStr";
        final ImageProvider avatar =
            (booking.profileImage != null &&
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
