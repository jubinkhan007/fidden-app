// lib/features/business_owner/profile/services/shop_api.dart

import 'dart:convert';
import 'dart:io';
import 'package:fidden/core/models/response_data.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/profile/data/stripe_models.dart';

class ShopApi {
  // ✅ Instantiate the NetworkCaller to use its methods
  final _networkCaller = NetworkCaller();

  static String toApiTime(String ui) {
    final m = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$',
      caseSensitive: false,
    ).firstMatch(ui);
    if (m == null) return ui; // fallback
    int h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:00';
  }

  // ✅ REFACTORED to use NetworkCaller
  Future<ResponseData> createShopWithImage({
    required String name,
    required String address,
    required String aboutUs,
    required int capacity,
    required String startAtUi,
    required String closeAtUi,
    required List<String> closeDays,
    String? latitude,
    String? longitude,
    String? imagePath,
    required List<File> documents,
    required String token,
  }) async {
    final body = <String, String>{
      'name': name,
      'address': address,
      'about_us': aboutUs,
      'capacity': capacity.toString(),
      'start_at': toApiTime(startAtUi),
      'close_at': toApiTime(closeAtUi),
      'close_days': jsonEncode(closeDays.map((e) => e.toLowerCase()).toList()),
    };

    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      body['location'] = '$lat,$lon';
    }

    return await _networkCaller.multipartRequest(
      AppUrls.getMBusinessProfile,
      method: 'POST',
      body: body,
      token: token,
      photo: imagePath != null ? File(imagePath) : null,
      documents: documents,
    );
  }

  // ✅ REFACTORED to use NetworkCaller
  Future<ResponseData> updateShopWithImage({
    required String id,
    required String name,
    required String address,
    required String aboutUs,
    required int capacity,
    required String startAtUi,
    required String closeAtUi,
    required List<String> closeDays,
    String? latitude,
    String? longitude,
    String? imagePath,
    required List<File> documents,
    required String token,
  }) async {
    final body = <String, String>{
      'name': name,
      'address': address,
      'about_us': aboutUs,
      'capacity': capacity.toString(),
      'start_at': toApiTime(startAtUi),
      'close_at': toApiTime(closeAtUi),
      'close_days': jsonEncode(closeDays.map((e) => e.toLowerCase()).toList()),
    };

    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      body['location'] = '$lat,$lon';
    }

    return await _networkCaller.multipartRequest(
      AppUrls.editBusinessProfile(id),
      method: 'PATCH', // Using PATCH as in your original code
      body: body,
      token: token,
      photo: imagePath != null ? File(imagePath) : null,
      documents: documents,
    );
  }

  // ✅ Now an instance method
  Future<StripeOnboardingLink> getStripeOnboardingLink({
    required int shopId,
    required String token,
  }) async {
    final res = await _networkCaller.getRequest(
      AppUrls.stripeOnborading(shopId),
      token: token,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to get onboarding link');
    }
    final data = (res.responseData is Map<String, dynamic>)
        ? res.responseData
        : json.decode(res.responseData as String);
    return StripeOnboardingLink.fromJson(data as Map<String, dynamic>);
  }

  // ✅ Now an instance method
  Future<StripeVerifyResponse> verifyStripeOnboarding({
    required int shopId,
    required String token,
  }) async {
    final res = await _networkCaller.getRequest(
      AppUrls.verifyOnborading(shopId),
      token: token,
    );
    if (!res.isSuccess) {
      throw Exception(res.errorMessage ?? 'Failed to verify onboarding');
    }
    final data = (res.responseData is Map<String, dynamic>)
        ? res.responseData
        : json.decode(res.responseData as String);
    return StripeVerifyResponse.fromJson(data as Map<String, dynamic>);
  }
}