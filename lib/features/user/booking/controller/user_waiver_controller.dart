import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:io';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../home/data/get_form_model.dart';

class UserWaiverBookingController extends GetxController {
  final firstNameTEController = TextEditingController();
  final lastNameTEController = TextEditingController();
  final emailTEController = TextEditingController();
  final phoneTEController = TextEditingController();
  final addressTEController = TextEditingController();
  final cityTEController = TextEditingController();
  final stateTEController = TextEditingController();
  final postalCodeTEController = TextEditingController();

  var isLoading = false.obs;
  var waiverDetails = GetMyForm().obs;

  // Function to fetch course details
  Future<void> fetchWaiverDetails(String businessId) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getWaiverFormCreate(businessId),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          waiverDetails.value = GetMyForm.fromJson(response.responseData);
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

  var selectedItem = ''.obs;

  final List<String> dropdownItems = [
    'Skin Conditions',
    'Allergies',
    'Heart Conditions',
    'High/Low Blood Pressure',
    'Diabetes',
    'Epilepsy/Seizures',
    'Pregnancy',
    'Recent Surgery',
    'Immune Disorders',
    'None',
  ];

  var isChecked = false.obs;

  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
  }

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  var signatureImage = Rx<Uint8List?>(null);

  SignatureController get signatureController => _signatureController;

  void clearSignature() {
    _signatureController.clear();
    signatureImage.value = null;
  }

  Future<void> saveSignature() async {
    final image = await _signatureController.toPngBytes();
    if (image != null) {
      signatureImage.value = image;
      AppSnackBar.showSuccess('Signature saved successfully');
    } else {
      AppSnackBar.showError('No signature to save');
    }
  }

  Future<void> createForm({
    required String bookingId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String postalCode,
  }) async {
    isLoading.value = true;

    final Uint8List? imageBytes = signatureImage.value;
    if (imageBytes == null) {
      Get.snackbar('Error', 'Please provide a signature');
      isLoading.value = false;
      return;
    }

    // Save signature to temp file
    final File imageFile = await _saveImageToFile(imageBytes);

    Map<String, dynamic> requestBody = {
      "bookingId": bookingId,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "state": state,
      "postalCode": int.parse(postalCode),
      "medicalHistory": selectedItem.value,
    };

    try {
      await _sendPutRequestWithHeadersAndImagesOnly(
        AppUrls.createCustomerForm,
        requestBody,
        imageFile.path,
        AuthService.accessToken,
      );
    } catch (e) {
      log('Error updating profile: $e');
      AppSnackBar.showError('Failed to upload form. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<File> _saveImageToFile(Uint8List imageBytes) async {
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(imageBytes);
    return file;
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
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      request.fields['bodyData'] = jsonEncode(body);

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'customerFormImage', // Make sure your API expects this key
            imagePath,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.toNamed(AppRoute.bookingSuccessFullScreen);
        AppSnackBar.showSuccess('Form submitted successfully!');
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError('Failed to submit form.');
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError('Failed to submit form. Please try again.');
    }
  }

  @override
  void onClose() {
    _signatureController.dispose();
    super.onClose();
  }
}
