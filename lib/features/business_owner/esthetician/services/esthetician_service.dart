import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import '../data/esthetician_models.dart';

/// Service for Esthetician API calls
class EstheticianService {
  final NetworkCaller _networkCaller = NetworkCaller();

  // ==========================================
  // DASHBOARD
  // ==========================================

  /// Get aggregated dashboard summary
  Future<EstheticianDashboard> getDashboard() async {
    final response = await _networkCaller.getRequest(
      AppUrls.estheticianDashboard,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return EstheticianDashboard.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch esthetician dashboard');
  }

  // ==========================================
  // CLIENT SKIN PROFILES
  // ==========================================

  /// Get all client skin profiles
  Future<List<ClientSkinProfile>> getClientProfiles() async {
    final response = await _networkCaller.getRequest(
      AppUrls.estheticianClientProfiles,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => ClientSkinProfile.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch client profiles');
  }

  /// Get single client profile
  Future<ClientSkinProfile> getClientProfile(int id) async {
    final response = await _networkCaller.getRequest(
      AppUrls.estheticianClientProfileDetail(id),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ClientSkinProfile.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch client profile');
  }

  /// Create client profile
  Future<ClientSkinProfile> createClientProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.postRequest(
      AppUrls.estheticianClientProfiles,
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ClientSkinProfile.fromJson(response.responseData);
    }
    throw Exception('Failed to create client profile');
  }

  /// Update client profile
  Future<ClientSkinProfile> updateClientProfile(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.estheticianClientProfileDetail(id),
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return ClientSkinProfile.fromJson(response.responseData);
    }
    throw Exception('Failed to update client profile');
  }

  /// Delete client profile
  Future<void> deleteClientProfile(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.estheticianClientProfileDetail(id),
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete client profile');
    }
  }

  // ==========================================
  // HEALTH DISCLOSURES
  // ==========================================

  /// Get health disclosures, optionally filtered by client
  Future<List<HealthDisclosure>> getHealthDisclosures({int? clientId}) async {
    String url = AppUrls.estheticianHealthDisclosures;
    if (clientId != null) {
      url = '${AppUrls.estheticianHealthDisclosures}?client=$clientId';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => HealthDisclosure.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch health disclosures');
  }

  /// Get single health disclosure
  Future<HealthDisclosure> getHealthDisclosure(int id) async {
    final response = await _networkCaller.getRequest(
      AppUrls.estheticianHealthDisclosureDetail(id),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return HealthDisclosure.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch health disclosure');
  }

  /// Create health disclosure
  Future<HealthDisclosure> createHealthDisclosure(
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.postRequest(
      AppUrls.estheticianHealthDisclosures,
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return HealthDisclosure.fromJson(response.responseData);
    }
    throw Exception('Failed to create health disclosure');
  }

  // ==========================================
  // TREATMENT NOTES
  // ==========================================

  /// Get treatment notes, optionally filtered by booking
  Future<List<TreatmentNote>> getTreatmentNotes({int? bookingId}) async {
    String url = AppUrls.estheticianTreatmentNotes;
    if (bookingId != null) {
      url = '${AppUrls.estheticianTreatmentNotes}?booking=$bookingId';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => TreatmentNote.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch treatment notes');
  }

  /// Get single treatment note
  Future<TreatmentNote> getTreatmentNote(int id) async {
    final response = await _networkCaller.getRequest(
      AppUrls.estheticianTreatmentNoteDetail(id),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return TreatmentNote.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch treatment note');
  }

  /// Create treatment note
  Future<TreatmentNote> createTreatmentNote(Map<String, dynamic> data) async {
    final response = await _networkCaller.postRequest(
      AppUrls.estheticianTreatmentNotes,
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return TreatmentNote.fromJson(response.responseData);
    }
    throw Exception('Failed to create treatment note');
  }

  /// Update treatment note
  Future<TreatmentNote> updateTreatmentNote(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.estheticianTreatmentNoteDetail(id),
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return TreatmentNote.fromJson(response.responseData);
    }
    throw Exception('Failed to update treatment note');
  }

  /// Delete treatment note
  Future<void> deleteTreatmentNote(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.estheticianTreatmentNoteDetail(id),
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete treatment note');
    }
  }

  // ==========================================
  // RETAIL PRODUCTS
  // ==========================================

  /// Get retail products, optionally filtered by category
  Future<List<RetailProduct>> getRetailProducts({String? category}) async {
    String url = AppUrls.estheticianRetailProducts;
    if (category != null && category.isNotEmpty) {
      url = '${AppUrls.estheticianRetailProducts}?category=$category';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => RetailProduct.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch retail products');
  }

  /// Get single retail product
  Future<RetailProduct> getRetailProduct(int id) async {
    final response = await _networkCaller.getRequest(
      AppUrls.estheticianRetailProductDetail(id),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return RetailProduct.fromJson(response.responseData);
    }
    throw Exception('Failed to fetch retail product');
  }

  /// Create retail product
  Future<RetailProduct> createRetailProduct(Map<String, dynamic> data) async {
    final response = await _networkCaller.postRequest(
      AppUrls.estheticianRetailProducts,
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return RetailProduct.fromJson(response.responseData);
    }
    throw Exception('Failed to create retail product');
  }

  /// Update retail product
  Future<RetailProduct> updateRetailProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.estheticianRetailProductDetail(id),
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData != null) {
      return RetailProduct.fromJson(response.responseData);
    }
    throw Exception('Failed to update retail product');
  }

  /// Delete retail product
  Future<void> deleteRetailProduct(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.estheticianRetailProductDetail(id),
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete retail product');
    }
  }
}
