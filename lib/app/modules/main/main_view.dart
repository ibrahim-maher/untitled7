// lib/app/modules/main/main_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../controllers/main_controller.dart';
import '../home/home_view.dart';
import '../Shipments/ShipmentsView.dart';
import '../bids/MyBidsView.dart';
import '../profile/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Obx(() => TabBarView(
        controller: controller.tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeView(),
          ShipmentsView(),
          MyBidsView(),
          ProfileView(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentTabIndex.value,
        onTap: controller.onTabChanged,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.home,
                color: Theme.of(context).primaryColor,
              ),
            ),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithBadge(
              Icons.local_shipping,
              controller.shipmentsCount,
              Colors.red,
              context,
            ),
            activeIcon: _buildActiveIconWithBadge(
              Icons.local_shipping,
              controller.shipmentsCount,
              context,
            ),
            label: 'Shipments',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithBadge(
              Icons.gavel,
              controller.bidsCount,
              Colors.orange,
              context,
            ),
            activeIcon: _buildActiveIconWithBadge(
              Icons.gavel,
              controller.bidsCount,
              context,
            ),
            label: 'Bidding',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_circle,
                color: Theme.of(context).primaryColor,
              ),
            ),
            label: l10n.profile,
          ),
        ],
      )),
    );
  }

  Widget _buildIconWithBadge(IconData icon, int count, Color badgeColor, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveIconWithBadge(IconData icon, int count, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}