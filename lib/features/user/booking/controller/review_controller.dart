import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  var isSubmitting = false.obs;

  Future<bool> submitReview({
    required int shopId,
    required int bookingId,
    required int serviceId,
    required double rating,
    required String review,
  }) async {
    isSubmitting.value = true;
    try {
      final response = await NetworkCaller().postRequest(
        AppUrls.createReview, // Ensure this is the correct endpoint
        token: AuthService.accessToken,
        body: {
          "shop": shopId,
          "booking_id": bookingId,
          "service": serviceId,
          "rating": rating,
          "review": review,
          "review_img": null,
        },
      );
      if (response.isSuccess) {
        AppSnackBar.showSuccess("Review submitted successfully!");
        return true;
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? "Failed to submit review.2",
        );
        return false;
      }
    } catch (e) {
      AppSnackBar.showError("An error occurred: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}