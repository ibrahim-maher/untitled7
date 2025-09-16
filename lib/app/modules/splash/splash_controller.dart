import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController {
  final AppController _appController = Get.find<AppController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    try {
      print('SplashController: Starting navigation logic');

      // Wait for 2 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      print('SplashController: Checking user auth status: ${_authController.isLoggedIn}');
      print('SplashController: Checking first time: ${_appController.isFirstTime.value}');

      // Check if user is logged in
      if (_authController.isLoggedIn) {
        print('SplashController: Navigating to HOME');
        Get.offAllNamed(Routes.HOME);
      } else if (_appController.isFirstTime.value) {
        // Show onboarding for first-time users
        print('SplashController: Navigating to ONBOARDING');
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        // Go directly to login
        print('SplashController: Navigating to LOGIN');
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print('SplashController Error: $e');
      // Fallback to login if there's any error
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}