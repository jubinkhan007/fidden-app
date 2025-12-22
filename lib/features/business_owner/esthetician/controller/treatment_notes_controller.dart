import 'package:get/get.dart';
import '../data/esthetician_models.dart';
import '../services/esthetician_service.dart';

/// Controller for treatment notes
class TreatmentNotesController extends GetxController {
  final EstheticianService _service = EstheticianService();

  final RxList<TreatmentNote> notes = <TreatmentNote>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Filter by booking ID
  int? filterBookingId;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  /// Fetch treatment notes
  Future<void> fetchNotes({int? bookingId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    filterBookingId = bookingId;

    try {
      notes.value = await _service.getTreatmentNotes(bookingId: bookingId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new treatment note
  Future<void> createNote(Map<String, dynamic> data) async {
    await _service.createTreatmentNote(data);
    await fetchNotes(bookingId: filterBookingId);
  }

  /// Update treatment note
  Future<void> updateNote(int id, Map<String, dynamic> data) async {
    await _service.updateTreatmentNote(id, data);
    await fetchNotes(bookingId: filterBookingId);
  }

  /// Delete treatment note
  Future<void> deleteNote(int id) async {
    await _service.deleteTreatmentNote(id);
    notes.removeWhere((n) => n.id == id);
  }
}
