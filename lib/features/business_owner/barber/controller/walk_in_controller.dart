import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/walk_in_model.dart';
import '../services/barber_dashboard_service.dart';

/// Controller for Walk-In Queue management
class WalkInController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  // State
  final Rx<WalkInQueueResponse?> queueResponse = Rx<WalkInQueueResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Convenience getters
  List<WalkInEntry> get queue => queueResponse.value?.queue ?? [];
  List<WalkInEntry> get waitingQueue => queueResponse.value?.waitingQueue ?? [];
  List<WalkInEntry> get inService => queueResponse.value?.inService ?? [];
  int get waitingCount => queueResponse.value?.waitingCount ?? 0;
  int get inServiceCount => queueResponse.value?.inServiceCount ?? 0;
  int get totalInQueue => queueResponse.value?.totalInQueue ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchQueue();
  }

  /// Fetch walk-in queue
  Future<void> fetchQueue() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      queueResponse.value = await _service.getWalkInQueue();
    } catch (e) {
      errorMessage.value = 'Failed to load queue: ${e.toString()}';
      debugPrint('WalkInController.fetchQueue error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add new walk-in customer
  Future<bool> addToQueue({
    required String customerName,
    String? customerPhone,
    int? serviceId,
    String? notes,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      
      await _service.addToWalkInQueue(
        customerName: customerName,
        customerPhone: customerPhone,
        serviceId: serviceId,
        notes: notes,
      );
      
      await fetchQueue(); // Refresh queue
      
      Get.snackbar(
        'Success',
        '$customerName added to queue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add to queue';
      Get.snackbar(
        'Error',
        'Failed to add to queue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Call next customer (mark as in_service)
  Future<bool> callCustomer(int id) async {
    return await _updateStatus(id, WalkInStatus.in_service, 'Called customer');
  }

  /// Mark customer as completed
  Future<bool> completeService(int id) async {
    return await _updateStatus(id, WalkInStatus.completed, 'Service completed');
  }

  /// Mark customer as no-show
  Future<bool> markNoShow(int id) async {
    return await _updateStatus(id, WalkInStatus.no_show, 'Marked as no-show');
  }

  /// Cancel walk-in
  Future<bool> cancelWalkIn(int id) async {
    return await _updateStatus(id, WalkInStatus.cancelled, 'Cancelled');
  }

  /// Internal method to update status
  Future<bool> _updateStatus(int id, WalkInStatus status, String successMessage) async {
    try {
      isSubmitting.value = true;
      await _service.updateWalkInStatus(id, status);
      await fetchQueue();
      
      Get.snackbar(
        'Success',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Remove from queue
  Future<bool> removeFromQueue(int id) async {
    try {
      isSubmitting.value = true;
      await _service.removeFromWalkInQueue(id);
      await fetchQueue();
      
      Get.snackbar(
        'Removed',
        'Customer removed from queue',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from queue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
