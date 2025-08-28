import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../core/utils/constants/icon_path.dart';

import '../../data/user_booking_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, this.shop1});

  final UserBookingDatum? shop1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: CustomText(
          text: "Booking Screen",
          fontWeight: FontWeight.w700,
          fontSize: getWidth(20),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: getWidth(10),
                  right: getWidth(8),
                  top: getHeight(8),
                  bottom: getHeight(8),
                ),
                decoration: BoxDecoration(
                  color: Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: shop1?.serviceImage != null
                          ? Image.network(
                              shop1?.serviceImage ?? '',
                              width: getWidth(100),
                              height: getHeight(80),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/images/barber_image.png",
                              width: getWidth(100),
                              height: getHeight(100),
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: getWidth(250),
                          child: Text(
                            shop1?.serviceName ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff111827),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xff7A49A5).withOpacity(0.7),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 230,
                              child: Text(
                                shop1?.businessAddress ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff7A49A5).withOpacity(0.7),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xff7A49A5).withOpacity(0.7),
                            ),
                            SizedBox(width: 8),
                            Text(
                              shop1?.review?.toStringAsFixed(2) ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff7A49A5).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: getHeight(24)),
              Image.asset(
                "assets/images/date_time.png",
                height: getHeight(35),
                width: getWidth(115),
                color: Colors.blue,
              ),
              CustomText(
                text:
                    "${_formatDate(shop1?.bookingDate.toString() ?? '')} - ${shop1?.bookingTime ?? ""}",
                color: const Color(0xff6B7280),
                fontSize: getWidth(14),
              ),
              SizedBox(height: getHeight(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    IconPath.serviceIcon,
                    height: getHeight(18),
                    width: getWidth(18),
                  ),
                  SizedBox(width: getWidth(8)),
                  CustomText(
                    text: "Service selected",
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                  height: getHeight(50),
                  width: getWidth(50),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/barber_image.png",
                    ),
                  ),
                ),
                title: Text(
                  shop1?.serviceName ?? '',
                  style: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  "\$ ${shop1?.servicePrice.toString() ?? ''}",
                  style: TextStyle(fontSize: getWidth(14)),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height / 2.25),
              CustomButton(
                onPressed: () {
                  // Get.to(
                  //   () => PaymentMethodScreen(
                  //     shop1: shop1,
                  //   ),
                  //   transition: Transition.rightToLeftWithFade,
                  //   duration: Duration(milliseconds: 400),
                  //   curve: Curves.easeOut,
                  // );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pay now",
                      style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: getWidth(10)),
                    Image.asset(
                      IconPath.waletIcon,
                      height: getHeight(22),
                      width: getWidth(22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('EEE, d MMM').format(date); // Ex: Sun, 15 Jan
    } catch (e) {
      return "";
    }
  }
}
