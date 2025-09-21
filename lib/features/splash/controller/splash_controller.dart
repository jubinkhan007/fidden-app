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

  void navigateToOnboardingScreen() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (AuthService.hasSeenOnboarding()) {
        if (AuthService.hasToken()) {
          final userRole = AuthService.role?.trim().toUpperCase();
          debugPrint(userRole.toString());

          if (userRole == "USER") {
            Get.offAll(() => UserNavBar());
          } else {
            Get.offAll(() => BusinessOwnerNavBar());
          }
        } else {
          // Onboarding seen but no token — go to common screen (login/register)
          Get.offAll(
                () => LoginScreen(),
            transition: Transition.fade,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        // Onboarding not seen — show onboarding first
        Get.offAll(
              () => const OnboardingScreenOne(),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onInit() {
    super.onInit();

    // After getting location, navigate
    _requestPermissionsAndFetchLocation().then((_) {
      navigateToOnboardingScreen();
    });
  }

  static var latitude = 0.0.obs;
  static var longitude = 0.0.obs;
  static var address = ''.obs;

  Future<void> _requestPermissionsAndFetchLocation() async {
    // 1. Request Notification Permission (if not already requested)
    final prefs = await SharedPreferences.getInstance();
    final bool hasBeenRequested = prefs.getBool(_permissionRequestedKey) ?? false;
    final notificationStatus = await Permission.notification.status;

    if (!hasBeenRequested || (!notificationStatus.isGranted && !notificationStatus.isPermanentlyDenied)) {
      await Permission.notification.request();
      await prefs.setBool(_permissionRequestedKey, true);
    }

    // 2. Request Location Permission and Fetch Location
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      // You might want to show a dialog to the user here
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      // You might want to show a dialog to the user here
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      debugPrint('Latitude: ${latitude.value}');
      debugPrint('Longitude: ${longitude.value}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        String fullAddress = [
          placemark.administrativeArea,
          placemark.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        address.value = fullAddress;
        debugPrint('Address: $fullAddress');
      } else {
        debugPrint('No placemarks found for the location.');
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }
  }
}