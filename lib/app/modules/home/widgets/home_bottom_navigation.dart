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
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        // Home Tab
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

        // Shipments Tab with Badge
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(
            Icons.local_shipping,
            controller.activeShipments.length,
            Colors.red,
            context,
          ),
          activeIcon: _buildActiveIconWithBadge(
            Icons.local_shipping,
            controller.activeShipments.length,
            context,
          ),
          label: 'Shipments',
        ),

        // Bidding Tab with Badge
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(
            Icons.gavel,
            controller.activeBids.length,
            Colors.orange,
            context,
          ),
          activeIcon: _buildActiveIconWithBadge(
            Icons.gavel,
            controller.activeBids.length,
            context,
          ),
          label: l10n.bidding ?? 'Bidding',
        ),

        // Profile Tab
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
    ));
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