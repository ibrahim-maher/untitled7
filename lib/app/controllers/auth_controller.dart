import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';
import '../data/models/user_model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      currentUser.value = null;
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        Get.offAllNamed(Routes.HOME);
        Get.snackbar('Success', 'Login successful');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getErrorMessage(e.code));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        UserModel user = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toMap());

        Get.offAllNamed(Routes.HOME);
        Get.snackbar('Success', 'Registration successful');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getErrorMessage(e.code));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'Logout failed');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'Password reset email sent');
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _getErrorMessage(e.code));
      return false;
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred');
      return false;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed';
    }
  }

  bool get isLoggedIn => _auth.currentUser != null;
}