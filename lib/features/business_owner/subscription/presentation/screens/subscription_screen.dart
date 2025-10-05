import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/features/business_owner/subscription/controller/subscription_controller.dart';
import 'package:fidden/features/business_owner/subscription/data/subscription_model.dart';
import 'package:intl/intl.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller = Get.put(SubscriptionController());

    return Scaffold(
      appBar: AppBar(
        title: Text("Subscriptions"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentSubscription.value == null) {
          return const Center(child: Text('Could not load subscription details.'));
        }

        final currentPlan = controller.currentSubscription.value!.plan;

        return RefreshIndicator(
          onRefresh: () => controller.fetchData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Current Plan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPlanCard(
                  context,
                  currentPlan,
                  isCurrentPlan: true,
                  controller: controller,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Manage Subscription',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...controller.availablePlans.where((plan) => plan.id != currentPlan.id).map((plan) {
                  return _buildPlanCard(
                    context,
                    plan,
                    isCurrentPlan: false,
                    controller: controller,
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan,
      {required bool isCurrentPlan, required SubscriptionController controller}) {

    final double currentPrice = double.tryParse(controller.currentSubscription.value?.plan.monthlyPrice ?? '0') ?? 0;
    final double planPrice = double.tryParse(plan.monthlyPrice) ?? 0;

    String buttonText = 'Switch to ${plan.name}';
    if (planPrice > currentPrice) {
      buttonText = 'Upgrade to ${plan.name}';
    } else if (plan.name == 'Foundation') {
      buttonText = 'Downgrade to Foundation';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isCurrentPlan ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentPlan ? AppColors.primaryColor : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              plan.name == "Foundation" ? 'Free' : '\$${plan.monthlyPrice}/month',
              style: const TextStyle(fontSize: 18, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
            ),
            if(double.tryParse(plan.commissionRate) != null && double.parse(plan.commissionRate) > 0)
              Text('+ ${plan.commissionRate}% commission per booking', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),

            const SizedBox(height: 16),
            _buildFeatureRow('Deposit Customization: ${plan.depositCustomization.capitalizeFirst}'),
            _buildFeatureRow('Priority Marketplace Ranking', enabled: plan.priorityMarketplaceRanking),
            _buildFeatureRow('Advanced Calendar Tools', enabled: plan.advancedCalendarTools),
            _buildFeatureRow('Auto-followups', enabled: plan.autoFollowups),
            _buildFeatureRow('Ghost Client Re-engagement', enabled: plan.ghostClientReEngagement),
            _buildFeatureRow('AI Assistant: ${plan.aiAssistant.capitalizeFirst}'),
            _buildFeatureRow('Performance Analytics: ${plan.performanceAnalytics.capitalizeFirst}'),
            const SizedBox(height: 20),

            // --- Button Logic ---
            if (isCurrentPlan)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Chip(
                    label: Text('CURRENT PLAN'),
                    backgroundColor: AppColors.primaryColor,
                    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if (plan.name != "Foundation" && controller.currentSubscription.value?.renewsOn != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Renews on: ${DateFormat.yMMMd().format(controller.currentSubscription.value!.renewsOn!)}', style: TextStyle(color: Colors.grey.shade700)),
                    ),
                  const SizedBox(height: 16),
                  if(plan.name != "Foundation")
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => controller.cancelSubscription(),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        child: const Text('Cancel Subscription'),
                      ),
                    ),
                ],
              ),
            if (!isCurrentPlan)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (plan.name == "Foundation") {
                      controller.cancelSubscription();
                    } else {
                      controller.createCheckoutSession(plan.id);
                    }
                  },
                  child: Text(buttonText),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(enabled ? Icons.check_circle : Icons.cancel_outlined, color: enabled ? AppColors.primaryColor : Colors.grey.shade400, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15, color: enabled ? Colors.black87 : Colors.grey.shade600))),
        ],
      ),
    );
  }
}