// lib/core/services/shop_api.dart
import 'dart:convert';
import 'dart:developer';
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

    final url = Uri.parse(
      'https://fidden-service-provider.onrender.com/api/shop/',
    );

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
    required String id, // "1"
    required String name,
    required String address,
    required String aboutUs,
    required int capacity,
    required String startAtUi, // "09:00 AM"
    required String closeAtUi, // "06:00 PM"
    required List<String> closeDays, // ["monday","tuesday"]
    String? latitude, // "23.78"
    String? longitude, // "90.41"
    String? imagePath, // local file path
    required String token, // Bearer token
  }) async {
    final startAt = toApiTime(startAtUi);
    final closeAt = toApiTime(closeAtUi);

    // Build "lat,long" (no space) only if valid
    String? location;
    final lat = double.tryParse(latitude ?? '');
    final lon = double.tryParse(longitude ?? '');
    if (lat != null && lon != null) {
      location = '$lat,$lon';
    }

    final url = Uri.parse(
      'https://fidden-service-provider.onrender.com/api/shop/$id/', // note trailing slash
    );

    final req = http.MultipartRequest('PUT', url);
    req.headers['Authorization'] = 'Bearer $token';

    // Text fields
    req.fields['name'] = name;
    req.fields['address'] = address;
    req.fields['about_us'] = aboutUs;
    req.fields['capacity'] = capacity.toString();
    req.fields['start_at'] = startAt; // "HH:mm:ss"
    req.fields['close_at'] = closeAt; // "HH:mm:ss"
    if (location != null) req.fields['location'] = location;

    // close_days as JSON string (works well with DRF)
    req.fields['close_days'] = jsonEncode(
      closeDays.map((e) => e.toLowerCase()).toList(),
    );

    // File
    if (imagePath != null && imagePath.isNotEmpty) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'shop_img', // server expects this field name
          imagePath,
          contentType: MediaType('image', 'jpeg'),
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
}
