import 'dart:convert';
import 'dart:io';
import 'package:fidden/core/models/time_range.dart'; // NEW import
import 'package:fidden/core/models/response_data.dart';

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
    final error = _validateSchedule(schedule);
    if (error != null) {
      AppSnackBar.showError(error);
      return false;
    }

    isSaving.value = true;
    try {
      final url = AppUrls.updateProvider(providerId);

      // Serialize schedule with 24-hour time conversion
      Map<String, dynamic>? workingHours;
      if (schedule != null && schedule.isNotEmpty) {
        workingHours = {};
        schedule.forEach((k, v) {
          // Convert full day name (monday) to 3-letter (mon)
          final shortKey = k.length > 3
              ? k.substring(0, 3).toLowerCase()
              : k.toLowerCase();
          // Convert AM/PM times to 24-hour format for the API
          workingHours![shortKey] = v
              .map((r) => [_uiTo24(r.start), _uiTo24(r.end)])
              .toList();
        });
      }

      debugPrint('[updateProvider] URL: $url');
      debugPrint('[updateProvider] Working Hours (24h): $workingHours');

      late final ResponseData res;

      // Use multipart request if image is selected, otherwise use regular PATCH
      if (selectedImage.value != null) {
        // Don't include 'services' in body - use arrayFields instead
        final multipartBody = <String, String>{
          'name': name,
          'bio': bio,
          'max_concurrent_processing_jobs': maxConcurrentProcessingJobs
              .toString(),
          'is_active': 'true', // <-- Ensure active on update
          if (workingHours != null) 'working_hours': jsonEncode(workingHours),
        };

        // Convert serviceIds to List<String> for arrayFields
        final servicesAsStrings = serviceIds
            .map((id) => id.toString())
            .toList();

        debugPrint('[updateProvider] Multipart Body: $multipartBody');
        debugPrint(
          '[updateProvider] Services (arrayFields): $servicesAsStrings',
        );

        res = await NetworkCaller().multipartRequest(
          url,
          method: 'PATCH',
          body: multipartBody,
          token: AuthService.accessToken,
          photo: selectedImage.value,
          photoFieldName: 'profile_image',
          arrayFields: {'services': servicesAsStrings}, // NEW: use arrayFields
        );
      } else {
        final body = {
          'name': name,
          'bio': bio,
          'services': serviceIds,
          'max_concurrent_processing_jobs': maxConcurrentProcessingJobs,
          'is_active': true, // <-- Ensure active on update
          if (workingHours != null) 'working_hours': workingHours,
        };

        debugPrint('[updateProvider] Body: $body');

        res = await NetworkCaller().patchRequest(
          url,
          token: AuthService.accessToken,
          body: body,
        );
      }

      debugPrint('[updateProvider] isSuccess: ${res.isSuccess}');
      debugPrint('[updateProvider] errorMessage: ${res.errorMessage}');
      debugPrint('[updateProvider] responseData: ${res.responseData}');

      if (res.isSuccess) {
        selectedImage.value = null;
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
    Map<String, List<TimeRange>>? schedule,
    int maxConcurrentProcessingJobs = 1,
  }) async {
    final error = _validateSchedule(schedule);
    if (error != null) {
      AppSnackBar.showError(error);
      return false;
    }

    final profileC = Get.find<BusinessOwnerProfileController>();
    final shopId = profileC.profileDetails.value.data?.id;
    if (shopId == null) return false;

    isSaving.value = true;
    try {
      final url = AppUrls.createProvider(int.parse(shopId));

      // Serialize schedule to backend format with 24-hour time conversion
      Map<String, dynamic>? workingHours;
      if (schedule != null && schedule.isNotEmpty) {
        workingHours = {};
        schedule.forEach((k, v) {
          // Convert full day name (monday) to 3-letter (mon)
          final shortKey = k.length > 3
              ? k.substring(0, 3).toLowerCase()
              : k.toLowerCase();
          // Convert AM/PM times to 24-hour format for the API
          workingHours![shortKey] = v
              .map((r) => [_uiTo24(r.start), _uiTo24(r.end)])
              .toList();
        });
      }

      late final ResponseData res;

      // Use multipart request if image is selected, otherwise use regular POST
      if (selectedImage.value != null) {
        debugPrint('🔍 [addProvider] serviceIds raw: $serviceIds');
        debugPrint(
          '🔍 [addProvider] serviceIds type: ${serviceIds.runtimeType}',
        );

        // Don't include 'services' in body - use arrayFields instead
        final multipartBody = <String, String>{
          'name': name,
          'bio': bio,
          'max_concurrent_processing_jobs': maxConcurrentProcessingJobs
              .toString(),
          'is_active': 'true', // <-- Ensure active on creation
          if (workingHours != null) 'working_hours': jsonEncode(workingHours),
        };

        // Convert serviceIds to List<String> for arrayFields
        final servicesAsStrings = serviceIds
            .map((id) => id.toString())
            .toList();
        debugPrint('🔍 [addProvider] servicesAsStrings: $servicesAsStrings');

        debugPrint('🔍 [addProvider] Full multipartBody: $multipartBody');

        res = await NetworkCaller().multipartRequest(
          url,
          method: 'POST',
          body: multipartBody,
          token: AuthService.accessToken,
          photo: selectedImage.value,
          photoFieldName: 'profile_image',
          arrayFields: {'services': servicesAsStrings}, // NEW: use arrayFields
        );
      } else {
        final body = {
          'name': name,
          'bio': bio,
          'services': serviceIds,
          'max_concurrent_processing_jobs': maxConcurrentProcessingJobs,
          'is_active': true, // <-- Ensure active on creation
          if (workingHours != null) 'working_hours': workingHours,
        };

        res = await NetworkCaller().postRequest(
          url,
          token: AuthService.accessToken,
          body: body,
        );
      }

      if (res.isSuccess) {
        selectedImage.value = null;

        // CHECK: If inactive by default (as per logs), force activate immediately
        if (res.responseData is Map<String, dynamic>) {
          final data = res.responseData as Map<String, dynamic>;
          if (data['is_active'] == false) {
            final newId = data['id'];
            if (newId != null && newId is int) {
              await updateProvider(
                providerId: newId,
                name: name,
                bio: bio,
                serviceIds: serviceIds,
                schedule: schedule, // Pass schedule to ensure it persists
                maxConcurrentProcessingJobs: maxConcurrentProcessingJobs,
              );
            }
          }
        }

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

  /// Converts 12-hour AM/PM format to 24-hour format for the API.
  /// e.g., "1:45 PM" -> "13:45", "9:00 AM" -> "09:00"
  String _uiTo24(String ui) {
    final reg = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$',
      caseSensitive: false,
    );
    final m = reg.firstMatch(ui.trim());
    if (m == null) {
      // Already in 24-hour format or unknown format
      final m24 = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(ui.trim());
      if (m24 != null) {
        return '${m24.group(1)!.padLeft(2, '0')}:${m24.group(2)!}';
      }
      debugPrint('⚠️ [TeamController] Unknown time format: "$ui"');
      return ui;
    }
    int h = int.parse(m.group(1)!);
    final mm = m.group(2)!;
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12; // PM times: +12 (except 12 PM)
    if (ap == 'AM' && h == 12) h = 0; // 12 AM = 00
    return '${h.toString().padLeft(2, '0')}:$mm';
  }

  /// Returns total minutes from a 24-hour time string like "HH:mm"
  int _toMinutes(String t24) {
    final parts = t24.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  /// Validates all schedule ranges
  String? _validateSchedule(Map<String, List<TimeRange>>? schedule) {
    if (schedule == null) return null;
    for (var entry in schedule.entries) {
      for (var range in entry.value) {
        final start24 = _uiTo24(range.start);
        final end24 = _uiTo24(range.end);
        if (_toMinutes(end24) <= _toMinutes(start24)) {
          return 'Invalid interval on ${entry.key}: ${range.start} to ${range.end}. End time must be after start time.';
        }
      }
    }
    return null;
  }
}
