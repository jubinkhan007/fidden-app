import 'package:get/get.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/utils/constants/api_constants.dart';

class ServiceManagementController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final RxList<dynamic> services = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _networkCaller.getRequest(
        AppUrls.getMyService,
        token: AuthService.accessToken,
      );

      if (response.isSuccess && response.responseData is List) {
        services.value = response.responseData;
      } else {
        throw Exception('Failed to fetch services');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createService({
    required String name,
    required String description,
    required double price,
    required int duration,
    required int category,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final body = {
        'name': name,
        'description': description,
        'price': price,
        'duration': duration,
        'category': category,
        'is_active': true,
      };

      final response = await _networkCaller.postRequest(
        AppUrls.createService,
        body: body,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        await fetchServices(); // Refresh list
        Get.back(); // Close create screen
        Get.snackbar('Success', 'Service created successfully');
      } else {
        throw Exception('Failed to create service');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to create service');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService({
    required int id,
    String? name,
    String? description,
    double? price,
    int? duration,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;
      if (duration != null) body['duration'] = duration;
      if (isActive != null) body['is_active'] = isActive;

      final response = await _networkCaller.patchRequest(
        AppUrls.updateService(id.toString()),
        body: body,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        await fetchServices(); // Refresh list
        Get.back(); // Close edit screen
        Get.snackbar('Success', 'Service updated successfully');
      } else {
        throw Exception('Failed to update service');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update service');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _networkCaller.deleteRequest(
        AppUrls.deleteService(id.toString()),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        services.removeWhere((service) => service['id'] == id);
        Get.snackbar('Success', 'Service deleted successfully');
      } else {
        throw Exception('Failed to delete service');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to delete service');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleServiceStatus(int id, bool currentStatus) async {
    await updateService(id: id, isActive: !currentStatus);
  }
}
