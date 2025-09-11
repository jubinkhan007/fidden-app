// lib/core/services/shop_api.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/profile/data/stripe_models.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ShopApi {
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

  static Future<http.StreamedResponse> createShopWithImage({
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
    final startAt = toApiTime(startAtUi);
    final closeAt = toApiTime(closeAtUi);

    String? location;
    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      location = '$lat,$lon';
    }

    final url = Uri.parse(AppUrls.getMBusinessProfile);

    final req = http.MultipartRequest('POST', url);
    req.headers['Authorization'] = 'Bearer $token';

    req.fields['name'] = name;
    req.fields['address'] = address;
    req.fields['about_us'] = aboutUs;
    req.fields['capacity'] = capacity.toString();
    req.fields['start_at'] = startAt;
    req.fields['close_at'] = closeAt;
    if (location != null) req.fields['location'] = location;
    req.fields['close_days'] = jsonEncode(
      closeDays.map((e) => e.toLowerCase()).toList(),
    );

    if (imagePath != null && imagePath.isNotEmpty) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'shop_img',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    for (var file in documents) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'verification_files',
          file.path,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
    }

    log('Uploading multipart to $url');
    log('Fields: ${req.fields}');
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    log('Status: ${streamed.statusCode}');
    log('Body: $body');
    return http.StreamedResponse(
      Stream.fromIterable([body.codeUnits]),
      streamed.statusCode,
      headers: streamed.headers,
      reasonPhrase: streamed.reasonPhrase,
    );
  }

  static Future<http.StreamedResponse> updateShopWithImage({
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
    final startAt = toApiTime(startAtUi);
    final closeAt = toApiTime(closeAtUi);

    String? location;
    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      location = '$lat,$lon';
    }

    final url = Uri.parse(AppUrls.editBusinessProfile(id));
    final req = http.MultipartRequest('PATCH', url);
    req.headers['Authorization'] = 'Bearer $token';

    // --- Text fields ---
    req.fields['name'] = name;
    req.fields['address'] = address;
    req.fields['about_us'] = aboutUs;
    req.fields['capacity'] = capacity.toString();
    req.fields['start_at'] = startAt;
    req.fields['close_at'] = closeAt;
    if (location != null) req.fields['location'] = location;
    req.fields['close_days'] = jsonEncode(
      closeDays.map((e) => e.toLowerCase()).toList(),
    );

    // --- Shop image file ---
    if (imagePath != null && imagePath.isNotEmpty) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'shop_img',
          imagePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // --- 🚀 CORRECTION FOR VERIFICATION FILES ---
    // Only add files to the request if the user has selected new ones.
    // If `documents` is empty, the `verification_files` field will not be sent,
    // and the backend should not clear the existing files.
    if (documents.isNotEmpty) {
      for (var file in documents) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'verification_files',
            file.path,
            contentType: MediaType('application', 'octet-stream'),
          ),
        );
      }
    }
    // --- END CORRECTION (The else block has been removed) ---

    log('Uploading multipart to $url');
    log('Fields: ${req.fields}');
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    log('Status: ${streamed.statusCode}');
    log('Body: $body');
    return http.StreamedResponse(
      Stream.fromIterable([body.codeUnits]),
      streamed.statusCode,
      headers: streamed.headers,
      reasonPhrase: streamed.reasonPhrase,
    );
  }

  static Future<StripeOnboardingLink> getStripeOnboardingLink({
    required int shopId,
    required String token,
  }) async {
    final res = await NetworkCaller().getRequest(
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

  static Future<StripeVerifyResponse> verifyStripeOnboarding({
    required int shopId,
    required String token,
  }) async {
    final res = await NetworkCaller().getRequest(
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
