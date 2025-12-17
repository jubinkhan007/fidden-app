import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/loyalty_model.dart';
import '../services/barber_dashboard_service.dart';

/// Controller for Loyalty Program management
class LoyaltyController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  // State
  final Rx<LoyaltyProgram?> program = Rx<LoyaltyProgram?>(null);
  final Rx<LoyaltyCustomersResponse?> customersResponse = Rx<LoyaltyCustomersResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Convenience getters
  bool get isProgramActive => program.value?.isActive ?? false;
  List<LoyaltyCustomer> get customers => customersResponse.value?.customers ?? [];
  int get customerCount => customersResponse.value?.count ?? 0;
  int get redeemableCount => customersResponse.value?.redeemableCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchProgram();
    fetchCustomers();
  }

  /// Fetch loyalty program settings
  Future<void> fetchProgram() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      program.value = await _service.getLoyaltyProgram();
    } catch (e) {
      errorMessage.value = 'Failed to load loyalty program';
      debugPrint('LoyaltyController.fetchProgram error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch loyalty customers
  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      customersResponse.value = await _service.getLoyaltyCustomers();
    } catch (e) {
      debugPrint('LoyaltyController.fetchCustomers error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle program active status
  Future<bool> toggleProgram(bool isActive) async {
    try {
      isSubmitting.value = true;
      program.value = await _service.updateLoyaltyProgram(isActive: isActive);
      
      Get.snackbar(
        'Success',
        isActive ? 'Loyalty program activated' : 'Loyalty program deactivated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update program',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update program settings
  Future<bool> updateProgram({
    double? pointsPerDollar,
    int? pointsForRedemption,
    RewardType? rewardType,
    double? rewardValue,
  }) async {
    try {
      isSubmitting.value = true;
      
      program.value = await _service.updateLoyaltyProgram(
        pointsPerDollar: pointsPerDollar,
        pointsForRedemption: pointsForRedemption,
        rewardType: rewardType?.toApiString(),
        rewardValue: rewardValue,
      );
      
      Get.snackbar(
        'Success',
        'Loyalty program updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update program',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Add points for a customer after purchase
  Future<AddPointsResponse?> addPoints({
    required int userId,
    required double amountSpent,
  }) async {
    try {
      isSubmitting.value = true;
      
      final response = await _service.addLoyaltyPoints(
        userId: userId,
        amountSpent: amountSpent,
      );
      
      await fetchCustomers(); // Refresh customer list
      
      Get.snackbar(
        'Points Added',
        '${response.pointsEarned} points earned! Balance: ${response.newBalance}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return response;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add points',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Redeem points for a customer
  Future<RedeemResponse?> redeemPoints({required int userId}) async {
    try {
      isSubmitting.value = true;
      
      final response = await _service.redeemLoyaltyPoints(userId: userId);
      
      if (response.success) {
        await fetchCustomers(); // Refresh customer list
        
        String rewardText = '';
        switch (response.rewardType) {
          case RewardType.discountPercent:
            rewardText = '${response.rewardValue.toStringAsFixed(0)}% discount';
            break;
          case RewardType.discountFixed:
            rewardText = '\$${response.rewardValue.toStringAsFixed(2)} off';
            break;
          case RewardType.freeService:
            rewardText = 'Free service';
            break;
        }
        
        Get.snackbar(
          'Reward Redeemed!',
          'Customer earned: $rewardText',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      
      return response;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to redeem points',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
