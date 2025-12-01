import 'package:get/get.dart';
import '../data/design_request_model.dart';
import '../services/design_request_service.dart';

class DesignRequestController extends GetxController {
  final DesignRequestService _service = DesignRequestService();

  final RxList<DesignRequest> requests = <DesignRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDesignRequests();
  }

  Future<void> fetchDesignRequests({String? status}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await _service.getDesignRequests(status: status);
      requests.value = items;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveRequest(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updated = await _service.approveDesignRequest(id);
      
      final index = requests.indexWhere((req) => req.id == id);
      if (index != -1) {
        requests[index] = updated;
      }
      
      Get.snackbar('Success', 'Design request approved');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to approve request');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectRequest(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updated = await _service.rejectDesignRequest(id);
      
      final index = requests.indexWhere((req) => req.id == id);
      if (index != -1) {
        requests[index] = updated;
      }
      
      Get.snackbar('Success', 'Design request rejected');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to reject request');
    } finally {
      isLoading.value = false;
    }
  }

  List<DesignRequest> get pendingRequests => 
      requests.where((req) => req.isPending).toList();
  
  List<DesignRequest> get approvedRequests => 
      requests.where((req) => req.isApproved).toList();
}
