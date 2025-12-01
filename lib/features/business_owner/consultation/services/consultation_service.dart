import '../data/consultation_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class ConsultationService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get all consultations with optional filters
  Future<List<Consultation>> getConsultations({
    String? dateFrom,
    String? dateTo,
    String? status,
  }) async {
    String url = AppUrls.consultations;
    final queryParams = <String>[];
    
    if (dateFrom != null) queryParams.add('date_from=$dateFrom');
    if (dateTo != null) queryParams.add('date_to=$dateTo');
    if (status != null) queryParams.add('status=$status');
    
    if (queryParams.isNotEmpty) {
      url = '$url?${queryParams.join('&')}';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((item) => Consultation.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch consultations');
  }

  /// Create a new consultation
  Future<Consultation> createConsultation({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String date,
    required String time,
    required int durationMinutes,
    String? notes,
  }) async {
    final body = {
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'date': date,
      'time': time,
      'duration_minutes': durationMinutes,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _networkCaller.postRequest(
      AppUrls.consultations,
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return Consultation.fromJson(response.responseData);
    }

    throw Exception('Failed to create consultation');
  }

  /// Update a consultation
  Future<Consultation> updateConsultation({
    required int id,
    String? date,
    String? time,
    int? durationMinutes,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (date != null) body['date'] = date;
    if (time != null) body['time'] = time;
    if (durationMinutes != null) body['duration_minutes'] = durationMinutes;
    if (notes != null) body['notes'] = notes;

    final response = await _networkCaller.patchRequest(
      '${AppUrls.consultations}$id/',
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return Consultation.fromJson(response.responseData);
    }

    throw Exception('Failed to update consultation');
  }

  /// Delete a consultation
  Future<void> deleteConsultation(int id) async {
    final response = await _networkCaller.deleteRequest(
      '${AppUrls.consultations}$id/',
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete consultation');
    }
  }

  /// Confirm a consultation
  Future<Consultation> confirmConsultation(int id) async {
    final response = await _networkCaller.postRequest(
      '${AppUrls.consultations}$id/confirm/',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return Consultation.fromJson(response.responseData);
    }

    throw Exception('Failed to confirm consultation');
  }

  /// Complete a consultation
  Future<Consultation> completeConsultation(int id, {String? notes}) async {
    final body = notes != null ? {'notes': notes} : null;
    
    final response = await _networkCaller.postRequest(
      '${AppUrls.consultations}$id/complete/',
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return Consultation.fromJson(response.responseData);
    }

    throw Exception('Failed to complete consultation');
  }

  /// Cancel a consultation
  Future<Consultation> cancelConsultation(int id) async {
    final response = await _networkCaller.postRequest(
      '${AppUrls.consultations}$id/cancel/',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return Consultation.fromJson(response.responseData);
    }

    throw Exception('Failed to cancel consultation');
  }

  /// Mark consultation as no-show
  Future<Consultation> markNoShow(int id) async {
    final response = await _networkCaller.postRequest(
      '${AppUrls.consultations}$id/mark_no_show/',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return Consultation.fromJson(response.responseData);
    }

    throw Exception('Failed to mark as no-show');
  }
}
