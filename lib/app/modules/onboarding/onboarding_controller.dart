import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../controllers/app_controller.dart';
import '../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final AppController _appController = Get.find<AppController>();

  var currentPage = 0.obs;

  List<Map<String, dynamic>> get onboardingPages {
    final l10n = AppLocalizations.of(Get.context!)!;
    return [
      {
        'title': l10n.onboardingTitle1,
        'description': l10n.onboardingDesc1,
        'icon': Icons.star,
      },
      {
        'title': l10n.onboardingTitle2,
        'description': l10n.onboardingDesc2,
        'icon': Icons.touch_app,
      },
      {
        'title': l10n.onboardingTitle3,
        'description': l10n.onboardingDesc3,
        'icon': Icons.connect_without_contact,
      },
    ];
  }

  bool get isLastPage => currentPage.value == onboardingPages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      _finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void skip() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    _appController.setFirstTime(false);
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}