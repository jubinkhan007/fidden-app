import 'package:get/get.dart';
import '../data/massage_models.dart';
import '../services/massage_service.dart';

/// Controller for managing massage client profiles
class MassageClientProfileController extends GetxController {
  final _service = MassageService();

  final profiles = <MassageClientProfile>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      profiles.value = await _service.getClientProfiles(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<MassageClientProfile> get filteredProfiles {
    if (searchQuery.value.isEmpty) return profiles;
    final q = searchQuery.value.toLowerCase();
    return profiles.where((p) {
      return (p.clientName?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> createProfile(Map<String, dynamic> data) async {
    await _service.createClientProfile(data);
    await fetchProfiles();
  }

  Future<void> updateProfile(int id, Map<String, dynamic> data) async {
    await _service.updateClientProfile(id, data);
    await fetchProfiles();
  }

  Future<void> deleteProfile(int id) async {
    await _service.deleteClientProfile(id);
    profiles.removeWhere((p) => p.id == id);
  }
}
