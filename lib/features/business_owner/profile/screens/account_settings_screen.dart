import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/screens/change_password_bottom_sheet.dart';
import '../../../settings/presentation/utils/app_data_utils.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            title: 'Security',
            children: [
              _buildSettingsItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () async {
                  final ok = await Get.bottomSheet(
                    const ChangePasswordBottomSheet(),
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  );
                  if (ok == true) {
  AppSnackBar.showSuccess('Password changed successfully!');
  // also refresh UI if needed
}
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'App Settings',
            children: [
              // _buildSettingsItem(
              //   icon: Icons.notifications_none,
              //   title: 'Manage Notifications',
              //   onTap: () {
              //     // TODO: Navigate to notification settings screen
              //   },
              // ),
              _buildSettingsItem(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear App Data',
                onTap: () {
                  _showConfirmationDialog(
                    context: context,
                    title: 'Clear App Data',
                    content: 'This will clear the app cache and log you out. Are you sure?',
                    onConfirm: AppDataUtils.clearAppData,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'Account Actions',
            children: [
              _buildSettingsItem(
                icon: Icons.power_settings_new,
                title: 'Deactivate Account',
                onTap: () {
                  _showConfirmationDialog(
                    context: context,
                    title: 'Deactivate Account',
                    content: 'This will permanently clear all app data and log you out. Are you sure?',
                    onConfirm: AppDataUtils.deactivateAccount,
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  // TODO: Implement delete account functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

}