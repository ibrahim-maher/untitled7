import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/auth_controller.dart';

class RegisterController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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

  String? validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(Get.context!)!;

    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value != passwordController.text) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }

  void register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await _authController.register(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}