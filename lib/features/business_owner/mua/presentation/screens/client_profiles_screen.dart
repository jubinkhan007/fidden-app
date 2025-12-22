import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/client_profile_controller.dart';
import '../../data/mua_models.dart';

/// Client Beauty Profiles screen for MUA
class ClientProfilesScreen extends StatelessWidget {
  const ClientProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClientProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Client Profiles'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${controller.count} clients',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.profiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'No client profiles yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Client beauty profiles will appear here',
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
            itemCount: controller.profiles.length,
            itemBuilder: (context, index) {
              final profile = controller.profiles[index];
              return _ClientProfileCard(
                profile: profile,
                onTap: () => Get.to(() => ClientProfileDetailScreen(profile: profile)),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ClientProfileCard extends StatelessWidget {
  final ClientBeautyProfile profile;
  final VoidCallback onTap;

  const _ClientProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFB8192E).withValues(alpha: 0.1),
          child: Text(
            (profile.clientName ?? 'C')[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8192E),
            ),
          ),
        ),
        title: Text(
          profile.clientName ?? 'Unknown Client',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (profile.foundationShade != null)
              Row(
                children: [
                  const Icon(Icons.palette, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(profile.foundationShade!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                if (profile.skinToneDisplay != null)
                  _buildTag(profile.skinToneDisplay!),
                if (profile.skinTypeDisplay != null)
                  _buildTag(profile.skinTypeDisplay!),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
    );
  }
}

/// Detail screen for viewing/editing client beauty profile
class ClientProfileDetailScreen extends StatefulWidget {
  final ClientBeautyProfile profile;

  const ClientProfileDetailScreen({super.key, required this.profile});

  @override
  State<ClientProfileDetailScreen> createState() => _ClientProfileDetailScreenState();
}

class _ClientProfileDetailScreenState extends State<ClientProfileDetailScreen> {
  late ClientBeautyProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_profile.clientName ?? 'Client Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Client info header
          _buildHeader(),
          const SizedBox(height: 24),

          // Skin Details
          _buildSectionTitle('Skin Details'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Skin Tone', _profile.skinToneDisplay ?? 'Not set'),
            _buildDetailRow('Skin Type', _profile.skinTypeDisplay ?? 'Not set'),
            _buildDetailRow('Undertone', _profile.undertoneDisplay ?? 'Not set'),
          ]),
          const SizedBox(height: 16),

          // Makeup Details
          _buildSectionTitle('Makeup Details'),
          const SizedBox(height: 12),
          _buildDetailCard([
            _buildDetailRow('Foundation Shade', _profile.foundationShade ?? 'Not set'),
          ]),
          const SizedBox(height: 16),

          // Preferences
          _buildSectionTitle('Preferences & Notes'),
          const SizedBox(height: 12),
          _buildDetailCard([
            if (_profile.allergies != null && _profile.allergies!.isNotEmpty)
              _buildTextBlock('Allergies', _profile.allergies!),
            if (_profile.preferences != null && _profile.preferences!.isNotEmpty)
              _buildTextBlock('Preferences', _profile.preferences!),
            if ((_profile.allergies == null || _profile.allergies!.isEmpty) &&
                (_profile.preferences == null || _profile.preferences!.isEmpty))
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No preferences or allergies noted', style: TextStyle(color: Colors.grey)),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFB8192E).withValues(alpha: 0.1),
            child: Text(
              (_profile.clientName ?? 'C')[0].toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFB8192E)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.clientName ?? 'Unknown',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_profile.clientEmail != null)
                  Text(_profile.clientEmail!, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTextBlock(String label, String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }
}
