// lib/app/modules/home/views/widgets/emergency_support_card.dart
import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/home_controller.dart';

class EmergencySupportCard extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const EmergencySupportCard({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: errorColor.withOpacity(0.1),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: errorColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Support',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: errorColor,
                        ),
                      ),
                      Text(
                        '24/7 assistance for urgent transport issues',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: errorColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: controller.callEmergencySupport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Call Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}