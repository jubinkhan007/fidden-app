import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/mua_models.dart';

/// Service for MUA Dashboard API calls
class MUAService {
  final NetworkCaller _networkCaller = NetworkCaller();

  // =========================
  // DASHBOARD SUMMARY
  // =========================

  Future<MUADashboard> getDashboard() async {
    final response = await _networkCaller.getRequest(
      AppUrls.muaDashboard,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return MUADashboard.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch MUA dashboard');
  }

  // =========================
  // FACE CHARTS
  // =========================

  Future<FaceChartsResponse> getFaceCharts({String? lookType}) async {
    String url = AppUrls.muaFaceCharts;
    if (lookType != null) {
      url += '?look_type=$lookType';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return FaceChartsResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch face charts');
  }

  // =========================
  // CLIENT BEAUTY PROFILES
  // =========================

  Future<List<ClientBeautyProfile>> getClientProfiles() async {
    final response = await _networkCaller.getRequest(
      AppUrls.muaClientProfiles,
      token: AuthService.accessToken,
    );

    if (response.isSuccess) {
      List<dynamic> data;
      if (response.responseData is List) {
        data = response.responseData;
      } else if (response.responseData is Map && response.responseData['results'] != null) {
        data = response.responseData['results'] as List;
      } else {
        data = [];
      }
      return data.map((e) => ClientBeautyProfile.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to fetch client profiles');
  }

  Future<ClientBeautyProfile> createClientProfile(ClientBeautyProfile profile) async {
    final response = await _networkCaller.postRequest(
      AppUrls.muaClientProfiles,
      body: profile.toJson(),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ClientBeautyProfile.fromJson(response.responseData);
    }

    throw Exception('Failed to create client profile');
  }

  Future<ClientBeautyProfile> updateClientProfile(int id, Map<String, dynamic> updates) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.muaClientProfileDetail(id),
      body: updates,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ClientBeautyProfile.fromJson(response.responseData);
    }

    throw Exception('Failed to update client profile');
  }

  // =========================
  // PRODUCT KIT
  // =========================

  Future<List<ProductKitItem>> getProductKit({String? category}) async {
    String url = AppUrls.muaProductKit;
    if (category != null) {
      url += '?category=$category';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess) {
      List<dynamic> data;
      if (response.responseData is List) {
        data = response.responseData;
      } else if (response.responseData is Map && response.responseData['results'] != null) {
        data = response.responseData['results'] as List;
      } else {
        data = [];
      }
      return data.map((e) => ProductKitItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception('Failed to fetch product kit');
  }

  Future<ProductKitItem> createProductKitItem(ProductKitItem item) async {
    final response = await _networkCaller.postRequest(
      AppUrls.muaProductKit,
      body: item.toJson(),
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ProductKitItem.fromJson(response.responseData);
    }

    throw Exception('Failed to create product kit item');
  }

  Future<ProductKitItem> togglePacked(int id, bool isPacked) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.muaProductKitDetail(id),
      body: {'is_packed': isPacked},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return ProductKitItem.fromJson(response.responseData);
    }

    throw Exception('Failed to toggle packed status');
  }

  Future<void> deleteProductKitItem(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.muaProductKitDetail(id),
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete product kit item');
    }
  }
}
