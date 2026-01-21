import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/core/services/Auth_service.dart';
import '../model/fitness_trainer_models.dart';

class FitnessTrainerRepository {
  final NetworkCaller _networkCaller = NetworkCaller();

  Future<FitnessDashboardModel?> fetchDashboard() async {
    final response = await _networkCaller.getRequest(
      AppUrls.fitnessDashboard,
      token: AuthService.accessToken,
    );
    if (response.isSuccess && response.responseData != null) {
      return FitnessDashboardModel.fromJson(response.responseData);
    }
    return null;
  }

  // --- Packages ---
  Future<List<FitnessPackageModel>> fetchPackages() async {
    final response = await _networkCaller.getRequest(
      AppUrls.fitnessPackages,
      token: AuthService.accessToken,
      treat404AsEmpty: true,
      emptyPayload: [],
    );
    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => FitnessPackageModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<bool> createPackage(Map<String, dynamic> data) async {
    final response = await _networkCaller.postRequest(
      AppUrls.fitnessPackages,
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  Future<bool> updatePackage(int id, Map<String, dynamic> data) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.fitnessPackageDetail(id),
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  Future<bool> deletePackage(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.fitnessPackageDetail(id),
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  // --- Workout Templates ---
  Future<List<WorkoutTemplateModel>> fetchWorkoutTemplates() async {
    final response = await _networkCaller.getRequest(
      AppUrls.workoutTemplates,
      token: AuthService.accessToken,
      treat404AsEmpty: true,
      emptyPayload: [],
    );
    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => WorkoutTemplateModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<bool> createWorkoutTemplate(Map<String, dynamic> data) async {
    final response = await _networkCaller.postRequest(
      AppUrls.workoutTemplates,
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  Future<bool> updateWorkoutTemplate(int id, Map<String, dynamic> data) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.workoutTemplateDetail(id),
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  Future<bool> deleteWorkoutTemplate(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.workoutTemplateDetail(id),
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  // --- Nutrition Plans ---
  Future<List<NutritionPlanModel>> fetchNutritionPlans() async {
    final response = await _networkCaller.getRequest(
      AppUrls.nutritionPlans,
      token: AuthService.accessToken,
      treat404AsEmpty: true,
      emptyPayload: [],
    );
    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => NutritionPlanModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<bool> createNutritionPlan(Map<String, dynamic> data) async {
    final response = await _networkCaller.postRequest(
      AppUrls.nutritionPlans,
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  Future<bool> updateNutritionPlan(int id, Map<String, dynamic> data) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.nutritionPlanDetail(id),
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  Future<bool> deleteNutritionPlan(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.nutritionPlanDetail(id),
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }

  // --- Shop Settings (Cancellation Policy) ---
  Future<bool> updateShopSettings(int shopId, Map<String, dynamic> data) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.editBusinessProfile(shopId.toString()),
      body: data,
      token: AuthService.accessToken,
    );
    return response.isSuccess;
  }
}
