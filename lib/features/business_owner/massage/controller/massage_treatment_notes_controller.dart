import 'package:get/get.dart';
import '../data/massage_models.dart';
import '../services/massage_service.dart';

/// Controller for managing massage treatment notes
class MassageTreatmentNotesController extends GetxController {
  final _service = MassageService();

  final notes = <MassageTreatmentNote>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes({int? bookingId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      notes.value = await _service.getTreatmentNotes(bookingId: bookingId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNote(Map<String, dynamic> data) async {
    await _service.createTreatmentNote(data);
    await fetchNotes();
  }

  Future<void> updateNote(int id, Map<String, dynamic> data) async {
    await _service.updateTreatmentNote(id, data);
    await fetchNotes();
  }
}
