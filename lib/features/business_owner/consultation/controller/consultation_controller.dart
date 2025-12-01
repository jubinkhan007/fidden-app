import 'package:get/get.dart';
import '../data/consultation_model.dart';
import '../services/consultation_service.dart';

class ConsultationController extends GetxController {
  final ConsultationService _service = ConsultationService();

  final RxList<Consultation> consultations = <Consultation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConsultations();
  }

  Future<void> fetchConsultations({
    String? dateFrom,
    String? dateTo,
    String? status,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await _service.getConsultations(
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );
      consultations.value = items;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createConsultation({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String date,
    required String time,
    required int durationMinutes,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final newConsultation = await _service.createConsultation(
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        date: date,
        time: time,
        durationMinutes: durationMinutes,
        notes: notes,
      );
      
      consultations.insert(0, newConsultation);
      Get.back(); // Close create screen
      Get.snackbar('Success', 'Consultation scheduled');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to schedule consultation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateConsultation({
    required int id,
    String? date,
    String? time,
    int? durationMinutes,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updated = await _service.updateConsultation(
        id: id,
        date: date,
        time: time,
        durationMinutes: durationMinutes,
        notes: notes,
      );
      
      final index = consultations.indexWhere((c) => c.id == id);
      if (index != -1) {
        consultations[index] = updated;
      }
      
      Get.back(); // Close edit screen
      Get.snackbar('Success', 'Consultation updated');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update consultation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteConsultation(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _service.deleteConsultation(id);
      consultations.removeWhere((c) => c.id == id);
      Get.snackbar('Success', 'Consultation deleted');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to delete consultation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmConsultation(int id) async {
    try {
      isLoading.value = true;
      final updated = await _service.confirmConsultation(id);
      
      final index = consultations.indexWhere((c) => c.id == id);
      if (index != -1) {
        consultations[index] = updated;
      }
      
      Get.snackbar('Success', 'Consultation confirmed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to confirm consultation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeConsultation(int id, {String? notes}) async {
    try {
      isLoading.value = true;
      final updated = await _service.completeConsultation(id, notes: notes);
      
      final index = consultations.indexWhere((c) => c.id == id);
      if (index != -1) {
        consultations[index] = updated;
      }
      
      Get.snackbar('Success', 'Consultation completed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete consultation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelConsultation(int id) async {
    try {
      isLoading.value = true;
      final updated = await _service.cancelConsultation(id);
      
      final index = consultations.indexWhere((c) => c.id == id);
      if (index != -1) {
        consultations[index] = updated;
      }
      
      Get.snackbar('Success', 'Consultation cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel consultation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNoShow(int id) async {
    try {
      isLoading.value = true;
      final updated = await _service.markNoShow(id);
      
      final index = consultations.indexWhere((c) => c.id == id);
      if (index != -1) {
        consultations[index] = updated;
      }
      
      Get.snackbar('Info', 'Marked as no-show');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as no-show');
    } finally {
      isLoading.value = false;
    }
  }

  List<Consultation> get upcomingConsultations => consultations
      .where((c) => !c.isCompleted && !c.isCancelled && !c.isNoShow)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
}
