import 'package:get/get.dart';
import '../../controllers/MyBidsController.dart';

class MyBidsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBidsController>(
          () => MyBidsController(),
    );
  }
}