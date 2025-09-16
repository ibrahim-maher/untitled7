import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Observable variables
  var isFirstTime = true.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkFirstTime();
  }

  void _checkFirstTime() {
    isFirstTime.value = _storage.read('first_time') ?? true;
  }

  void setFirstTime(bool value) {
    isFirstTime.value = value;
    _storage.write('first_time', value);
  }

  void setLoading(bool value) {
    isLoading.value = value;
  }
}