// lib/app/controllers/main_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/profile/profile_controller.dart';
import 'home_controller.dart';
import 'ShipmentsController.dart';
import 'MyBidsController.dart';

class MainController extends GetxController with GetSingleTickerProviderStateMixin {
  var currentTabIndex = 0.obs;
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);

    // Initialize controllers if they don't exist
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    if (!Get.isRegistered<ShipmentsController>()) {
      Get.put(ShipmentsController(), permanent: true);
    }
    if (!Get.isRegistered<MyBidsController>()) {
      Get.put(MyBidsController(), permanent: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void onTabChanged(int index) {
    currentTabIndex.value = index;
    tabController.animateTo(index);
  }

  // Get badge counts from individual controllers
  int get shipmentsCount {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.activeShipments.length;
    } catch (e) {
      return 0;
    }
  }

  int get bidsCount {
    try {
      final homeController = Get.find<HomeController>();
      return homeController.activeBids.length;
    } catch (e) {
      return 0;
    }
  }
}