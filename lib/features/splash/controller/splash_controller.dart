// lib/features/splash/controller/splash_controller.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/Auth_service.dart';
import '../../auth/presentation/screens/login/login_screen.dart';
import '../../business_owner/nav_bar/presentation/screens/user_nav_bar.dart';
import '../../user/nav_bar/presentation/screens/user_nav_bar.dart';
import '../presentation/screens/onboarding_screen_one.dart';

class SplashController extends GetxController {
  static const _permissionRequestedKey = 'notification_permission_requested';

  static var latitude = 0.0.obs;
  static var longitude = 0.0.obs;
  static var address = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for a minimum amount of time to show the splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Ensure Auth Service is ready before navigating
    await _ensureAuthReady();

    // Navigate to the correct screen
    _navigate();

    // Request permissions in the background
    _requestPermissionsAndFetchLocation();
  }

  Future<void> _ensureAuthReady() async {
    try {
      await AuthService.init();
    } catch (e) {
      debugPrint('[boot] AuthService.init error: $e');
    }
  }

  void _navigate() {
    final seen = AuthService.hasSeenOnboarding();
    final hasToken = AuthService.hasToken();

    if (!seen) {
      Get.offAll(
        () => const OnboardingScreenOne(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    if (hasToken) {
      final role = (AuthService.role ?? '').trim().toUpperCase();
      if (role == 'USER') {
        Get.offAll(() => UserNavBar());
      } else {
        Get.offAll(() => BusinessOwnerNavBar());
      }
    } else {
      Get.offAll(
        () => LoginScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _requestPermissionsAndFetchLocation() async {
    // ---- Notifications (non-blocking) ----
    try {
      final prefs = await SharedPreferences.getInstance();
      final requested = prefs.getBool(_permissionRequestedKey) ?? false;
      final status = await Permission.notification.status;

      if (!requested || (!status.isGranted && !status.isPermanentlyDenied)) {
        await Permission.notification.request();
        await prefs.setBool(_permissionRequestedKey, true);
      }
    } catch (e) {
      debugPrint('Notification perm error: $e');
    }

    // ---- Location (non-blocking; bail early on any issue) ----
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          p.administrativeArea ?? '',
          p.country ?? '',
        ].where((s) => s.trim().isNotEmpty).toList();

        address.value = parts.join(', ');
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }
  }
}