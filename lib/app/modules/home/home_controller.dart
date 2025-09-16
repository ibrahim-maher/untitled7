import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;

  String get userName => _authController.currentUser.value?.name ?? 'User';

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() async {
    isLoading.value = true;

    // Simulate loading data
    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;
  }

  void onMenuSelected(String value) {
    switch (value) {
      case 'profile':
        Get.toNamed(Routes.PROFILE);
        break;
      case 'settings':
        _showSettingsDialog();
        break;
      case 'logout':
        _logout();
        break;
    }
  }

  void _showSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              trailing: Switch(
                value: false,
                onChanged: null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}