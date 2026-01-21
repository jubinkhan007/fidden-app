import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart'
    show myShopId;
import 'package:get/get.dart';
import '../data/fitness_trainer_repository.dart';
import '../model/fitness_trainer_models.dart';

class FitnessTrainerDashboardController extends GetxController {
  final FitnessTrainerRepository _repo = FitnessTrainerRepository();

  final RxBool isLoading = false.obs;
  final Rxn<FitnessDashboardModel> dashboard = Rxn<FitnessDashboardModel>();

  // Lists
  final RxList<FitnessPackageModel> packages = <FitnessPackageModel>[].obs;
  final RxList<WorkoutTemplateModel> templates = <WorkoutTemplateModel>[].obs;
  final RxList<NutritionPlanModel> nutritionPlans = <NutritionPlanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Refresh dashboard when shop ID is available
    if (myShopId.value != null && myShopId.value! > 0) {
      loadDashboard();
    }
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final res = await _repo.fetchDashboard();
      if (res != null) {
        dashboard.value = res;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Packages CRUD ---
  Future<void> loadPackages() async {
    isLoading.value = true;
    try {
      final list = await _repo.fetchPackages();
      packages.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPackage(Map<String, dynamic> data) async {
    final success = await _repo.createPackage(data);
    if (success) {
      Get.snackbar('Success', 'Package created successfully');
      loadPackages();
      loadDashboard(); // Update stats
    }
    return success;
  }

  Future<bool> updatePackage(int id, Map<String, dynamic> data) async {
    final success = await _repo.updatePackage(id, data);
    if (success) {
      Get.snackbar('Success', 'Package updated successfully');
      loadPackages();
    }
    return success;
  }

  Future<bool> deletePackage(int id) async {
    final success = await _repo.deletePackage(id);
    if (success) {
      Get.snackbar('Success', 'Package deleted successfully');
      loadPackages();
      loadDashboard();
    }
    return success;
  }

  // --- Templates CRUD ---
  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      final list = await _repo.fetchWorkoutTemplates();
      templates.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTemplate(Map<String, dynamic> data) async {
    final success = await _repo.createWorkoutTemplate(data);
    if (success) {
      Get.snackbar('Success', 'Template created successfully');
      loadTemplates();
    }
    return success;
  }

  Future<bool> updateTemplate(int id, Map<String, dynamic> data) async {
    final success = await _repo.updateWorkoutTemplate(id, data);
    if (success) {
      Get.snackbar('Success', 'Template updated successfully');
      loadTemplates();
    }
    return success;
  }

  Future<bool> deleteTemplate(int id) async {
    final success = await _repo.deleteWorkoutTemplate(id);
    if (success) {
      Get.snackbar('Success', 'Template deleted successfully');
      loadTemplates();
    }
    return success;
  }

  // --- Nutrition Plans CRUD ---
  Future<void> loadNutritionPlans() async {
    isLoading.value = true;
    try {
      final list = await _repo.fetchNutritionPlans();
      nutritionPlans.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createNutritionPlan(Map<String, dynamic> data) async {
    final success = await _repo.createNutritionPlan(data);
    if (success) {
      Get.snackbar('Success', 'Nutrition Plan created successfully');
      loadNutritionPlans();
    }
    return success;
  }

  Future<bool> updateNutritionPlan(int id, Map<String, dynamic> data) async {
    final success = await _repo.updateNutritionPlan(id, data);
    if (success) {
      Get.snackbar('Success', 'Nutrition Plan updated successfully');
      loadNutritionPlans();
    }
    return success;
  }

  Future<bool> deleteNutritionPlan(int id) async {
    final success = await _repo.deleteNutritionPlan(id);
    if (success) {
      Get.snackbar('Success', 'Nutrition Plan deleted successfully');
      loadNutritionPlans();
    }
    return success;
  }

  // --- Settings ---
  Future<void> updateCancellationPolicy({
    required bool enabled,
    String? text,
  }) async {
    final shopId = myShopId.value;
    if (shopId == null) return;

    final data = {
      'cancellation_policy_enabled': enabled,
      if (text != null) 'cancellation_policy_text': text,
    };

    final success = await _repo.updateShopSettings(shopId, data);
    if (success) {
      Get.snackbar('Success', 'Cancellation Policy updated');
      loadDashboard();
    } else {
      Get.snackbar('Error', 'Failed to update policy');
      // Revert UI state if needed, depending on how it's bound
    }
  }
}
