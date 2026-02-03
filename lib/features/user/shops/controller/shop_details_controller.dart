// lib/features/user/shops/controller/shop_details_controller.dart

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
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
  var selectedServiceId = Rxn<int>(); // Legacy: single service selection (kept for compatibility)

  // Multi-service selection for premium service rows
  final RxList<int> selectedServiceIds = <int>[].obs;

  // New state for service category selection
  var selectedServiceCategoryTabIndex = 0.obs;

  /// Toggle a service in/out of the selection
  void toggleService(int serviceId) {
    if (selectedServiceIds.contains(serviceId)) {
      selectedServiceIds.remove(serviceId);
    } else {
      selectedServiceIds.add(serviceId);
    }
    // Also update legacy single selection for backwards compatibility
    selectedServiceId.value = selectedServiceIds.isNotEmpty
        ? selectedServiceIds.first
        : null;
  }

  /// Check if a service is selected
  bool isServiceSelected(int serviceId) {
    return selectedServiceIds.contains(serviceId);
  }

  /// Get selected services data
  List<Service> get selectedServices {
    final allServices = shopDetails.value.services ?? [];
    return allServices
        .where((s) => s.id != null && selectedServiceIds.contains(s.id))
        .toList();
  }

  /// Calculate total price of selected services
  double get totalPrice {
    return selectedServices.fold(0.0, (sum, s) {
      final price = (s.discountPrice != null && s.discountPrice! > 0)
          ? s.discountPrice!
          : (s.price ?? 0);
      return sum + price;
    });
  }

  /// Calculate total duration of selected services in minutes
  int get totalDuration {
    return selectedServices.fold(0, (sum, s) => sum + (s.duration ?? 0));
  }

  /// Format duration for display: "30 min", "1h 15 min", etc.
  String get formattedDuration {
    final mins = totalDuration;
    if (mins < 60) return '$mins min';
    final hours = mins ~/ 60;
    final remainder = mins % 60;
    if (remainder == 0) return '${hours}h';
    return '${hours}h $remainder min';
  }

  // Get an instance of HomeController to access the category list (for fallback)
  HomeController? get _homeController =>
      Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
  List<CategoryModel> get categories => _homeController?.categories ?? [];

  // Get unique categories from the shop's services
  List<MapEntry<int, String>> get shopServiceCategories {
    final services = shopDetails.value.services ?? [];
    final cats = <int, String>{};
    for (final s in services) {
      if (s.categoryId != null && s.categoryName != null) {
        cats[s.categoryId!] = s.categoryName!;
      }
    }
    return cats.entries.toList();
  }

  // New getter to provide a filtered list of services
  List<Service> get filteredServices {
    final services = shopDetails.value.services ?? [];
    // If "All" is selected (index 0), return the full list
    if (selectedServiceCategoryTabIndex.value == 0) {
      return services;
    }

    // Get the shop's own category list
    final shopCats = shopServiceCategories;
    if (shopCats.isEmpty) return services;

    // Adjust index for "All" tab
    final catIndex = selectedServiceCategoryTabIndex.value - 1;
    if (catIndex < 0 || catIndex >= shopCats.length) return services;

    final selectedCategoryId = shopCats[catIndex].key;
    return services
        .where((service) => service.categoryId == selectedCategoryId)
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
        // Token is auto-fetched by NetworkCaller - do NOT pass it explicitly
        // so that on 401 retry, a fresh token is used.
      );

      if (response.isSuccess) {
        shopDetails.value = ShopDetailsModel.fromJson(response.responseData);
        shopDetails.refresh(); // make sure Obx rebuilds
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
