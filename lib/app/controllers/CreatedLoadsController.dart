import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:async';

import '../data/models/LoadModel.dart';
import '../routes/app_pages.dart';
import '../services/firestore_service.dart';

class CreatedLoadsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab controller
  late TabController tabController;

  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isFilterApplied = false.obs;
  var searchQuery = ''.obs;

  // Load lists
  var allLoads = <LoadModel>[].obs;
  var filteredLoads = <LoadModel>[].obs;

  // Filter variables
  var selectedStatus = Rxn<LoadStatus>();
  var selectedLoadType = Rxn<LoadType>();
  var selectedVehicleType = Rxn<VehicleType>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var minBudget = Rxn<double>();
  var maxBudget = Rxn<double>();

  // Streams
  StreamSubscription? _loadsSubscription;

  // Computed properties
  int get totalLoads => allLoads.length;
  int get activeLoadsCount => allLoads.where((load) =>
      [LoadStatus.posted, LoadStatus.bidding, LoadStatus.assigned, LoadStatus.inProgress]
          .contains(load.status)).length;
  int get completedLoadsCount => allLoads.where((load) =>
  load.status == LoadStatus.completed).length;

  List<LoadModel> get activeLoads => allLoads.where((load) =>
      [LoadStatus.posted, LoadStatus.bidding, LoadStatus.assigned, LoadStatus.inProgress]
          .contains(load.status)).toList();

  List<LoadModel> get completedLoads => allLoads.where((load) =>
  load.status == LoadStatus.completed).toList();

  double get successRate {
    if (totalLoads == 0) return 0.0;
    return (completedLoadsCount / totalLoads) * 100;
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _initializeData();
    _setupRealTimeListener();
  }

  @override
  void onClose() {
    tabController.dispose();
    _loadsSubscription?.cancel();
    super.onClose();
  }

  void _initializeData() async {
    try {
      isLoading.value = true;
      await _loadUserLoads();
    } catch (e) {
      print('Error initializing loads data: $e');
      _showErrorSnackbar('Failed to load your loads');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealTimeListener() {
    _loadsSubscription = FirestoreService.getUserLoadsStream().listen(
          (loads) {
        allLoads.value = loads;
        _applyFilters();
      },
      onError: (error) {
        print('Error in loads stream: $error');
        _showErrorSnackbar('Failed to sync loads data');
      },
    );
  }

  Future<void> _loadUserLoads() async {
    try {
      final loads = await FirestoreService.getUserLoads(limit: 100);
      allLoads.value = loads;
      _applyFilters();
    } catch (e) {
      print('Error loading user loads: $e');
      throw e;
    }
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  // Filter functionality
  void _applyFilters() {
    var filtered = allLoads.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((load) =>
      load.title.toLowerCase().contains(query) ||
          load.pickupLocation.toLowerCase().contains(query) ||
          load.deliveryLocation.toLowerCase().contains(query) ||
          load.description!.toLowerCase().contains(query)).toList();
    }

    // Apply status filter
    if (selectedStatus.value != null) {
      filtered = filtered.where((load) => load.status == selectedStatus.value).toList();
    }

    // Apply load type filter
    if (selectedLoadType.value != null) {
      filtered = filtered.where((load) => load.loadType == selectedLoadType.value).toList();
    }

    // Apply vehicle type filter
    if (selectedVehicleType.value != null) {
      filtered = filtered.where((load) => load.vehicleType == selectedVehicleType.value).toList();
    }

    // Apply date range filter
    if (startDate.value != null) {
      filtered = filtered.where((load) => load.createdAt.isAfter(startDate.value!)).toList();
    }
    if (endDate.value != null) {
      filtered = filtered.where((load) => load.createdAt.isBefore(endDate.value!)).toList();
    }

    // Apply budget range filter
    if (minBudget.value != null) {
      filtered = filtered.where((load) => load.budget >= minBudget.value!).toList();
    }
    if (maxBudget.value != null) {
      filtered = filtered.where((load) => load.budget <= maxBudget.value!).toList();
    }

    filteredLoads.value = filtered;
    _updateFilterStatus();
  }

  void _updateFilterStatus() {
    isFilterApplied.value = searchQuery.value.isNotEmpty ||
        selectedStatus.value != null ||
        selectedLoadType.value != null ||
        selectedVehicleType.value != null ||
        startDate.value != null ||
        endDate.value != null ||
        minBudget.value != null ||
        maxBudget.value != null;
  }

  void showFilterDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Loads',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: clearAllFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status filter
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: LoadStatus.values.map((status) =>
                  Obx(() => FilterChip(
                    label: Text(status.displayName),
                    selected: selectedStatus.value == status,
                    onSelected: (selected) {
                      selectedStatus.value = selected ? status : null;
                      _applyFilters();
                    },
                  )),
              ).toList(),
            ),

            const SizedBox(height: 16),

            // Load type filter
            const Text('Load Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: LoadType.values.map((type) =>
                  Obx(() => FilterChip(
                    label: Text(type.displayName),
                    selected: selectedLoadType.value == type,
                    onSelected: (selected) {
                      selectedLoadType.value = selected ? type : null;
                      _applyFilters();
                    },
                  )),
              ).toList(),
            ),

            const SizedBox(height: 16),

            // Date range filter
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectStartDate(),
                    child: Text(startDate.value != null
                        ? 'From: ${startDate.value!.day}/${startDate.value!.month}'
                        : 'Start Date'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectEndDate(),
                    child: Text(endDate.value != null
                        ? 'To: ${endDate.value!.day}/${endDate.value!.month}'
                        : 'End Date'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStartDate() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: startDate.value ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
      ),
    );
    if (date != null) {
      startDate.value = date;
      _applyFilters();
    }
  }

  void _selectEndDate() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: endDate.value ?? DateTime.now(),
        firstDate: startDate.value ?? DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now(),
      ),
    );
    if (date != null) {
      endDate.value = date;
      _applyFilters();
    }
  }

  void clearAllFilters() {
    selectedStatus.value = null;
    selectedLoadType.value = null;
    selectedVehicleType.value = null;
    startDate.value = null;
    endDate.value = null;
    minBudget.value = null;
    maxBudget.value = null;
    _applyFilters();
    Get.back();
  }

  // Navigation methods
  void navigateToPostLoad() {
    Get.toNamed(Routes.POST_LOAD);
  }

  void navigateToLoadDetails(LoadModel load) {
    Get.toNamed(Routes.LOAD_DETAILS, arguments: load);
  }

  void editLoad(LoadModel load) {
    Get.toNamed(Routes.EDIT_LOAD, arguments: load);
  }

  // Load actions
  void showLoadActions(LoadModel load) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Load Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Get.back();
                navigateToLoadDetails(load);
              },
            ),

            if ([LoadStatus.draft, LoadStatus.posted].contains(load.status))
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Load'),
                onTap: () {
                  Get.back();
                  editLoad(load);
                },
              ),

            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Load'),
              onTap: () {
                Get.back();
                duplicateLoad(load);
              },
            ),

            if (load.bidsCount > 0)
              ListTile(
                leading: const Icon(Icons.how_to_vote),
                title: Text('View Bids (${load.bidsCount})'),
                onTap: () {
                  Get.back();
                  viewLoadBids(load);
                },
              ),

            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Load'),
              onTap: () {
                Get.back();
                shareLoad(load);
              },
            ),

            if ([LoadStatus.draft, LoadStatus.posted, LoadStatus.bidding].contains(load.status))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Load', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  deleteLoad(load);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteLoad(LoadModel load) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Load'),
        content: Text('Are you sure you want to delete "${load.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        isLoading.value = true;
        final success = await FirestoreService.deleteLoad(load.id);

        if (success) {
          _showSuccessSnackbar('Load deleted successfully');
        } else {
          _showErrorSnackbar('Failed to delete load');
        }
      } catch (e) {
        print('Error deleting load: $e');
        _showErrorSnackbar('Failed to delete load');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void duplicateLoad(LoadModel load) {
    // Create a copy of the load and navigate to post load with prefilled data
    Get.toNamed(Routes.POST_LOAD, arguments: {
      'template': load,
      'isDuplicate': true,
    });
    _showSuccessSnackbar('Load template loaded');
  }

  void viewLoadBids(LoadModel load) {
    Get.toNamed(Routes.BID_DETAILS, arguments: load);
  }

  void shareLoad(LoadModel load) {
    Get.snackbar(
      'Share Load',
      'Load details copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Refresh functionality
  Future<void> refreshLoads() async {
    try {
      isRefreshing.value = true;
      await _loadUserLoads();
      _showSuccessSnackbar('Loads refreshed');
    } catch (e) {
      print('Error refreshing loads: $e');
      _showErrorSnackbar('Failed to refresh loads');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Export functionality
  void exportLoads() {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Loads'),
        content: const Text('Choose export format for your loads data.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _exportToCSV();
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _exportToPDF();
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    // Implement CSV export
    _showSuccessSnackbar('Exporting to CSV...');
  }

  void _exportToPDF() {
    // Implement PDF export
    _showSuccessSnackbar('Exporting to PDF...');
  }

  // Helper methods
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[700],
      icon: const Icon(Icons.error, color: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
      icon: const Icon(Icons.check_circle, color: Colors.green),
    );
  }
}