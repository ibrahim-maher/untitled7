// lib/app/modules/home/views/widgets/quick_stats_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';

import '../../../theme/app_theme.dart';
import '../../../controllers/home_controller.dart';
import 'stat_card.dart';

class QuickStatsSection extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const QuickStatsSection({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final stats = controller.quickStats.value;
        if (stats == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section - Fixed overflow
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.quickOverview ?? 'Quick Overview',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.trending_up,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid - Completely overflow-safe
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;

                      // Determine grid configuration based on screen width
                      int crossAxisCount;
                      double childAspectRatio;
                      double crossAxisSpacing;
                      double mainAxisSpacing;

                      if (availableWidth > 600) {
                        // Large screens - 4 columns
                        crossAxisCount = 4;
                        childAspectRatio = 1.2;
                        crossAxisSpacing = 12;
                        mainAxisSpacing = 12;
                      } else if (availableWidth > 400) {
                        // Medium screens - 2 columns
                        crossAxisCount = 2;
                        childAspectRatio = 1.6;
                        crossAxisSpacing = 10;
                        mainAxisSpacing = 10;
                      } else {
                        // Small screens - 2 columns but more compact
                        crossAxisCount = 2;
                        childAspectRatio = 1.4;
                        crossAxisSpacing = 8;
                        mainAxisSpacing = 8;
                      }

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildStatCard(
                            context: context,
                            title: l10n.totalShipments ?? 'Total',
                            value: _formatNumber(stats.totalShipments),
                            icon: Icons.local_shipping,
                            color: Theme.of(context).colorScheme.primary,
                            availableWidth: availableWidth,
                          ),
                          _buildStatCard(
                            context: context,
                            title: l10n.activeShipments ?? 'Active',
                            value: _formatNumber(stats.activeShipments),
                            icon: Icons.pending_actions,
                            color: Theme.of(context).extension<AppColors>()?.warning ?? AppTheme.warningColor,
                            availableWidth: availableWidth,
                          ),
                          _buildStatCard(
                            context: context,
                            title: l10n.completedShipments ?? 'Done',
                            value: _formatNumber(stats.completedShipments),
                            icon: Icons.check_circle,
                            color: Theme.of(context).extension<AppColors>()?.success ?? AppTheme.successColor,
                            availableWidth: availableWidth,
                          ),
                          _buildStatCard(
                            context: context,
                            title: l10n.totalSavings ?? 'Savings',
                            value: '₹${_formatCurrency(stats.totalSavings)}',
                            icon: Icons.savings,
                            color: Theme.of(context).colorScheme.tertiary,
                            availableWidth: availableWidth,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double availableWidth,
  }) {
    // Adjust font sizes based on available width
    final isSmallScreen = availableWidth <= 400;
    final titleFontSize = isSmallScreen ? 10.0 : 12.0;
    final valueFontSize = isSmallScreen ? 14.0 : 16.0;
    final iconSize = isSmallScreen ? 16.0 : 20.0;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Value Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: valueFontSize,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 4 : 6),

            // Title
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      final millions = number / 1000000;
      return millions >= 10
          ? '${millions.toInt()}M'
          : '${millions.toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      final thousands = number / 1000;
      return thousands >= 10
          ? '${thousands.toInt()}K'
          : '${thousands.toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      final crores = amount / 10000000;
      return crores >= 10
          ? '${crores.toInt()}Cr'
          : '${crores.toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      final lakhs = amount / 100000;
      return lakhs >= 10
          ? '${lakhs.toInt()}L'
          : '${lakhs.toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      final thousands = amount / 1000;
      return thousands >= 10
          ? '${thousands.toInt()}K'
          : '${thousands.toStringAsFixed(1)}K';
    } else {
      return amount.toInt().toString();
    }
  }
}