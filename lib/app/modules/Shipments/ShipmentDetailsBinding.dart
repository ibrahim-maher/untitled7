import 'package:get/get.dart';

import '../../controllers/ShipmentDetailsController.dart';

class ShipmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipmentDetailsController>(() => ShipmentDetailsController());
  }
}