import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
// import 'package:fidden/features/user/booking/presentation/screens/booking_screen.dart';
// import 'package:fidden/features/user/home/presentation/screens/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../user/profile/presentation/screens/profile_screen.dart';
// import '../../booking/screen/booking_screen.dart';
// import '../../home/screens/business_owner_home_screen.dart';
// import '../../profile/screens/business_owner_profile_screen.dart';

class BusinessOwnerNavBarController extends GetxController {
  final _selectedIndex = 0.obs;

  int get currentIndex => _selectedIndex.value;

  void changeIndex(int index) {
    _selectedIndex.value = index;
  }

  // final List<Widget> screens = [
  //   BusinessOwnerHomeScreen (),
  //   BusinessOwnerBookingScreen(),
  //   BusinessOwnerProfileScreen()
  // ];

  final List<String> labels = const ['Home', "Booking", 'Profile'];

  final List activeIcons = [
    Image.asset(IconPath.homeActive, height: getWidth(24), width: getWidth(24)),
    Image.asset(
      IconPath.bookingActive,
      height: getWidth(24),
      width: getWidth(24),
    ),
    Image.asset(
      IconPath.profileActive,
      height: getWidth(24),
      width: getWidth(24),
    ),
  ];

  final List inActiveIcons = [
    Image.asset(
      IconPath.homeInActive,
      height: getWidth(20),
      width: getWidth(20),
    ),
    Image.asset(
      IconPath.bookingInActive,
      height: getWidth(20),
      width: getWidth(20),
    ),
    Image.asset(
      IconPath.profileInActive,
      height: getWidth(20),
      width: getWidth(20),
    ),
  ];
}
