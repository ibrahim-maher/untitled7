import 'package:get/get.dart';

import '../../controllers/ShipmentsController.dart';

class ShipmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipmentsController>(
          () => ShipmentsController(),
    );
  }
}