import 'package:get/get.dart';
import '../../controllers/CreatedLoadsController.dart';

class CreatedLoadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatedLoadsController>(
          () => CreatedLoadsController(),
    );
  }
}