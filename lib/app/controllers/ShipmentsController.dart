import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../generated/l10n/app_localizations.dart';
import 'auth_controller.dart';
import '../data/models/LoadModel.dart';
import '../services/firestore_service.dart';
import '../routes/app_pages.dart';

class ShipmentsController extends GetxController with GetTickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();

  // Tab Controller
  late TabController tabController;

  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var allShipments = <ShipmentModel>[].obs;
  var activeShipments = <ShipmentModel>[].obs;
  var completedShipments = <ShipmentModel>[].obs;
  var currentTab = 0.obs;

  // Search and filter
  var searchQuery = ''.obs;
  var selectedStatus = Rxn<ShipmentStatus>();
  var selectedDateRange = Rxn<DateTimeRange>();
  var isFilterApplied = false.obs;

  // Streams
  StreamSubscription? _shipmentsSubscription;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentTab.value = tabController.index;
    });
    _initializeData();
    _setupRealTimeListener();
  }

  @override
  void onClose() {
    tabController.dispose();
    _shipmentsSubscription?.cancel();
    super.onClose();
  }

  void _initializeData() async {
    try {
      isLoading.value = true;
      await _loadShipments();
    } catch (e) {
      print('Error initializing shipments data: $e');
      _showErrorSnackbar('Failed to load shipments');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealTimeListener() {
    // Listen to user's shipments in real-time
    _shipmentsSubscription = FirestoreService.getUserShipmentsStream().listen(
          (shipments) {
        allShipments.value = shipments;
        _categorizeShipments();
      },
      onError: (error) {
        print('Error in shipments stream: $error');
        _showErrorSnackbar('Connection error. Please check your internet.');
      },
    );
  }

  Future<void> _loadShipments() async {
    try {
      final shipments = await FirestoreService.getUserShipments(limit: 50);
      allShipments.value = shipments;
      _categorizeShipments();
    } catch (e) {
      print('Error loading shipments: $e');
    }
  }

  void _categorizeShipments() {
    final active = <ShipmentModel>[];
    final completed = <ShipmentModel>[];

    for (final shipment in allShipments) {
      if (_isActiveStatus(shipment.status)) {
        active.add(shipment);
      } else if (_isCompletedStatus(shipment.status)) {
        completed.add(shipment);
      }
    }

    activeShipments.value = active;
    completedShipments.value = completed;
  }

  bool _isActiveStatus(ShipmentStatus status) {
    return [
      ShipmentStatus.pending,
      ShipmentStatus.accepted,
      ShipmentStatus.pickup,
      ShipmentStatus.loaded,
      ShipmentStatus.inTransit,
    ].contains(status);
  }

  bool _isCompletedStatus(ShipmentStatus status) {
    return [
      ShipmentStatus.delivered,
      ShipmentStatus.completed,
      ShipmentStatus.cancelled,
    ].contains(status);
  }

  // Get filtered shipments based on current tab and filters
  List<ShipmentModel> get filteredShipments {
    List<ShipmentModel> baseList;

    switch (currentTab.value) {
      case 0:
        baseList = allShipments;
        break;
      case 1:
        baseList = activeShipments;
        break;
      case 2:
        baseList = completedShipments;
        break;
      default:
        baseList = allShipments;
    }

    var filtered = baseList.where((shipment) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!shipment.id.toLowerCase().contains(query) &&
            !shipment.pickupLocation.toLowerCase().contains(query) &&
            !shipment.deliveryLocation.toLowerCase().contains(query) &&
            !shipment.driverName.toLowerCase().contains(query) &&
            !shipment.vehicleNumber.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Status filter
      if (selectedStatus.value != null && shipment.status != selectedStatus.value) {
        return false;
      }

      // Date range filter
      if (selectedDateRange.value != null) {
        final range = selectedDateRange.value!;
        if (shipment.createdAt.isBefore(range.start) ||
            shipment.createdAt.isAfter(range.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _updateFilterStatus();
  }

  void clearSearch() {
    searchQuery.value = '';
    _updateFilterStatus();
  }

  // Filter functionality
  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Shipments'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status filter
              const Text('Status'),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                children: ShipmentStatus.values.map((status) {
                  final isSelected = selectedStatus.value == status;
                  return FilterChip(
                    label: Text(status.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      selectedStatus.value = selected ? status : null;
                    },
                  );
                }).toList(),
              )),

              const SizedBox(height: 16),

              // Date range filter
              const Text('Date Range'),
              const SizedBox(height: 8),
              Obx(() => InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        selectedDateRange.value != null
                            ? '${_formatDate(selectedDateRange.value!.start)} - ${_formatDate(selectedDateRange.value!.end)}'
                            : 'Select date range',
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _updateFilterStatus();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange.value,
    );

    if (range != null) {
      selectedDateRange.value = range;
    }
  }

  void _clearFilters() {
    selectedStatus.value = null;
    selectedDateRange.value = null;
    searchQuery.value = '';
    _updateFilterStatus();
  }

  void _updateFilterStatus() {
    isFilterApplied.value = searchQuery.value.isNotEmpty ||
        selectedStatus.value != null ||
        selectedDateRange.value != null;
  }

  // Navigation methods
  void navigateToShipmentDetails(ShipmentModel shipment) {
    // Get.toNamed(Routes.TRACK_SHIPMENT, parameters: {'id': shipment.id});
  }

  void navigateToLoadDetails(String loadId) {
    // Get.toNamed(Routes.LOAD_DETAILS, parameters: {'id': loadId});
  }

  // Shipment actions
  void showShipmentActions(ShipmentModel shipment) {
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
            Text(
              'Shipment Actions',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Track Shipment'),
              onTap: () {
                Get.back();
                navigateToShipmentDetails(shipment);
              },
            ),

            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Driver'),
              onTap: () {
                Get.back();
                _callDriver(shipment.driverPhone);
              },
            ),

            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Message Driver'),
              onTap: () {
                Get.back();
                _messageDriver(shipment);
              },
            ),

            if (_canCancelShipment(shipment))
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Shipment'),
                textColor: Colors.red,
                onTap: () {
                  Get.back();
                  _showCancelDialog(shipment);
                },
              ),

            if (_canRateShipment(shipment))
              ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: const Text('Rate & Review'),
                onTap: () {
                  Get.back();
                  _showRatingDialog(shipment);
                },
              ),
          ],
        ),
      ),
    );
  }

  bool _canCancelShipment(ShipmentModel shipment) {
    return [
      ShipmentStatus.pending,
      ShipmentStatus.accepted,
      ShipmentStatus.pickup,
    ].contains(shipment.status);
  }

  bool _canRateShipment(ShipmentModel shipment) {
    return shipment.status == ShipmentStatus.delivered &&
        shipment.customerRating == null;
  }

  void _callDriver(String phoneNumber) {
    // Implement phone call functionality
    Get.snackbar(
      'Calling',
      'Calling driver at $phoneNumber',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _messageDriver(ShipmentModel shipment) {
    // Get.toNamed(Routes.CHAT, arguments: {
    //   'shipmentId': shipment.id,
    //   'driverName': shipment.driverName,
    //   'driverPhone': shipment.driverPhone,
    // });
  }

  void _showCancelDialog(ShipmentModel shipment) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Shipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this shipment?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Shipment'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _cancelShipment(shipment, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Shipment'),
          ),
        ],
      ),
    );
  }

  void _cancelShipment(ShipmentModel shipment, String reason) async {
    try {
      isLoading.value = true;

      final success = await FirestoreService.updateShipmentStatus(
        shipment.id,
        ShipmentStatus.cancelled,
      );

      if (success) {
        _showSuccessSnackbar('Shipment cancelled successfully');
      } else {
        _showErrorSnackbar('Failed to cancel shipment');
      }

    } catch (e) {
      print('Error cancelling shipment: $e');
      _showErrorSnackbar('Error occurred while cancelling shipment');
    } finally {
      isLoading.value = false;
    }
  }

  void _showRatingDialog(ShipmentModel shipment) {
    var rating = 5.0.obs;
    final feedbackController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Rate Your Experience'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How was your experience with ${shipment.driverName}?'),
            const SizedBox(height: 16),

            // Star rating
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => rating.value = index + 1.0,
                  icon: Icon(
                    index < rating.value ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32,
                  ),
                );
              }),
            )),

            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _submitRating(shipment, rating.value, feedbackController.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitRating(ShipmentModel shipment, double rating, String feedback) async {
    try {
      // Update shipment with rating and feedback
      // This would be implemented in FirestoreService
      _showSuccessSnackbar('Thank you for your feedback!');
    } catch (e) {
      _showErrorSnackbar('Failed to submit rating');
    }
  }

  // Refresh functionality
  Future<void> refreshShipments() async {
    try {
      isRefreshing.value = true;
      await _loadShipments();
      _showSuccessSnackbar('Shipments refreshed');
    } catch (e) {
      _showErrorSnackbar('Failed to refresh shipments');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Emergency actions
  void emergencyCall() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Emergency Support'),
          ],
        ),
        content: const Text(
          'This will immediately connect you to our emergency support team. Use only for urgent safety issues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement emergency call
              _showSuccessSnackbar('Connecting to emergency support...');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  // Utility methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

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

  // Statistics
  int get totalShipments => allShipments.length;
  int get activeShipmentsCount => activeShipments.length;
  int get completedShipmentsCount => completedShipments.length;
  double get completionRate => totalShipments > 0
      ? (completedShipmentsCount / totalShipments) * 100
      : 0.0;
}