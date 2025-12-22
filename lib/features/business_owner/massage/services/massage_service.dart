import 'dart:convert';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import '../data/massage_models.dart';

/// Service layer for Massage Therapist API interactions
class MassageService {
  final _network = NetworkCaller();

  // ========== Dashboard ==========
  Future<MassageDashboard> getDashboard() async {
    final res = await _network.getRequest(
      AppUrls.massageDashboard,
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to load dashboard');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);
    return MassageDashboard.fromJson(data);
  }

  // ========== Client Profiles ==========
  Future<List<MassageClientProfile>> getClientProfiles({String? search}) async {
    String url = AppUrls.massageClientProfiles;
    if (search != null && search.isNotEmpty) {
      url = '$url?search=$search';
    }

    final res = await _network.getRequest(url, token: AuthService.accessToken);
    if (!res.isSuccess) throw Exception('Failed to load client profiles');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);

    final List results = data['results'] ?? data;
    return results.map((e) => MassageClientProfile.fromJson(e)).toList();
  }

  Future<MassageClientProfile> getClientProfile(int id) async {
    final res = await _network.getRequest(
      AppUrls.massageClientProfileDetail(id),
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to load client profile');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);
    return MassageClientProfile.fromJson(data);
  }

  Future<MassageClientProfile> createClientProfile(
    Map<String, dynamic> data,
  ) async {
    final res = await _network.postRequest(
      AppUrls.massageClientProfiles,
      body: data,
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to create client profile');

    dynamic responseData = res.responseData;
    if (responseData is String) responseData = jsonDecode(responseData);
    return MassageClientProfile.fromJson(responseData);
  }

  Future<MassageClientProfile> updateClientProfile(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await _network.patchRequest(
      AppUrls.massageClientProfileDetail(id),
      body: data,
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to update client profile');

    dynamic responseData = res.responseData;
    if (responseData is String) responseData = jsonDecode(responseData);
    return MassageClientProfile.fromJson(responseData);
  }

  Future<void> deleteClientProfile(int id) async {
    final res = await _network.deleteRequest(
      AppUrls.massageClientProfileDetail(id),
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to delete client profile');
  }

  // ========== Health Disclosures ==========
  Future<List<MassageHealthDisclosure>> getHealthDisclosures({
    int? clientId,
  }) async {
    String url = AppUrls.massageHealthDisclosures;
    if (clientId != null) url = '$url?client=$clientId';

    final res = await _network.getRequest(url, token: AuthService.accessToken);
    if (!res.isSuccess) throw Exception('Failed to load health disclosures');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);

    final List results = data['results'] ?? data;
    return results.map((e) => MassageHealthDisclosure.fromJson(e)).toList();
  }

  Future<MassageHealthDisclosure> getHealthDisclosure(int id) async {
    final res = await _network.getRequest(
      AppUrls.massageHealthDisclosureDetail(id),
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to load health disclosure');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);
    return MassageHealthDisclosure.fromJson(data);
  }

  Future<MassageHealthDisclosure> createHealthDisclosure(
    Map<String, dynamic> data,
  ) async {
    final res = await _network.postRequest(
      AppUrls.massageHealthDisclosures,
      body: data,
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to create health disclosure');

    dynamic responseData = res.responseData;
    if (responseData is String) responseData = jsonDecode(responseData);
    return MassageHealthDisclosure.fromJson(responseData);
  }

  // ========== Treatment Notes ==========
  Future<List<MassageTreatmentNote>> getTreatmentNotes({int? bookingId}) async {
    String url = AppUrls.massageTreatmentNotes;
    if (bookingId != null) url = '$url?booking=$bookingId';

    final res = await _network.getRequest(url, token: AuthService.accessToken);
    if (!res.isSuccess) throw Exception('Failed to load treatment notes');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);

    final List results = data['results'] ?? data;
    return results.map((e) => MassageTreatmentNote.fromJson(e)).toList();
  }

  Future<MassageTreatmentNote> getTreatmentNote(int id) async {
    final res = await _network.getRequest(
      AppUrls.massageTreatmentNoteDetail(id),
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to load treatment note');

    dynamic data = res.responseData;
    if (data is String) data = jsonDecode(data);
    return MassageTreatmentNote.fromJson(data);
  }

  Future<MassageTreatmentNote> createTreatmentNote(
    Map<String, dynamic> data,
  ) async {
    final res = await _network.postRequest(
      AppUrls.massageTreatmentNotes,
      body: data,
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to create treatment note');

    dynamic responseData = res.responseData;
    if (responseData is String) responseData = jsonDecode(responseData);
    return MassageTreatmentNote.fromJson(responseData);
  }

  Future<MassageTreatmentNote> updateTreatmentNote(
    int id,
    Map<String, dynamic> data,
  ) async {
    final res = await _network.patchRequest(
      AppUrls.massageTreatmentNoteDetail(id),
      body: data,
      token: AuthService.accessToken,
    );
    if (!res.isSuccess) throw Exception('Failed to update treatment note');

    dynamic responseData = res.responseData;
    if (responseData is String) responseData = jsonDecode(responseData);
    return MassageTreatmentNote.fromJson(responseData);
  }
}
