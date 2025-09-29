import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/commom/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/Auth_service.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../business_owner/nav_bar/presentation/screens/user_nav_bar.dart'
    as owner_nav;
import '../../user/nav_bar/presentation/screens/user_nav_bar.dart' as user_nav;

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;
  var obscurePassword = true.obs;

  bool _loggingIn = false;

  void toggleRememberMe() => rememberMe.value = !rememberMe.value;

  void togglePasswordVisibility(RxBool obscureVar) {
    obscureVar.value = !obscureVar.value;
  }

  String _friendlyApiError(
    dynamic data, {
    String fallback = 'Something went wrong',
  }) {
    try {
      if (data is Map) {
        if (data['message'] is String &&
            data['message'].toString().trim().isNotEmpty) {
          return data['message'];
        }
        if (data['detail'] is String &&
            data['detail'].toString().trim().isNotEmpty) {
          return data['detail'];
        }
        if (data['non_field_errors'] is List &&
            (data['non_field_errors'] as List).isNotEmpty) {
          return (data['non_field_errors'] as List).join(', ');
        }
        if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
          final first = (data['errors'] as Map).values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
      if (data is String && data.trim().isNotEmpty) return data;
    } catch (_) {}
    return fallback;
  }

  Future<void> login() async {
    if (_loggingIn) return;
    _loggingIn = true;

    showProgressIndicator();

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        validateStatus: (s) => s != null && s < 500,
        headers: {'Accept': 'application/json'},
      ),
    );

    final body = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    try {
      final res = await dio.post(
        AppUrls.login,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );

      final data = res.data is Map
          ? Map<String, dynamic>.from(res.data as Map)
          : jsonDecode(res.data as String) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        final accessToken = data["accessToken"] .toString();
        final refreshToken = data["refreshToken"] .toString();
        final role = (data["role"] ?? data["user"]?["role"])?.toString();

        if (accessToken == null) {
          // ⬇️ hide first, then snackbar
          hideProgressIndicator();
          AppSnackBar.showError('No access token from server.');
          return;
        }

        await AuthService.saveToken(
          accessToken,
          refreshToken ?? '',
          role ?? '',
        );

        // ⬇️ hide before snackbar & navigation
        await AuthService.registerDeviceIfNeeded();
        hideProgressIndicator();
        AppSnackBar.showSuccess(data["message"]?.toString() ?? "Logged in");

        final r = (role ?? '').toUpperCase();
        if (r == "USER") {
          await Get.offAll(() => const user_nav.UserNavBar());
        } else if (r == "OWNER") {
          await Get.offAll(() => const owner_nav.BusinessOwnerNavBar());
        } else {
          await Get.offAll(() => const user_nav.UserNavBar());
        }
        return;
      }

      // Non-200 (<500): ⬇️ hide first, then snackbar
      hideProgressIndicator();
      final msg = _friendlyApiError(data, fallback: 'Login failed');
      AppSnackBar.showError(msg);
    } on DioException catch (e) {
      // ⬇️ hide first, then snackbar
      hideProgressIndicator();
      final msg = _friendlyApiError(
        e.response?.data,
        fallback: 'Network error',
      );
      AppSnackBar.showError(msg);
    } catch (e, st) {
      // ⬇️ hide first, then snackbar
      hideProgressIndicator();
      log('Login error: $e\n$st');
      AppSnackBar.showError('Unexpected error: $e');
    } finally {
      // Safe even if already hidden
      hideProgressIndicator();
      _loggingIn = false;
    }
  }
}
