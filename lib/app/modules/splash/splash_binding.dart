import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Use Get.put instead of Get.lazyPut to ensure immediate initialization
    Get.put<SplashController>(SplashController());

    print('SplashBinding: SplashController created and bound');
  }
}