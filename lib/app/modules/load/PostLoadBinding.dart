import 'package:get/get.dart';
import '../../controllers/post_load_controller.dart';

class PostLoadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostLoadController>(
          () => PostLoadController(),
    );
  }
}