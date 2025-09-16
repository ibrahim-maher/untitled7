import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/auth_controller.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  String? validateEmail(String? value) {
    final l10n = AppLocalizations.of(Get.context!)!;

    if (value == null || value.isEmpty) {
      return l10n.emailRequired;
    }
    if (!GetUtils.isEmail(value)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    final l10n = AppLocalizations.of(Get.context!)!;

    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 6) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  void login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await _authController.login(
        emailController.text.trim(),
        passwordController.text,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _authController.resetPassword(emailController.text.trim());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}