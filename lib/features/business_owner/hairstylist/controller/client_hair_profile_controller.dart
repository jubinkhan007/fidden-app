import 'package:get/get.dart';
import '../data/hairstylist_models.dart';
import '../services/hairstylist_service.dart';

/// Controller for client hair profiles
class ClientHairProfileController extends GetxController {
  final HairstylistService _service = HairstylistService();

  final RxList<ClientHairProfile> profiles = <ClientHairProfile>[].obs;
  final Rx<ClientHairProfile?> selectedProfile = Rx<ClientHairProfile?>(null);
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
    try {
      isLoading.value = true;
      errorMessage.value = '';
      profiles.value = await _service.getClientProfiles();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch a single profile
  Future<void> fetchProfile(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedProfile.value = await _service.getClientProfile(id);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new client profile
  Future<bool> createProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final newProfile = await _service.createClientProfile(data);
      profiles.insert(0, newProfile);
      Get.back();
      Get.snackbar('Success', 'Client profile created');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to create profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update a client profile
  Future<bool> updateProfile(int id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final updated = await _service.updateClientProfile(id, data);

      final index = profiles.indexWhere((p) => p.id == id);
      if (index != -1) {
        profiles[index] = updated;
      }
      selectedProfile.value = updated;

      Get.snackbar('Success', 'Profile updated');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered profiles based on search
  List<ClientHairProfile> get filteredProfiles {
    if (searchQuery.value.isEmpty) return profiles;

    final query = searchQuery.value.toLowerCase();
    return profiles.where((p) {
      return (p.clientName?.toLowerCase().contains(query) ?? false) ||
          (p.clientEmail?.toLowerCase().contains(query) ?? false) ||
          (p.hairTypeDisplay?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Group profiles by hair type
  Map<String, List<ClientHairProfile>> get profilesByHairType {
    final grouped = <String, List<ClientHairProfile>>{};
    for (final profile in profiles) {
      final type = profile.hairTypeDisplay ?? 'Unknown';
      grouped.putIfAbsent(type, () => []).add(profile);
    }
    return grouped;
  }
}
