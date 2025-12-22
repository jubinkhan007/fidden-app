import 'package:get/get.dart';
import '../data/mua_models.dart';
import '../services/mua_service.dart';

/// Controller for MUA Face Charts
class FaceChartController extends GetxController {
  final MUAService _service = MUAService();

  final RxList<FaceChart> faceCharts = <FaceChart>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedLookType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFaceCharts();
  }

  Future<void> fetchFaceCharts({String? lookType}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _service.getFaceCharts(lookType: lookType);
      faceCharts.assignAll(response.items);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByLookType(String? lookType) {
    selectedLookType.value = lookType ?? '';
    fetchFaceCharts(lookType: lookType);
  }

  int get count => faceCharts.length;
}
