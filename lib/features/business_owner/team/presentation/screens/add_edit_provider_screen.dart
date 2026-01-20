import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/business_owner/team/controller/team_controller.dart';
import 'package:fidden/features/business_owner/team/presentation/widgets/provider_schedule_editor.dart';
import 'package:fidden/core/models/time_range.dart';
import 'package:fidden/features/user/shops/data/provider_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditProviderScreen extends StatefulWidget {
  final Provider? provider; // NEW: optional for edit

  const AddEditProviderScreen({super.key, this.provider});

  @override
  State<AddEditProviderScreen> createState() => _AddEditProviderScreenState();
}

class _AddEditProviderScreenState extends State<AddEditProviderScreen> {
  final controller = Get.find<TeamController>();

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _maxConcurrentCtrl = TextEditingController(text: '1');
  final _selectedServices = <int>[].obs;
  Map<String, List<TimeRange>> _schedule = {}; // NEW: Local schedule state

  @override
  void initState() {
    super.initState();
    controller.clearForm();
    _selectedServices.clear();

    // Pre-fill if editing
    if (widget.provider != null) {
      final p = widget.provider!;
      _nameCtrl.text = p.name;
      _bioCtrl.text = p.bio ?? '';
      if (p.serviceIds != null) {
        _selectedServices.addAll(p.serviceIds!);
      }
      if (p.schedule != null) {
        _schedule = Map.from(p.schedule!);
      }
      _maxConcurrentCtrl.text = p.maxConcurrentProcessingJobs.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _maxConcurrentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.provider != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Team Member' : 'Add Team Member'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar Picker
            Center(
              child: GestureDetector(
                onTap: controller.pickImage,
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.selectedImage.value != null) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(
                            controller.selectedImage.value!,
                          ),
                        );
                      }
                      // Show existing network image if editing and no new file selected
                      if (widget.provider?.profileImage != null) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            widget.provider!.profileImage!,
                          ),
                        );
                      }
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: const AssetImage(
                          ImagePath.profileImage,
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: getHeight(24)),

            // Name
            _buildLabel('Name'),
            CustomTexFormField(hintText: 'Full Name', controller: _nameCtrl),
            SizedBox(height: getHeight(16)),

            // Bio
            _buildLabel('Bio / Title'),
            CustomTexFormField(
              hintText: 'Short bio or title (e.g. Senior Stylist)',
              controller: _bioCtrl,
              maxLines: 3,
            ),
            SizedBox(height: getHeight(24)),

            // Services Selection
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: 'Assigned Services',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: getHeight(8)),

            Obx(() {
              final services = controller.availableServices;
              if (services.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'No services available. Please add services to your shop first.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: services.map((service) {
                  final isSelected = _selectedServices.contains(service.id);
                  return FilterChip(
                    label: Text(service.title ?? 'Unknown'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (service.id == null) return;
                      if (selected) {
                        _selectedServices.add(service.id!);
                      } else {
                        _selectedServices.remove(service.id!);
                      }
                    },
                    selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryColor,
                  );
                }).toList(),
              );
            }),

            SizedBox(height: getHeight(24)),

            // Max Concurrent Jobs
            _buildLabel('Max Concurrent Processing Jobs'),
            CustomTexFormField(
              hintText: 'Default: 1',
              controller: _maxConcurrentCtrl,
              isPhoneField: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return null; // Fallback to 1
                final v = int.tryParse(val.trim());
                if (v == null) return 'Invalid number';
                if (v < 1) return 'Must be 1 or more';
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'How many simultaneous tasks can this member handle during processing?',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            SizedBox(height: getHeight(32)),

            // Schedule Editor
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: 'Individual Schedule (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set specific working hours for this team member. If left empty, they will follow the shop\'s main business hours.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ProviderScheduleEditor(
              initialSchedule: _schedule,
              onChanged: (val) {
                _schedule = val;
              },
            ),

            SizedBox(height: getHeight(32)),

            // Save Button
            Obx(
              () => CustomButton(
                isLoading: controller.isSaving.value,
                onPressed: () async {
                  if (_nameCtrl.text.trim().isEmpty) {
                    AppSnackBar.showError('Name is required');
                    return;
                  }

                  final maxJobs =
                      int.tryParse(_maxConcurrentCtrl.text.trim()) ?? 1;

                  bool success;
                  if (widget.provider != null) {
                    success = await controller.updateProvider(
                      providerId: widget.provider!.id,
                      name: _nameCtrl.text.trim(),
                      bio: _bioCtrl.text.trim(),
                      serviceIds: _selectedServices,
                      schedule: _schedule.isNotEmpty ? _schedule : null, // NEW
                      maxConcurrentProcessingJobs: maxJobs,
                    );
                  } else {
                    success = await controller.addProvider(
                      name: _nameCtrl.text.trim(),
                      bio: _bioCtrl.text.trim(),
                      serviceIds: _selectedServices,
                      schedule: _schedule.isNotEmpty ? _schedule : null, // NEW
                      maxConcurrentProcessingJobs: maxJobs,
                    );
                  }

                  if (success) {
                    Get.back();
                    AppSnackBar.showSuccess(
                      widget.provider != null
                          ? 'Team member updated successfully'
                          : 'Team member added successfully',
                    );
                  }
                },
                child: Text(
                  widget.provider != null
                      ? 'Update Team Member'
                      : 'Save Team Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomText(
          text: label,
          color: const Color(0xff141414),
          fontSize: getWidth(14.5),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
