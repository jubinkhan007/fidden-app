import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import '../models/response_data.dart';
import 'Auth_service.dart';

class NetworkCaller {
  static bool _isRefreshing = false;
  static final List<Completer<ResponseData>> _pendingRequests = [];

  final _retryOptions = const RetryOptions(
    maxAttempts: 3,
    delayFactor: Duration(seconds: 1),
    maxDelay: Duration(seconds: 3),
  );

  static Completer<bool>? _refreshingCompleter; // gate so only 1 refresh runs

  Future<bool> _ensureTokenRefreshed() async {
    if (_refreshingCompleter != null) {
      return _refreshingCompleter!.future;        // wait for the in-flight refresh
    }
    final c = Completer<bool>();
    _refreshingCompleter = c;
    final ok = await _refreshToken();
    c.complete(ok);
    _refreshingCompleter = null;
    return ok;
  }

  Future<ResponseData> getRequest(String endpoint, {String? token, bool treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('GET Request: $endpoint');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
          'Content-type': 'application/json',
        },
      );
      return _handleResponse(response, treat404AsEmpty: treat404AsEmpty, emptyPayload: emptyPayload);
    });
  }

  Future<ResponseData> multipartRequest(String endpoint, {String method = 'POST', required Map<String, String> body, String? token, File? photo, List<File>? documents}) {
    return _makeRequestWithRetry(() async {
      log('Multipart Request: $endpoint');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final request = http.MultipartRequest(method, Uri.parse(endpoint));
      request.fields.addAll(body);

      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath('image', photo.path));
      }
      if (documents != null && documents.isNotEmpty) {
        for (var doc in documents) {
          request.files.add(await http.MultipartFile.fromPath('verification_files', doc.path));
        }
      }
      request.headers.addAll({
        if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    });
  }

  Future<ResponseData> getRequestWithBody(String endpoint, {Map<String, dynamic>? body, String? token, bool treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('GET Request with body: $endpoint');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final request = http.Request('GET', Uri.parse(endpoint));
      request.headers.addAll({
        if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        'Content-Type': 'application/json',
      });
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response, treat404AsEmpty: treat404AsEmpty, emptyPayload: emptyPayload);
    });
  }

  Future<ResponseData> postRequest(String endpoint, {Map<String, dynamic>? body, String? token, bool treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('POST Request: $endpoint');
      log('Request Body: ${jsonEncode(body)}');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _handleResponse(response, treat404AsEmpty: treat404AsEmpty, emptyPayload: emptyPayload);
    });
  }

  Future<ResponseData> putRequest(String endpoint, {Map<String, dynamic>? body, String? token, treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('PUT Request: $endpoint');
      log('Request Body: ${jsonEncode(body)}');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
          'Content-type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _handleResponse(response, treat404AsEmpty: treat404AsEmpty, emptyPayload: emptyPayload);
    });
  }

  Future<ResponseData> deleteRequest(String endpoint, {Map<String, dynamic>? body, String? token, bool treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('DELETE Request: $endpoint');
      log('Request Body: ${jsonEncode(body)}');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final req = http.Request('DELETE', Uri.parse(endpoint));
      req.headers.addAll({
        if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        'Content-Type': 'application/json',
      });
      if (body != null) req.body = jsonEncode(body);
      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    });
  }

  Future<ResponseData> patchRequest(
      String endpoint, {
        Map<String, dynamic>? body,
        String? token,
        bool treat404AsEmpty = false,
        dynamic emptyPayload,
      }) {
    return _makeRequestWithRetry(() async {
      log('PATCH Request: $endpoint');
      log('Request Body: ${jsonEncode(body)}');
      // --- MODIFIED: Reliably get token if not provided ---
      final effectiveToken = token ?? await AuthService.getValidAccessToken();

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      return _handleResponse(
        response,
        treat404AsEmpty: treat404AsEmpty,
        emptyPayload: emptyPayload,
      );
    });
  }

  // --- No changes needed below this line ---

  Future<ResponseData> _makeRequestWithRetry(
  Future<ResponseData> Function() request,
) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return ResponseData(
      isSuccess: false,
      statusCode: -1,
      errorMessage: 'No internet connection. Please check your settings.',
      responseData: null,
    );
  }

  try {
    // First attempt with standard network retry (socket/timeouts)
    final first = await _retryOptions.retry(
      request,
      retryIf: (e) =>
          e is SocketException || e is TimeoutException || e is http.ClientException,
      onRetry: (e) => log('Retrying request after error: $e'),
    );

    // If token expired, refresh ONCE and then re-run *this caller’s* request.
    if (first.statusCode == 401) {
      final ok = await _ensureTokenRefreshed();
      if (!ok) {
        await AuthService.clearAuthData();
        return ResponseData(
          isSuccess: false,
          statusCode: 401,
          errorMessage: 'You are not authorized. Please log in to continue.',
          responseData: null,
        );
      }
      // re-run same request with the new token (no extra recursion)
      return await request();
    }

    return first;
  } on SocketException {
    return ResponseData(
      isSuccess: false, statusCode: -1,
      errorMessage: 'Failed to connect. Please check your internet connection.',
      responseData: null,
    );
  } on TimeoutException {
    return ResponseData(
      isSuccess: false, statusCode: 408,
      errorMessage: 'The connection timed out. Please try again.',
      responseData: null,
    );
  } catch (e) {
    return ResponseData(
      isSuccess: false, statusCode: 500,
      errorMessage: 'An unexpected error occurred: $e',
      responseData: null,
    );
  }
}


  Future<ResponseData> _handleResponse(http.Response response, {
    bool treat404AsEmpty = false,
    dynamic emptyPayload,
  }) async {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    if (response.statusCode == 401) {
  // Just return 401; _makeRequestWithRetry will handle refresh + retry.
  return ResponseData(
    isSuccess: false,
    statusCode: 401,
    errorMessage: 'Unauthorized',
    responseData: null,
  );
}


    final code = response.statusCode;
    final raw = response.body;

    if (code == 204 || raw.trim().isEmpty) {
      return ResponseData(
        isSuccess: code >= 200 && code < 300,
        statusCode: code,
        responseData: null,
        errorMessage: '',
      );
    }

    if (code == 404 && treat404AsEmpty) {
      return ResponseData(
        isSuccess: true,
        statusCode: 200,
        responseData: emptyPayload ?? [],
        errorMessage: '',
      );
    }

    dynamic decoded = raw;
    try {
      final ct = response.headers['content-type'] ?? '';
      if (ct.contains('application/json')) decoded = jsonDecode(raw);
    } catch (_) {
      // leave decoded as raw string
    }

    if (code >= 200 && code < 300) {
      return ResponseData(
        isSuccess: true,
        statusCode: code,
        responseData: decoded,
        errorMessage: '',
      );
    }

    switch (code) {
      case 401:
        await AuthService.logoutUser();
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: 'You are not authorized. Please log in to continue.',
          responseData: null,
        );
      case 403:
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: 'You do not have permission to access this resource.',
          responseData: null,
        );
      case 404:
        {
          final friendly = extractErrorMessage(raw);
          final decoded = jsonDecode(raw);
          return ResponseData(
            isSuccess: false,
            statusCode: code,
            errorMessage: friendly.isNotEmpty
                ? friendly
                : 'The resource you are looking for was not found.',
            responseData: decoded,
          );
        }
      case 409:
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: extractErrorMessage(raw),
          responseData: decoded,
        );
      case 400:
        {
          final friendly = extractErrorMessage(raw);
          return ResponseData(
            isSuccess: false,
            statusCode: code,
            errorMessage: friendly.isNotEmpty ? friendly : 'Bad request.',
            responseData: decoded,
          );
        }
      case 500:
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: 'Internal server error. Please try again later.',
          responseData: null,
        );
      default:
        {
          final friendly = extractErrorMessage(raw);
          final msg = (friendly.isNotEmpty)
              ? friendly
              : (decoded is Map && decoded['detail'] != null)
              ? decoded['detail'].toString()
              : (decoded is Map && decoded['error'] != null)
              ? decoded['error'].toString()
              : 'Something went wrong. Please try again.';
          return ResponseData(
            isSuccess: false,
            statusCode: code,
            errorMessage: msg,
            responseData: decoded,
          );
        }
    }
  }

  Future<bool> _refreshToken() async {
    try {
      // Use the reliable async getter here as well
      final String? refreshToken = await AuthService.getValidRefreshToken();
      if (refreshToken == null) {
        log('No refresh token found.');
        return false;
      }

      final http.Response response = await http.post(
        Uri.parse(AppUrls.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      log('Refresh Token Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];
        final newRefreshToken = responseData['refresh'];

        await AuthService.saveToken(
          newAccessToken,
          newRefreshToken ?? refreshToken,
          AuthService.role ?? '',
        );
        log('Tokens refreshed successfully.');
        return true;
      }
      return false;
    } catch (e) {
      log('Token refresh error: $e');
      return false;
    }
  }

  Future<ResponseData> _retryRequest(http.BaseRequest request) async {
    final client = http.Client();
    final newRequest = http.Request(request.method, request.url);
    newRequest.headers.addAll(request.headers);

    // Use the reliable getter for the new token
    newRequest.headers['Authorization'] = 'Bearer ${await AuthService.getValidAccessToken()}';

    if (request is http.Request && request.body.isNotEmpty) {
      newRequest.body = request.body;
    }

    log('Retrying request to ${request.url}');
    final streamedResponse = await client.send(newRequest);
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  String extractErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] is String) return decoded['detail'];
        if (decoded.values.any((v) => v is List)) {
          final buf = StringBuffer();
          decoded.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              final msg = value.first.toString();
              final prettyKey = key == 'non_field_errors' ? '' : '${key[0].toUpperCase()}${key.substring(1)}: ';
              buf.writeln('$prettyKey$msg');
            }
          });
          final text = buf.toString().trim();
          if (text.isNotEmpty) return text;
        }
        final firstString = decoded.values.firstWhere(
              (v) => v is String,
          orElse: () => null,
        );
        if (firstString is String && firstString.isNotEmpty) return firstString;
      }
      if (decoded is String && decoded.isNotEmpty) return decoded;
    } catch (_) {
      // body wasn't JSON; fall through
    }
    return 'Something went wrong. Please try again.';
  }
}