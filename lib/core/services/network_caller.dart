import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import '../models/response_data.dart';
import 'Auth_service.dart';

class NetworkCaller {
  final int timeoutDuration = 30;
  static bool _isRefreshing = false;
  static final List<Completer<ResponseData>> _pendingRequests = [];

  Future<ResponseData> getRequest(String endpoint, {String? token}) async {
    log('GET Request: $endpoint');
    try {
      final http.Response response = await http
          .get(
            // Use the 'http' alias
            Uri.parse(endpoint),
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
              'Content-type': 'application/json',
            },
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ✅ New method for GET with a body
  Future<ResponseData> getRequestWithBody(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('GET Request with body: $endpoint');
    log('Request Body: ${jsonEncode(body)}');
    try {
      // Use the Request class from the http package
      final request = http.Request('GET', Uri.parse(endpoint));
      request.headers.addAll({
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamedResponse = await request.send();
      // Use the Response class from the http package
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('POST Request: $endpoint');
    log('Request Body: ${jsonEncode(body)}');

    try {
      final http.Response response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
              'Content-Type': 'application/json', // <- use this canonical key
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutDuration));

      // ✅ One path: centralize in _handleResponse
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseData> putRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('PUT Request: $endpoint');
    log('Request Body: ${jsonEncode(body)}');

    try {
      final http.Response response = await http
          .put(
            // Use the 'http' alias
            Uri.parse(endpoint),
            headers: {
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
              'Content-type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // services/network_caller.dart
  Future<ResponseData> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    log('DELETE Request: $endpoint');
    log('Request Body: ${jsonEncode(body)}');
    try {
      // Use Request so we can send a body with DELETE
      final req = http.Request('DELETE', Uri.parse(endpoint));
      req.headers.addAll({
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      if (body != null) req.body = jsonEncode(body);

      final streamed = await req.send().timeout(
        Duration(seconds: timeoutDuration),
      );
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Handle the response from the server
  Future<ResponseData> _handleResponse(http.Response response) async {
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
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: 'The resource you are looking for was not found.',
          responseData: null,
        );
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
