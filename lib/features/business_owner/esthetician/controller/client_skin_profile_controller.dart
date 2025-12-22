import 'package:get/get.dart';
import '../data/esthetician_models.dart';
import '../services/esthetician_service.dart';

/// Controller for client skin profiles
class ClientSkinProfileController extends GetxController {
  final EstheticianService _service = EstheticianService();

  final RxList<ClientSkinProfile> profiles = <ClientSkinProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  /// Fetch all client profiles
  Future<void> fetchProfiles() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      profiles.value = await _service.getClientProfiles();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered profiles based on search query
  List<ClientSkinProfile> get filteredProfiles {
    if (searchQuery.value.isEmpty) return profiles;
    final q = searchQuery.value.toLowerCase();
    return profiles.where((p) {
      final name = p.clientName?.toLowerCase() ?? '';
      final email = p.clientEmail?.toLowerCase() ?? '';
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  /// Create new profile
  Future<void> createProfile(Map<String, dynamic> data) async {
    await _service.createClientProfile(data);
    await fetchProfiles();
  }

  /// Update profile
  Future<void> updateProfile(int id, Map<String, dynamic> data) async {
    await _service.updateClientProfile(id, data);
    await fetchProfiles();
  }

  /// Delete profile
  Future<void> deleteProfile(int id) async {
    await _service.deleteClientProfile(id);
    profiles.removeWhere((p) => p.id == id);
  }
}
