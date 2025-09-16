import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'generated/l10n/app_localizations.dart';
import 'app/controllers/app_controller.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/language_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with explicit options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase if initialization fails
  }

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Controllers
  Get.put(LanguageController());
  Get.put(AuthController());
  Get.put(AppController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter GetX App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      locale: Get.find<LanguageController>().currentLocale.value,
      fallbackLocale: const Locale('en', ''),

      // Routing
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // Translations
      translationsKeys: {},
    );
  }
}