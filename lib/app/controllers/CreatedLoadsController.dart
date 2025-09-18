import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

import '../data/models/LoadModel.dart';
import '../services/firestore_service.dart';
import '../routes/app_pages.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class CreatedLoadsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab controller
  late TabController tabController;

  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var allLoads = <LoadModel>[].obs;
  var filteredLoads = <LoadModel>[].obs;
  var searchQuery = ''.obs;
  var selectedFilter = LoadFilter.all.obs;
  var selectedSort = LoadSort.newest.obs;
  var isFilterApplied = false.obs;

  // Statistics
  var totalLoads = 0.obs;
  var activeLoadsCount = 0.obs;
  var completedLoadsCount = 0.obs;
  var successRate = 0.0.obs;
  var averageBudget = 0.0.obs;
  var totalRevenue = 0.0.obs;

  // Current tab index
  var currentTabIndex = 0.obs;

  // Computed lists
  List<LoadModel> get activeLoads => allLoads.where((load) =>
  load.status == LoadStatus.posted ||
      load.status == LoadStatus.bidding ||
      load.status == LoadStatus.assigned ||
      load.status == LoadStatus.inProgress ||
      load.status == LoadStatus.active
  ).toList();

  List<LoadModel> get completedLoads => allLoads.where((load) =>
  load.status == LoadStatus.completed
  ).toList();

  List<LoadModel> get draftLoads => allLoads.where((load) =>
  load.status == LoadStatus.draft
  ).toList();

  List<LoadModel> get cancelledLoads => allLoads.where((load) =>
  load.status == LoadStatus.cancelled
  ).toList();

  List<LoadModel> get expiredLoads => allLoads.where((load) =>
  load.status == LoadStatus.expired
  ).toList();

  // Real-time listener
  StreamSubscription? _loadsSubscription;

  // Selected loads for bulk operations
  var selectedLoadIds = <String>[].obs;
  var isSelectionMode = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize tab controller
    tabController = TabController(length: 3, vsync: this);

    // Setup listeners
    tabController.addListener(_onTabChanged);
    ever(searchQuery, (_) => _debounceSearch());

    // Load data
    _loadLoads();
    _setupRealTimeListener();
  }

  @override
  void onClose() {
    tabController.dispose();
    _loadsSubscription?.cancel();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging && tabController.index >= 0 && tabController.index < 3) {
      currentTabIndex.value = tabController.index;
      _applyFilters();
    }
  }

  Timer? _debounceTimer;
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _applyFilters);
  }

  void _setupRealTimeListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _loadsSubscription = FirestoreService.getUserLoadsStream().listen(
          (loads) {
        allLoads.assignAll(loads);
        _updateStatistics();
        _applyFilters();
      },
      onError: (error) {
        debugPrint('Error in loads stream: $error');
        _showErrorSnackbar('Failed to sync loads');
      },
    );
  }

  Future<void> _loadLoads() async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackbar('Please login to view your loads');
        return;
      }

      final loads = await FirestoreService.getUserLoads();
      allLoads.assignAll(loads);

      _updateStatistics();
      _applyFilters();

    } catch (e) {
      debugPrint('Error loading loads: $e');
      _showErrorSnackbar('Failed to load loads');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStatistics() {
    totalLoads.value = allLoads.length;
    activeLoadsCount.value = activeLoads.length;
    completedLoadsCount.value = completedLoads.length;

    // Calculate success rate
    if (totalLoads.value > 0) {
      successRate.value = (completedLoadsCount.value / totalLoads.value) * 100;
    } else {
      successRate.value = 0.0;
    }

    // Calculate average budget
    if (allLoads.isNotEmpty) {
      final totalBudget = allLoads.fold<double>(0.0, (sum, load) => sum + load.budget);
      averageBudget.value = totalBudget / allLoads.length;
    } else {
      averageBudget.value = 0.0;
    }

    // Calculate total revenue from completed loads
    totalRevenue.value = completedLoads.fold<double>(0.0, (sum, load) => sum + load.budget);
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // Filter and sort
  void _applyFilters() {
    var filtered = List<LoadModel>.from(allLoads);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((load) =>
      load.title.toLowerCase().contains(searchQuery.value) ||
          load.pickupLocation.toLowerCase().contains(searchQuery.value) ||
          load.deliveryLocation.toLowerCase().contains(searchQuery.value) ||
          load.loadType.displayName.toLowerCase().contains(searchQuery.value) ||
          load.vehicleType.displayName.toLowerCase().contains(searchQuery.value) ||
          (load.description?.toLowerCase().contains(searchQuery.value) ?? false) ||
          (load.contactPerson?.toLowerCase().contains(searchQuery.value) ?? false)
      ).toList();
    }

    // Apply status filter based on current tab and selected filter
    final currentTab = currentTabIndex.value;
    switch (currentTab) {
      case 0: // All tab
        break; // No additional filtering for All tab
      case 1: // Active tab
        filtered = filtered.where((load) => activeLoads.contains(load)).toList();
        break;
      case 2: // Completed tab
        filtered = filtered.where((load) => completedLoads.contains(load)).toList();
        break;
    }

    // Apply additional filter
    switch (selectedFilter.value) {
      case LoadFilter.active:
        filtered = filtered.where((load) => activeLoads.contains(load)).toList();
        break;
      case LoadFilter.completed:
        filtered = filtered.where((load) => completedLoads.contains(load)).toList();
        break;
      case LoadFilter.draft:
        filtered = filtered.where((load) => draftLoads.contains(load)).toList();
        break;
      case LoadFilter.cancelled:
        filtered = filtered.where((load) => cancelledLoads.contains(load)).toList();
        break;
      case LoadFilter.expired:
        filtered = filtered.where((load) => expiredLoads.contains(load)).toList();
        break;
      case LoadFilter.urgent:
        filtered = filtered.where((load) => load.isUrgent).toList();
        break;
      case LoadFilter.highBudget:
        final avgBudget = averageBudget.value;
        filtered = filtered.where((load) => load.budget > avgBudget * 1.5).toList();
        break;
      case LoadFilter.recentlyPosted:
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        filtered = filtered.where((load) => load.createdAt.isAfter(threeDaysAgo)).toList();
        break;
      case LoadFilter.all:
      default:
      // No additional filtering
        break;
    }

    // Apply sorting
    switch (selectedSort.value) {
      case LoadSort.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case LoadSort.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case LoadSort.budgetHigh:
        filtered.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case LoadSort.budgetLow:
        filtered.sort((a, b) => a.budget.compareTo(b.budget));
        break;
      case LoadSort.mostBids:
        filtered.sort((a, b) => b.bidsCount.compareTo(a.bidsCount));
        break;
      case LoadSort.leastBids:
        filtered.sort((a, b) => a.bidsCount.compareTo(b.bidsCount));
        break;
      case LoadSort.alphabetical:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case LoadSort.distance:
        filtered.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        break;
      case LoadSort.mostViewed:
        filtered.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case LoadSort.pickupDate:
        filtered.sort((a, b) => a.pickupDate.compareTo(b.pickupDate));
        break;
    }

    filteredLoads.assignAll(filtered);

    // Update filter applied status
    isFilterApplied.value = selectedFilter.value != LoadFilter.all ||
        selectedSort.value != LoadSort.newest ||
        searchQuery.value.isNotEmpty;
  }

  // Filter dialog
  void showFilterDialog() {
    final l10n = AppLocalizations.of(Get.context!)!;
    final theme = Theme.of(Get.context!);
    final appColors = theme.extension<AppColors>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filterAndSort,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    l10n.clearAll,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter by status
            Text(
              l10n.filterByStatus,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LoadFilter.values.map((filter) {
                final isSelected = selectedFilter.value == filter;
                return FilterChip(
                  label: Text(_getFilterDisplayName(filter, l10n)),
                  selected: isSelected,
                  onSelected: (_) => _selectFilter(filter),
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
            )),

            const SizedBox(height: 20),

            // Sort options
            Text(
              l10n.sortBy,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Obx(() => Column(
                  children: LoadSort.values.map((sort) {
                    final isSelected = selectedSort.value == sort;
                    return RadioListTile<LoadSort>(
                      title: Text(
                        _getSortDisplayName(sort, l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      value: sort,
                      groupValue: selectedSort.value,
                      onChanged: (value) => _selectSort(value!),
                      contentPadding: EdgeInsets.zero,
                      activeColor: theme.colorScheme.primary,
                    );
                  }).toList(),
                )),
              ),
            ),

            const SizedBox(height: 20),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Text(l10n.applyFilters),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFilter(LoadFilter filter) {
    selectedFilter.value = filter;
  }

  void _selectSort(LoadSort sort) {
    selectedSort.value = sort;
  }

  void _clearFilters() {
    selectedFilter.value = LoadFilter.all;
    selectedSort.value = LoadSort.newest;
    searchQuery.value = '';
    _applyFilters();
  }

  String _getFilterDisplayName(LoadFilter filter, AppLocalizations l10n) {
    switch (filter) {
      case LoadFilter.all:
        return l10n.all;
      case LoadFilter.active:
        return l10n.active;
      case LoadFilter.completed:
        return l10n.completed;
      case LoadFilter.draft:
        return l10n.draft;
      case LoadFilter.cancelled:
        return l10n.cancelled;
      case LoadFilter.expired:
        return l10n.expired;
      case LoadFilter.urgent:
        return l10n.urgent;
      case LoadFilter.highBudget:
        return l10n.highBudget;
      case LoadFilter.recentlyPosted:
        return l10n.recentlyPosted;
    }
  }

  String _getSortDisplayName(LoadSort sort, AppLocalizations l10n) {
    switch (sort) {
      case LoadSort.newest:
        return l10n.newestFirst;
      case LoadSort.oldest:
        return l10n.oldestFirst;
      case LoadSort.budgetHigh:
        return l10n.highestBudget;
      case LoadSort.budgetLow:
        return l10n.lowestBudget;
      case LoadSort.mostBids:
        return l10n.mostBids;
      case LoadSort.leastBids:
        return l10n.leastBids;
      case LoadSort.alphabetical:
        return l10n.alphabetical;
      case LoadSort.distance:
        return l10n.distance;
      case LoadSort.mostViewed:
        return l10n.mostViewed;
      case LoadSort.pickupDate:
        return l10n.pickupDate;
    }
  }

  // Refresh data
  Future<void> refreshLoads() async {
    try {
      isRefreshing.value = true;
      await _loadLoads();
      _showSuccessSnackbar('Loads refreshed');
    } catch (e) {
      _showErrorSnackbar('Failed to refresh loads');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Navigation
  void navigateToPostLoad() {
    Get.toNamed(Routes.POST_LOAD);
  }

  void navigateToLoadDetails(LoadModel load) {
    Get.toNamed(Routes.LOAD_DETAILS, parameters: {'id': load.id});
  }

  void navigateToEditLoad(LoadModel load) {
    Get.toNamed(Routes.POST_LOAD, arguments: {
      'mode': 'edit',
      'load': load,
    });
  }

  void navigateToBidsView(LoadModel load) {
    // Get.toNamed(Routes.LOAD_BIDS, parameters: {'loadId': load.id});
  }

  // Load actions
  void showLoadActions(LoadModel load) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final theme = Theme.of(Get.context!);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.inventory,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
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
              ],
            ),
            const SizedBox(height: 20),

            // Actions
            _buildActionTile(
              icon: Icons.visibility,
              title: l10n.viewDetails,
              onTap: () {
                Get.back();
                navigateToLoadDetails(load);
              },
              theme: theme,
            ),

            if (load.bidsCount > 0)
              _buildActionTile(
                icon: Icons.how_to_vote,
                title: '${l10n.viewBids} (${load.bidsCount})',
                onTap: () {
                  Get.back();
                  navigateToBidsView(load);
                },
                theme: theme,
              ),

            if (_canEditLoad(load))
              _buildActionTile(
                icon: Icons.edit,
                title: l10n.editLoad,
                onTap: () {
                  Get.back();
                  navigateToEditLoad(load);
                },
                theme: theme,
              ),

            _buildActionTile(
              icon: Icons.copy,
              title: l10n.duplicateLoad,
              onTap: () {
                Get.back();
                _duplicateLoad(load);
              },
              theme: theme,
            ),

            _buildActionTile(
              icon: Icons.share,
              title: l10n.shareLoad,
              onTap: () {
                Get.back();
                _shareLoad(load);
              },
              theme: theme,
            ),

            if (load.status == LoadStatus.posted || load.status == LoadStatus.bidding)
              _buildActionTile(
                icon: Icons.pause,
                title: l10n.pauseLoad,
                onTap: () {
                  Get.back();
                  _pauseLoad(load);
                },
                theme: theme,
              ),

            if (load.status == LoadStatus.draft)
              _buildActionTile(
                icon: Icons.publish,
                title: l10n.publishLoad,
                onTap: () {
                  Get.back();
                  _publishLoad(load);
                },
                theme: theme,
              ),

            if (_canDeleteLoad(load)) ...[
              const Divider(),
              _buildActionTile(
                icon: Icons.delete,
                title: l10n.deleteLoad,
                onTap: () {
                  Get.back();
                  _confirmDeleteLoad(load);
                },
                theme: theme,
                isDestructive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? theme.extension<AppColors>()?.error ?? Colors.red
        : theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  bool _canEditLoad(LoadModel load) {
    return load.status == LoadStatus.draft ||
        load.status == LoadStatus.posted ||
        load.status == LoadStatus.bidding;
  }

  bool _canDeleteLoad(LoadModel load) {
    return load.status == LoadStatus.draft ||
        load.status == LoadStatus.posted ||
        load.status == LoadStatus.cancelled;
  }

  Future<void> _duplicateLoad(LoadModel load) async {
    try {
      _showInfoSnackbar('Creating duplicate load...');

      final duplicatedLoad = load.copyWith(
        id: '', // Will be generated
        status: LoadStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        bidsCount: 0,
        viewCount: 0,
      );

      final newLoadId = await FirestoreService.createLoad(duplicatedLoad);

      if (newLoadId != null) {
        _showSuccessSnackbar('Load duplicated successfully');
        navigateToLoadDetails(duplicatedLoad.copyWith(id: newLoadId));
      } else {
        _showErrorSnackbar('Failed to duplicate load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to duplicate load');
    }
  }

  Future<void> _shareLoad(LoadModel load) async {
    try {
      final shareText = '''
🚚 Load Available for Transport

📦 ${load.title}
🏷️ ${load.loadType.displayName}
⚖️ ${load.weight}kg
📍 ${load.pickupLocation} → ${load.deliveryLocation}
💰 ₹${load.budget.toStringAsFixed(0)}

Contact: ${load.contactPerson ?? 'N/A'}
Phone: ${load.contactPhone ?? 'N/A'}

Load ID: ${load.id}
''';

      await Share.share(shareText, subject: 'Load Available - ${load.title}');
    } catch (e) {
      _showErrorSnackbar('Failed to share load');
    }
  }

  Future<void> _pauseLoad(LoadModel load) async {
    try {
      _showInfoSnackbar('Pausing load...');

      final success = await FirestoreService.updateLoadStatus(
        load.id,
        LoadStatus.draft,
      );

      if (success) {
        _showSuccessSnackbar('Load paused successfully');
      } else {
        _showErrorSnackbar('Failed to pause load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pause load');
    }
  }

  Future<void> _publishLoad(LoadModel load) async {
    try {
      _showInfoSnackbar('Publishing load...');

      final success = await FirestoreService.updateLoadStatus(
        load.id,
        LoadStatus.posted,
      );

      if (success) {
        _showSuccessSnackbar('Load published successfully');
      } else {
        _showErrorSnackbar('Failed to publish load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to publish load');
    }
  }

  void _confirmDeleteLoad(LoadModel load) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final theme = Theme.of(Get.context!);
    final appColors = theme.extension<AppColors>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: appColors?.error ?? Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.deleteLoad,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteLoadConfirmation(load.title),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.actionCannotBeUndone,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (load.bidsCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (appColors?.warning ?? Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: appColors?.warning ?? Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.deleteLoadWithBidsWarning(load.bidsCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: appColors?.warning ?? Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteLoad(load);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors?.error ?? Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLoad(LoadModel load) async {
    try {
      _showInfoSnackbar('Deleting load...');

      final success = await FirestoreService.deleteLoad(load.id);

      if (success) {
        _showSuccessSnackbar('Load deleted successfully');
      } else {
        _showErrorSnackbar('Failed to delete load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete load');
    }
  }

  // Bulk operations
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedLoadIds.clear();
    }
  }

  void toggleLoadSelection(String loadId) {
    if (selectedLoadIds.contains(loadId)) {
      selectedLoadIds.remove(loadId);
    } else {
      selectedLoadIds.add(loadId);
    }
  }

  void selectAllLoads() {
    selectedLoadIds.assignAll(filteredLoads.map((load) => load.id));
  }

  void clearSelection() {
    selectedLoadIds.clear();
  }

  void showBulkActionsDialog() {
    final l10n = AppLocalizations.of(Get.context!)!;
    final theme = Theme.of(Get.context!);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bulkActions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            if (selectedLoadIds.isNotEmpty) ...[
              _buildActionTile(
                icon: Icons.publish,
                title: '${l10n.publishSelected} (${selectedLoadIds.length})',
                onTap: () {
                  Get.back();
                  _publishSelectedLoads();
                },
                theme: theme,
              ),
              _buildActionTile(
                icon: Icons.pause,
                title: '${l10n.pauseSelected} (${selectedLoadIds.length})',
                onTap: () {
                  Get.back();
                  _pauseSelectedLoads();
                },
                theme: theme,
              ),
              _buildActionTile(
                icon: Icons.delete,
                title: '${l10n.deleteSelected} (${selectedLoadIds.length})',
                onTap: () {
                  Get.back();
                  _confirmDeleteSelectedLoads();
                },
                theme: theme,
                isDestructive: true,
              ),
            ] else ...[
              _buildActionTile(
                icon: Icons.publish,
                title: '${l10n.publishAllDrafts} (${_getDraftCount()})',
                onTap: () {
                  Get.back();
                  _publishAllDrafts();
                },
                theme: theme,
              ),
              _buildActionTile(
                icon: Icons.pause,
                title: '${l10n.pauseAllActive} (${activeLoadsCount.value})',
                onTap: () {
                  Get.back();
                  _pauseAllActive();
                },
                theme: theme,
              ),
            ],

            _buildActionTile(
              icon: Icons.download,
              title: '${l10n.exportAll} (${totalLoads.value})',
              onTap: () {
                Get.back();
                exportLoads();
              },
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  int _getDraftCount() {
    return draftLoads.length;
  }

  Future<void> _publishSelectedLoads() async {
    final selectedLoads = allLoads.where((load) => selectedLoadIds.contains(load.id)).toList();
    final draftLoads = selectedLoads.where((load) => load.status == LoadStatus.draft).toList();

    if (draftLoads.isEmpty) {
      _showInfoSnackbar('No draft loads selected to publish');
      return;
    }

    try {
      _showInfoSnackbar('Publishing ${draftLoads.length} loads...');

      for (final load in draftLoads) {
        await FirestoreService.updateLoadStatus(load.id, LoadStatus.posted);
      }

      _showSuccessSnackbar('${draftLoads.length} loads published successfully');
      clearSelection();
      isSelectionMode.value = false;
    } catch (e) {
      _showErrorSnackbar('Failed to publish some loads');
    }
  }

  Future<void> _pauseSelectedLoads() async {
    final selectedLoads = allLoads.where((load) => selectedLoadIds.contains(load.id)).toList();
    final activeLoadsList = selectedLoads.where((load) => activeLoads.contains(load)).toList();

    if (activeLoadsList.isEmpty) {
      _showInfoSnackbar('No active loads selected to pause');
      return;
    }

    try {
      _showInfoSnackbar('Pausing ${activeLoadsList.length} loads...');

      for (final load in activeLoadsList) {
        await FirestoreService.updateLoadStatus(load.id, LoadStatus.draft);
      }

      _showSuccessSnackbar('${activeLoadsList.length} loads paused successfully');
      clearSelection();
      isSelectionMode.value = false;
    } catch (e) {
      _showErrorSnackbar('Failed to pause some loads');
    }
  }

  void _confirmDeleteSelectedLoads() {
    final l10n = AppLocalizations.of(Get.context!)!;
    final theme = Theme.of(Get.context!);
    final appColors = theme.extension<AppColors>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.deleteSelectedLoads,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          l10n.deleteSelectedLoadsConfirmation(selectedLoadIds.length),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteSelectedLoads();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors?.error ?? Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedLoads() async {
    final selectedLoads = allLoads.where((load) => selectedLoadIds.contains(load.id)).toList();
    final deletableLoads = selectedLoads.where(_canDeleteLoad).toList();

    if (deletableLoads.isEmpty) {
      _showInfoSnackbar('No loads can be deleted from selection');
      return;
    }

    try {
      _showInfoSnackbar('Deleting ${deletableLoads.length} loads...');

      for (final load in deletableLoads) {
        await FirestoreService.deleteLoad(load.id);
      }

      _showSuccessSnackbar('${deletableLoads.length} loads deleted successfully');
      clearSelection();
      isSelectionMode.value = false;
    } catch (e) {
      _showErrorSnackbar('Failed to delete some loads');
    }
  }

  Future<void> _publishAllDrafts() async {
    if (draftLoads.isEmpty) {
      _showInfoSnackbar('No draft loads to publish');
      return;
    }

    try {
      _showInfoSnackbar('Publishing ${draftLoads.length} draft loads...');

      for (final load in draftLoads) {
        await FirestoreService.updateLoadStatus(load.id, LoadStatus.posted);
      }

      _showSuccessSnackbar('${draftLoads.length} loads published successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to publish some loads');
    }
  }

  Future<void> _pauseAllActive() async {
    if (activeLoads.isEmpty) {
      _showInfoSnackbar('No active loads to pause');
      return;
    }

    try {
      _showInfoSnackbar('Pausing ${activeLoads.length} active loads...');

      for (final load in activeLoads) {
        await FirestoreService.updateLoadStatus(load.id, LoadStatus.draft);
      }

      _showSuccessSnackbar('${activeLoads.length} loads paused successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to pause some loads');
    }
  }

  // Export functionality
  void exportLoads() async {
    try {
      _showInfoSnackbar('Preparing export...');

      // In production, generate CSV or Excel file
      await Future.delayed(const Duration(seconds: 2));

      _showSuccessSnackbar('Export feature coming soon');
    } catch (e) {
      _showErrorSnackbar('Failed to export loads');
    }
  }

  // Helper methods
  void _showErrorSnackbar(String message) {
    final theme = Theme.of(Get.context!);
    final appColors = theme.extension<AppColors>();

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: (appColors?.error ?? Colors.red).withOpacity(0.1),
      colorText: appColors?.error ?? Colors.red,
      icon: Icon(Icons.error, color: appColors?.error ?? Colors.red),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showSuccessSnackbar(String message) {
    final theme = Theme.of(Get.context!);
    final appColors = theme.extension<AppColors>();

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: (appColors?.success ?? Colors.green).withOpacity(0.1),
      colorText: appColors?.success ?? Colors.green,
      icon: Icon(Icons.check_circle, color: appColors?.success ?? Colors.green),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showInfoSnackbar(String message) {
    final theme = Theme.of(Get.context!);
    final appColors = theme.extension<AppColors>();

    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: (appColors?.info ?? Colors.blue).withOpacity(0.1),
      colorText: appColors?.info ?? Colors.blue,
      icon: Icon(Icons.info, color: appColors?.info ?? Colors.blue),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}

// Enhanced enums for filtering and sorting
enum LoadFilter {
  all,
  active,
  completed,
  draft,
  cancelled,
  expired,
  urgent,
  highBudget,
  recentlyPosted,
}

enum LoadSort {
  newest,
  oldest,
  budgetHigh,
  budgetLow,
  mostBids,
  leastBids,
  alphabetical,
  distance,
  mostViewed,
  pickupDate,
}