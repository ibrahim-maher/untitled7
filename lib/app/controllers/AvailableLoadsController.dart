import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/LoadModel.dart';
import '../routes/app_pages.dart';
import '../services/firestore_service.dart';

class AvailableLoadsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isFilterApplied = false.obs;
  var searchQuery = ''.obs;

  // Load lists
  var allLoads = <LoadModel>[].obs;
  var filteredLoads = <LoadModel>[].obs;

  // Quick filters
  var showUrgentOnly = false.obs;
  var showHighBudgetOnly = false.obs;
  var showNearMeOnly = false.obs;
  var showFreshOnly = false.obs;

  // Filter variables
  var selectedLoadTypes = <LoadType>[].obs;
  var selectedVehicleTypes = <VehicleType>[].obs;
  var selectedMinBudget = 0.0.obs;
  var selectedMaxBudget = 100000.0.obs;
  var selectedMinWeight = 0.0.obs;
  var selectedMaxWeight = 50000.0.obs;
  var selectedMaxDistance = 1000.0.obs;
  var selectedLocations = <String>[].obs;

  // Sort options
  var sortBy = LoadSortOption.newest.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAvailableLoads();
  }

  // Computed properties
  int get totalLoads => allLoads.length;
  int get urgentLoadsCount => allLoads.where((load) => load.isUrgent).length;

  double get averageBudget {
    if (allLoads.isEmpty) return 0.0;
    return allLoads.fold(0.0, (sum, load) => sum + load.budget) / allLoads.length;
  }

  // Load available loads from Firestore
  void _loadAvailableLoads() async {
    try {
      isLoading.value = true;
      final loads = await FirestoreService.getAvailableLoads(limit: 100);
      allLoads.assignAll(loads);
      _applyFilters();
    } catch (e) {
      _showErrorSnackbar('Failed to load available loads: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh loads
  Future<void> refreshLoads() async {
    _loadAvailableLoads();
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

  // Quick filter toggles
  void toggleUrgentFilter() {
    showUrgentOnly.value = !showUrgentOnly.value;
    _applyFilters();
  }

  void toggleHighBudgetFilter() {
    showHighBudgetOnly.value = !showHighBudgetOnly.value;
    _applyFilters();
  }

  void toggleNearMeFilter() {
    showNearMeOnly.value = !showNearMeOnly.value;
    _applyFilters();
  }

  void toggleFreshFilter() {
    showFreshOnly.value = !showFreshOnly.value;
    _applyFilters();
  }

  // Filter functionality
  void _applyFilters() {
    var filtered = allLoads.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((load) {
        final query = searchQuery.value.toLowerCase();
        return load.title.toLowerCase().contains(query) ||
            load.pickupLocation.toLowerCase().contains(query) ||
            load.deliveryLocation.toLowerCase().contains(query) ||
            load.loadType.displayName.toLowerCase().contains(query) ||
            load.description?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply quick filters
    if (showUrgentOnly.value) {
      filtered = filtered.where((load) => load.isUrgent).toList();
    }

    if (showHighBudgetOnly.value) {
      final averageBudget = this.averageBudget;
      filtered = filtered.where((load) => load.budget > averageBudget * 1.5).toList();
    }

    if (showFreshOnly.value) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      filtered = filtered.where((load) => load.createdAt.isAfter(yesterday)).toList();
    }

    if (showNearMeOnly.value) {
      // For now, implement basic location filtering
      // In production, you'd use actual location services
      filtered = filtered.where((load) =>
      load.pickupLocation.toLowerCase().contains('mumbai') ||
          load.pickupLocation.toLowerCase().contains('delhi') ||
          load.pickupLocation.toLowerCase().contains('bangalore')).toList();
    }

    // Apply advanced filters if applied
    if (isFilterApplied.value) {
      if (selectedLoadTypes.isNotEmpty) {
        filtered = filtered.where((load) => selectedLoadTypes.contains(load.loadType)).toList();
      }

      if (selectedVehicleTypes.isNotEmpty) {
        filtered = filtered.where((load) => selectedVehicleTypes.contains(load.vehicleType)).toList();
      }

      filtered = filtered.where((load) =>
      load.budget >= selectedMinBudget.value &&
          load.budget <= selectedMaxBudget.value).toList();

      filtered = filtered.where((load) =>
      load.weight >= selectedMinWeight.value &&
          load.weight <= selectedMaxWeight.value).toList();

      if (selectedLocations.isNotEmpty) {
        filtered = filtered.where((load) =>
            selectedLocations.any((location) =>
            load.pickupLocation.toLowerCase().contains(location.toLowerCase()) ||
                load.deliveryLocation.toLowerCase().contains(location.toLowerCase()))).toList();
      }
    }

    // Apply sorting
    _applySorting(filtered);

    filteredLoads.assignAll(filtered);
  }

  void _applySorting(List<LoadModel> loads) {
    switch (sortBy.value) {
      case LoadSortOption.newest:
        loads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case LoadSortOption.oldest:
        loads.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case LoadSortOption.budgetHighToLow:
        loads.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case LoadSortOption.budgetLowToHigh:
        loads.sort((a, b) => a.budget.compareTo(b.budget));
        break;
      case LoadSortOption.weightHighToLow:
        loads.sort((a, b) => b.weight.compareTo(a.weight));
        break;
      case LoadSortOption.weightLowToHigh:
        loads.sort((a, b) => a.weight.compareTo(b.weight));
        break;
      case LoadSortOption.pickupDate:
        loads.sort((a, b) => a.pickupDate.compareTo(b.pickupDate));
        break;
      case LoadSortOption.urgent:
        loads.sort((a, b) => b.isUrgent ? 1 : a.isUrgent ? -1 : 0);
        break;
    }
  }

  // Filter dialog
  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Advanced Filters'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load Types
                Text('Load Types', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: LoadType.values.map((type) {
                    return Obx(() => FilterChip(
                      label: Text(type.displayName),
                      selected: selectedLoadTypes.contains(type),
                      onSelected: (selected) {
                        if (selected) {
                          selectedLoadTypes.add(type);
                        } else {
                          selectedLoadTypes.remove(type);
                        }
                      },
                    ));
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Vehicle Types
                Text('Vehicle Types', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: VehicleType.values.map((type) {
                    return Obx(() => FilterChip(
                      label: Text(type.displayName),
                      selected: selectedVehicleTypes.contains(type),
                      onSelected: (selected) {
                        if (selected) {
                          selectedVehicleTypes.add(type);
                        } else {
                          selectedVehicleTypes.remove(type);
                        }
                      },
                    ));
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Budget Range
                Text('Budget Range (₹)', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min Budget',
                          prefixText: '₹',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: selectedMinBudget.value.toString(),
                        onChanged: (value) {
                          selectedMinBudget.value = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Budget',
                          prefixText: '₹',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: selectedMaxBudget.value.toString(),
                        onChanged: (value) {
                          selectedMaxBudget.value = double.tryParse(value) ?? 100000.0;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Weight Range
                Text('Weight Range (kg)', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min Weight',
                          suffixText: 'kg',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: selectedMinWeight.value.toString(),
                        onChanged: (value) {
                          selectedMinWeight.value = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Weight',
                          suffixText: 'kg',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: selectedMaxWeight.value.toString(),
                        onChanged: (value) {
                          selectedMaxWeight.value = double.tryParse(value) ?? 50000.0;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearAdvancedFilters();
              Get.back();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyAdvancedFilters();
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyAdvancedFilters() {
    isFilterApplied.value = true;
    _applyFilters();
  }

  void _clearAdvancedFilters() {
    isFilterApplied.value = false;
    selectedLoadTypes.clear();
    selectedVehicleTypes.clear();
    selectedMinBudget.value = 0.0;
    selectedMaxBudget.value = 100000.0;
    selectedMinWeight.value = 0.0;
    selectedMaxWeight.value = 50000.0;
    selectedLocations.clear();
    _applyFilters();
  }

  // Sort dialog
  void showSortDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LoadSortOption.values.map((option) {
            return Obx(() => RadioListTile<LoadSortOption>(
              title: Text(_getSortOptionName(option)),
              value: option,
              groupValue: sortBy.value,
              onChanged: (value) {
                if (value != null) {
                  sortBy.value = value;
                  _applyFilters();
                }
              },
            ));
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getSortOptionName(LoadSortOption option) {
    switch (option) {
      case LoadSortOption.newest:
        return 'Newest First';
      case LoadSortOption.oldest:
        return 'Oldest First';
      case LoadSortOption.budgetHighToLow:
        return 'Budget: High to Low';
      case LoadSortOption.budgetLowToHigh:
        return 'Budget: Low to High';
      case LoadSortOption.weightHighToLow:
        return 'Weight: High to Low';
      case LoadSortOption.weightLowToHigh:
        return 'Weight: Low to High';
      case LoadSortOption.pickupDate:
        return 'Pickup Date';
      case LoadSortOption.urgent:
        return 'Urgent First';
    }
  }

  // Clear all filters
  void clearAllFilters() {
    searchQuery.value = '';
    showUrgentOnly.value = false;
    showHighBudgetOnly.value = false;
    showNearMeOnly.value = false;
    showFreshOnly.value = false;
    _clearAdvancedFilters();
  }

  // Bid functionality
  void showBidDialog(LoadModel load) {
    final bidAmountController = TextEditingController();
    final notesController = TextEditingController();
    final vehicleTypeController = TextEditingController();
    final vehicleNumberController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Place Bid for Load #${load.id.substring(0, 8)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        load.title,
                        style: Get.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${load.pickupLocation} → ${load.deliveryLocation}'),
                      Text('Budget: ₹${load.budget.toStringAsFixed(0)}'),
                      Text('Weight: ${load.weight.toStringAsFixed(0)} kg'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bid amount
                TextFormField(
                  controller: bidAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Your Bid Amount *',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                    helperText: 'Enter your competitive bid amount',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // Vehicle type
                TextFormField(
                  controller: vehicleTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type *',
                    border: OutlineInputBorder(),
                    helperText: 'e.g., Truck 10-Wheeler, Container',
                  ),
                ),

                const SizedBox(height: 16),

                // Vehicle number
                TextFormField(
                  controller: vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number',
                    border: OutlineInputBorder(),
                    helperText: 'e.g., MH-01-AB-1234',
                  ),
                ),

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    border: OutlineInputBorder(),
                    helperText: 'Optional: Special offers, experience, etc.',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (bidAmountController.text.isNotEmpty && vehicleTypeController.text.isNotEmpty) {
                Get.back();
                _submitBid(
                  load,
                  double.tryParse(bidAmountController.text) ?? 0.0,
                  vehicleTypeController.text,
                  vehicleNumberController.text,
                  notesController.text,
                );
              } else {
                _showErrorSnackbar('Please fill in required fields');
              }
            },
            child: const Text('Place Bid'),
          ),
        ],
      ),
    );
  }

  void _submitBid(LoadModel load, double amount, String vehicleType, String vehicleNumber, String notes) async {
    try {
      _showInfoSnackbar('Submitting your bid...');

      final bidData = {
        'loadId': load.id,
        'amount': amount,
        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,
        'notes': notes,
      };

      final success = await FirestoreService.submitBid(bidData);

      if (success) {
        _showSuccessSnackbar('Bid submitted successfully!');
        refreshLoads(); // Refresh to update bid counts
      } else {
        _showErrorSnackbar('Failed to submit bid');
      }
    } catch (e) {
      _showErrorSnackbar('Error submitting bid: $e');
    }
  }

  // Navigation methods
  void navigateToLoadDetails(LoadModel load) {
    Get.toNamed(Routes.LOAD_DETAILS, arguments: {'loadId': load.id});
  }

  void navigateToMyBids() {
    Get.toNamed(Routes.MY_BIDS);
  }

  // Snackbar methods
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

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[700],
      icon: const Icon(Icons.info, color: Colors.blue),
    );
  }
}

// Enum for sort options
enum LoadSortOption {
  newest,
  oldest,
  budgetHighToLow,
  budgetLowToHigh,
  weightHighToLow,
  weightLowToHigh,
  pickupDate,
  urgent,
}