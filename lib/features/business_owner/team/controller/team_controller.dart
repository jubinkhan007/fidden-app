import 'dart:io';
import 'package:fidden/core/models/time_range.dart'; // NEW import

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:fidden/features/user/shops/data/provider_model.dart';
import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TeamController extends GetxController {
  final providers = <Provider>[].obs;
  final availableServices = <GetMyServiceModel>[].obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  // For Add/Edit form
  final selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchTeam();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final res = await NetworkCaller().getRequest(
        AppUrls.getMyService,
        token: AuthService.accessToken,
      );
      if (res.isSuccess) {
        final list = <GetMyServiceModel>[];
        // Handle diverse backend responses
        if (res.responseData is List) {
          list.addAll(
            (res.responseData as List)
                .map((e) => GetMyServiceModel.fromJson(e))
                .toList(),
          );
        } else if (res.responseData is Map) {
          final data = res.responseData as Map<String, dynamic>;
          final raw = data['data'] ?? data['results'] ?? [];
          if (raw is List) {
            list.addAll(raw.map((e) => GetMyServiceModel.fromJson(e)).toList());
          }
        }
        availableServices.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    }
  }

  Future<void> fetchTeam() async {
    final profileC = Get.find<BusinessOwnerProfileController>();
    final shopId = profileC.profileDetails.value.data?.id;
    if (shopId == null) return;

    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final url = AppUrls.shopProviders(int.parse(shopId));
      final res = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (res.isSuccess) {
        final list = <Provider>[];
        if (res.responseData is List) {
          list.addAll(
            (res.responseData as List)
                .map((e) => Provider.fromJson(e))
                .toList(),
          );
        } else if (res.responseData is Map) {
          final data = res.responseData as Map<String, dynamic>;
          final rawList =
              data['providers'] ?? data['data'] ?? data['results'] ?? [];
          if (rawList is List) {
            list.addAll(rawList.map((e) => Provider.fromJson(e)).toList());
          }
        }
        providers.assignAll(list);
      }
    } catch (e) {
      debugPrint('Error fetching team: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProvider({
    required int providerId,
    required String name,
    required String bio,
    required List<int> serviceIds,
    Map<String, List<TimeRange>>? schedule,
    int maxConcurrentProcessingJobs = 1,
  }) async {
    isSaving.value = true;
    try {
      final url = AppUrls.updateProvider(providerId);

      // Serialize schedule
      Map<String, dynamic>? workingHours;
      if (schedule != null && schedule.isNotEmpty) {
        workingHours = {};
        workingHours = {};
        schedule.forEach((k, v) {
          // Convert full day name (monday) to 3-letter (mon)
          final shortKey = k.length > 3
              ? k.substring(0, 3).toLowerCase()
              : k.toLowerCase();
          workingHours![shortKey] = v.map((r) => [r.start, r.end]).toList();
        });
      }

      final body = {
        'name': name,
        'bio': bio,
        'services': serviceIds,
        'max_concurrent_processing_jobs': maxConcurrentProcessingJobs,
        if (workingHours != null) 'working_hours': workingHours,
      };

      debugPrint('[updateProvider] URL: $url');
      debugPrint('[updateProvider] Body: $body');

      final res = await NetworkCaller().patchRequest(
        url,
        token: AuthService.accessToken,
        body: body,
      );

      debugPrint('[updateProvider] isSuccess: ${res.isSuccess}');
      debugPrint('[updateProvider] errorMessage: ${res.errorMessage}');
      debugPrint('[updateProvider] responseData: ${res.responseData}');

      if (res.isSuccess) {
        await fetchTeam();
        return true;
      } else {
        AppSnackBar.showError(res.errorMessage);
        return false;
      }
    } catch (e) {
      debugPrint('[updateProvider] Exception: $e');
      AppSnackBar.showError('Error updating provider: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> addProvider({
    required String name,
    required String bio,
    required List<int> serviceIds,
    Map<String, List<TimeRange>>? schedule, // CHANGED to TimeRange
    int maxConcurrentProcessingJobs = 1,
  }) async {
    final profileC = Get.find<BusinessOwnerProfileController>();
    final shopId = profileC.profileDetails.value.data?.id;
    if (shopId == null) return false;

    isSaving.value = true;
    try {
      final url = AppUrls.createProvider(int.parse(shopId));

      // Serialize schedule to backend format: {'monday': [['09:00 AM', '05:00 PM']]}
      Map<String, dynamic>? workingHours;
      if (schedule != null && schedule.isNotEmpty) {
        workingHours = {};
        schedule.forEach((k, v) {
          // Convert full day name (monday) to 3-letter (mon)
          final shortKey = k.length > 3
              ? k.substring(0, 3).toLowerCase()
              : k.toLowerCase();
          workingHours![shortKey] = v.map((r) => [r.start, r.end]).toList();
        });
      }

      final body = {
        'name': name,
        'bio': bio,
        'services': serviceIds,
        'max_concurrent_processing_jobs': maxConcurrentProcessingJobs,
        if (workingHours != null) 'working_hours': workingHours,
      };

      final res = await NetworkCaller().postRequest(
        url,
        token: AuthService.accessToken,
        body: body,
      );

      if (res.isSuccess) {
        // TODO: Image upload logic if supported (separate endpoint or multipart)
        await fetchTeam();
        return true;
      } else {
        AppSnackBar.showError(res.errorMessage);
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error adding provider: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteProvider(int providerId) async {
    try {
      final url = AppUrls.deleteProvider(providerId);
      final res = await NetworkCaller().deleteRequest(
        url,
        token: AuthService.accessToken,
      );
      if (res.isSuccess) {
        providers.removeWhere((p) => p.id == providerId);
        return true;
      } else {
        AppSnackBar.showError(res.errorMessage);
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error removing provider: $e');
      return false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      selectedImage.value = File(xFile.path);
    }
  }

  void clearForm() {
    selectedImage.value = null;
  }
}
