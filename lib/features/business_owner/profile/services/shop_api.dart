// lib/features/business_owner/profile/services/shop_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:fidden/core/models/response_data.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/profile/data/stripe_models.dart';

class ShopApi {
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

  // NEW: "09:00 AM" -> "09:00"  (keeps "HH:mm" if already that)
  static String toApiHHmm(String ui) {
    final s = toApiTime(ui); // HH:mm:ss or original
    final hhmmss = RegExp(r'^\d{2}:\d{2}:\d{2}$');
    final hhmm   = RegExp(r'^\d{2}:\d{2}$');
    if (hhmmss.hasMatch(s)) return s.substring(0, 5);
    if (hhmm.hasMatch(s)) return s;
    return ui; // fallback unchanged
  }

  // NEW: normalize and JSON-encode business_hours
  // Expects UI map: {"monday":[["09:00 AM","02:00 PM"],["03:00 PM","06:00 PM"]], ...}
  static String? encodeBusinessHoursUi(
      Map<String, List<List<String>>>? ui,
      ) {
    if (ui == null) return null;
    final out = <String, List<List<String>>>{};
    ui.forEach((day, ranges) {
      final d = day.toLowerCase();
      final list = <List<String>>[];
      for (final r in ranges) {
        if (r.length >= 2) {
          final s = toApiHHmm(r[0]);
          final e = toApiHHmm(r[1]);
          // (optional) skip obviously bad pairs
          if (s.isNotEmpty && e.isNotEmpty) list.add([s, e]);
        }
      }
      out[d] = list;
    });
    return jsonEncode(out);
  }

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

    // Optional (controller enforces plan-gating)
    int? freeCancellationHours,
    int? cancellationFeePercentage,
    int? noRefundHours,
    bool? isDepositRequired,
    int? defaultDepositPercentage,

    // NEW: arbitrary extra JSON (e.g., business_hours)
    Map<String, dynamic>? extraJson,
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

    // Policy
    final fch = _clamp(_asInt(freeCancellationHours));
    final cfp = _clamp(_asInt(cancellationFeePercentage), min: 0, max: 100);
    final nrf = _clamp(_asInt(noRefundHours));
    if (fch != null) body['free_cancellation_hours'] = '$fch';
    if (cfp != null) body['cancellation_fee_percentage'] = '$cfp';
    if (nrf != null) body['no_refund_hours'] = '$nrf';

    // Deposit
    if (isDepositRequired != null) {
      body['is_deposit_required'] = isDepositRequired ? 'true' : 'false';
    }
    if (defaultDepositPercentage != null) {
      body['default_deposit_percentage'] = defaultDepositPercentage.toString();
    }

    // NEW: merge extra JSON (encode non-strings)
    if (extraJson != null) {
      extraJson.forEach((k, v) {
        body[k] = v is String ? v : jsonEncode(v);
      });
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

    int? freeCancellationHours,
    int? cancellationFeePercentage,
    int? noRefundHours,
    bool? isDepositRequired,
    int? defaultDepositPercentage,

    // NEW
    Map<String, dynamic>? extraJson,
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

    // Policy
    final fch = _clamp(_asInt(freeCancellationHours));
    final cfp = _clamp(_asInt(cancellationFeePercentage), min: 0, max: 100);
    final nrf = _clamp(_asInt(noRefundHours));
    if (fch != null) body['free_cancellation_hours'] = '$fch';
    if (cfp != null) body['cancellation_fee_percentage'] = '$cfp';
    if (nrf != null) body['no_refund_hours'] = '$nrf';

    // Deposit
    if (isDepositRequired != null) {
      body['is_deposit_required'] = isDepositRequired ? 'true' : 'false';
    }
    if (defaultDepositPercentage != null) {
      body['default_deposit_percentage'] = defaultDepositPercentage.toString();
    }

    // NEW: merge extra JSON
    if (extraJson != null) {
      extraJson.forEach((k, v) {
        body[k] = v is String ? v : jsonEncode(v);
      });
    }

    return await _networkCaller.multipartRequest(
      AppUrls.editBusinessProfile(id),
      method: 'PATCH',
      body: body,
      token: token,
      photo: imagePath != null ? File(imagePath) : null,
      documents: documents,
    );
  }


  Future<StripeOnboardingLink> getStripeOnboardingLink({
    required int shopId,
    required String token,
  }) async {
    const String returnUrl =
        'https://fidden-service-provider-1.onrender.com/payments/stripe/return/';
    const String refreshUrl =
        'https://fidden-service-provider-1.onrender.com/payments/stripe/refresh/';

    final String urlWithParams =
        '${AppUrls.stripeOnborading(shopId)}?return_url=$returnUrl&refresh_url=$refreshUrl';

    final ResponseData res = await _networkCaller.getRequest(
      urlWithParams,
      token: token,
    );

    if (res.isSuccess) {
      final data = (res.responseData is Map<String, dynamic>)
          ? res.responseData
          : json.decode(res.responseData as String);
      return StripeOnboardingLink.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception(res.errorMessage ?? 'Failed to get onboarding link');
    }
  }

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
