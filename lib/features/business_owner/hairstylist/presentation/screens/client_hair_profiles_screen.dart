import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/hairstylist/controller/client_hair_profile_controller.dart';
import 'package:fidden/features/business_owner/hairstylist/data/hairstylist_models.dart';
import 'package:fidden/features/business_owner/hairstylist/presentation/screens/hair_profile_form_screen.dart';

/// Screen displaying client hair profiles list
class ClientHairProfilesScreen extends StatelessWidget {
  const ClientHairProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientHairProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Client Hair Profiles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${controller.profiles.length} clients',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
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
              if (controller.isLoading.value && controller.profiles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.profiles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.fetchProfiles(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final profiles = controller.filteredProfiles;

              if (profiles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No client profiles yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Client hair profiles will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchProfiles(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return _ProfileCard(
                      profile: profile,
                      onTap: () => Get.to(
                        () => ClientHairProfileDetailScreen(profile: profile),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const HairProfileFormScreen());
          controller.fetchProfiles(); // Refresh after returning
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ClientHairProfile profile;
  final VoidCallback onTap;

  const _ProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: _getHairTypeColor(profile.hairType),
              child: Text(
                (profile.clientName ?? 'C')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.clientName ?? 'Unknown Client',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (profile.hairTypeDisplay != null)
                    Row(
                      children: [
                        Icon(Icons.texture, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          profile.hairTypeDisplay!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  if (profile.currentColor != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Color: ${profile.currentColor}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Color _getHairTypeColor(String? hairType) {
    if (hairType == null) return Colors.grey;
    if (hairType.startsWith('1')) return Colors.brown[300]!;
    if (hairType.startsWith('2')) return Colors.brown[400]!;
    if (hairType.startsWith('3')) return Colors.brown[600]!;
    if (hairType.startsWith('4')) return Colors.brown[800]!;
    return Colors.brown;
  }
}

/// Detail screen for a client hair profile
class ClientHairProfileDetailScreen extends StatelessWidget {
  final ClientHairProfile profile;

  const ClientHairProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(profile.clientName ?? 'Client Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Get.to(
                () => HairProfileFormScreen(existingProfile: profile),
              );
              // Refresh list when returning
              if (Get.isRegistered<ClientHairProfileController>()) {
                Get.find<ClientHairProfileController>().fetchProfiles();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.brown[400],
                    child: Text(
                      (profile.clientName ?? 'C')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.clientName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.clientEmail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        profile.clientEmail!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hair Details
            _buildSection('Hair Details', [
              _buildDetailRow(
                'Hair Type',
                profile.hairTypeDisplay ?? 'Not specified',
              ),
              _buildDetailRow(
                'Texture',
                profile.hairTextureDisplay ?? 'Not specified',
              ),
              _buildDetailRow(
                'Porosity',
                profile.hairPorosityDisplay ?? 'Not specified',
              ),
            ]),

            const SizedBox(height: 16),

            // Color Info
            _buildSection('Color Information', [
              _buildDetailRow(
                'Natural Color',
                profile.naturalColor ?? 'Not specified',
              ),
              _buildDetailRow(
                'Current Color',
                profile.currentColor ?? 'Not specified',
              ),
              if (profile.colorHistory != null &&
                  profile.colorHistory!.isNotEmpty)
                _buildDetailRow('Color History', profile.colorHistory!),
            ]),

            const SizedBox(height: 16),

            // Chemical & Scalp
            _buildSection('Treatment History', [
              if (profile.chemicalHistory != null &&
                  profile.chemicalHistory!.isNotEmpty)
                _buildDetailRow('Chemical History', profile.chemicalHistory!),
              _buildDetailRow(
                'Scalp Condition',
                profile.scalpCondition ?? 'Not specified',
              ),
            ]),

            const SizedBox(height: 16),

            // Allergies & Preferences
            if (profile.allergies != null || profile.preferences != null)
              _buildSection('Notes', [
                if (profile.allergies != null && profile.allergies!.isNotEmpty)
                  _buildDetailRow(
                    'Allergies',
                    profile.allergies!,
                    isWarning: true,
                  ),
                if (profile.preferences != null &&
                    profile.preferences!.isNotEmpty)
                  _buildDetailRow('Preferences', profile.preferences!),
              ]),

            const SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
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
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isWarning ? Colors.red[700] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
