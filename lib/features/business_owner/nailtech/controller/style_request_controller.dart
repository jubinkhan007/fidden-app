import 'package:get/get.dart';
import '../data/style_request_model.dart';
import '../services/nailtech_dashboard_service.dart';

/// Controller for Style Requests
class StyleRequestController extends GetxController {
  final NailTechDashboardService _service = NailTechDashboardService();

  final RxList<StyleRequest> styleRequests = <StyleRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<int> _busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStyleRequests();
  }

  bool isBusy(int id) => _busyIds.contains(id);

  /// Get pending requests count
  int get pendingCount => styleRequests.where((r) => r.status == StyleRequestStatus.pending).length;

  /// Get pending requests
  List<StyleRequest> get pendingRequests => 
      styleRequests.where((r) => r.status == StyleRequestStatus.pending).toList();

  /// Fetch all style requests
  Future<void> fetchStyleRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getStyleRequests();
      styleRequests.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve a style request
  Future<void> approveRequest(int id) async {
    await _updateStatus(id, StyleRequestStatus.approved, 'approved');
  }

  /// Decline a style request
  Future<void> declineRequest(int id) async {
    await _updateStatus(id, StyleRequestStatus.declined, 'declined');
  }

  /// Mark a style request as completed
  Future<void> completeRequest(int id) async {
    await _updateStatus(id, StyleRequestStatus.completed, 'completed');
  }

  Future<void> _updateStatus(int id, StyleRequestStatus status, String actionName) async {
    if (_busyIds.contains(id)) return;
    _busyIds.add(id);
    _busyIds.refresh();

    try {
      final updated = await _service.updateStyleRequestStatus(id, status);
      
      // Update local list
      final index = styleRequests.indexWhere((r) => r.id == id);
      if (index != -1) {
        styleRequests[index] = updated;
        styleRequests.refresh();
      }

      Get.snackbar(
        'Success',
        'Style request $actionName',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update style request',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _busyIds.remove(id);
      _busyIds.refresh();
    }
  }
}
