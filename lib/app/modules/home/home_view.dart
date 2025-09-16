import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../routes/app_pages.dart';
import 'home_controller.dart';
import '../../controllers/language_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        actions: [
          // Language switcher
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
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

          // Profile menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 8),
                      Text(l10n.logout),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.welcome} ${controller.userName}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to your dashboard',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.person,
                    title: l10n.profile,
                    subtitle: 'View your profile',
                    onTap: () => Get.toNamed(Routes.PROFILE),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.settings,
                    title: l10n.settings,
                    subtitle: 'App settings',
                    onTap: () => controller.onMenuSelected('settings'),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.language,
                    title: l10n.language,
                    subtitle: languageController.getCurrentLanguageName(),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'App information',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageController.languages.map((lang) {
            return ListTile(
              leading: Text(lang['flag']),
              title: Text(lang['name']),
              onTap: () {
                languageController.changeLanguage(lang['code']);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter GetX App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Your Company',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('A Flutter app built with GetX, Firebase, and internationalization support.'),
        ),
      ],
    );
  }
}