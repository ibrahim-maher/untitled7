import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'profile_controller.dart';
import '../../widgets/custom_button.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: controller.user.value?.photoUrl != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            controller.user.value!.photoUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Text(
                          controller.user.value?.name
                              .split(' ')
                              .map((e) => e[0])
                              .take(2)
                              .join() ??
                              'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        controller.user.value?.name ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        controller.user.value?.email ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Edit Profile Button
                      CustomButton(
                        text: 'Edit Profile',
                        isOutlined: true,
                        onPressed: controller.editProfile,
                        width: 150,
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Profile Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInfoRow(
                        context,
                        icon: Icons.person,
                        label: 'Full Name',
                        value: controller.user.value?.name ?? 'N/A',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoRow(
                        context,
                        icon: Icons.email,
                        label: l10n.email,
                        value: controller.user.value?.email ?? 'N/A',
                      ),

                      const SizedBox(height: 12),

                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Member Since',
                        value: controller.memberSince,
                      ),

                      const SizedBox(height: 12),

                      _buildInfoRow(
                        context,
                        icon: Icons.verified,
                        label: 'Account Status',
                        value: 'Verified',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: controller.changePassword,
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: controller.deleteAccount,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}