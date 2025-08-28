import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:get/get.dart';

class ShopDetailsController extends GetxController {
  var isLoading = false.obs;
  var shopDetails = ShopDetailsModel().obs;
  var selectedTab = 0.obs;

  void selectTab(int index) {
    selectedTab.value = index;
  }

  Future<void> fetchShopDetails(String id) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.shopDetails(id),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        shopDetails.value = ShopDetailsModel.fromJson(response.responseData);
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? 'Failed to fetch shop details.',
        );
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
