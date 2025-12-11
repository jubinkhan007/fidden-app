import 'dart:developer';
import 'dart:io';

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/get_my_profile_model.dart';

class ProfileController extends GetxController {
  var profileImage = Rxn<File>();
  var imagePath = ''.obs;
  
  // Observable fields for profile data
  final profileDetails = GetMyProfileModel().obs;
  final isLoading = false.obs;
  
  // DEPRECATED: Single niche for backward compat
  final RxString shopNiche = ''.obs;
  
  // NEW: Multi-niche support
  final RxList<String> shopNiches = <String>[].obs;

  // Method to pick profile image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      imagePath.value = pickedFile.path;
      // updateProfilePhoto();
    }
  }

  @override
  void onInit() {
    super.onInit();
    log('🟢 ProfileController onInit called');
    fetchProfileDetails();
    
    // Re-fetch profile when token refreshes to ensure data is loaded with valid token
    ever(AuthService.tokenRefreshCount, (_) async {
      log('🔄 ProfileController: Token refreshed, re-fetching profile');
      await fetchProfileDetails();
    });
  }

  @override
  void onClose() {
    log('🔴 ProfileController onClose called');
    super.onClose();
  }

  // Function to fetch profile details
  Future<void> fetchProfileDetails() async {
    isLoading.value = true;
    try {
      // Try to load from cache first to avoid empty state
      await _loadCachedNiches();

      final response = await NetworkCaller().getRequest(
        AppUrls.getMyProfile,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          // 1. Directly parse the response into the Data object.
          final data = Data.fromJson(response.responseData);

          // 2. Handle multi-niche support with backward compatibility
          if (data.shopNiches != null && data.shopNiches!.isNotEmpty) {
            // Use new shop_niches array
            shopNiches.value = data.shopNiches!;
            log('🔍 API returned shop_niches: ${data.shopNiches}'); // DEBUG LOG
            
            // Cache the niches
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('cached_shop_niches', data.shopNiches!);

            // Load persisted selection or default to first
            final savedNiche = prefs.getString('selected_niche');
            
            if (savedNiche != null && shopNiches.contains(savedNiche)) {
              shopNiche.value = savedNiche;
            } else {
              shopNiche.value = data.shopNiches!.first;
            }
          } else if (data.shopNiche != null && data.shopNiche!.isNotEmpty) {
            // Fallback to old shop_niche field
            shopNiches.value = [data.shopNiche!];
            shopNiche.value = data.shopNiche!;
            
            // Cache fallback value
            final prefs = await SharedPreferences.getInstance();
            await prefs.setStringList('cached_shop_niches', shopNiches);
            if (prefs.getString('selected_niche') == null) {
               await prefs.setString('selected_niche', shopNiche.value);
            }
          } else if (shopNiche.value.isNotEmpty) {
            // Preserve existing value from login
            if (shopNiches.isEmpty) {
              shopNiches.value = [shopNiche.value];
            }
          }

          // 3. Manually construct the parent GetMyProfileModel.
          profileDetails.value = GetMyProfileModel(
            success: true,
            statusCode: response.statusCode,
            message: "Profile loaded successfully",
            data: data,
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      // Handle exceptions
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadCachedNiches() async {
    if (shopNiches.isNotEmpty) return; // Already loaded

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList('cached_shop_niches');
      final savedNiche = prefs.getString('selected_niche');

      if (cached != null && cached.isNotEmpty) {
        shopNiches.value = cached;
        log('📦 Loaded cached shop_niches: $cached');
        
        if (savedNiche != null && cached.contains(savedNiche)) {
          shopNiche.value = savedNiche;
        } else {
          shopNiche.value = cached.first;
        }
      }
    } catch (e) {
      log('Error loading cached niches: $e');
    }
  }

  // Set primary niche and persist preference
  Future<void> setPrimaryNiche(String niche) async {
    if (shopNiches.contains(niche)) {
      shopNiche.value = niche;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_niche', niche);
      log('Switched dashboard to niche: $niche');
      update(); // Trigger UI updates
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String mobileNumber,
  }) async {
    isLoading.value = true;
    Map<String, dynamic> requestBody = {
      "name": name,
      "email": email,
      "mobile_number": mobileNumber,
    };

    try {
      await _sendPutRequestWithHeadersAndImagesOnly(
        AppUrls.updateProfile,
        requestBody,
        imagePath.value,
        AuthService.accessToken,
      );
    } catch (e) {
      log('Error updating profile: $e');
      AppSnackBar.showError('Failed to update profile. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendPutRequestWithHeadersAndImagesOnly(
    String url,
    Map<String, dynamic> body,
    String? imagePath,
    String? token,
  ) async {
    if (token == null || token.isEmpty) {
      AppSnackBar.showError('Token is invalid or expired.');

      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      request.headers.addAll({'Authorization': 'Bearer $token'});

      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imagePath),
        );
      }

      log('Request Headers: ${request.headers}');
      log('Request Fields: ${request.fields}');

      var response = await request.send();
      debugPrint("----------------------------------------------------------");

      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 1. Fetch the new profile details FIRST to get the updated image URL
        await fetchProfileDetails();

        // 2. NOW, get the correct image URL from the updated data
        final newImageUrl = profileDetails.value.data?.image;

        // 3. Clear the correct image from the cache
        if (newImageUrl != null && newImageUrl.isNotEmpty) {
          final imageProvider = NetworkImage(newImageUrl);
          await imageProvider.evict();
        }

        // (Optional) Call again to ensure the UI rebuilds with the evicted image
        await fetchProfileDetails();
        AppSnackBar.showSuccess('Update Profile successfully!');
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError('Failed to upload profile. Please try again.');
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError('An error occurred: $e');
    }
  }
}
