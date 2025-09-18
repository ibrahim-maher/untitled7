import 'package:get/get.dart';
import '../../controllers/AvailableLoadsController.dart';

class AvailableLoadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AvailableLoadsController>(
          () => AvailableLoadsController(),
    );
  }
}