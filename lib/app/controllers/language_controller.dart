import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final GetStorage _storage = GetStorage();

  var currentLocale = const Locale('en', '').obs;

  final List<Map<String, dynamic>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() {
    String? languageCode = _storage.read('language_code');
    if (languageCode != null) {
      currentLocale.value = Locale(languageCode);
      Get.updateLocale(currentLocale.value);
    }
  }

  void changeLanguage(String languageCode) {
    currentLocale.value = Locale(languageCode);
    Get.updateLocale(currentLocale.value);
    _storage.write('language_code', languageCode);
  }

  bool get isRtl => currentLocale.value.languageCode == 'ar';

  String getCurrentLanguageName() {
    return languages
        .firstWhere(
          (lang) => lang['code'] == currentLocale.value.languageCode,
      orElse: () => languages.first,
    )['name'];
  }
}