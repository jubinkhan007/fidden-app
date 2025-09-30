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

  // small helpers
  static int? _asInt(dynamic v) =>
      v == null ? null : (v is int ? v : int.tryParse(v.toString()));

  static int? _clamp(int? v, {int min = 0, int max = 100000}) {
    if (v == null) return null;
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

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

    // NEW (optional – pass from your controller/UI)
    int? freeCancellationHours,
    int? cancellationFeePercentage,
    int? noRefundHours,
  }) async {
    final body = <String, String>{
      'name': name,
      'address': address,
      'about_us': aboutUs,
      'capacity': capacity.toString(),
      'start_at': toApiTime(startAtUi),
      'close_at': toApiTime(closeAtUi),
      'close_days': jsonEncode(
        closeDays.map((e) => e.toLowerCase()).toList(),
      ),
    };

    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      body['location'] = '$lat,$lon';
    }

    // include only if provided
    final fch = _clamp(_asInt(freeCancellationHours));
    final cfp = _clamp(_asInt(cancellationFeePercentage), min: 0, max: 100);
    final nrf = _clamp(_asInt(noRefundHours));
    if (fch != null) body['free_cancellation_hours'] = '$fch';
    if (cfp != null) body['cancellation_fee_percentage'] = '$cfp';
    if (nrf != null) body['no_refund_hours'] = '$nrf';

    return await _networkCaller.multipartRequest(
      AppUrls.getMBusinessProfile,
      method: 'POST',
      body: body,
      token: token,
      photo: imagePath != null ? File(imagePath) : null,
      documents: documents,
    );
  }

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

    // NEW (optional – pass from your controller/UI)
    int? freeCancellationHours,
    int? cancellationFeePercentage,
    int? noRefundHours,
  }) async {
    final body = <String, String>{
      'name': name,
      'address': address,
      'about_us': aboutUs,
      'capacity': capacity.toString(),
      'start_at': toApiTime(startAtUi),
      'close_at': toApiTime(closeAtUi),
      'close_days': jsonEncode(
        closeDays.map((e) => e.toLowerCase()).toList(),
      ),
    };

    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      body['location'] = '$lat,$lon';
    }

    // include only if provided
    final fch = _clamp(_asInt(freeCancellationHours));
    final cfp = _clamp(_asInt(cancellationFeePercentage), min: 0, max: 100);
    final nrf = _clamp(_asInt(noRefundHours));
    if (fch != null) body['free_cancellation_hours'] = '$fch';
    if (cfp != null) body['cancellation_fee_percentage'] = '$cfp';
    if (nrf != null) body['no_refund_hours'] = '$nrf';

    return await _networkCaller.multipartRequest(
      AppUrls.editBusinessProfile(id),
      method: 'PATCH',
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

    // V-- THIS IS THE FINAL CORRECTED CODE --V

    // 1. These URLs must EXACTLY match what you put in your Stripe Dashboard.
    const String returnUrl  = 'https://fidden-service-provider-1.onrender.com/payments/stripe/return/';
    const String refreshUrl = 'https://fidden-service-provider-1.onrender.com/payments/stripe/refresh/';


    // 2. Manually build the final URL with the required query parameters.
    final String urlWithParams =
        '${AppUrls.stripeOnborading(shopId)}?return_url=$returnUrl&refresh_url=$refreshUrl';

    // 3. Make sure you are using your .getRequest() method.
    final ResponseData res = await _networkCaller.getRequest(
      urlWithParams,
      token: token,
    );

    // ^-- THIS IS THE FINAL CORRECTED CODE --^

    if (res.isSuccess) {
      final data = (res.responseData is Map<String, dynamic>)
          ? res.responseData
          : json.decode(res.responseData as String);
      return StripeOnboardingLink.fromJson(data as Map<String, dynamic>);
    } else {
      // Throw an exception so the controller can catch it and show an error.
      throw Exception(res.errorMessage ?? 'Failed to get onboarding link');
    }
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