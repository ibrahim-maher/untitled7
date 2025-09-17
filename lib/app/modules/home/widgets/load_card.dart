// lib/app/modules/home/views/widgets/load_card.dart
import 'package:flutter/material.dart';

import '../../../data/models/LoadModel.dart';
import '../../../theme/app_theme.dart';
import 'load_info_chip.dart';

class LoadCard extends StatelessWidget {
  final LoadModel load;
  final VoidCallback onTap;

  const LoadCard({
    Key? key,
    required this.load,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      load.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '₹${_formatCurrency(load.budget)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${load.pickupLocation} → ${load.deliveryLocation}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  LoadInfoChip(
                    text: '${load.weight.toInt()}kg',
                    icon: Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  LoadInfoChip(
                    text: load.loadType.displayName,
                    icon: Icons.category,
                    color: Theme.of(context).extension<AppColors>()?.warning ?? AppTheme.warningColor,
                  ),
                  const SizedBox(width: 8),
                  if (load.bidsCount > 0)
                    LoadInfoChip(
                      text: '${load.bidsCount} Bids',
                      icon: Icons.gavel,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                ],
              ),
              if (load.isUrgent) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: Theme.of(context).colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Urgent',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}