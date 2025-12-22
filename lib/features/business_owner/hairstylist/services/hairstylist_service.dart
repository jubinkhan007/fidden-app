import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import '../data/hairstylist_models.dart';

/// Service for Hairstylist/Loctician API calls
class HairstylistService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get dashboard summary metrics
  Future<HairstylistDashboard> getDashboard() async {
    final response = await _networkCaller.getRequest(
      AppUrls.hairstylistDashboard,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return HairstylistDashboard.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch hairstylist dashboard');
  }

  /// Get weekly schedule with appointments
  Future<WeeklyScheduleResponse> getWeeklySchedule({int days = 7}) async {
    final response = await _networkCaller.getRequest(
      '${AppUrls.hairstylistWeeklySchedule}?days=$days',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return WeeklyScheduleResponse.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch weekly schedule');
  }

  /// Get appointments with prep notes
  Future<List<PrepNoteItem>> getPrepNotes() async {
    final response = await _networkCaller.getRequest(
      AppUrls.hairstylistPrepNotes,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      final appointments = response.responseData['appointments'] as List? ?? [];
      return appointments.map((e) => PrepNoteItem.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch prep notes');
  }

  /// Update prep notes for a booking
  Future<void> updatePrepNotes(int bookingId, String notes) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.hairstylistPrepNotes,
      body: {'booking_id': bookingId, 'prep_notes': notes},
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to update prep notes');
    }
  }

  /// Get all client hair profiles
  Future<List<ClientHairProfile>> getClientProfiles() async {
    final response = await _networkCaller.getRequest(
      AppUrls.hairstylistClientProfiles,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => ClientHairProfile.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch client profiles');
  }

  /// Get a single client profile
  Future<ClientHairProfile> getClientProfile(int id) async {
    final response = await _networkCaller.getRequest(
      AppUrls.hairstylistClientProfileDetail(id),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ClientHairProfile.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch client profile');
  }

  /// Create a new client profile
  Future<ClientHairProfile> createClientProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.postRequest(
      AppUrls.hairstylistClientProfiles,
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ClientHairProfile.fromJson(response.responseData);
    }
    throw Exception('Failed to create client profile');
  }

  /// Update a client profile
  Future<ClientHairProfile> updateClientProfile(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.hairstylistClientProfileDetail(id),
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ClientHairProfile.fromJson(response.responseData);
    }
    throw Exception('Failed to update client profile');
  }

  /// Get product recommendations, optionally filtered by client
  Future<List<ProductRecommendation>> getRecommendations({
    int? clientId,
  }) async {
    String url = AppUrls.hairstylistRecommendations;
    if (clientId != null) {
      url = '${AppUrls.hairstylistRecommendations}?client=$clientId';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => ProductRecommendation.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch recommendations');
  }

  /// Create a product recommendation
  Future<ProductRecommendation> createRecommendation(
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.postRequest(
      AppUrls.hairstylistRecommendations,
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ProductRecommendation.fromJson(response.responseData);
    }
    throw Exception('Failed to create recommendation');
  }

  /// Delete a product recommendation
  Future<void> deleteRecommendation(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.hairstylistRecommendationDetail(id),
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete recommendation');
    }
  }
}
