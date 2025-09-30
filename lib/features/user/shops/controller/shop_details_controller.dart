import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/home/data/category_model.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:get/get.dart';

import '../../home/controller/home_controller.dart';

class ShopDetailsController extends GetxController {
  var isLoading = false.obs;
  var shopDetails = ShopDetailsModel().obs;
  var selectedTab = 0.obs;
  var selectedServiceId = Rxn<int>(); // To track the selected service

  // New state for service category selection
  var selectedServiceCategoryTabIndex = 0.obs;

  // Get an instance of HomeController to access the category list
  final HomeController _homeController = Get.find<HomeController>();
  List<CategoryModel> get categories => _homeController.categories;

  // New getter to provide a filtered list of services
  List<Service> get filteredServices {
    // If "All" is selected (index 0), return the full list
    if (selectedServiceCategoryTabIndex.value == 0) {
      return shopDetails.value.services ?? [];
    }
    // Otherwise, find the selected category ID (adjusting for the "All" tab)
    final selectedCategory =
        categories[selectedServiceCategoryTabIndex.value - 1];
    // Filter the services list to match the selected category
    return (shopDetails.value.services ?? [])
        .where((service) => service.categoryId == selectedCategory.id)
        .toList();
  }

  /// Selects the main tab (Services, About, Review).
  void selectTab(int index) {
    selectedTab.value = index;
  }

  /// Selects a service category tab.
  void selectServiceCategoryTab(int index) {
    selectedServiceCategoryTabIndex.value = index;
  }

  /// Fetches the complete details for a specific shop.
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