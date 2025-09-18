// lib/app/modules/main/main_binding.dart
import 'package:get/get.dart';
import '../../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
  }
}