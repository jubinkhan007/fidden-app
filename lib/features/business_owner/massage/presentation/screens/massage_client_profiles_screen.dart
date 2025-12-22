import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/massage_client_profile_controller.dart';
import '../../data/massage_models.dart';
import 'massage_client_profile_form_screen.dart';

/// Screen displaying massage client profiles
class MassageClientProfilesScreen extends StatelessWidget {
  const MassageClientProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MassageClientProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Client Profiles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value)
                return const Center(child: CircularProgressIndicator());
              if (controller.errorMessage.isNotEmpty)
                return Center(child: Text(controller.errorMessage.value));

              final profiles = controller.filteredProfiles;
              if (profiles.isEmpty)
                return const Center(child: Text('No profiles found'));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: profiles.length,
                itemBuilder: (context, index) =>
                    _ProfileCard(profile: profiles[index]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const MassageClientProfileFormScreen());
          controller.fetchProfiles();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final MassageClientProfile profile;
  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo[100],
                child: Text(
                  (profile.clientName?[0] ?? 'C').toUpperCase(),
                  style: TextStyle(
                    color: Colors.indigo[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.clientName ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTag(
                          profile.pressureDisplay ?? profile.pressurePreference,
                          Colors.indigo,
                        ),
                        if (profile.areasOfConcern != null &&
                            profile.areasOfConcern!.isNotEmpty)
                          const SizedBox(width: 4),
                        if (profile.areasOfConcern != null &&
                            profile.areasOfConcern!.isNotEmpty)
                          _buildTag('Focus Areas', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                profile.clientName ?? 'Client Profile',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _detailRow(
                'Pressure Preference',
                profile.pressureDisplay ?? profile.pressurePreference,
              ),
              _detailRow('Areas of Concern', profile.areasOfConcern),
              _detailRow('Areas to Avoid', profile.areasToAvoid),
              _detailRow('Medical Conditions', profile.medicalConditions),
              _detailRow('Current Medications', profile.currentMedications),
              _detailRow('Injuries History', profile.injuriesHistory),
              _detailRow('Notes', profile.notes),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Get.to(
                      () => MassageClientProfileFormScreen(
                        existingProfile: profile,
                      ),
                    );
                    if (Get.isRegistered<MassageClientProfileController>()) {
                      Get.find<MassageClientProfileController>()
                          .fetchProfiles();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Profile',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
          'Are you sure you want to delete ${profile.clientName ?? "this profile"}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet

              try {
                final controller = Get.find<MassageClientProfileController>();
                await controller.deleteProfile(profile.id);

                // Show success snackbar
                Future.delayed(const Duration(milliseconds: 100), () {
                  Get.snackbar(
                    'Success',
                    'Profile deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                });
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete profile',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
