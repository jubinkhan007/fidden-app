import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/business_owner/team/controller/team_controller.dart';
import 'package:fidden/features/business_owner/team/presentation/screens/add_edit_provider_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageTeamScreen extends StatelessWidget {
  const ManageTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate controller
    final controller = Get.put(TeamController());

    return Scaffold(
      appBar: AppBar(title: const Text('My Team'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddEditProviderScreen());
        },
        label: const Text('Add Member'),
        icon: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.providers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                CustomText(
                  text: 'No team members yet',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add staff to allow customers to book specific people.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.providers.length,
          itemBuilder: (context, index) {
            final provider = controller.providers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: provider.profileImage != null
                      ? CachedNetworkImageProvider(provider.profileImage!)
                      : null,
                  child: provider.profileImage == null
                      ? Text(
                          provider.name.isNotEmpty ? provider.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  provider.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: provider.bio != null && provider.bio!.isNotEmpty
                    ? Text(
                        provider.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Remove Member?',
                      middleText:
                          'Are you sure you want to remove ${provider.name}?',
                      textConfirm: 'Remove',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      onConfirm: () async {
                        Get.back(); // close dialog
                        await controller.deleteProvider(provider.id);
                      },
                    );
                  },
                ),
                onTap: () {
                  Get.to(() => AddEditProviderScreen(provider: provider));
                },
              ),
            );
          },
        );
      }),
    );
  }
}
