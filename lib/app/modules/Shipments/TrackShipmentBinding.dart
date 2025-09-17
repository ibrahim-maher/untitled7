import 'package:get/get.dart';

import 'TrackShipmentController.dart';

class TrackShipmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackShipmentController>(
          () => TrackShipmentController(),
    );
  }
}