import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/fallBack_image.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/features/business_owner/home/screens/reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/constants/image_path.dart';
import '../../../user/booking/presentation/screens/view_waiver_form_screen.dart';
import '../../home/controller/business_owner_controller.dart';

class CircleNetAvatar extends StatelessWidget {
  const CircleNetAvatar({
    super.key,
    required this.url,
    this.size = 66,
  });

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipOval(
        child: NetThumb(
          url: url,
          w: size,
          h: size,
          borderRadius: size / 2, // not strictly needed; ClipOval already clips
        ),
      ),
    );
  }
}


class BusinessOwnerBookingScreen extends StatelessWidget {
  const BusinessOwnerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessOwnerController());
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('All Bookings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getHeight(19)),
            Obx(() {
  if (controller.isLoading.value == true) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: getHeight(300)),
          const ShowProgressIndicator(),
        ],
      ),
    );
  }

  final results = controller.allBusinessOwnerBookingOne.value.results;

  if (results.isEmpty) {
    return Center(
      child: CustomText(
        text: "No Booking Found",
        fontSize: getWidth(16),
      ),
    );
  }

  return ListView.separated(
    padding: EdgeInsets.only(
      left: getWidth(22),
      right: getWidth(22),
      top: getHeight(10),
    ),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: results.length,
    separatorBuilder: (context, index) => SizedBox(height: getWidth(20)),
    itemBuilder: (context, index) {
  final booking = results[index]; // OwnerBookingItem
  final displayName = (booking.userName?.trim().isNotEmpty == true)
      ? booking.userName!.trim()
      : booking.userEmail;
  final when =
      "${DateFormat('hh:mm a').format(booking.slotTime)} , ${DateFormat('d MMMM yy').format(booking.slotTime)}";

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Avatar (safe fallback)
      CircleNetAvatar(
        url: booking.profileImage,
        size: getWidth(66),
      ),
      SizedBox(width: getWidth(16)),

      // Text column should be flexible so it doesn't overflow
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: displayName,
              fontSize: getWidth(16),
              textOverflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: getHeight(4)),
            CustomText(
              text: booking.serviceTitle,
              fontSize: getWidth(14),
              textOverflow: TextOverflow.ellipsis,
              color: const Color(0xff898989),
            ),
            SizedBox(height: getHeight(4)),
            CustomText(
              text: when,
              fontSize: getWidth(14),
              textOverflow: TextOverflow.ellipsis,
              color: const Color(0xff898989),
            ),
          ],
        ),
      ),

      SizedBox(width: getWidth(12)),

      // Actions column stays narrow; no overflow
      Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => AddReminderScreen(
                    userId: booking.user.toString(),
                  ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff7A49A5).withOpacity(0.72),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(10),
                vertical: getHeight(4),
              ),
              child: CustomText(
                text: "Reminder",
                color: const Color(0xffF4F4F4),
                fontSize: getWidth(14),
              ),
            ),
          ),
          SizedBox(height: getHeight(8)),
          // (Keep "View Form" removed per your newer API; add back when API supports it)
        ],
      ),
    ],
  );
},

  );
}),

            // Obx(() => ListView.separated(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: controller.bookings.length,
            //   separatorBuilder: (context, index) => SizedBox(height: getWidth(26),),
            //   itemBuilder: (context, index) {
            //     final booking = controller.bookings[index];
            //     return Padding(
            //       padding:  EdgeInsets.only(left: getWidth(18),right: getWidth(20)),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Row(
            //             children: [
            //               SizedBox(
            //                 height:getHeight(66),
            //                 width:getWidth(66),
            //                 child: CircleAvatar(
            //                   backgroundImage: NetworkImage(booking.imageUrl),
            //                 ),
            //               ),
            //               SizedBox(width: getWidth(20),),
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   CustomText(text: booking.name,fontSize: getWidth(16),textOverflow: TextOverflow.ellipsis,),
            //                   SizedBox(width: getWidth(4),),
            //                   CustomText(text: booking.service,fontSize: getWidth(14),textOverflow: TextOverflow.ellipsis,color: Color(0xff898989),),
            //                   SizedBox(width: getWidth(4),),
            //                   CustomText(text: "${booking.time} with ${booking.stylist}",fontSize: getWidth(14),textOverflow: TextOverflow.ellipsis,color: Color(0xff898989),)
            //
            //                 ],
            //               ),
            //             ],
            //           ),
            //           Column(
            //
            //             children: [
            //               GestureDetector(
            //                 onTap:(){
            //                   Get.to(()=>AddReminderScreen());
            //
            //                 },
            //                 child: Container(
            //                   decoration:BoxDecoration(
            //                       color: Color(0xff7A49A5).withOpacity(0.72),
            //                       borderRadius: BorderRadius.circular(6)
            //                   ),
            //                   child: Padding(
            //                     padding: EdgeInsets.only(left: getWidth(10),right: getWidth(10),top: getHeight(4),bottom: getHeight(4)),
            //                     child: CustomText(text: "Reminder",color: Color(0xffF4F4F4),fontSize: getWidth(14),),
            //                   ),
            //                 ),
            //               ),
            //               SizedBox(height: getHeight(15),),
            //               GestureDetector(
            //                   onTap:(){
            //                     Get.to(()=>ViewWaiverFormScreen());
            //
            //                   },
            //                   child: Text("View Form",style: TextStyle(fontSize: getWidth(15),color: Color(0xff898989),decoration: TextDecoration.underline,decorationColor: Color(0xff898989),),)),
            //
            //
            //
            //
            //             ],
            //           )
            //
            //         ],
            //       ),
            //     );
            //   },
            // )),
          ],
        ),
      ),
    );
  }

  String formattedDate(String date) {
    DateTime dt = DateTime.parse(
      date,
    ); // or directly use booking.bookingDate if it's already DateTime
    return DateFormat("d MMMM yy").format(dt); // Output: 17 April 25
  }
}
