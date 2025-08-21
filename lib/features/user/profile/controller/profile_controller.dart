import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/get_my_profile_model.dart';

class ProfileController extends GetxController {
  var profileImage = Rxn<File>();
  var imagePath = ''.obs;

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
    // TODO: implement onInit
    fetchProfileDetails();
    super.onInit();
  }

  var isLoading = false.obs;
  var profileDetails = GetMyProfileModel().obs;

  // Function to fetch course details
  Future<void> fetchProfileDetails() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getMyProfile,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          // 1. Directly parse the response into the Data object.
          final data = Data.fromJson(response.responseData);

          // 2. Manually construct the parent GetMyProfileModel.
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
