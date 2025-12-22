import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/client_skin_profile_controller.dart';
import '../../data/esthetician_models.dart';
import 'skin_profile_form_screen.dart';

/// Screen displaying client skin profiles
class ClientSkinProfilesScreen extends StatelessWidget {
  const ClientSkinProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientSkinProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Client Skin Profiles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
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

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              final profiles = controller.filteredProfiles;
              if (profiles.isEmpty) {
                return const Center(child: Text('No profiles found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return _ProfileCard(profile: profile);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const SkinProfileFormScreen());
          controller.fetchProfiles();
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ClientSkinProfile profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => _ProfileDetailScreen(profile: profile)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal[100],
                child: Text(
                  (profile.clientName?[0] ?? 'C').toUpperCase(),
                  style: TextStyle(
                    color: Colors.teal[800],
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
                          profile.skinTypeDisplay ?? profile.skinType,
                          Colors.teal,
                        ),
                        if (profile.primaryConcerns.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          _buildTag(
                            profile.primaryConcerns.first,
                            Colors.orange,
                          ),
                        ],
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
        color: color.withValues(alpha: 0.1),
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
}

/// Detail screen for skin profile
class _ProfileDetailScreen extends StatelessWidget {
  final ClientSkinProfile profile;

  const _ProfileDetailScreen({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(profile.clientName ?? 'Skin Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Get.to(
                () => SkinProfileFormScreen(existingProfile: profile),
              );
              if (Get.isRegistered<ClientSkinProfileController>()) {
                Get.find<ClientSkinProfileController>().fetchProfiles();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection('Skin Information', [
              _buildRow(
                'Skin Type',
                profile.skinTypeDisplay ?? profile.skinType,
              ),
              _buildRow('Primary Concerns', profile.primaryConcerns.join(', ')),
              _buildRow('Allergies', profile.allergies),
              _buildRow('Sensitivities', profile.sensitivities),
            ]),

            const SizedBox(height: 16),

            _buildSection('Current Products', [
              _buildRow('Products', profile.currentProducts),
            ]),

            if (profile.morningRoutine.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRoutineSection('Morning Routine', profile.morningRoutine),
            ],

            if (profile.eveningRoutine.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRoutineSection('Evening Routine', profile.eveningRoutine),
            ],

            if (profile.regimenNotes != null &&
                profile.regimenNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Notes', [
                _buildRow('Regimen Notes', profile.regimenNotes),
                _buildRow('Additional Notes', profile.notes),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildRoutineSection(String title, List<RoutineStep> steps) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.teal[100],
                    child: Text(
                      '${step.step}',
                      style: TextStyle(fontSize: 10, color: Colors.teal[800]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.product,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (step.notes != null && step.notes!.isNotEmpty)
                          Text(
                            step.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              Get.back(); // Go back to list screen first

              try {
                final controller = Get.find<ClientSkinProfileController>();
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
}
