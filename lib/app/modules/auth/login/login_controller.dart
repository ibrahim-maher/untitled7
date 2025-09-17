import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/auth_controller.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form and controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Observable variables
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var isFormValid = false.obs;
  var emailError = RxnString();
  var passwordError = RxnString();

  // Form state tracking
  var hasAttemptedSubmit = false.obs;
  var isEmailFocused = false.obs;
  var isPasswordFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('LoginController: Initializing...');
    _setupFormListeners();
    _setupControllerListeners();
  }

  @override
  void onReady() {
    super.onReady();
    print('LoginController: Ready - Auth state: ${_authController.authState.value}');
  }

  /// Setup form validation listeners
  void _setupFormListeners() {
    // Email field listeners
    emailController.addListener(_onEmailChanged);
    emailFocusNode.addListener(() {
      isEmailFocused.value = emailFocusNode.hasFocus;
      print('LoginController: Email focus changed - Focused: ${isEmailFocused.value}');

      if (!emailFocusNode.hasFocus && hasAttemptedSubmit.value) {
        _validateEmailField();
      }
    });

    // Password field listeners
    passwordController.addListener(_onPasswordChanged);
    passwordFocusNode.addListener(() {
      isPasswordFocused.value = passwordFocusNode.hasFocus;
      print('LoginController: Password focus changed - Focused: ${isPasswordFocused.value}');

      if (!passwordFocusNode.hasFocus && hasAttemptedSubmit.value) {
        _validatePasswordField();
      }
    });

    print('LoginController: Form listeners setup complete');
  }

  /// Setup auth controller listeners
  void _setupControllerListeners() {
    // Listen to auth controller loading state
    ever(_authController.isLoading, (bool loading) {
      isLoading.value = loading;
      print('LoginController: Loading state changed to: $loading');
    });

    // Listen to auth state changes
    ever(_authController.authState, (AuthState state) {
      print('LoginController: Auth state changed to: $state');
      _handleAuthStateChange(state);
    });
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(AuthState state) {
    switch (state) {
      case AuthState.loading:
        print('LoginController: Authentication in progress...');
        break;
      case AuthState.authenticated:
        print('LoginController: User authenticated successfully');
        _clearForm();
        break;
      case AuthState.unauthenticated:
        print('LoginController: User not authenticated');
        break;
      case AuthState.error:
        print('LoginController: Authentication error occurred');
        break;
      case AuthState.initial:
        print('LoginController: Initial auth state');
        break;
    }
  }

  /// Handle email field changes
  void _onEmailChanged() {
    final email = emailController.text;
    print('LoginController: Email changed - Length: ${email.length}');

    if (hasAttemptedSubmit.value) {
      _validateEmailField();
    }
    _updateFormValidation();
  }

  /// Handle password field changes
  void _onPasswordChanged() {
    final password = passwordController.text;
    print('LoginController: Password changed - Length: ${password.length}');

    if (hasAttemptedSubmit.value) {
      _validatePasswordField();
    }
    _updateFormValidation();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
    HapticFeedback.lightImpact();
    print('LoginController: Password visibility toggled - Hidden: ${isPasswordHidden.value}');
  }

  /// Validate email field
  void _validateEmailField() {
    emailError.value = validateEmail(emailController.text);
    print('LoginController: Email validation - Error: ${emailError.value}');
  }

  /// Validate password field
  void _validatePasswordField() {
    passwordError.value = validatePassword(passwordController.text);
    print('LoginController: Password validation - Error: ${passwordError.value}');
  }

  /// Update overall form validation state
  void _updateFormValidation() {
    final emailValid = validateEmail(emailController.text) == null;
    final passwordValid = validatePassword(passwordController.text) == null;

    isFormValid.value = emailValid && passwordValid;
    print('LoginController: Form validation - Valid: ${isFormValid.value}');
  }

  /// Validate email with detailed checks
  String? validateEmail(String? value) {
    print('LoginController: Validating email - Value: "$value"');

    final l10n = AppLocalizations.of(Get.context!)!;

    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }

    final trimmedEmail = value.trim();

    if (!GetUtils.isEmail(trimmedEmail)) {
      return l10n.invalidEmail;
    }

    // Additional email format checks
    if (trimmedEmail.length > 320) {
      return 'Email address is too long';
    }

    if (trimmedEmail.contains('..') ||
        trimmedEmail.startsWith('.') ||
        trimmedEmail.endsWith('.')) {
      return l10n.invalidEmail;
    }

    print('LoginController: Email validation passed');
    return null;
  }

  /// Validate password with detailed checks
  String? validatePassword(String? value) {
    print('LoginController: Validating password - Length: ${value?.length ?? 0}');

    final l10n = AppLocalizations.of(Get.context!)!;

    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }

    if (value.length < 6) {
      return l10n.passwordTooShort;
    }

    if (value.length > 128) {
      return 'Password is too long (max 128 characters)';
    }

    print('LoginController: Password validation passed');
    return null;
  }

  /// Submit login form
  void login() async {
    print('LoginController: Login attempt started');

    hasAttemptedSubmit.value = true;

    // Validate form
    if (!formKey.currentState!.validate()) {
      print('LoginController: Form validation failed');
      _showValidationErrors();
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    print('LoginController: Form validation passed - Email: $email');

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      final success = await _authController.login(email, password);

      if (success) {
        print('LoginController: Login successful');
      } else {
        print('LoginController: Login failed');
        _handleLoginFailure();
      }
    } catch (e) {
      print('LoginController: Login error: $e');
      _handleLoginError(e);
    }
  }

  /// Handle forgot password
  void forgotPassword() {
    print('LoginController: Forgot password initiated');

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email address first');
      emailFocusNode.requestFocus();
      return;
    }

    if (validateEmail(email) != null) {
      _showError('Please enter a valid email address');
      emailFocusNode.requestFocus();
      return;
    }

    print('LoginController: Sending password reset for email: $email');
    _authController.resetPassword(email);
  }

  /// Handle login failure
  void _handleLoginFailure() {
    print('LoginController: Handling login failure');

    // Clear password field for security
    passwordController.clear();
    passwordFocusNode.requestFocus();

    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  /// Handle login error
  void _handleLoginError(dynamic error) {
    print('LoginController: Handling login error: $error');

    passwordController.clear();
    _showError('Login failed. Please try again.');

    HapticFeedback.heavyImpact();
  }

  /// Show validation errors
  void _showValidationErrors() {
    _validateEmailField();
    _validatePasswordField();

    if (emailError.value != null) {
      emailFocusNode.requestFocus();
    } else if (passwordError.value != null) {
      passwordFocusNode.requestFocus();
    }

    HapticFeedback.mediumImpact();
  }

  /// Clear form data
  void _clearForm() {
    print('LoginController: Clearing form data');

    emailController.clear();
    passwordController.clear();
    hasAttemptedSubmit.value = false;
    emailError.value = null;
    passwordError.value = null;
    isFormValid.value = false;
  }

  /// Show error message
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Auto-fill and accessibility helpers
  void fillTestCredentials() {
    if (_authController.isLoggedIn) return;

    emailController.text = 'test@example.com';
    passwordController.text = 'password123';
    _updateFormValidation();

    print('LoginController: Test credentials filled');
  }

  void clearAllFields() {
    emailController.clear();
    passwordController.clear();
    emailError.value = null;
    passwordError.value = null;
    hasAttemptedSubmit.value = false;
    isFormValid.value = false;

    print('LoginController: All fields cleared');
  }

  @override
  void onClose() {
    print('LoginController: Disposing resources...');

    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    super.onClose();
    print('LoginController: Disposed successfully');
  }

  // Getters for view state
  bool get canSubmit => isFormValid.value && !isLoading.value;
  bool get showEmailError => hasAttemptedSubmit.value && emailError.value != null;
  bool get showPasswordError => hasAttemptedSubmit.value && passwordError.value != null;
}