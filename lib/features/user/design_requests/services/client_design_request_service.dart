import 'dart:io';
import '../data/client_design_request_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

/// Service for client-side design request operations
class ClientDesignRequestService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Submit a new design request to a shop
  Future<ClientDesignRequest> createDesignRequest({
    required int shopId,
    required String description,
    int? bookingId,
    String? placement,
    String? sizeApprox,
  }) async {
    final body = <String, dynamic>{
      'shop': shopId,
      'description': description,
      if (bookingId != null) 'booking': bookingId,
      if (placement != null && placement.isNotEmpty) 'placement': placement,
      if (sizeApprox != null && sizeApprox.isNotEmpty)
        'size_approx': sizeApprox,
    };

    final response = await _networkCaller.postRequest(
      AppUrls.designRequests,
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ClientDesignRequest.fromJson(response.responseData);
    }

    throw Exception(
      'Failed to submit design request: ${response.errorMessage}',
    );
  }

  /// Upload a reference image for a design request
  Future<void> uploadDesignImage(int id, File image) async {
    final response = await _networkCaller.multipartRequest(
      AppUrls.designRequestImages(id),
      body: {},
      photo: image,
      photoFieldName: 'image',
    );

    if (!response.isSuccess) {
      throw Exception('Failed to upload image: ${response.errorMessage}');
    }
  }

  /// Get all design requests submitted by the current user
  Future<List<ClientDesignRequest>> getMyDesignRequests() async {
    final response = await _networkCaller.getRequest(
      AppUrls.designRequests,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map(
            (item) =>
                ClientDesignRequest.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception('Failed to fetch design requests');
  }

  /// Get a single design request by ID
  Future<ClientDesignRequest> getDesignRequest(int id) async {
    final response = await _networkCaller.getRequest(
      '${AppUrls.designRequests}$id/',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ClientDesignRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch design request');
  }

  /// Update a pending design request
  Future<ClientDesignRequest> updateDesignRequest({
    required int id,
    String? description,
    String? placement,
    String? sizeApprox,
  }) async {
    final body = <String, dynamic>{};
    if (description != null) body['description'] = description;
    if (placement != null) body['placement'] = placement;
    if (sizeApprox != null) body['size_approx'] = sizeApprox;

    final response = await _networkCaller.patchRequest(
      '${AppUrls.designRequests}$id/',
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ClientDesignRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to update design request');
  }

  /// Delete a design request
  Future<void> deleteDesignRequest(int id) async {
    final response = await _networkCaller.deleteRequest(
      '${AppUrls.designRequests}$id/',
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete design request');
    }
  }
}
