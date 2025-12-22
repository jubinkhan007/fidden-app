import 'package:get/get.dart';
import '../data/massage_models.dart';
import '../services/massage_service.dart';

/// Controller for Massage Therapist Dashboard
class MassageDashboardController extends GetxController {
  final _service = MassageService();

  final dashboard = Rxn<MassageDashboard>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      dashboard.value = await _service.getDashboard();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Top 3 disclosure alerts for the card
  List<DisclosureAlert> get topAlerts =>
      dashboard.value?.disclosureAlerts.take(3).toList() ?? [];

  int get alertCount => dashboard.value?.activeDisclosuresCount ?? 0;

  List<RecentTreatmentNote> get recentTreatmentNotes =>
      dashboard.value?.recentTreatmentNotes ?? [];
}
