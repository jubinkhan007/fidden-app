import 'package:get/get.dart';
import '../data/esthetician_models.dart';
import '../services/esthetician_service.dart';

/// Controller for health disclosures
class HealthDisclosureController extends GetxController {
  final EstheticianService _service = EstheticianService();

  final RxList<HealthDisclosure> disclosures = <HealthDisclosure>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Filter by client ID (null = all)
  int? filterClientId;

  @override
  void onInit() {
    super.onInit();
    fetchDisclosures();
  }

  /// Fetch disclosures, optionally filtered by client
  Future<void> fetchDisclosures({int? clientId}) async {
    isLoading.value = true;
    errorMessage.value = '';
    filterClientId = clientId;

    try {
      disclosures.value = await _service.getHealthDisclosures(
        clientId: clientId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get disclosures with medical conditions
  List<HealthDisclosure> get alertDisclosures => disclosures
      .where((d) => d.hasMedicalConditions || d.pregnantOrNursing)
      .toList();

  /// Create new disclosure
  Future<void> createDisclosure(Map<String, dynamic> data) async {
    await _service.createHealthDisclosure(data);
    await fetchDisclosures(clientId: filterClientId);
  }
}
