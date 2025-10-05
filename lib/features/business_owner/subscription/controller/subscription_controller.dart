// lib/features/business_owner/subscription/controller/subscription_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/subscription/data/subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fidden/core/services/Auth_service.dart'; // ⬅️ add this

class SubscriptionController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<CurrentSubscription?> currentSubscription = Rx<CurrentSubscription?>(null);
  final RxList<SubscriptionPlan> availablePlans = <SubscriptionPlan>[].obs;

  String? get _token => AuthService.accessToken; // ⬅️ convenience getter

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);

      // ⬇️ pass token to BOTH requests
      final responses = await Future.wait([
        NetworkCaller().getRequest(
          AppUrls.subscriptionDetails,
          token: _token,
        ),
        NetworkCaller().getRequest(
          AppUrls.subscriptionPlans,
          token: _token,
        ),
      ]);

      final currentSubResponse = responses[0];
      final allPlansResponse = responses[1];

      if (currentSubResponse.isSuccess) {
        currentSubscription.value =
            CurrentSubscription.fromJson(currentSubResponse.responseData);
      } else {
        AppSnackBar.showError('Failed to load your current subscription.');
      }

      if (allPlansResponse.isSuccess) {
        availablePlans.value = (allPlansResponse.responseData as List)
            .map((planJson) => SubscriptionPlan.fromJson(planJson))
            .toList();
      } else {
        AppSnackBar.showError('Failed to load available plans.');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createCheckoutSession(int planId) async {
    final response = await NetworkCaller().postRequest(
      AppUrls.createCheckoutSession,
      token: _token, // ⬅️ add token
      body: {'plan_id': planId},
    );

    if (response.isSuccess) {
      final url = response.responseData['url'];
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          AppSnackBar.showError('Could not launch payment page.');
        }
      }
    } else {
      AppSnackBar.showError('Could not create payment session.');
    }
  }

  Future<void> cancelSubscription() async {
    Get.defaultDialog(
      title: "Cancel Subscription",
      middleText:
      "Are you sure you want to cancel your subscription? You will be downgraded to the Foundation plan.",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      onConfirm: () async {
        Get.back(); // Close dialog

        final response = await NetworkCaller().postRequest(
          AppUrls.cancelSubscription,
          token: _token, // ⬅️ add token
          body: {},
        );

        if (response.isSuccess) {
          AppSnackBar.showSuccess(
              response.responseData['message'] ?? 'Your subscription has been cancelled.');
          await fetchData(); // Refresh data
        } else {
          AppSnackBar.showError('Failed to cancel subscription.');
        }
      },
    );
  }
}
