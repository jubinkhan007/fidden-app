import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/walk_in_model.dart';
import '../services/barber_dashboard_service.dart';
import '../../tattoo_dashboard/controller/tattoo_artist_dashboard_controller.dart';
import '../../nailtech/controller/nailtech_dashboard_controller.dart';

/// Controller for Walk-In Queue management
class WalkInController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  // State
  final RxList<WalkInEntry> queue = <WalkInEntry>[].obs;
  final RxMap<String, int> stats = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Convenience getters
  List<WalkInEntry> get waitingQueue =>
      queue.where((e) => e.status == WalkInStatus.waiting).toList();
  List<WalkInEntry> get inService =>
      queue.where((e) => e.status == WalkInStatus.in_service).toList();
  int get waitingCount => stats['waiting'] ?? waitingQueue.length;
  int get inServiceCount => stats['in_service'] ?? inService.length;
  int get totalInQueue => stats['total'] ?? queue.length;

  @override
  void onInit() {
    super.onInit();
    fetchQueue();
  }

  /// Fetch walk-in queue
  Future<void> fetchQueue({String? serviceNiche}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getWalkInQueue(serviceNiche: serviceNiche);
      queue.assignAll(data);
    } catch (e) {
      errorMessage.value = 'Failed to load queue: ${e.toString()}';
      debugPrint('WalkInController.fetchQueue error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch stats
  Future<void> fetchStats({String? serviceNiche}) async {
    try {
      final data = await _service.getWalkInStats(serviceNiche: serviceNiche);
      stats.assignAll(data);
    } catch (e) {
      debugPrint('WalkInController.fetchStats error: $e');
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

      Get.snackbar(
        'Success',
        '$customerName added to queue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      fetchQueue();
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

  /// Start service for customer (call them in)
  Future<bool> startService(int id) async {
    try {
      isSubmitting.value = true;
      await _service.startWalkInService(id);
      await fetchQueue();

      Get.snackbar(
        'Success',
        'Customer called',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to call customer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Complete walk-in with payment (creates SlotBooking + Payment)
  Future<bool> completeWithPayment({
    required int id,
    required String paymentMethod,
    required double amountPaid,
    double tipsAmount = 0,
  }) async {
    try {
      isSubmitting.value = true;
      await _service.completeWalkInWithPayment(
        id: id,
        paymentMethod: paymentMethod,
        amountPaid: amountPaid,
        tipsAmount: tipsAmount,
      );
      await fetchQueue();

      Get.snackbar(
        'Checkout Complete',
        'Payment of \$${amountPaid.toStringAsFixed(2)} recorded',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh dashboards if active
      if (Get.isRegistered<TattooArtistDashboardController>()) {
        Get.find<TattooArtistDashboardController>().fetchNicheRevenue();
      }
      if (Get.isRegistered<NailTechDashboardController>()) {
        Get.find<NailTechDashboardController>().fetchDashboard();
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete checkout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Mark customer as no-show
  Future<bool> markNoShow(int id) async {
    try {
      isSubmitting.value = true;
      await _service.markWalkInNoShow(id);
      await fetchQueue();

      Get.snackbar(
        'Marked',
        'Customer marked as no-show',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark as no-show',
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
