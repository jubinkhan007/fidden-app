import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/features/user/booking/presentation/screens/view_waiver_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../core/utils/constants/image_path.dart';
import '../../controller/booking_controller.dart';
import 'booking_details_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.put(BookingController());

    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      appBar: AppBar(
        title: CustomText(
          text: "Booking Screen",
          fontWeight: FontWeight.w700,
          fontSize: getWidth(20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
        child: Column(
          children: [
            Obx(
              () => Container(
                padding: EdgeInsets.symmetric(horizontal: getWidth(6)),
                decoration: BoxDecoration(
                  color: Color(0xffDC143C),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => controller.toggleTab(true),
                        style: TextButton.styleFrom(
                          backgroundColor: controller.isActiveBooking.value
                              ? Colors.white
                              : Color(0xffDC143C),
                        ),
                        child: Text(
                          "Active Booking",
                          style: TextStyle(
                            color: controller.isActiveBooking.value
                                ? Color(0xff0F172A)
                                : Colors.white,
                            fontSize: getWidth(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => controller.toggleTab(false),
                        style: TextButton.styleFrom(
                          backgroundColor: !controller.isActiveBooking.value
                              ? Colors.white
                              : Color(0xffDC143C),
                        ),
                        child: Text(
                          "History",
                          style: TextStyle(
                            color: !controller.isActiveBooking.value
                                ? Color(0xff0F172A)
                                : Colors.white,
                            fontSize: getWidth(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getHeight(24)),
            Obx(
              () => controller.isActiveBooking.value
                  ? Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(child: ShowProgressIndicator());
                        }

                        final data =
                            controller.allUserBookingDetails.value.data;

                        debugPrint(
                          "------------------------------------------------------------------------------------",
                        );

                        debugPrint(data.toString());

                        if (data == null || data.isEmpty) {
                          return Center(
                            child: CustomText(
                              text: "No Active Booking",
                              color: Colors.grey,
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount:
                              controller
                                  .allUserBookingDetails
                                  .value
                                  .data
                                  ?.length ??
                              0,
                          separatorBuilder: (_, __) => SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            final shop = controller
                                .allUserBookingDetails
                                .value
                                .data?[index];
                            return Container(
                              // color: Color(0xffFFFFFF),
                              decoration: BoxDecoration(
                                //color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Card(
                                color: Color(0xffFFFFFF),
                                elevation: 0,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    top: 12,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: shop?.serviceImage != null
                                                ? Image.network(
                                                    shop?.serviceImage ?? '',
                                                    width: getWidth(100),
                                                    height: getHeight(80),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    "assets/images/barber_image.png",
                                                    width: getWidth(100),
                                                    height: getHeight(80),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  shop?.serviceName ?? '',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    //color: Color(0xff111827),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 16,
                                                      color: Color(0xff7A49A5),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        shop?.businessAddress ??
                                                            '',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          //color: Color(0xff7A49A5),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                shop?.review == 0
                                                    ? Image.asset(
                                                        ImagePath.newImage,
                                                        width: getWidth(40),
                                                        height: getHeight(16),
                                                      )
                                                    : Row(
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            size: 16,
                                                            color: Color(
                                                              0xff7A49A5,
                                                            ),
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            shop?.review
                                                                    ?.toStringAsFixed(
                                                                      2,
                                                                    ) ??
                                                                '',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              //color: Color(0xff7A49A5),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: getHeight(10)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => ViewWaiverFormScreen(
                                                  bookingId: shop?.id ?? '',
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "View Form",
                                              style: TextStyle(
                                                fontSize: getWidth(16),
                                                color: Color(0xff7A49A5),
                                                fontFamily: 'Raleway',
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => BookingDetailsScreen(
                                                  shop1: shop,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: getWidth(18),
                                                vertical: getHeight(8),
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "Done",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    )
                  : Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(child: ShowProgressIndicator());
                        }

                        final data =
                            controller.allUserCompleteBookingDetails.value.data;

                        debugPrint(
                          "------------------------------------------------------------------------------------",
                        );

                        debugPrint(data.toString());

                        if (data == null || data.isEmpty) {
                          return Center(
                            child: CustomText(
                              text: "No booking history",
                              color: Colors.grey,
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount:
                              controller
                                  .allUserCompleteBookingDetails
                                  .value
                                  .data
                                  ?.length ??
                              0,
                          separatorBuilder: (_, __) => SizedBox(height: 0),
                          itemBuilder: (context, index) {
                            final shop = controller
                                .allUserCompleteBookingDetails
                                .value
                                .data?[index];
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: shop?.serviceImage != null
                                              ? Image.network(
                                                  shop?.serviceImage ?? '',
                                                  width: getWidth(100),
                                                  height: getHeight(80),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  "assets/images/barber_image.png",
                                                  width: getWidth(100),
                                                  height: getHeight(80),
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                shop?.serviceName ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Color(0xff7A49A5),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      shop?.businessAddress ??
                                                          '',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              shop?.review == 0
                                                  ? Image.asset(
                                                      ImagePath.newImage,
                                                      width: getWidth(40),
                                                      height: getHeight(16),
                                                    )
                                                  : Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          size: 16,
                                                          color: Color(
                                                            0xff7A49A5,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          shop?.review
                                                                  ?.toStringAsFixed(
                                                                    2,
                                                                  ) ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: getHeight(10)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(
                                              () => ViewWaiverFormScreen(
                                                bookingId: shop?.id ?? '',
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "View Form",
                                            style: TextStyle(
                                              fontSize: getWidth(16),
                                              color: Color(0xff898989),
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        // GestureDetector(
                                        //   onTap: () {
                                        //     Get.to(() => BookingDetailsScreen(shop1: shop,));
                                        //   },
                                        //   child: Container(
                                        //     padding: EdgeInsets.symmetric(
                                        //         horizontal: getWidth(18),
                                        //         vertical: getHeight(8)),
                                        //     decoration: BoxDecoration(
                                        //       color: AppColors.primaryColor,
                                        //       borderRadius: BorderRadius.circular(8),
                                        //     ),
                                        //     child: Text(
                                        //       "Done",style: TextStyle(fontSize: 16,
                                        //       fontWeight: FontWeight.w700,
                                        //       color: Colors.white,),
                                        //
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
