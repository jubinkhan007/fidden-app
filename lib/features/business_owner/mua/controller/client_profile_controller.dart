import 'package:get/get.dart';
import '../data/mua_models.dart';
import '../services/mua_service.dart';

/// Controller for Client Beauty Profiles
class ClientProfileController extends GetxController {
  final MUAService _service = MUAService();

  final RxList<ClientBeautyProfile> profiles = <ClientBeautyProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxSet<int> _busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  bool isBusy(int id) => _busyIds.contains(id);

  Future<void> fetchProfiles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getClientProfiles();
      profiles.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createProfile(ClientBeautyProfile profile) async {
    try {
      final created = await _service.createClientProfile(profile);
      profiles.insert(0, created);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create profile');
      return false;
    }
  }

  Future<bool> updateProfile(int id, Map<String, dynamic> updates) async {
    try {
      _busyIds.add(id);
      _busyIds.refresh();
      
      final updated = await _service.updateClientProfile(id, updates);
      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = updated;
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
      return false;
    } finally {
      _busyIds.remove(id);
      _busyIds.refresh();
    }
  }

  int get count => profiles.length;
}
