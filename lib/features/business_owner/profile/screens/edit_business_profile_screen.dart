import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/features/business_owner/profile/screens/widgets/cancellationPolicy_card.dart';
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
import '../data/business_profile_model.dart';
import 'map_screen.dart';
import 'package:fidden/core/services/location_service.dart';

class EditBusinessOwnerProfileScreen extends StatefulWidget {
  final String? id;
  const EditBusinessOwnerProfileScreen({super.key, this.id});

  @override
  State<EditBusinessOwnerProfileScreen> createState() =>
      _EditBusinessOwnerProfileScreenState();
}

class _EditBusinessOwnerProfileScreenState
    extends State<EditBusinessOwnerProfileScreen> {
  final controller1 = Get.find<BusinessOwnerProfileController>();
  final nameTEController = TextEditingController();
  final aboutUsTEController = TextEditingController();
  final capacityTEController = TextEditingController();
  final locationTEController = TextEditingController();
    final _freeHCtrl = TextEditingController();
  final _feePctCtrl = TextEditingController();
  final _noRefHCtrl = TextEditingController();
  late final Worker _profileSub;


  @override
  void initState() {
    super.initState();
    final profileData = controller1.profileDetails.value.data;
    if (profileData != null) {
      nameTEController.text = profileData.businessName ?? '';
      locationTEController.text = profileData.businessAddress ?? '';
      capacityTEController.text = profileData.capacity?.toString() ?? '';
      aboutUsTEController.text = profileData.details ?? '';
          _freeHCtrl.text  = (profileData?.freeCancellationHours ?? 24).toString();
    _feePctCtrl.text = (profileData?.cancellationFeePercentage ?? 0).toString();
    _noRefHCtrl.text = (profileData?.noRefundHours ?? 0).toString();
    }
    // <-- ADD THIS SUBSCRIPTION
    _profileSub = ever<GetBusinesModel>(controller1.profileDetails, (m) {
      final d = m.data;
      if (d == null) return;

      void put(TextEditingController c, int? v) {
        final newText = (v ?? 0).toString();
        if (c.text != newText) {
          c.text = newText;
          c.selection = TextSelection.collapsed(offset: newText.length);
        }
      }

      put(_freeHCtrl,  d.freeCancellationHours);
      put(_feePctCtrl, d.cancellationFeePercentage);
      put(_noRefHCtrl, d.noRefundHours);
      setState(() {});
    });

  }

  @override
  void dispose() {
    _profileSub.dispose();
    nameTEController.dispose();
    aboutUsTEController.dispose();
    capacityTEController.dispose();
    locationTEController.dispose();
      _freeHCtrl.dispose();
  _feePctCtrl.dispose();
  _noRefHCtrl.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog() {
  Get.defaultDialog(
    title: "Delete Profile",
    middleText: "Are you sure you want to delete your business profile? This action cannot be undone.",
    content: Obx(() => controller1.isDeleting.value
        ? const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
        : const SizedBox.shrink()),
    textConfirm: "Delete",
    confirmTextColor: Colors.white,
    textCancel: "Cancel",
    onConfirm: controller1.isDeleting.value ? null : () async {
      if (widget.id == null) return;
      final ok = await controller1.deleteBusinessProfile(widget.id!);

      // 1) close the confirm dialog
      if (Get.isDialogOpen ?? false) Get.back();

      if (ok) {
        // 2) pop the EDIT screen and send result back to caller
        if (mounted) Navigator.of(context).pop(true);
      }
    },
  );
}



  // ---------- UI Helpers ----------

  Widget _buildFilePicker({required bool isDisabled}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CustomText(
        //   text: "Verification Documents",
        //   color: const Color(0xff141414),
        //   fontSize: getWidth(17),
        //   fontWeight: FontWeight.w600,
        // ),
        // SizedBox(height: getHeight(10)),
        GestureDetector(
          onTap: isDisabled ? null : () => controller1.pickDocuments(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isDisabled ? Colors.grey.shade100 : Colors.transparent,
            ),
            child: Obx(() {
              // ---  CORRECTION IS HERE ---
              final uploadedFiles =
                  controller1.profileDetails.value.data?.verificationFiles ??
                  [];
              final newFiles = controller1.documents;
              // --- END CORRECTION ---

              if (uploadedFiles.isEmpty && newFiles.isEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: isDisabled ? Colors.grey.shade400 : Colors.grey,
                    ),
                    SizedBox(width: getWidth(10)),
                    Text(
                      "Select documents (images, pdf, etc.)",
                      style: TextStyle(
                        color: isDisabled ? Colors.grey.shade400 : Colors.black,
                      ),
                    ),
                  ],
                );
              }
              return Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ...uploadedFiles.map(
                    (fileUrl) => Chip(
                      label: Text(
                        fileUrl.file.split('/').last,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                  ...newFiles.map(
                    (file) => Chip(
                      label: Text(
                        file.path.split('/').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onDeleted: isDisabled
                          ? null
                          : () => controller1.documents.remove(file),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        SizedBox(height: getHeight(24)),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
    EdgeInsets padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
  }) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      margin: EdgeInsets.only(bottom: getHeight(16)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: getWidth(12.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: getHeight(12)),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800),
          SizedBox(width: getWidth(10)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPicker({required bool disabled}) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: getWidth(60),
            backgroundImage: controller1.profileImage.value != null
                ? FileImage(controller1.profileImage.value!)
                : controller1.profileDetails.value.data?.image != null
                ? NetworkImage(
                        "${controller1.profileDetails.value.data?.image}",
                      )
                      as ImageProvider
                : const AssetImage(ImagePath.profileImage),
          ),
          Positioned(
            bottom: 0,
            right: 2,
            child: InkWell(
              onTap: disabled ? null : () => controller1.pickImage(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: disabled
                      ? Colors.grey.shade300
                      : AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: disabled ? Colors.grey.shade600 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressPicker({required bool disabled}) {
    final hint = 'Select your address';
    final hasValue = locationTEController.text.trim().isNotEmpty;

    return InkWell(
      onTap: disabled ? null : _openMapFlow,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: disabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: disabled ? Colors.grey : AppColors.primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: getWidth(12.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? locationTEController.text : hint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: getWidth(14),
                      color: hasValue ? Colors.black : Colors.grey.shade500,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.map_outlined,
              color: disabled ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeTile({
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _daysMultiSelect({required bool disabled}) {
    return Obx(() {
      final sel = controller1.openDays.toSet();
      return InkWell(
        onTap: disabled
            ? null
            : () async {
                final result = await showModalBottomSheet<Set<String>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  builder: (_) => const _DaysPickerSheet(),
                );
                if (result != null) controller1.openDays.value = result.toSet();
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            color: disabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Open Days',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              sel.isEmpty
                  ? Text(
                      'Tap to choose days',
                      style: TextStyle(color: Colors.grey.shade500),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: sel
                          .map(
                            (d) => Chip(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(d),
                              backgroundColor: const Color(0xFFE8F5E9),
                              labelStyle: const TextStyle(
                                color: Color(0xFF1B5E20),
                              ),
                              shape: const StadiumBorder(
                                side: BorderSide(color: Color(0xFFC8E6C9)),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      );
    });
  }

  // inside _EditBusinessOwnerProfileScreenState

ButtonStyle _deleteBtnStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(const StadiumBorder()),
    // outline color changes when disabled
    side: MaterialStateProperty.resolveWith((states) {
      final c = states.contains(MaterialState.disabled)
          ? Colors.red.shade200
          : Colors.red.shade400;
      return BorderSide(color: c, width: 1.5);
    }),
    // text/icon color
    foregroundColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.disabled)
          ? Colors.red.shade300
          : Colors.red.shade700;
    }),
    // subtle fill when disabled so it looks “off”
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.disabled)
          ? Colors.red.shade50
          : Colors.transparent;
    }),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.red.shade100.withOpacity(.20);
      }
      return null;
    }),
  );
}

ButtonStyle _saveBtnStyle() {
  return ButtonStyle(
    shape: MaterialStateProperty.all(const StadiumBorder()),
    // label color
    foregroundColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.disabled)
          ? Colors.grey.shade600
          : Colors.white;
    }),
    // background color
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.disabled)
          ? Colors.grey.shade300
          : AppColors.primaryColor;
    }),
    elevation: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.disabled) ? 0 : 1;
    }),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.white.withOpacity(.08);
      }
      return null;
    }),
  );
}


  // ---------- Build ----------

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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: CustomText(
          text: "Business Profile",
          color: const Color(0xff212121),
          fontWeight: FontWeight.bold,
          fontSize: getWidth(20),
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
      // Sticky bottom actions
      bottomNavigationBar: Obx(() {
  final isPending = controller1.profileDetails.value.data?.status == 'pending';

  return SafeArea(
    top: false,
    child: Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // DELETE
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: _deleteBtnStyle(),
                onPressed: isPending ? null : _showDeleteConfirmationDialog,
                child: const Text('Delete'),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // SAVE & CONTINUE
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              // If you must keep CustomButton, see NOTE below
              child: FilledButton(
                style: _saveBtnStyle(),
                onPressed: isPending
                    ? null
                    : () {
                                      controller1.freeCancellationHours.value =
                    _freeHCtrl.text.trim();
                controller1.cancellationFeePercentage.value =
                    _feePctCtrl.text.trim();
                controller1.noRefundHours.value =
                    _noRefHCtrl.text.trim();

                        controller1.updateBusinessProfile(
                          businessName: nameTEController.text,
                          businessAddress: locationTEController.text,
                          aboutUs: aboutUsTEController.text,
                          capacity: capacityTEController.text,
                          id: widget.id.toString(),
                          openDays: controller1.openDays.toList(),
                          closeDays: const [],
                          startAt: controller1.startTime.value,
                          closeAt: controller1.endTime.value,
                        );
                      },
                child: const Text('Save & Continue'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}),


      body: Obx(() {
        final profileData = controller1.profileDetails.value.data;
        final bool isPending = profileData?.status == 'pending';
        return RefreshIndicator(
          onRefresh: () => controller1.fetchProfileDetails(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              getWidth(16),
              getHeight(16),
              getWidth(16),
              getHeight(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPending)
                  _statusBanner(
                    "Your business profile is under review. You will be notified once it is approved.",
                  ),
                _sectionCard(
                  title: 'Basic Info',
                  children: [
                    _avatarPicker(disabled: isPending),
                    VerticalSpace(height: getHeight(16)),
                    CustomTextAndTextFormField(
                      controller: nameTEController,
                      text: 'Shop Name',
                      hintText: "Enter your shop name",
                      readOnly: isPending,
                    ),
                  ],
                ),
                _sectionCard(
                  title: 'Location',
                  subtitle: 'Choose from map or use your current location.',
                  children: [_addressPicker(disabled: isPending)],
                ),
                _sectionCard(
                  title: 'Capacity & About',
                  children: [
                    CustomTextAndTextFormField(
                      controller: capacityTEController,
                      text: 'Shop Capacity',
                      hintText: "Capacity of your shop",
                      readOnly: isPending,
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
                    VerticalSpace(height: getHeight(12)),
                    CustomTextAndTextFormField(
                      controller: aboutUsTEController,
                      text: 'About Us',
                      hintText: "Write here",
                      readOnly: isPending,
                      maxLines: 3,
                    ),
                  ],
                ),
                _sectionCard(
                  title: 'Business Hours',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _timeTile(
                            label: 'Opens at',
                            value: controller1.startTime.value.isEmpty
                                ? (controller1
                                          .profileDetails
                                          .value
                                          .data
                                          ?.startTime ??
                                      '09:00 AM')
                                : controller1.startTime.value,
                            onTap: isPending
                                ? null
                                : () async {
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
                                      );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _timeTile(
                            label: 'Closes at',
                            value: controller1.endTime.value.isEmpty
                                ? (controller1
                                          .profileDetails
                                          .value
                                          .data
                                          ?.endTime ??
                                      '08:00 PM')
                                : controller1.endTime.value,
                            onTap: isPending
                                ? null
                                : () async {
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
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _daysMultiSelect(disabled: isPending),
                    const SizedBox(height: 8),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
                                          ),
                                          labelStyle: const TextStyle(
                                            color: Color(0xFFB71C1C),
                                          ),
                                          shape: const StadiumBorder(
                                            side: BorderSide(
                                              color: Color(0xFFFFCDD2),
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      )
                                      .toList(),
                          ),
                        ],
                      );
                    }),
                  ],
                ),                _sectionCard(
                  title: 'Cancellation Policy',
                  subtitle: 'Configure refund windows and fees.',
                  children: [
                    AbsorbPointer(
                      absorbing: isPending, // lock when pending
                      child: CancellationPolicyCard(
                        freeHController: _freeHCtrl,
                        feePctController: _feePctCtrl,
                        noRefHController: _noRefHCtrl,
                      ),
                    ),
                    if (isPending)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Editing is disabled while under review.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),


                // Attach docs section (kept simple)
                _sectionCard(
                  title: 'Verification Documents',
                  children: [_buildFilePicker(isDisabled: isPending)],
                ),
                SizedBox(height: getHeight(80)), // spacer above sticky bar
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------- Map & Geocoding ----------

  Future<void> _openMapFlow() async {
    LatLng? initialPosition;
    final existingAddress = locationTEController.text.trim();

    if (existingAddress.isNotEmpty) {
      try {
        final locations = await locationFromAddress(existingAddress);
        if (locations.isNotEmpty) {
          initialPosition = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
        }
      } catch (_) {}
    } else {
      try {
        final position = await LocationService().getCurrentPosition();
        if (position != null) {
          initialPosition = LatLng(position.latitude, position.longitude);
        }
      } catch (_) {}
    }

    final selected = await Get.to(
      () => MapScreenProfile(initialPosition: initialPosition),
    );

    if (selected != null && selected is LatLng) {
      final address = await _getAddressFromLatLng(selected);

      setState(() {
        // <— force rebuild so the address shows immediately
        locationTEController.text = address;
        controller1.lat.value = selected.latitude.toString();
        controller1.long.value = selected.longitude.toString();
      });
    }
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // More complete address line
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
          place.postalCode,
        ].where((s) => (s ?? '').toString().trim().isNotEmpty).toList();
        return parts.join(', ');
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
          color: const Color(0xff141414),
          fontSize: getWidth(14.5),
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: getHeight(8)),
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

class _DaysPickerSheet extends StatefulWidget {
  const _DaysPickerSheet();

  @override
  State<_DaysPickerSheet> createState() => _DaysPickerSheetState();
}

class _DaysPickerSheetState extends State<_DaysPickerSheet> {
  static const _allDays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  late Set<String> _sel;

  @override
  void initState() {
    super.initState();
    _sel = {...Get.find<BusinessOwnerProfileController>().openDays};
  }

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

// Time parser
TimeOfDay _parseOrNow(String s) {
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
