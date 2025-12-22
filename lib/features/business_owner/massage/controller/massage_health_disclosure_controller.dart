import 'package:get/get.dart';
import '../data/massage_models.dart';
import '../services/massage_service.dart';

/// Controller for managing massage health disclosures
class MassageHealthDisclosureController extends GetxController {
  final _service = MassageService();

  final disclosures = <MassageHealthDisclosure>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final filterClientId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchDisclosures();
  }

  Future<void> fetchDisclosures({int? clientId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      filterClientId.value = clientId;
      disclosures.value = await _service.getHealthDisclosures(
        clientId: clientId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get disclosures with alerts
  List<MassageHealthDisclosure> get alertDisclosures => disclosures
      .where((d) => d.hasMedicalConditions || d.pregnantOrNursing)
      .toList();
}
