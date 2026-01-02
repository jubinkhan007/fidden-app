import 'package:get/get.dart';
import '../data/style_request_model.dart';
import '../services/nailtech_dashboard_service.dart';
import '../../../../features/user/design_requests/data/client_design_request_model.dart';

/// Controller for Style Requests
class StyleRequestController extends GetxController {
  final NailTechDashboardService _service = NailTechDashboardService();

  final RxList<StyleRequest> styleRequests = <StyleRequest>[].obs;
  final RxList<ClientDesignRequest> designRequests =
      <ClientDesignRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<int> _busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStyleRequests();
    fetchDesignRequests();
  }

  bool isBusy(int id) => _busyIds.contains(id);

  /// Get pending style requests count
  int get pendingCount =>
      styleRequests.where((r) => r.status == StyleRequestStatus.pending).length;

  /// Get pending design requests count
  int get pendingDesignCount => designRequests.where((r) => r.isPending).length;

  /// Get combined pending count
  int get totalPendingCount => pendingCount + pendingDesignCount;

  /// Get pending style requests
  List<StyleRequest> get pendingRequests => styleRequests
      .where((r) => r.status == StyleRequestStatus.pending)
      .toList();

  /// Get pending design requests (filtered for nail_tech niche, or null/empty for backward compat)
  List<ClientDesignRequest> get pendingDesignRequests {
    final pending = designRequests.where((r) {
      final isNailNiche =
          r.serviceNiche == 'nail_tech' ||
          r.serviceNiche == null ||
          r.serviceNiche?.isEmpty == true;
      return r.isPending && isNailNiche;
    }).toList();
    print(
      '🔍 Design requests total: ${designRequests.length}, pending nail: ${pending.length}',
    );
    return pending;
  }

  /// Get ALL design requests for nail_tech (including approved/rejected for View All screen)
  List<ClientDesignRequest> get allNailDesignRequests {
    return designRequests.where((r) {
      final isNailNiche =
          r.serviceNiche == 'nail_tech' ||
          r.serviceNiche == null ||
          r.serviceNiche?.isEmpty == true;
      return isNailNiche;
    }).toList();
  }

  /// Fetch all style requests
  Future<void> fetchStyleRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _service.getStyleRequests();
      styleRequests.assignAll(data);
      print('🔍 Style requests fetched: ${data.length}');
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Failed to fetch style requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch design requests from booking flow
  Future<void> fetchDesignRequests() async {
    try {
      final data = await _service.getDesignRequests();
      designRequests.assignAll(data);
      print('🔍 Design requests fetched: ${data.length}');
      for (var r in data) {
        print(
          '   - ID: ${r.id}, niche: "${r.serviceNiche}", status: "${r.status}"',
        );
      }
    } catch (e) {
      print('❌ Failed to fetch design requests: $e');
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

  Future<void> _updateStatus(
    int id,
    StyleRequestStatus status,
    String actionName,
  ) async {
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
