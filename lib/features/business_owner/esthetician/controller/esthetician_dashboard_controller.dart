import 'package:get/get.dart';
import '../data/esthetician_models.dart';
import '../services/esthetician_service.dart';

/// Controller for esthetician dashboard
class EstheticianDashboardController extends GetxController {
  final EstheticianService _service = EstheticianService();

  final Rx<EstheticianDashboard?> dashboard = Rx<EstheticianDashboard?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  /// Fetch aggregated dashboard
  Future<void> fetchDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      dashboard.value = await _service.getDashboard();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get disclosure alerts from dashboard
  List<DisclosureAlert> get disclosureAlerts =>
      dashboard.value?.disclosureAlerts ?? [];

  /// Get recent treatment notes from dashboard
  List<RecentTreatmentNote> get recentTreatmentNotes =>
      dashboard.value?.recentTreatmentNotes ?? [];

  /// Count of disclosure alerts needing attention
  int get alertCount => disclosureAlerts.length;

  /// Top 3 disclosure alerts for dashboard preview
  List<DisclosureAlert> get topAlerts => disclosureAlerts.take(3).toList();
}
