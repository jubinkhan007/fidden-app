import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/design_requests/data/design_request_model.dart';
import 'package:get/get.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';

class DesignRequestController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<DesignRequest> designRequests = <DesignRequest>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDesignRequests();
  }

  Future<void> fetchDesignRequests() async {
    try {
      isLoading(true);
      final response = await NetworkCaller().getRequest(AppUrls.designRequests);

      if (response.isSuccess) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        designRequests.value = data
            .map((json) => DesignRequest.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (response.statusCode != 401) {
          AppSnackBar.showError('Failed to load design requests');
        }
      }
    } catch (e) {
      AppSnackBar.showError('Error loading design requests: \$e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      final response = await NetworkCaller().patchRequest(
        AppUrls.designRequest(id),
        body: {'status': status},
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess('Status updated to \$status');
        await fetchDesignRequests();
      } else {
        AppSnackBar.showError('Failed to update status');
      }
    } catch (e) {
      AppSnackBar.showError('Error: \$e');
    }
  }
}
