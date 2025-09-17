// lib/app/modules/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/home_controller.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final AppLocalizations l10n;
  final LanguageController languageController;

  const HomeAppBar({
    Key? key,
    required this.controller,
    required this.l10n,
    required this.languageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'FreightX',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${l10n.welcome}, ${controller.userName}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your freight operations seamlessly',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // Notifications with badge
        Obx(() => Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: controller.navigateToNotifications,
            ),
            if (controller.unreadNotificationsCount.value > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${controller.unreadNotificationsCount.value}',
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
        )),

        // Language switcher
        PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: Colors.white),
          onSelected: (String languageCode) {
            languageController.changeLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) {
            return languageController.languages.map((lang) {
              return PopupMenuItem<String>(
                value: lang['code'],
                child: Row(
                  children: [
                    Text(lang['flag']),
                    const SizedBox(width: 8),
                    Text(lang['name']),
                  ],
                ),
              );
            }).toList();
          },
        ),

        // More options menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: controller.onMenuSelected,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(l10n.profile),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text(l10n.settings),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'support',
                child: Row(
                  children: [
                    const Icon(Icons.support_agent),
                    const SizedBox(width: 8),
                    const Text('Support'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}

// Alternative: Regular AppBar version (non-sliver)
class HomeAppBarRegular extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final AppLocalizations l10n;
  final LanguageController languageController;

  const HomeAppBarRegular({
    Key? key,
    required this.controller,
    required this.l10n,
    required this.languageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      toolbarHeight: 80,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FreightX',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            '${l10n.welcome}, ${controller.userName}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        // Notifications with badge
        Obx(() => Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: controller.navigateToNotifications,
            ),
            if (controller.unreadNotificationsCount.value > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${controller.unreadNotificationsCount.value}',
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
        )),

        // Language switcher
        PopupMenuButton<String>(
          icon: const Icon(Icons.language, color: Colors.white),
          onSelected: (String languageCode) {
            languageController.changeLanguage(languageCode);
          },
          itemBuilder: (BuildContext context) {
            return languageController.languages.map((lang) {
              return PopupMenuItem<String>(
                value: lang['code'],
                child: Row(
                  children: [
                    Text(lang['flag']),
                    const SizedBox(width: 8),
                    Text(lang['name']),
                  ],
                ),
              );
            }).toList();
          },
        ),

        // More options menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: controller.onMenuSelected,
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(l10n.profile),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text(l10n.settings),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'support',
                child: Row(
                  children: [
                    const Icon(Icons.support_agent),
                    const SizedBox(width: 8),
                    const Text('Support'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}