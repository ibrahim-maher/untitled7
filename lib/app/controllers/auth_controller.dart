import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_pages.dart';
import '../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Observable variables
  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();
  var authState = AuthState.initial.obs;

  // Constants
  static const String _userStorageKey = 'cached_user_data';
  static const String _authStateKey = 'auth_state';

  @override
  void onInit() {
    super.onInit();
    print('AuthController: Initializing...');
    _initializeAuthState();
    _setupAuthListener();
  }

  @override
  void onReady() {
    super.onReady();
    print('AuthController: Ready - Current auth state: ${authState.value}');
    print('AuthController: Is logged in: $isLoggedIn');
  }

  /// Initialize authentication state from storage
  void _initializeAuthState() {
    try {
      // Load cached user data
      final cachedUserData = _storage.read(_userStorageKey);
      if (cachedUserData != null) {
        currentUser.value = UserModel.fromMap(Map<String, dynamic>.from(cachedUserData));
        print('AuthController: Loaded cached user: ${currentUser.value?.email}');
      }

      // Load auth state
      final savedAuthState = _storage.read(_authStateKey);
      if (savedAuthState != null) {
        authState.value = AuthState.values.firstWhere(
              (state) => state.toString() == savedAuthState,
          orElse: () => AuthState.initial,
        );
      }

      print('AuthController: Initialization complete - Auth state: ${authState.value}');
    } catch (e) {
      print('AuthController: Error during initialization: $e');
      authState.value = AuthState.initial;
    }
  }

  /// Set up Firebase auth state listener
  void _setupAuthListener() {
    _auth.authStateChanges().listen(
      _onAuthStateChanged,
      onError: (error) {
        print('AuthController: Auth state change error: $error');
        _handleAuthError(error);
      },
    );
  }

  /// Handle authentication state changes
  void _onAuthStateChanged(User? user) async {
    print('AuthController: Auth state changed - User: ${user?.email ?? 'null'}');

    try {
      if (user != null) {
        print('AuthController: User signed in - UID: ${user.uid}');
        authState.value = AuthState.authenticated;
        await _loadUserData(user.uid);
        _saveAuthState();
      } else {
        print('AuthController: User signed out');
        authState.value = AuthState.unauthenticated;
        currentUser.value = null;
        _clearUserData();
      }
    } catch (e) {
      print('AuthController: Error handling auth state change: $e');
      _handleAuthError(e);
    }
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      print('AuthController: Loading user data for UID: $uid');

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists && doc.data() != null) {
        final userData = doc.data() as Map<String, dynamic>;
        currentUser.value = UserModel.fromMap(userData);

        // Cache user data locally
        _storage.write(_userStorageKey, userData);

        print('AuthController: User data loaded successfully - Name: ${currentUser.value?.name}');
      } else {
        print('AuthController: User document not found in Firestore');
        throw Exception('User data not found');
      }
    } catch (e) {
      print('AuthController: Error loading user data: $e');
      // Don't throw the error, just log it - user might still be authenticated
      if (e.toString().contains('TimeoutException')) {
        _showError('Network timeout. Please check your connection.');
      } else {
        _showError('Failed to load user profile.');
      }
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    print('AuthController: Starting login process for email: $email');

    if (!_validateLoginInput(email, password)) {
      return false;
    }

    try {
      _setLoadingState(true);
      authState.value = AuthState.loading;

      print('AuthController: Attempting Firebase authentication...');

      UserCredential credential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30));

      if (credential.user != null) {
        print('AuthController: Firebase authentication successful');
        print('AuthController: User UID: ${credential.user!.uid}');

        // Auth state listener will handle the rest
        await Future.delayed(const Duration(milliseconds: 500)); // Allow state to update

        Get.offAllNamed(Routes.HOME);
        _showSuccess('Login successful! Welcome back.');

        print('AuthController: Login process completed successfully');
        return true;
      } else {
        print('AuthController: Firebase authentication failed - null user');
        _showError('Authentication failed. Please try again.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('AuthController: Firebase auth error - Code: ${e.code}, Message: ${e.message}');
      _showError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      print('AuthController: Unexpected login error: $e');
      if (e.toString().contains('TimeoutException')) {
        _showError('Login timeout. Please check your connection and try again.');
      } else {
        _showError('An unexpected error occurred during login.');
      }
      return false;
    } finally {
      _setLoadingState(false);
      if (authState.value == AuthState.loading) {
        authState.value = AuthState.unauthenticated;
      }
    }
  }

  /// Register new user
  Future<bool> register(String email, String password, String name) async {
    print('AuthController: Starting registration process for email: $email');

    if (!_validateRegistrationInput(email, password, name)) {
      return false;
    }

    try {
      _setLoadingState(true);
      authState.value = AuthState.loading;

      print('AuthController: Creating Firebase user account...');

      UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30));

      if (credential.user != null) {
        print('AuthController: Firebase user created successfully');
        print('AuthController: User UID: ${credential.user!.uid}');

        // Create user document in Firestore
        await _createUserDocument(credential.user!.uid, email, name);

        // Update Firebase user profile
        await credential.user!.updateDisplayName(name);

        Get.offAllNamed(Routes.HOME);
        _showSuccess('Registration successful! Welcome to our app.');

        print('AuthController: Registration process completed successfully');
        return true;
      } else {
        print('AuthController: Firebase user creation failed - null user');
        _showError('Registration failed. Please try again.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('AuthController: Firebase registration error - Code: ${e.code}, Message: ${e.message}');
      _showError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      print('AuthController: Unexpected registration error: $e');
      if (e.toString().contains('TimeoutException')) {
        _showError('Registration timeout. Please check your connection and try again.');
      } else {
        _showError('An unexpected error occurred during registration.');
      }
      return false;
    } finally {
      _setLoadingState(false);
      if (authState.value == AuthState.loading) {
        authState.value = AuthState.unauthenticated;
      }
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(String uid, String email, String name) async {
    try {
      print('AuthController: Creating user document in Firestore...');

      UserModel user = UserModel(
        uid: uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(user.toMap())
          .timeout(const Duration(seconds: 15));

      print('AuthController: User document created successfully');

      // The auth state listener will load this data automatically
    } catch (e) {
      print('AuthController: Error creating user document: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    print('AuthController: Starting logout process...');

    try {
      _setLoadingState(true);
      authState.value = AuthState.loading;

      await _auth.signOut().timeout(const Duration(seconds: 10));

      print('AuthController: Firebase signout successful');

      Get.offAllNamed(Routes.LOGIN);
      _showSuccess('Logged out successfully. See you soon!');

      print('AuthController: Logout process completed successfully');
    } catch (e) {
      print('AuthController: Logout error: $e');
      _showError('Logout failed. Please try again.');
    } finally {
      _setLoadingState(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    print('AuthController: Starting password reset for email: $email');

    if (email.trim().isEmpty) {
      _showError('Please enter your email address.');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address.');
      return false;
    }

    try {
      await _auth
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 15));

      _showSuccess('Password reset link sent to $email. Please check your inbox.');
      print('AuthController: Password reset email sent successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('AuthController: Password reset error - Code: ${e.code}');
      _showError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      print('AuthController: Unexpected password reset error: $e');
      _showError('Failed to send password reset email. Please try again.');
      return false;
    }
  }

  // Helper methods
  bool _validateLoginInput(String email, String password) {
    if (email.trim().isEmpty) {
      _showError('Email is required.');
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address.');
      return false;
    }
    if (password.isEmpty) {
      _showError('Password is required.');
      return false;
    }
    return true;
  }

  bool _validateRegistrationInput(String email, String password, String name) {
    if (name.trim().isEmpty) {
      _showError('Name is required.');
      return false;
    }
    if (name.trim().length < 2) {
      _showError('Name must be at least 2 characters long.');
      return false;
    }
    return _validateLoginInput(email, password);
  }

  void _setLoadingState(bool loading) {
    isLoading.value = loading;
    print('AuthController: Loading state changed to: $loading');
  }

  void _saveAuthState() {
    _storage.write(_authStateKey, authState.value.toString());
  }

  void _clearUserData() {
    _storage.remove(_userStorageKey);
    _storage.remove(_authStateKey);
    print('AuthController: User data cleared from storage');
  }

  void _handleAuthError(dynamic error) {
    print('AuthController: Handling auth error: $error');
    authState.value = AuthState.error;
    currentUser.value = null;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.secondaryContainer,
      colorText: Get.theme.colorScheme.onSecondaryContainer,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Getters
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isAuthenticated => authState.value == AuthState.authenticated;
  bool get hasUserData => currentUser.value != null;
  String? get currentUserEmail => _auth.currentUser?.email;
  String? get currentUserId => _auth.currentUser?.uid;
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}