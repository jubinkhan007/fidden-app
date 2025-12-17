import 'package:get/get.dart';
import '../data/nailtech_dashboard_model.dart';
import '../services/nailtech_dashboard_service.dart';

/// Controller for Nail Tech Lookbook
class NailTechLookbookController extends GetxController {
  final NailTechDashboardService _service = NailTechDashboardService();

  final Rx<LookbookResponse?> lookbookData = Rx<LookbookResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLookbook();
  }

  /// Get all lookbook items (GalleryItemModel from portfolio)
  List<GalleryItemModel> get items => lookbookData.value?.items ?? [];

  /// Get total count
  int get count => lookbookData.value?.count ?? 0;

  /// Fetch lookbook items
  Future<void> fetchLookbook() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getLookbook();
      lookbookData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
