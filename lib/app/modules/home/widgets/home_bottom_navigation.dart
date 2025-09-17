// lib/app/modules/home/views/widgets/home_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/home_controller.dart';

class HomeBottomNavigation extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const HomeBottomNavigation({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: controller.currentTabIndex.value,
      onTap: controller.onTabChanged,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.home,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'Shipments',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'Bidding',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle),
          label: l10n.profile,
        ),
      ],
    ));
  }
}