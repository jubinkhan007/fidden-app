import 'dart:io';
import 'package:get/get.dart';
import '../data/client_design_request_model.dart';
import '../services/client_design_request_service.dart';

/// Controller for client-side design request management
class ClientDesignRequestController extends GetxController {
  final ClientDesignRequestService _service = ClientDesignRequestService();

  final RxList<ClientDesignRequest> requests = <ClientDesignRequest>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyRequests();
  }

  /// Fetch all design requests for the current user
  Future<void> fetchMyRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      requests.value = await _service.getMyDesignRequests();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit a new design request
  Future<ClientDesignRequest?> submitRequest({
    required int shopId,
    required String description,
    int? bookingId,
    String? placement,
    String? sizeApprox,
    File? image, // New image parameter
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final request = await _service.createDesignRequest(
        shopId: shopId,
        description: description,
        bookingId: bookingId,
        placement: placement,
        sizeApprox: sizeApprox,
      );

      // Upload image if provided
      if (image != null) {
        try {
          await _service.uploadDesignImage(request.id, image);
        } catch (imageError) {
          // Log but don't fail the main request flow visibly to UI if possible,
          // or just append to error.
          print("Image upload failed: $imageError");
          // optional: errorMessage.value = "Request created but image failed.";
        }
      }

      // Add to local list
      requests.insert(0, request);

      return request;
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update an existing design request
  Future<bool> updateRequest({
    required int id,
    String? description,
    String? placement,
    String? sizeApprox,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final updated = await _service.updateDesignRequest(
        id: id,
        description: description,
        placement: placement,
        sizeApprox: sizeApprox,
      );

      // Update in local list
      final index = requests.indexWhere((r) => r.id == id);
      if (index >= 0) {
        requests[index] = updated;
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete a design request
  Future<bool> deleteRequest(int id) async {
    try {
      await _service.deleteDesignRequest(id);
      requests.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  /// Get requests by status
  List<ClientDesignRequest> getRequestsByStatus(String status) {
    return requests.where((r) => r.status == status).toList();
  }

  /// Get pending requests count
  int get pendingCount => requests.where((r) => r.isPending).length;

  /// Get approved requests count
  int get approvedCount => requests.where((r) => r.isApproved).length;
}
