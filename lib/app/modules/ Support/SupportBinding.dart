import 'package:get/get.dart';
import '../../controllers/SupportController.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(
          () => SupportController(),
    );
  }
}