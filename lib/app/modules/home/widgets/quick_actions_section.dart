// lib/app/modules/home/views/widgets/quick_actions_section.dart
import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../controllers/home_controller.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const QuickActionsSection({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the AppColors extension from the theme
    final appColors = Theme.of(context).extension<AppColors>();
    final colorScheme = Theme.of(context).colorScheme;

    final actions = [
      {
        'icon': Icons.add_box,
        'title': l10n.postLoad,
        'action': 'post_load',
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.search,
        'title': l10n.findTrucks,
        'action': 'search_trucks',
        'color': colorScheme.secondary,
      },
      {
        'icon': Icons.track_changes,
        'title': l10n.track,
        'action': 'track_shipment',
        'color': appColors?.warning ?? colorScheme.tertiary,
      },
      {
        'icon': Icons.gavel,
        'title': l10n.bidding,
        'action': 'bidding',
        'color': colorScheme.tertiary,
      },
      {
        'icon': Icons.payment,
        'title': l10n.payments,
        'action': 'payments',
        'color': appColors?.error ?? colorScheme.error,
      },
      {
        'icon': Icons.support_agent,
        'title': l10n.support,
        'action': 'support',
        'color': appColors?.info ?? colorScheme.primary,
      },
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.quickActions,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, // Use theme color
                  ),
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.apps,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    l10n.viewAll,
                    style: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                  onPressed: () {
                    // Navigate to all services page
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return QuickActionCard(
                  icon: action['icon'] as IconData,
                  title: action['title'] as String,
                  color: action['color'] as Color,
                  onTap: () => controller.onQuickActionTapped(action['action'] as String),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}