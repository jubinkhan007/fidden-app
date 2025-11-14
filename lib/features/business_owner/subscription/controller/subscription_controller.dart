import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/subscription/data/subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fidden/core/services/Auth_service.dart'; // still fine to import if you need it later


class SubscriptionController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<CurrentSubscription?> currentSubscription =
  Rx<CurrentSubscription?>(null);
  final RxList<SubscriptionPlan> availablePlans =
      <SubscriptionPlan>[].obs;

  String get planName =>
      (currentSubscription.value?.plan.name ?? '').trim();

  bool get isFoundation => planName.toLowerCase() == 'foundation';
  bool get isMomentum   => planName.toLowerCase() == 'momentum';
  bool get isIcon       => planName.toLowerCase() == 'icon';

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);

      // ⬇️ NOTE: we are NOT passing token anymore.
      final responses = await Future.wait([
        NetworkCaller().getRequest(
          AppUrls.subscriptionDetails,
        ),
        NetworkCaller().getRequest(
          AppUrls.subscriptionPlans,
        ),
      ]);

      final currentSubResponse = responses[0];
      final allPlansResponse   = responses[1];

      // --- current subscription ---
      if (currentSubResponse.isSuccess) {
        currentSubscription.value = CurrentSubscription.fromJson(
          currentSubResponse.responseData,
        );
      } else {
        // suppress snackbar for 401 (expired token / logged out flow)
        if (currentSubResponse.statusCode != 401) {
          AppSnackBar.showError(
            'Failed to load your current subscription.',
          );
        }
      }

      // --- available plans ---
      if (allPlansResponse.isSuccess) {
        availablePlans.value = (allPlansResponse.responseData as List)
            .map((planJson) => SubscriptionPlan.fromJson(planJson))
            .toList();
      } else {
        if (allPlansResponse.statusCode != 401) {
          AppSnackBar.showError('Failed to load available plans.');
        }
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> createCheckoutSession(int planId) async {
    final response = await NetworkCaller().postRequest(
      AppUrls.createCheckoutSession,
      //  no token param
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
      return;
    }

    // better inline error handling:
    final code = response.responseData is Map<String, dynamic>
        ? (response.responseData['code'] as String?)?.toUpperCase()
        : null;

    final sc  = response.statusCode ?? 0;
    final msg = (response.errorMessage ?? '').toLowerCase();

    if (code == 'NO_SHOP' || (sc == 404 && msg.contains('shop'))) {
      AppSnackBar.showError(
        'Please create your shop first to purchase a subscription.',
      );
      // Optional: deep link -> Get.toNamed('/add-business-profile');
      return;
    }

    if (sc == 401) {
      // Session actually dead. You can route to login here.
      AppSnackBar.showError('You need to sign in again.');
      // trigger re-auth flow / Get.offAllNamed(LoginRoute)
      return;
    }

    if (code == 'PLAN_NOT_FOUND') {
      AppSnackBar.showError('Selected plan is unavailable.');
      return;
    }

    AppSnackBar.showError('Could not create payment session.');
  }

  Future<void> handleReturnFromStripeCheckout(String? sessionId) async {
    // This can still just refetch
    await fetchData();
  }

  Future<void> cancelSubscription() async {
    Get.defaultDialog(
      title: "Cancel Subscription",
      middleText:
      "Are you sure you want to cancel your subscription? You will be downgraded to the Foundation plan.",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      onConfirm: () async {
        Get.back(); // close dialog

        final response = await NetworkCaller().postRequest(
          AppUrls.cancelSubscription,
          //  no token param
          body: {},
        );

        if (response.isSuccess) {
          AppSnackBar.showSuccess(
            response.responseData['message'] ??
                'Your subscription has been cancelled.',
          );
          await fetchData(); // refresh UI
        } else {
          if (response.statusCode == 401) {
            // probably logged out – don't show a scary "failed" message
            // you might want to push to login instead
            return;
          }
          AppSnackBar.showError('Failed to cancel subscription.');
        }
      },
    );
  }
}
