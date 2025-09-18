import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../data/models/LoadModel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../controllers/CreatedLoadsController.dart';

class CreatedLoadsView extends GetView<CreatedLoadsController> {
  const CreatedLoadsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(context, l10n, theme, appColors),
      body: _buildBody(context, l10n, theme, appColors),
      floatingActionButton: _buildFloatingActionButton(context, l10n, theme),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n, ThemeData theme, AppColors? appColors) {
    return AppBar(
      title: Text(
        l10n.myLoads,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      actions: [
        // Selection mode toggle
        Obx(() => controller.isSelectionMode.value
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.selectedLoadIds.isNotEmpty)
              Text(
                '${controller.selectedLoadIds.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: controller.selectAllLoads,
              tooltip: l10n.selectAll,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: controller.toggleSelectionMode,
              tooltip: l10n.cancel,
            ),
          ],
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter button
            Obx(() => IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list),
                  if (controller.isFilterApplied.value)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: appColors?.error ?? Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: controller.showFilterDialog,
              tooltip: l10n.filter,
            )),
            // More options
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'selection':
                    controller.toggleSelectionMode();
                    break;
                  case 'bulk':
                    controller.showBulkActionsDialog();
                    break;
                  case 'export':
                    controller.exportLoads();
                    break;
                  case 'refresh':
                    controller.refreshLoads();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'selection',
                  child: Row(
                    children: [
                      const Icon(Icons.checklist),
                      const SizedBox(width: 8),
                      Text(l10n.selectMode),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'bulk',
                  child: Row(
                    children: [
                      const Icon(Icons.batch_prediction),
                      const SizedBox(width: 8),
                      Text(l10n.bulkActions),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(Icons.download),
                      const SizedBox(width: 8),
                      Text(l10n.export),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      const Icon(Icons.refresh),
                      const SizedBox(width: 8),
                      Text(l10n.refresh),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                hint: l10n.searchLoads,
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                )
                    : const SizedBox.shrink()),
                onChanged: controller.onSearchChanged,
              ),
            ),

            // Tab bar
            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                controller: controller.tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                isScrollable: false,
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.all),
                        const SizedBox(width: 4),
                        _buildTabBadge(
                          '${controller.totalLoads}',
                          theme.colorScheme.primary,
                          theme,
                        ),
                      ],
                    )),
                  ),
                  Tab(
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.active),
                        const SizedBox(width: 4),
                        _buildTabBadge(
                          '${controller.activeLoadsCount}',
                          appColors?.warning ?? Colors.orange,
                          theme,
                        ),
                      ],
                    )),
                  ),
                  Tab(
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.completed),
                        const SizedBox(width: 4),
                        _buildTabBadge(
                          '${controller.completedLoadsCount}',
                          appColors?.success ?? Colors.green,
                          theme,
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBadge(String count, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, ThemeData theme, AppColors? appColors) {
    return Column(
      children: [
        // Statistics card
        _buildStatisticsCard(context, l10n, theme, appColors),

        // Loads list
        Expanded(
          child: Obx(
                () => controller.isLoading.value
                ? Center(
              child: LoadingWidget(
                message: l10n.loadingLoads,
              ),
            )
                : TabBarView(
              controller: controller.tabController,
              children: [
                _buildLoadsList(context, controller.filteredLoads, l10n, theme, appColors),
                _buildLoadsList(
                  context,
                  controller.activeLoads.where((load) => controller.filteredLoads.contains(load)).toList(),
                  l10n,
                  theme,
                  appColors,
                ),
                _buildLoadsList(
                  context,
                  controller.completedLoads.where((load) => controller.filteredLoads.contains(load)).toList(),
                  l10n,
                  theme,
                  appColors,
                ),
              ],
            ),
          ),
        ),

        // Bulk actions bar
        Obx(() => controller.isSelectionMode.value && controller.selectedLoadIds.isNotEmpty
            ? _buildBulkActionsBar(context, l10n, theme, appColors)
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildStatisticsCard(BuildContext context, AppLocalizations l10n, ThemeData theme, AppColors? appColors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildStatItem(
              context,
              l10n.total,
              '${controller.totalLoads}',
              Icons.inventory,
              theme.colorScheme.onPrimary,
              theme,
            )),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
          Expanded(
            child: Obx(() => _buildStatItem(
              context,
              l10n.active,
              '${controller.activeLoadsCount}',
              Icons.pending_actions,
              theme.colorScheme.onPrimary,
              theme,
            )),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
          Expanded(
            child: Obx(() => _buildStatItem(
              context,
              l10n.successRate,
              '${controller.successRate.toStringAsFixed(0)}%',
              Icons.check_circle,
              theme.colorScheme.onPrimary,
              theme,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ThemeData theme,
      ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadsList(
      BuildContext context,
      List<LoadModel> loads,
      AppLocalizations l10n,
      ThemeData theme,
      AppColors? appColors,
      ) {
    if (loads.isEmpty) {
      return _buildEmptyState(context, l10n, theme, appColors);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshLoads,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: loads.length,
        itemBuilder: (context, index) {
          final load = loads[index];
          return _buildLoadCard(context, load, l10n, theme, appColors);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ThemeData theme, AppColors? appColors) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noLoadsFound,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startByPostingFirstLoad,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.navigateToPostLoad,
            icon: const Icon(Icons.add),
            label: Text(l10n.postLoad),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadCard(
      BuildContext context,
      LoadModel load,
      AppLocalizations l10n,
      ThemeData theme,
      AppColors? appColors,
      ) {
    final statusColor = _getStatusColor(load.status, appColors);

    return Obx(() {
      final isSelected = controller.selectedLoadIds.contains(load.id);

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: () {
            if (controller.isSelectionMode.value) {
              controller.toggleLoadSelection(load.id);
            } else {
              controller.navigateToLoadDetails(load);
            }
          },
          onLongPress: () {
            if (!controller.isSelectionMode.value) {
              controller.toggleSelectionMode();
              controller.toggleLoadSelection(load.id);
            } else {
              controller.showLoadActions(load);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Selection checkbox
                    Obx(() => controller.isSelectionMode.value
                        ? Checkbox(
                      value: isSelected,
                      onChanged: (_) => controller.toggleLoadSelection(load.id),
                      activeColor: theme.colorScheme.primary,
                    )
                        : const SizedBox.shrink()),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            load.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Load #${load.id.substring(0, 8).toUpperCase()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            load.status.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Route information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: appColors?.success ?? Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 30,
                            color: theme.colorScheme.outline,
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: appColors?.error ?? Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              load.pickupLocation,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              load.deliveryLocation,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (load.distance != null) ...[
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            Icon(
                              Icons.route,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            Text(
                              '${load.distance!.toStringAsFixed(0)} km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Load details
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.category,
                        text: load.loadType.displayName,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.local_shipping,
                        text: load.vehicleType.displayName,
                        theme: theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.fitness_center,
                        text: '${load.weight.toStringAsFixed(0)} kg',
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (load.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (appColors?.error ?? Colors.red).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flash_on,
                              size: 14,
                              color: appColors?.error ?? Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.urgent,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: appColors?.error ?? Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Time and budget info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(load.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        if (load.bidsCount > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.how_to_vote,
                                size: 16,
                                color: appColors?.info ?? Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.bidsCount(load.bidsCount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: appColors?.info ?? Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${load.budget.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: appColors?.success ?? Colors.green,
                          ),
                        ),
                        if (load.viewCount > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${load.viewCount} views',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),

                // Action buttons (only show when not in selection mode)
                if (!controller.isSelectionMode.value) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.navigateToLoadDetails(load),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: Text(l10n.view),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: theme.colorScheme.outline),
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.showLoadActions(load),
                          icon: const Icon(Icons.more_horiz, size: 18),
                          label: Text(l10n.actions),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: BorderSide(color: theme.colorScheme.outline),
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
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
    });
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(
      BuildContext context,
      AppLocalizations l10n,
      ThemeData theme,
      AppColors? appColors,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.showBulkActionsDialog,
              icon: const Icon(Icons.batch_prediction),
              label: Text(l10n.bulkActions),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: controller.clearSelection,
            icon: const Icon(Icons.clear),
            tooltip: l10n.clearSelection,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Obx(() => controller.isSelectionMode.value
        ? const SizedBox.shrink()
        : FloatingActionButton.extended(
      onPressed: controller.navigateToPostLoad,
      icon: const Icon(Icons.add),
      label: Text(l10n.postLoad),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    ));
  }

  Color _getStatusColor(LoadStatus status, AppColors? appColors) {
    switch (status) {
      case LoadStatus.draft:
        return Colors.grey[600]!;
      case LoadStatus.posted:
      case LoadStatus.active:
        return appColors?.info ?? Colors.blue;
      case LoadStatus.bidding:
        return appColors?.warning ?? Colors.orange;
      case LoadStatus.assigned:
        return Colors.purple[600]!;
      case LoadStatus.inProgress:
        return Colors.teal[600]!;
      case LoadStatus.completed:
        return appColors?.success ?? Colors.green;
      case LoadStatus.cancelled:
        return appColors?.error ?? Colors.red;
      case LoadStatus.expired:
        return Colors.grey[800]!;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}