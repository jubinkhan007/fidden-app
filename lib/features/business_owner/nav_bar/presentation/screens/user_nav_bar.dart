import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import '../../../../../core/common/styles/get_text_style.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../controllers/user_nav_bar_controller.dart';

class BusinessOwnerNavBar extends StatelessWidget {
  const BusinessOwnerNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: GetX<BusinessOwnerNavBarController>(
      //   init: BusinessOwnerNavBarController(),
      //   builder: (driverNavBarController) =>
      //       driverNavBarController.screens[driverNavBarController.currentIndex],
      // ),
      bottomNavigationBar: GetX<BusinessOwnerNavBarController>(
        builder: (navController) {
          return BottomNavigationBar(
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
