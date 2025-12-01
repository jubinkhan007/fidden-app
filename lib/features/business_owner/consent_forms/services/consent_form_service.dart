import 'package:dio/dio.dart';
import '../data/consent_form_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class ConsentFormService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get all consent form templates
  Future<List<ConsentFormTemplate>> getTemplates() async {
    final response = await _networkCaller.getRequest(
      AppUrls.consentTemplates,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((item) => ConsentFormTemplate.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch consent templates');
  }

  /// Get all signed consent forms
  Future<List<SignedConsentForm>> getSignedForms() async {
    final response = await _networkCaller.getRequest(
      AppUrls.signedConsents,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((item) => SignedConsentForm.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch signed consents');
  }
}
