import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_bar_controller.dart';

class UserNavBar extends StatelessWidget {
  const UserNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<UserNavBarController>(
        init: UserNavBarController(),
        builder: (driverNavBarController) =>
            driverNavBarController.screens[driverNavBarController.currentIndex],
      ),
      bottomNavigationBar: GetX<UserNavBarController>(
        builder: (navController) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            //backgroundColor: AppColors.white,
            currentIndex: navController.currentIndex,
            selectedItemColor: const Color(0xff7A49A5),
            unselectedItemColor: const Color(0xff898989),
            showUnselectedLabels: true,
            onTap: navController.changeIndex,
            items: List.generate(navController.activeIcons.length, (index) {
              return BottomNavigationBarItem(
                backgroundColor: Colors.white,
                icon: navController.currentIndex == index
                    ? navController.activeIcons[index]
                    : navController.inActiveIcons[index],
                label: navController.labels[index],
                tooltip: navController.labels[index],
              );
            }),
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: const Color(0xffFCC734),
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: const Color(0xffFCC734),
            ),
          );
        },
      ),
    );
  }
}
