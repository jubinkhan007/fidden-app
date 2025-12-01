import 'package:dio/dio.dart';
import '../data/id_verification_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class IDVerificationService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get all ID verification requests
  Future<List<IDVerificationRequest>> getIDVerifications({String? status}) async {
    String url = AppUrls.idVerification;
    if (status != null) {
      url = '$url?status=$status';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((item) => IDVerificationRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch ID verifications');
  }

  /// Approve an ID verification
  Future<IDVerificationRequest> approveID(int id) async {
    final response = await _networkCaller.patchRequest(
      '${AppUrls.idVerification}$id/',
      body: {'status': 'approved'},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return IDVerificationRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to approve ID verification');
  }

  /// Reject an ID verification
  Future<IDVerificationRequest> rejectID(int id, String reason) async {
    final response = await _networkCaller.patchRequest(
      '${AppUrls.idVerification}$id/',
      body: {
        'status': 'rejected',
        'rejection_reason': reason,
      },
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return IDVerificationRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to reject ID verification');
  }
}
