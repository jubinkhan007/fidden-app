// import 'package:fidden/core/commom/widgets/custom_text.dart';
// import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
// import 'package:fidden/core/utils/constants/icon_path.dart';
// import 'package:fidden/features/user/home/controller/book_apoint_ment_controller.dart';
// import 'package:fidden/features/user/home/controller/home_controller.dart';
// import 'package:fidden/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../../../core/utils/constants/app_colors.dart';
// import '../../../../../core/utils/constants/app_sizes.dart';

// class AppointmentScreen extends StatelessWidget {
//   const AppointmentScreen({
//     super.key,
//     required this.controller1,
//     required this.businessId,
//   });

//   final HomeController controller1;
//   final String businessId;

//   @override
//   Widget build(BuildContext context) {
//     final AppointmentController controller = Get.put(AppointmentController());
//     return Scaffold(
//       backgroundColor: Color(0xffF4F4F4),
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(Icons.arrow_back_ios_new_outlined),
//         ),
//         title: CustomText(
//           text: "Book Appointment",
//           fontWeight: FontWeight.w700,
//           fontSize: getWidth(20),
//         ),
//         centerTitle: true,
//         backgroundColor: Color(0xffF4F4F4),
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Choose date",
//                 style: TextStyle(
//                   fontSize: getWidth(16),
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Raleway',
//                 ),
//               ),
//               SizedBox(height: getHeight(12)),
//               _buildCalendar(controller),
//               //SizedBox(height: 20),
//               Text(
//                 "Choose Services",
//                 style: TextStyle(
//                   fontSize: getWidth(17),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               SizedBox(height: getHeight(10)),
//               _buildServiceSelection(controller1, controller),
//               SizedBox(height: getWidth(20)),
//               Text(
//                 "Available time",
//                 style: TextStyle(
//                   fontSize: getWidth(17),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               SizedBox(height: getHeight(10)),
//               _buildTimeSelection(controller),
//               SizedBox(height: getHeight(20)),
//               _buildConfirmButton(controller),
//               SizedBox(height: getHeight(20)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendar(AppointmentController controller) {
//     return Obx(() {
//       final selectedDate = controller.selectedDate.value;
//       final firstDayOfMonth = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         1,
//       );
//       final lastDayOfMonth = DateTime(
//         selectedDate.year,
//         selectedDate.month + 1,
//         0,
//       );
//       final daysInMonth = lastDayOfMonth.day;
//       final startingWeekday = firstDayOfMonth.weekday; // 1 (Mon) - 7 (Sun)

//       return Container(
//         padding: EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
//         child: Column(
//           children: [
//             // Month Navigation
//             Container(
//               padding: EdgeInsets.only(
//                 left: getWidth(18),
//                 right: getWidth(18),
//                 top: getHeight(12),
//                 bottom: getHeight(12),
//               ),
//               decoration: BoxDecoration(
//                 color: Color(0xffEDEFFB),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       controller.selectDate(
//                         DateTime(selectedDate.year, selectedDate.month - 1, 1),
//                       );
//                     },
//                     child: Image.asset(
//                       IconPath.backArrowAppleIcon,
//                       width: getWidth(10),
//                       height: getHeight(14),
//                     ),
//                   ),
//                   Text(
//                     DateFormat.yMMMM().format(selectedDate),
//                     style: TextStyle(
//                       fontFamily: 'Raleway',
//                       fontSize: getWidth(16),
//                       fontStyle: FontStyle.normal,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xff111827),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       controller.selectDate(
//                         DateTime(selectedDate.year, selectedDate.month + 1, 1),
//                       );
//                     },
//                     child: Image.asset(
//                       IconPath.rightArrowAppleIcon,
//                       width: getWidth(20),
//                       height: getHeight(20),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: getHeight(16)),

//             // Weekday Headers
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
//                   .map(
//                     (day) => Text(
//                       day,
//                       style: TextStyle(
//                         fontFamily: 'Raleway',
//                         fontSize: getWidth(14),
//                         fontStyle: FontStyle.normal,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xff111827),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//             SizedBox(height: getHeight(20)),

//             // Dates Grid
//             GridView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 childAspectRatio: 1.2,
//               ),
//               itemCount: daysInMonth + startingWeekday - 1,
//               itemBuilder: (context, index) {
//                 if (index < startingWeekday - 1) {
//                   return SizedBox(); // Empty cells before first day
//                 }
//                 final day = index - startingWeekday + 2;
//                 final date = DateTime(
//                   selectedDate.year,
//                   selectedDate.month,
//                   day,
//                 );
//                 final isSelected = controller.selectedDate.value.day == day;

//                 return GestureDetector(
//                   onTap: () {
//                     controller.selectDate(date);
//                     controller.fetchTime(
//                       businessId: businessId,
//                       date: DateFormat(
//                         'yyyy-MM-dd',
//                       ).format(controller.selectedDate.value),
//                     );
//                   },
//                   child: Center(
//                     child: CircleAvatar(
//                       backgroundColor: isSelected
//                           ? Color(0xff7A49A5)
//                           : Colors.transparent,
//                       child: Text(
//                         "$day",
//                         style: TextStyle(
//                           fontFamily: 'Raleway',
//                           fontSize: getWidth(14),
//                           fontStyle: FontStyle.normal,
//                           fontWeight: FontWeight.w500,
//                           color: isSelected ? Colors.white : Color(0xff111827),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   //

//   Widget _buildServiceSelection(
//     HomeController controller1,
//     AppointmentController controller,
//   ) {
//     return Obx(() {
//       final services =
//           controller1.singleNearestBarBarDetails.value.data?.service ?? [];

//       return SizedBox(
//         height: getHeight(100),
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: services.length,
//           itemBuilder: (context, index) {
//             final service = services[index];
//             final serviceName = service.id ?? "";
//             final serviceImage = service.image ?? "";

//             return GestureDetector(
//               onTap: () {
//                 if (serviceName.isNotEmpty) {
//                   controller.selectService(serviceName);
//                 }
//               },
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: getWidth(8)),
//                 child: Column(
//                   children: [
//                     Obx(() {
//                       bool isSelected = controller.isServiceSelected(
//                         serviceName,
//                       );

//                       return Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: getWidth(30),
//                             backgroundImage: NetworkImage(serviceImage),
//                           ),
//                           if (isSelected)
//                             Positioned(
//                               right: 10,
//                               bottom: 0,
//                               child: Container(
//                                 height: getHeight(20),
//                                 width: getWidth(20),
//                                 decoration: const BoxDecoration(
//                                   color: Color(0xff7A49A5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Center(
//                                   child: Icon(
//                                     Icons.check,
//                                     color: Colors.white,
//                                     size: 14,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     }),
//                     const SizedBox(height: 5),
//                     Text(
//                       service.name ?? "",
//                       style: TextStyle(
//                         fontSize: getWidth(11),
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   Widget _buildTimeSelection(AppointmentController controller) {
//     return Obx(() {
//       if (controller.isLoading.value) {
//         return const Center(
//           child: ShowProgressIndicator(),
//         ); // or your ShowProgressIndicator()
//       }

//       final timeList = controller.nearestBarBarDetails.value.data ?? [];

//       return SizedBox(
//         height: 50,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           itemCount: timeList.length,
//           separatorBuilder: (context, index) => const SizedBox(width: 15),
//           itemBuilder: (context, index) {
//             final timeData = timeList[index];
//             final time = timeData.time ?? "";
//             final isSelected = controller.selectedTime.value == time;
//             final isAvailable = controller.isTimeAvailable(time);

//             return GestureDetector(
//               onTap: isAvailable ? () => controller.selectTime(time) : null,
//               child: Obx(() {
//                 final isCurrentlySelected =
//                     controller.selectedTime.value == time;

//                 return Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 10,
//                     horizontal: 20,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isAvailable ? Colors.purple : Colors.grey,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                     color: isCurrentlySelected
//                         ? Colors.purple
//                         : (isAvailable ? Colors.transparent : Colors.grey[300]),
//                   ),
//                   child: Center(
//                     child: isCurrentlySelected
//                         ? Text(
//                             time,
//                             style: TextStyle(
//                               color: isCurrentlySelected
//                                   ? Colors.white
//                                   : (isAvailable ? Colors.black : Colors.grey),
//                             ),
//                           )
//                         : Text(time, style: TextStyle()),
//                   ),
//                 );
//               }),
//             );
//           },
//         ),
//       );
//     });
//   }

//   Widget _buildConfirmButton(AppointmentController controller) {
//     return Obx(
//       () => controller.inProgress.value
//           ? SpinKitWave(color: AppColors.primaryColor, size: 30.0)
//           : ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xffDC143C),
//                 minimumSize: Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed:
//                   controller.selectedTime.value.isEmpty ||
//                       controller.selectedService.isEmpty
//                   ? null
//                   : () {
//                       controller.createBooking(
//                         businessId: businessId,
//                         serviceId: controller.selectedService.value,
//                       );

//                       //Get.toNamed(AppRoute.bookingSuccessFullScreen);
//                     },
//               child: Text(
//                 "Confirm booking",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//     );
//   }
// }
