import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var user = Rxn<UserModel>();

  String get memberSince {
    if (user.value?.createdAt != null) {
      return DateFormat('MMM dd, yyyy').format(user.value!.createdAt);
    }
    return 'N/A';
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    user.value = _authController.currentUser.value;

    // Listen to auth controller changes
    ever(_authController.currentUser, (UserModel? updatedUser) {
      user.value = updatedUser;
    });
  }

  void editProfile() {
    // TODO: Navigate to edit profile screen
    Get.snackbar(
      'Info',
      'Edit profile feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void changePassword() {
    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'A password reset link will be sent to your email address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (user.value?.email != null) {
                _authController.resetPassword(user.value!.email);
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDeleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Type "DELETE" to confirm account deletion:',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Implement account deletion
              Get.snackbar(
                'Info',
                'Account deletion feature will be implemented soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}