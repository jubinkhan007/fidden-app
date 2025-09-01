import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'
    as http; // Use the standard http package with an alias
import '../models/response_data.dart';
import 'Auth_service.dart';

class NetworkCaller {
  final int timeoutDuration = 30;

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
          errorMessage: 'User already exists.',
          responseData: null,
        );
      case 400:
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: 'Bad request.',
          responseData: null,
        );
      case 500:
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: 'Internal server error. Please try again later.',
          responseData: null,
        );
      default:
        final msg = (decoded is Map && decoded['detail'] != null)
            ? decoded['detail'].toString()
            : (decoded is Map && decoded['error'] != null)
            ? decoded['error'].toString()
            : 'Something went wrong. Please try again.';
        return ResponseData(
          isSuccess: false,
          statusCode: code,
          errorMessage: msg,
          responseData: null,
        );
    }
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
}
