import 'package:get/get.dart';
import '../data/id_verification_model.dart';
import '../services/id_verification_service.dart';

class IDVerificationController extends GetxController {
  final IDVerificationService _service = IDVerificationService();

  final RxList<IDVerificationRequest> verifications = <IDVerificationRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchIDVerifications();
  }

  Future<void> fetchIDVerifications({String? status}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await _service.getIDVerifications(status: status);
      verifications.value = items;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveID(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updated = await _service.approveID(id);
      
      final index = verifications.indexWhere((req) => req.id == id);
      if (index != -1) {
        verifications[index] = updated;
      }
      
      Get.snackbar('Success', 'ID verification approved');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to approve ID');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectID(int id, String reason) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updated = await _service.rejectID(id, reason);
      
      final index = verifications.indexWhere((req) => req.id == id);
      if (index != -1) {
        verifications[index] = updated;
      }
      
      Get.snackbar('Success', 'ID verification rejected');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to reject ID');
    } finally {
      isLoading.value = false;
    }
  }

  List<IDVerificationRequest> get pendingVerifications => 
      verifications.where((v) => v.isUnderReview).toList();
  
  List<IDVerificationRequest> get approvedVerifications => 
      verifications.where((v) => v.isApproved).toList();
}
