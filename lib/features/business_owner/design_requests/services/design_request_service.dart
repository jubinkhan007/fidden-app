import 'package:dio/dio.dart';
import '../data/design_request_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class DesignRequestService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get all design requests for the current shop
  Future<List<DesignRequest>> getDesignRequests({String? status}) async {
    String url = AppUrls.designRequests;
    if (status != null) {
      url = '$url?status=$status';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((item) => DesignRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch design requests');
  }

  /// Approve a design request
  Future<DesignRequest> approveDesignRequest(int id) async {
    final response = await _networkCaller.patchRequest(
      '${AppUrls.designRequests}$id/',
      body: {'status': 'approved'},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return DesignRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to approve design request');
  }

  /// Reject a design request
  Future<DesignRequest> rejectDesignRequest(int id) async {
    final response = await _networkCaller.patchRequest(
      '${AppUrls.designRequests}$id/',
      body: {'status': 'rejected'},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return DesignRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to reject design request');
  }
}
