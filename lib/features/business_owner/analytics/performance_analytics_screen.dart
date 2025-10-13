import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_spacers.dart';
import 'package:fidden/features/business_owner/analytics/controller/analytics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class PerformanceAnalyticsScreen extends StatelessWidget {
  const PerformanceAnalyticsScreen({super.key});

  static const double kPad = 16.0;
  static const double kGap = 12.0;
  static const double kSectionGap = 24.0;
  static const double kXs = 4.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Analytics"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ---- Foundation plan or restricted user ----
        final detailMsg = controller.analyticsData.value.detail;
        if (detailMsg != null && detailMsg.isNotEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPad),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 80,
                    color: Colors.grey.shade500,
                  ),
                  const VerticalSpace(height: kSectionGap),
                  Text(
                    detailMsg, // e.g. "No analytics available for your current plan."
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.black87),
                  ),
                  const VerticalSpace(height: kGap),
                  Text(
                    'Upgrade your plan to unlock powerful insights and grow your business.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade700),
                  ),
                  const VerticalSpace(height: kSectionGap * 2),
                  CustomButton(
                    onPressed: () => Get.toNamed(AppRoute.subscriptionScreen),
                    child: const Text(
                      'Upgrade Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ---- Paid plans (show analytics data) ----
        return SingleChildScrollView(
          padding: const EdgeInsets.all(kPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Performance Snapshot',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const VerticalSpace(height: kSectionGap),
              _buildAnalyticsGrid(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAnalyticsGrid(
      BuildContext context, AnalyticsController controller) {
    final data = controller.analyticsData.value;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: kGap,
      mainAxisSpacing: kGap,
      children: [
        if (data.totalRevenue != null)
          _buildMetricCard(
            context,
            'Total Revenue',
            '\$${data.totalRevenue}',
            Icons.attach_money,
            AppColors.primaryColor,
          ),
        if (data.totalBookings != null)
          _buildMetricCard(
            context,
            'Total Bookings',
            data.totalBookings.toString(),
            Icons.book_online,
            AppColors.secondaryColor,
          ),
        if (data.averageRating != null)
          _buildMetricCard(
            context,
            'Average Rating',
            data.averageRating!.toStringAsFixed(1),
            Icons.star,
            AppColors.accent,
          ),
        if (data.cancellationRate != null)
          _buildMetricCard(
            context,
            'Cancellation Rate',
            '${data.cancellationRate!.toStringAsFixed(2)}%',
            Icons.cancel,
            Colors.red,
          ),
        if (data.repeatCustomerRate != null)
          _buildMetricCard(
            context,
            'Repeat Customer Rate',
            '${data.repeatCustomerRate!.toStringAsFixed(2)}%',
            Icons.repeat,
            Colors.green,
          ),
        if (data.topService != null)
          _buildMetricCard(
            context,
            'Top Service',
            data.topService!,
            Icons.spa,
            Colors.orange,
          ),
        if (data.peakBookingTime != null)
          _buildMetricCard(
            context,
            'Peak Booking Time',
            data.peakBookingTime!,
            Icons.timer,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildMetricCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(kGap),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const VerticalSpace(height: kGap / 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const VerticalSpace(height: kXs),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
