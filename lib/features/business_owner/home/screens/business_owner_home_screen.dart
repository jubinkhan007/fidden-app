import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/business_owner/home/screens/reminder_screen.dart';
import 'package:fidden/features/splash/controller/splash_controller.dart';
import 'package:fidden/features/user/booking/presentation/screens/view_waiver_form_screen.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../core/utils/constants/icon_path.dart';
import '../../../../routes/app_routes.dart';
import '../controller/business_owner_controller.dart';
import '../simmer/business_owner_home_shimmer.dart';
import 'all_booking_list_screen.dart';
import 'all_service_screen.dart';

class BusinessOwnerHomeScreen extends StatelessWidget {
  const BusinessOwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessOwnerController>();
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (controller.isLoading.value) {
                return FullScreenShimmerLoader();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                profileController
                                        .profileDetails
                                        .value
                                        .data
                                        ?.image !=
                                    null
                                ? NetworkImage(
                                    profileController
                                        .profileDetails
                                        .value
                                        .data!
                                        .image!,
                                  )
                                : AssetImage(ImagePath.profileImage)
                                      as ImageProvider,
                          ),
                          SizedBox(width: getWidth(10)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text:
                                    "Hello, ${profileController.profileDetails.value.data?.name ?? ''}",
                                color: Color(0xff2D2D2D),
                                fontWeight: FontWeight.bold,
                                fontSize: getWidth(18),
                              ),
                              CustomText(
                                text: SplashController.address.value,
                                color: Color(0xff2D2D2D),
                                fontWeight: FontWeight.w400,
                                fontSize: getWidth(14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoute.notificationScreen);
                        },
                        child: Image.asset(
                          IconPath.notificationIcon,
                          height: getHeight(25),
                          width: getWidth(25),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getWidth(24)),
                  CustomText(
                    text: "Special Offer",
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111827),
                    fontSize: getWidth(18),
                  ),
                  SizedBox(height: getHeight(16)),
                  SizedBox(
                    height: getHeight(230),
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: controller.pageController,
                            itemCount: controller.discountedServices.length,
                            itemBuilder: (context, index) {
                              final offer =
                                  controller.discountedServices[index];
                              final price =
                                  double.tryParse(offer.price ?? '0') ?? 0.0;
                              final discount =
                                  double.tryParse(offer.discountPrice ?? '0') ??
                                  0.0;
                              final discountPercent = price > 0
                                  ? ((price - discount) / price * 100).round()
                                  : 0;

                              return Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        children: [
                                          if (offer.serviceImg != null &&
                                              offer.serviceImg
                                                  .toString()
                                                  .isNotEmpty)
                                            Image.network(
                                              offer.serviceImg.toString(),
                                              width: double.infinity,
                                              height: 230,
                                              fit: BoxFit.cover,
                                            )
                                          else
                                            Container(
                                              width: double.infinity,
                                              height: 230,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 60,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.deepPurple.withOpacity(
                                                    0.6,
                                                  ),
                                                  Colors.transparent,
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.pinkAccent,
                                            Colors.orangeAccent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        "$discountPercent% OFF",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black45,
                                              blurRadius: 4,
                                              offset: Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40,
                                    left: 14,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          offer.title ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: getWidth(18),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 200,
                                          child: Text(
                                            offer.description ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: getWidth(14),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 14,
                                    left: 14,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "\$${price.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white70,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "\$${discount.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightGreenAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: getHeight(12)),
                        SmoothPageIndicator(
                          controller: controller.pageController,
                          count: controller.discountedServices.length,
                          effect: WormEffect(
                            activeDotColor: Color(0xffDC143C),
                            dotColor: Color(0xff898989).withOpacity(0.4),
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "My Services",
                        fontWeight: FontWeight.w600,
                        color: Color(0xff111827),
                        fontSize: getWidth(18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => AllServiceScreen());
                        },
                        child: CustomText(
                          text: "See All",
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                          color: Color(0xff898989),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getHeight(12)),
                  _buildServiceSelection(controller),
                  SizedBox(height: getHeight(0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Booking List",
                        fontWeight: FontWeight.w600,
                        color: Color(0xff111827),
                        fontSize: getWidth(18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => AllBookingListScreen());
                        },
                        child: CustomText(
                          text: "See All",
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                          color: Color(0xff898989),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getHeight(24)),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:
                        (controller
                                    .allBusinessOwnerBookingOne
                                    .value
                                    .data
                                    ?.length ??
                                0) >
                            7
                        ? 5
                        : (controller
                                  .allBusinessOwnerBookingOne
                                  .value
                                  .data
                                  ?.length ??
                              0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: getWidth(20)),
                    itemBuilder: (context, index) {
                      final booking = controller
                          .allBusinessOwnerBookingOne
                          .value
                          .data?[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: getHeight(66),
                                width: getWidth(66),
                                child: CircleAvatar(
                                  backgroundImage: booking?.serviceImage != null
                                      ? NetworkImage(booking!.serviceImage!)
                                      : AssetImage(ImagePath.profileImage)
                                            as ImageProvider,
                                ),
                              ),
                              SizedBox(width: getWidth(20)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text:
                                        (booking?.customerForm != null &&
                                            booking!.customerForm!.isNotEmpty)
                                        ? "${booking.customerForm!.first.firstName ?? ''} ${booking.customerForm!.first.lastName ?? ''}"
                                        : '',
                                    fontSize: getWidth(16),
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(width: getWidth(4)),
                                  CustomText(
                                    text: booking?.serviceName ?? "",
                                    fontSize: getWidth(14),
                                    textOverflow: TextOverflow.ellipsis,
                                    color: Color(0xff898989),
                                  ),
                                  SizedBox(width: getWidth(4)),
                                  CustomText(
                                    text:
                                        "${booking?.bookingTime ?? ''} , ${formattedDate(booking?.bookingDate.toString() ?? "")}",
                                    fontSize: getWidth(14),
                                    textOverflow: TextOverflow.ellipsis,
                                    color: Color(0xff898989),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => AddReminderScreen(
                                      userId:
                                          booking?.customerForm?.first.userId ??
                                          '',
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xff7A49A5).withOpacity(0.72),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: getWidth(10),
                                      right: getWidth(10),
                                      top: getHeight(4),
                                      bottom: getHeight(4),
                                    ),
                                    child: CustomText(
                                      text: "Reminder",
                                      color: Color(0xffF4F4F4),
                                      fontSize: getWidth(14),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: getHeight(15)),
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => ViewWaiverFormScreen(
                                      bookingId: booking?.id ?? '',
                                    ),
                                  );
                                },
                                child: Text(
                                  "View Form",
                                  style: TextStyle(
                                    fontSize: getWidth(15),
                                    color: Color(0xff898989),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xff898989),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: getHeight(24)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  String formattedDate(String date) {
    if (date.isEmpty) {
      return '';
    }
    DateTime dt = DateTime.parse(date);
    return DateFormat("d MMMM yy").format(dt);
  }
}

Widget _buildServiceSelection(BusinessOwnerController controller) {
  return SizedBox(
    height: getHeight(100),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: controller.allServiceList.length,
      separatorBuilder: (context, index) => SizedBox(width: getWidth(8)),
      itemBuilder: (context, index) {
        final service = controller.allServiceList[index];
        return Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(service.serviceImg ?? ''),
            ),
            SizedBox(height: 5),
            Text(
              service.title ?? "",
              style: TextStyle(
                fontSize: getWidth(14),
                fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    ),
  );
}
