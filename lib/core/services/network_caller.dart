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

  // --- NEW: Configuration for the retry mechanism ---
  final _retryOptions = const RetryOptions(
    maxAttempts: 3, // Number of retry attempts
    delayFactor: Duration(seconds: 1), // Delay between retries
    maxDelay: Duration(seconds: 3), // Maximum delay
  );

  // --- MODIFIED: All public methods now use the _makeRequestWithRetry wrapper ---

  Future<ResponseData> getRequest(String endpoint, {String? token, bool treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('GET Request: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-type': 'application/json',
        },
      );
      return _handleResponse(response, treat404AsEmpty: treat404AsEmpty, emptyPayload: emptyPayload);
    });
  }

  Future<ResponseData> multipartRequest(String endpoint, {String method = 'POST', required Map<String, String> body, String? token, File? photo, List<File>? documents}) {
    return _makeRequestWithRetry(() async {
      log('Multipart Request: $endpoint');
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
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    });
  }

  Future<ResponseData> getRequestWithBody(String endpoint, {Map<String, dynamic>? body, String? token, bool treat404AsEmpty = false, dynamic emptyPayload}) {
    return _makeRequestWithRetry(() async {
      log('GET Request with body: $endpoint');
      final request = http.Request('GET', Uri.parse(endpoint));
      request.headers.addAll({
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      final req = http.Request('DELETE', Uri.parse(endpoint));
      req.headers.addAll({
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (body != null) req.body = jsonEncode(body);
      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    });
  }

  // --- NEW: Central wrapper for all requests ---
  Future<ResponseData> _makeRequestWithRetry(Future<ResponseData> Function() request) async {
    // 1. Check for internet connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      log('No internet connection.');
      return ResponseData(
        isSuccess: false,
        statusCode: -1, // Custom status code for no network
        errorMessage: 'No internet connection. Please check your settings.', responseData: null,
      );
    }

    // 2. Use the retry package to attempt the request
    try {
      return await _retryOptions.retry(
        request,
        retryIf: (e) => e is SocketException || e is TimeoutException || e is http.ClientException,
        onRetry: (e) => log('Retrying request after error: $e'),
      );
    } on SocketException catch (e) {
      log('Network error after all retries: $e');
      return ResponseData(
        isSuccess: false,
        statusCode: -1,
        errorMessage: 'Failed to connect. Please check your internet connection.', responseData: null,
      );
    } on TimeoutException catch (e) {
      log('Request timed out after all retries: $e');
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        errorMessage: 'The connection timed out. Please try again.', responseData: null,
      );
    } catch (e) {
      log('An unexpected error occurred during the request: $e');
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'An unexpected error occurred: $e', responseData: null,
      );
    }
  }

  // Your existing _handleResponse, _refreshToken, _retryRequest, and other methods remain the same.
  // ... (paste your existing private methods here)
  
  Future<ResponseData> _handleResponse(http.Response response, {
  bool treat404AsEmpty = false,
  dynamic emptyPayload,
}) async {
    log('Response Status: ${response.statusCode}');
    log('Response Body: ${response.body}');

    // ---  NEW: Token Refresh Logic ---
    // Intercept 401 Unauthorized errors *before* the switch statement.
    if (response.statusCode == 401) {
      // If a refresh is already in progress, queue this request and wait for it to complete.
      if (_isRefreshing) {
        final completer = Completer<ResponseData>();
        _pendingRequests.add(completer);
        return completer.future;
      }

      _isRefreshing = true;

      // Attempt to get a new access token using the refresh token.
      final bool refreshedSuccessfully = await _refreshToken();

      _isRefreshing = false; // Mark refreshing as complete

      if (refreshedSuccessfully) {
        // If refresh succeeded, retry the original failed request with the new token.
        final newResponse = await _retryRequest(response.request!);

        // Fulfill all pending requests with the new response.
        for (var completer in _pendingRequests) {
          completer.complete(newResponse);
        }
        _pendingRequests.clear();

        return newResponse; // Return the response from the retried request.
      } else {
        // If refresh failed, log out the user.
        await AuthService.logoutUser();

        // Reject all pending requests.
        for (var completer in _pendingRequests) {
          completer.completeError('Token refresh failed');
        }
        _pendingRequests.clear();

        return ResponseData(
          isSuccess: false,
          statusCode: 401,
          errorMessage: 'You are not authorized. Please log in to continue.',
          responseData: null,
        );
      }
    }
    // --- End of new logic ---

    final code = response.statusCode;
    final raw = response.body;

    // ✅ 204 or empty body: don’t decode
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
      statusCode: 200,           // normalize so global “error banners” don’t fire
      responseData: emptyPayload ?? [],
      errorMessage: '',
    );
  }

    // Try to decode JSON only when present
    dynamic decoded = raw;
    try {
      final ct = response.headers['content-type'] ?? '';
      if (ct.contains('application/json')) decoded = jsonDecode(raw);
    } catch (_) {
      // leave decoded as raw string
    }

    // Success range
    if (code >= 200 && code < 300) {
      return ResponseData(
        isSuccess: true,
        statusCode: code,
        responseData: decoded,
        errorMessage: '',
      );
    }

    // Auth / common errors
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
          errorMessage: extractErrorMessage(raw), // instead of hard-coded text
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
          // Try to extract a helpful message from the body first
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
      final String? refreshToken = AuthService.refreshToken;
      if (refreshToken == null) {
        log('No refresh token found.');
        return false;
      }

      final http.Response response = await http.post(
        Uri.parse(AppUrls.refreshToken), // Using the URL you added
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      log('Refresh Token Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];
        // Some backends might also return a new refresh token (token rotation)
        final newRefreshToken = responseData['refresh'];

        // Save the new tokens using your AuthService
        await AuthService.saveToken(
          newAccessToken,
          newRefreshToken ??
              refreshToken, // Use new refresh token if available, otherwise keep the old one
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

  // ---  NEW: Method to retry a failed request ---
  Future<ResponseData> _retryRequest(http.BaseRequest request) async {
    final client = http.Client();

    // Create a new request from the original one
    final newRequest = http.Request(request.method, request.url);
    newRequest.headers.addAll(request.headers);

    //  Update the Authorization header with the NEW access token
    newRequest.headers['Authorization'] = 'Bearer ${AuthService.accessToken}';

    // Copy the body if it exists
    if (request is http.Request && request.body.isNotEmpty) {
      newRequest.body = request.body;
    }

    log('Retrying request to ${request.url}');
    final streamedResponse = await client.send(newRequest);
    final response = await http.Response.fromStream(streamedResponse);

    // Handle the response of the retried request (it could still fail)
    return _handleResponse(response);
  }

  // Handle errors during the request process
  ResponseData _handleError(dynamic error) {
    log('Request Error: $error');

    if (error is TimeoutException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 408,
        errorMessage:
            'Request timed out. Please check your internet connection and try again.',
        responseData: null,
      );
    } else if (error is http.ClientException) {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage:
            'Network error occurred. Please check your connection and try again.',
        responseData: null,
      );
    } else {
      return ResponseData(
        isSuccess: false,
        statusCode: 500,
        errorMessage: 'Unexpected error occurred. Please try again later.',
        responseData: null,
      );
    }
  }

  String extractErrorMessage(String body) {
    try {
      final decoded = json.decode(body);

      // Django REST Framework common shapes:

      // 1) {"detail": "Something"}  OR {"non_field_errors": ["..."]}
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] is String) return decoded['detail'];

        // 2) Field errors: {"email": ["user with this email already exists."]}
        if (decoded.values.any((v) => v is List)) {
          final buf = StringBuffer();
          decoded.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              final msg = value.first.toString();
              // prettify key
              final prettyKey = key == 'non_field_errors'
                  ? ''
                  : '${key[0].toUpperCase()}${key.substring(1)}: ';
              buf.writeln('$prettyKey$msg');
            }
          });
          final text = buf.toString().trim();
          if (text.isNotEmpty) return text;
        }

        // 3) Flat strings map: {"error": "message"}
        final firstString = decoded.values.firstWhere(
          (v) => v is String,
          orElse: () => null,
        );
        if (firstString is String && firstString.isNotEmpty) return firstString;
      }

      // If it's just a string JSON, return it
      if (decoded is String && decoded.isNotEmpty) return decoded;
    } catch (_) {
      // body wasn't JSON; fall through
    }
    // ultimate fallback
    return 'Something went wrong. Please try again.';
  }
}