// lib/app/modules/Shipments/RateShipmentBinding.dart
import 'package:get/get.dart';
import '../../controllers/RateShipmentController.dart';

class RateShipmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RateShipmentController>(() => RateShipmentController());
  }
}