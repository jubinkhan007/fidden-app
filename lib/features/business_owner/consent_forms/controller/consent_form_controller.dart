import 'package:get/get.dart';
import '../data/consent_form_model.dart';
import '../services/consent_form_service.dart';

class ConsentFormController extends GetxController {
  final ConsentFormService _service = ConsentFormService();

  final RxList<ConsentFormTemplate> templates = <ConsentFormTemplate>[].obs;
  final RxList<SignedConsentForm> signedForms = <SignedConsentForm>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTemplates();
    fetchSignedForms();
  }

  Future<void> fetchTemplates() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await _service.getTemplates();
      templates.value = items;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSignedForms() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await _service.getSignedForms();
      signedForms.value = items;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
