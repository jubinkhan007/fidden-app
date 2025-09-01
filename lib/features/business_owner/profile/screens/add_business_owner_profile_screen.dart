// lib/features/business_owner/profile/screens/add_business_owner_profile_screen.dart

import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';

import '../../../../core/utils/constants/app_spacers.dart';
import '../../../../core/utils/constants/icon_path.dart';
import '../../../../core/utils/constants/image_path.dart';
import '../controller/busines_owner_profile_controller.dart';
import 'map_screen.dart';

class AddBusinessOwnerProfileScreen extends StatefulWidget {
  final String? id;
  const AddBusinessOwnerProfileScreen({super.key, this.id});

  @override
  State<AddBusinessOwnerProfileScreen> createState() =>
      _AddBusinessOwnerProfileScreenState();
}

class _AddBusinessOwnerProfileScreenState
    extends State<AddBusinessOwnerProfileScreen> {
  final controller1 = Get.find<BusinessOwnerProfileController>();
  final nameTEController = TextEditingController();
  final aboutUsTEController = TextEditingController();
  final capacityTEController = TextEditingController();
  final locationTEController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileData = controller1.profileDetails.value.data;
    if (profileData != null) {
      nameTEController.text = profileData.businessName ?? '';
      locationTEController.text = profileData.businessAddress ?? '';
      capacityTEController.text = profileData.capacity?.toString() ?? '';
      aboutUsTEController.text = profileData.details ?? '';
    }
  }

  @override
  void dispose() {
    nameTEController.dispose();
    aboutUsTEController.dispose();
    capacityTEController.dispose();
    locationTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const _allDays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xffffffff),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: CustomText(
          text: "Business Profile",
          color: const Color(0xff212121),
          fontWeight: FontWeight.bold,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Manage services',
            icon: const Icon(Icons.design_services_outlined),
            onPressed: () => Get.toNamed('/all-services'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getHeight(24)),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: getWidth(150),
                          height: getHeight(150),
                          child: CircleAvatar(
                            backgroundImage:
                                controller1.profileImage.value != null
                                ? FileImage(controller1.profileImage.value!)
                                : controller1
                                          .profileDetails
                                          .value
                                          .data
                                          ?.image !=
                                      null
                                ? NetworkImage(
                                    "${controller1.profileDetails.value.data?.image}",
                                  )
                                : const AssetImage(ImagePath.profileImage)
                                      as ImageProvider,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 10,
                          child: GestureDetector(
                            onTap: () {
                              controller1.pickImage();
                            },
                            child: SizedBox(
                              height: getHeight(35),
                              width: getWidth(35),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Image.asset(
                                  IconPath.uploadImageIcon,
                                  height: getHeight(17),
                                  width: getWidth(17),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(20)),
                  CustomTextAndTextFormField(
                    controller: nameTEController,
                    text: 'Shop Name',
                    hintText: "Enter your shop name",
                  ),
                  VerticalSpace(height: getHeight(20)),
                  CustomText(
                    text: "Address",
                    color: const Color(0xff141414),
                    fontSize: getWidth(17),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  CustomTexFormField(
                    hintText: 'Select your address',
                    controller: locationTEController,
                    readOnly: true,
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        LatLng? selectedLocation = await Get.to(
                          () => MapScreenProfile(),
                        );
                        if (selectedLocation != null) {
                          String address = await _getAddressFromLatLng(
                            selectedLocation,
                          );
                          locationTEController.text = address;
                          controller1.lat.value = selectedLocation.latitude
                              .toString();
                          controller1.long.value = selectedLocation.longitude
                              .toString();
                        }
                      },
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  VerticalSpace(height: getHeight(20)),
                  CustomTextAndTextFormField(
                    controller: capacityTEController,
                    text: 'Shop Capacity',
                    hintText: "Capacity of your shop",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Capacity is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  VerticalSpace(height: getHeight(20)),
                  CustomTextAndTextFormField(
                    controller: aboutUsTEController,
                    text: 'About Us',
                    hintText: "Write here",
                    maxLines: 3,
                  ),
                  VerticalSpace(height: getHeight(20)),
                ],
              ),
            ),
            CustomText(
              text: "Business Hours",
              color: const Color(0xff141414),
              fontSize: getWidth(17),
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),

            // Times (explicit labels, no seconds)
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _timeTile(
                      label: 'Opens at',
                      value: controller1.startTime.value.isEmpty
                          ? (controller1.profileDetails.value.data?.startTime ??
                                '09:00 AM')
                          : controller1.startTime.value,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _parseOrNow(
                            controller1.startTime.value.isEmpty
                                ? (controller1
                                          .profileDetails
                                          .value
                                          .data
                                          ?.startTime ??
                                      '09:00 AM')
                                : controller1.startTime.value,
                          ),
                        );
                        if (t != null) {
                          controller1.startTime.value = t.format(
                            context,
                          ); // <-- no seconds
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeTile(
                      label: 'Closes at',
                      value: controller1.endTime.value.isEmpty
                          ? (controller1.profileDetails.value.data?.endTime ??
                                '08:00 PM')
                          : controller1.endTime.value,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _parseOrNow(
                            controller1.endTime.value.isEmpty
                                ? (controller1
                                          .profileDetails
                                          .value
                                          .data
                                          ?.endTime ??
                                      '08:00 PM')
                                : controller1.endTime.value,
                          ),
                        );
                        if (t != null) {
                          controller1.endTime.value = t.format(
                            context,
                          ); // <-- no seconds
                        }
                      },
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: getHeight(16)),

            // One card to select multiple OPEN days
            _DaysMultiSelectCard(
              title: 'Open Days',
              selectedDays: controller1
                  .openDays, // RxSet<String> in controller (see below)
              onChanged: (set) => controller1.openDays.value = set.toSet(),
            ),

            SizedBox(height: getHeight(12)),

            // Closed days shown differently (computed)
            Obx(() {
              final closed = _allDays
                  .where((d) => !controller1.openDays.contains(d))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Closed on',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: closed.isEmpty
                        ? [const Chip(label: Text('None'))]
                        : closed
                              .map(
                                (d) => Chip(
                                  label: Text(d),
                                  backgroundColor: const Color(
                                    0xFFFFEBEE,
                                  ), // light red
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFB71C1C),
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(color: Color(0xFFFFCDD2)),
                                  ),
                                ),
                              )
                              .toList(),
                  ),
                ],
              );
            }),
            SizedBox(height: getHeight(24)),
            Obx(
              () => controller1.isLoading.value
                  ? const SpinKitWave(color: AppColors.primaryColor, size: 30.0)
                  : CustomButton(
                      onPressed: () {
                        controller1.createBusinessProfile(
                          businessName: nameTEController.text,
                          businessAddress: locationTEController.text,
                          aboutUs: aboutUsTEController.text,
                          capacity: capacityTEController.text,
                        );
                      },
                      child: Text(
                        "Save & Continue",
                        style: TextStyle(
                          fontSize: getWidth(18),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            VerticalSpace(height: getHeight(42)),
          ],
        ),
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.country}";
      }
      return "Unknown location";
    } catch (e) {
      return "Failed to get address";
    }
  }
}

class CustomTextAndTextFormField extends StatelessWidget {
  const CustomTextAndTextFormField({
    super.key,
    required this.text,
    required this.hintText,
    this.validator,
    this.controller,
    this.readOnly,
    this.contentPadding,
    this.maxLines,
  });

  final String text, hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool? readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: text,
          color: Color(0xff141414),
          fontSize: getWidth(17),
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: getHeight(10)),
        CustomTexFormField(
          maxLines: maxLines ?? 1,
          readOnly: readOnly ?? false,
          controller: controller,
          hintText: hintText,
          validator: validator,
          contentPadding: contentPadding,
        ),
      ],
    );
  }
}

Widget _dayField({
  required bool isStart,
  required BusinessOwnerProfileController controller,
}) {
  return Obx(() {
    final value = isStart ? controller.startDay.value : controller.endDay.value;

    final profileDay = isStart
        ? controller.profileDetails.value.data?.startDay
        : controller.profileDetails.value.data?.endDay;

    final displayDay = value.isEmpty
        ? (profileDay?.isNotEmpty ?? false
              ? profileDay
              : (isStart ? "Monday" : "Friday"))
        : value;

    return _inputTile(
      label: displayDay!,
      icon: Icons.calendar_today,
      onTap: () => controller.pickDay(isStart: isStart),
    );
  });
}

Widget _timeField({
  required bool isStart,
  required BusinessOwnerProfileController controller,
}) {
  return Obx(() {
    final value = isStart
        ? controller.startTime.value
        : controller.endTime.value;
    final profileDay = isStart
        ? controller.profileDetails.value.data?.startTime
        : controller.profileDetails.value.data?.endTime;

    final displayDay = value.isEmpty
        ? (profileDay?.isNotEmpty ?? false
              ? profileDay
              : (isStart ? "09:00 AM" : "08:00 PM"))
        : value;

    return _inputTile(
      label: displayDay!,
      icon: Icons.access_time,
      onTap: () => controller.pickTime(isStart: isStart),
    );
  });
}

Widget _inputTile({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 60,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Icon(icon, color: Colors.grey),
            ],
          ),
        ),
      ),
    ),
  );
}

TimeOfDay _parseOrNow(String s) {
  // Accepts formats like "09:00 AM" or "9:00 AM"
  try {
    final reg = RegExp(r'(\d{1,2}):(\d{2})\s*([AP]M)', caseSensitive: false);
    final m = reg.firstMatch(s.trim());
    if (m != null) {
      var hour = int.parse(m.group(1)!);
      final minute = int.parse(m.group(2)!);
      final ampm = m.group(3)!.toUpperCase();
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
  } catch (_) {}
  return TimeOfDay.now();
}

Widget _timeTile({
  required String label,
  required String value,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 60,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const Icon(Icons.access_time, color: Colors.grey),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DaysMultiSelectCard extends StatelessWidget {
  final String title;
  final RxSet<String> selectedDays;
  final ValueChanged<Set<String>> onChanged;

  const _DaysMultiSelectCard({
    required this.title,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sel = selectedDays.toSet();
      return Center(
        child: InkWell(
          onTap: () async {
            final result = await showModalBottomSheet<Set<String>>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => _DaysPickerSheet(initial: sel),
            );
            if (result != null) onChanged(result);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  sel.isEmpty
                      ? const Text(
                          'Tap to choose days',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sel
                              .map(
                                (d) => Chip(
                                  label: Text(d),
                                  backgroundColor: const Color(
                                    0xFFE8F5E9,
                                  ), // light green
                                  labelStyle: const TextStyle(
                                    color: Color(0xFF1B5E20),
                                  ),
                                  shape: const StadiumBorder(
                                    side: BorderSide(color: Color(0xFFC8E6C9)),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _DaysPickerSheet extends StatefulWidget {
  final Set<String> initial;
  const _DaysPickerSheet({required this.initial});

  @override
  State<_DaysPickerSheet> createState() => _DaysPickerSheetState();
}

class _DaysPickerSheetState extends State<_DaysPickerSheet> {
  late Set<String> _sel;

  @override
  void initState() {
    super.initState();
    _sel = {...widget.initial};
  }

  @override
  Widget build(BuildContext context) {
    const _allDays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Select Open Days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allDays.map((d) {
                  final on = _sel.contains(d);
                  return FilterChip(
                    label: Text(d),
                    selected: on,
                    onSelected: (val) {
                      setState(() {
                        if (val)
                          _sel.add(d);
                        else
                          _sel.remove(d);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _sel),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
