import 'package:get/get.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/user_booking_model.dart';
import '../presentation/screens/shop_model.dart';

class BookingController extends GetxController {
  var isActiveBooking = true.obs;
  var shopList = <ShopModel>[].obs;
  @override
  void onInit() {
    fetchUserBooking();
    fetchUserCompleteBooking();

    super.onInit();
  }

  void toggleTab(bool isActive) {
    isActiveBooking.value = isActive;
  }

  var isLoading = false.obs;

  var allUserBookingDetails = GetUserBookingModel().obs;

  Future<void> fetchUserBooking() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.activeBooking,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          allUserBookingDetails.value = GetUserBookingModel.fromJson(
            response.responseData,
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

  var inProgress = false.obs;

  var allUserCompleteBookingDetails = GetUserBookingModel().obs;

  Future<void> fetchUserCompleteBooking() async {
    inProgress.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.completeBooking,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          allUserCompleteBookingDetails.value = GetUserBookingModel.fromJson(
            response.responseData,
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      // Handle exceptions
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      inProgress.value = false;
    }
  }
}
