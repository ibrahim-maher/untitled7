import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../data/models/LoadModel.dart';
import '../routes/app_pages.dart';
import '../services/firestore_service.dart';
import 'dart:async';

import 'main_controller.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var currentTabIndex = 0.obs;
  var activeShipments = <ShipmentModel>[].obs;
  var recentLoads = <LoadModel>[].obs;
  var activeBids = <BidModel>[].obs;
  var quickStats = Rx<QuickStats?>(null);
  var notifications = <Map<String, dynamic>>[].obs;
  var unreadNotificationsCount = 0.obs;

  // Search and filter variables
  var searchQuery = ''.obs;
  var selectedLocation = ''.obs;

  // Location selection variables
  var pickupLocation = ''.obs;
  var deliveryLocation = ''.obs;
  var pickupCoordinates = Rxn<Map<String, double>>();
  var deliveryCoordinates = Rxn<Map<String, double>>();
  var isPickupLocationSelected = false.obs;
  var isDeliveryLocationSelected = false.obs;

  // Streams
  StreamSubscription? _activeShipmentsSubscription;
  StreamSubscription? _recentLoadsSubscription;
  StreamSubscription? _activeBidsSubscription;

  String get userName => _authController.currentUser.value?.name ?? 'User';
  String get userEmail => _authController.currentUser.value?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupRealTimeListeners();
  }

  @override
  void onClose() {
    _activeShipmentsSubscription?.cancel();
    _recentLoadsSubscription?.cancel();
    _activeBidsSubscription?.cancel();
    super.onClose();
  }

  void _initializeData() async {
    try {
      isLoading.value = true;

      // Load all data concurrently
      await Future.wait([
        _loadQuickStats(),
        _loadNotifications(),
      ]);

      // Load other data
      await _loadRecentLoads();
    } catch (e) {
      print('Error initializing home data: $e');
      _showErrorSnackbar('Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealTimeListeners() {
    // Listen to active shipments in real-time
    _activeShipmentsSubscription = FirestoreService.getActiveShipmentsStream().listen(
          (shipments) {
        activeShipments.value = shipments;
      },
      onError: (error) {
        print('Error in active shipments stream: $error');
      },
    );

    // Listen to user loads in real-time
    _recentLoadsSubscription = FirestoreService.getUserLoadsStream().listen(
          (loads) {
        recentLoads.value = loads.take(5).toList(); // Show only recent 5
      },
      onError: (error) {
        print('Error in loads stream: $error');
      },
    );

    // Listen to active bids in real-time
    _activeBidsSubscription = FirestoreService.getActiveBidsStream().listen(
          (bids) {
        activeBids.value = bids;
      },
      onError: (error) {
        print('Error in active bids stream: $error');
      },
    );
  }

  Future<void> _loadQuickStats() async {
    try {
      final stats = await FirestoreService.getUserStats();

      quickStats.value = QuickStats(
        totalShipments: stats['totalShipments'] ?? 0,
        activeShipments: stats['activeShipments'] ?? 0,
        completedShipments: stats['completedShipments'] ?? 0,
        totalSavings: stats['totalSavings'] ?? 0.0,
        monthlyShipments: stats['monthlyShipments'] ?? 0,
        averageRating: stats['averageRating'] ?? 0.0,
        totalLoads: stats['totalLoads'] ?? 0,
        activeBids: stats['activeBids'] ?? 0,
        pendingBids: stats['pendingBids'] ?? 0,
      );
    } catch (e) {
      print('Error loading quick stats: $e');
    }
  }

  Future<void> _loadRecentLoads() async {
    try {
      final loads = await FirestoreService.getUserLoads(limit: 5);
      recentLoads.value = loads;
    } catch (e) {
      print('Error loading recent loads: $e');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationsList = await FirestoreService.getUserNotifications(limit: 10);
      notifications.value = notificationsList;

      // Count unread notifications
      unreadNotificationsCount.value = notificationsList
          .where((notification) => !(notification['isRead'] ?? false))
          .length;
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // Navigation methods
  void onTabChanged(int index) {
    if (Get.isRegistered<MainController>()) {
      final mainController = Get.find<MainController>();
      mainController.onTabChanged(index);
    }
  }


  void navigateToPostLoad() {
    Get.toNamed(Routes.POST_LOAD);
  }

  void navigateToCreatedLoads() {
    Get.toNamed(Routes.CREATED_LOADS);
  }

  void navigateToSearchTrucks() {
    Get.toNamed(Routes.SEARCH_TRUCKS);
  }

  void navigateToShipments() {
    Get.toNamed(Routes.MAIN);
    if (Get.isRegistered<MainController>()) {
      final mainController = Get.find<MainController>();
      mainController.onTabChanged(1);
    }
  }
  void navigateToTrackShipment(String shipmentId) {
    Get.toNamed(Routes.TRACK_SHIPMENT, parameters: {'id': shipmentId});
  }

  void navigateToLoadDetails(String loadId) {
    Get.toNamed(Routes.LOAD_DETAILS, parameters: {'id': loadId});
  }

  void navigateToProfile() {
    Get.toNamed(Routes.MAIN);
    if (Get.isRegistered<MainController>()) {
      final mainController = Get.find<MainController>();
      mainController.onTabChanged(3);
    }
  }


  void navigateToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void navigateToSupport() {
    Get.toNamed(Routes.SUPPORT);
  }

  void navigateToBidding() {
    Get.toNamed(Routes.MAIN);
    if (Get.isRegistered<MainController>()) {
      final mainController = Get.find<MainController>();
      mainController.onTabChanged(2);
    }
  }

  void navigateToPayments() {
    Get.toNamed(Routes.PAYMENTS);
  }

  void navigateToNotifications() {
    Get.toNamed(Routes.NOTIFICATIONS);
  }

  // Bid-related navigation methods
  void navigateToBidDetails(String bidId) {
    Get.toNamed(Routes.BID_DETAILS, parameters: {'id': bidId});
  }

  void navigateToMyBids() {
    Get.toNamed(Routes.MY_BIDS);
  }

  void navigateToAvailableLoads() {
    Get.toNamed(Routes.AVAILABLE_LOADS);
  }

  // Quick actions
  void onQuickActionTapped(String action) {
    switch (action) {
      case 'post_load':
        navigateToPostLoad();
        break;
      case 'created_loads':
        navigateToCreatedLoads();
        break;
      case 'search_trucks':
        navigateToSearchTrucks();
        break;
      case 'track_shipment':
        if (activeShipments.isNotEmpty) {
          navigateToTrackShipment(activeShipments.first.id);
        } else {
          navigateToShipments();
        }
        break;
      case 'bidding':
        navigateToBidding();
        break;
      case 'my_bids':
        navigateToMyBids();
        break;
      case 'available_loads':
        navigateToAvailableLoads();
        break;
      case 'payments':
        navigateToPayments();
        break;
      case 'support':
        navigateToSupport();
        break;
      default:
        break;
    }
  }

  // Search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isNotEmpty) {
      _performSearch(query);
    }
  }

  // Location selection methods
  void onPickupLocationSelected(String address, Map<String, double>? coordinates) {
    pickupLocation.value = address;
    pickupCoordinates.value = coordinates;
    isPickupLocationSelected.value = true;

    // Save to recent locations
    _saveToRecentLocations(address, coordinates, true);

    _showSuccessSnackbar('Pickup location selected: $address');
  }

  void onDeliveryLocationSelected(String address, Map<String, double>? coordinates) {
    deliveryLocation.value = address;
    deliveryCoordinates.value = coordinates;
    isDeliveryLocationSelected.value = true;

    // Save to recent locations
    _saveToRecentLocations(address, coordinates, false);

    _showSuccessSnackbar('Delivery location selected: $address');
  }

  void _saveToRecentLocations(String address, Map<String, double>? coordinates, bool isPickup) {
    // In production, save to local storage or user preferences
    print('Saving location: $address (${isPickup ? 'Pickup' : 'Delivery'})');
  }

  void swapLocations() {
    if (pickupLocation.value.isNotEmpty && deliveryLocation.value.isNotEmpty) {
      final tempLocation = pickupLocation.value;
      final tempCoordinates = pickupCoordinates.value;

      pickupLocation.value = deliveryLocation.value;
      pickupCoordinates.value = deliveryCoordinates.value;

      deliveryLocation.value = tempLocation;
      deliveryCoordinates.value = tempCoordinates;

      _showSuccessSnackbar('Locations swapped');
    }
  }

  void clearPickupLocation() {
    pickupLocation.value = '';
    pickupCoordinates.value = null;
    isPickupLocationSelected.value = false;
  }

  void clearDeliveryLocation() {
    deliveryLocation.value = '';
    deliveryCoordinates.value = null;
    isDeliveryLocationSelected.value = false;
  }

  Future<void> _performSearch(String query) async {
    try {
      isLoading.value = true;
      final searchResults = await FirestoreService.searchLoads(query);

      Get.snackbar(
        'Search Results',
        'Found ${searchResults.length} loads matching "$query"',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error performing search: $e');
      _showErrorSnackbar('Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  void onLocationChanged(String location) {
    selectedLocation.value = location;
  }

  // Refresh data
  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;

      await Future.wait([
        _loadQuickStats(),
        _loadNotifications(),
        _loadRecentLoads(),
      ]);

      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error refreshing data: $e');
      _showErrorSnackbar('Failed to refresh data');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Menu actions
  void onMenuSelected(String value) {
    switch (value) {
      case 'profile':
        navigateToProfile();
        break;
      case 'settings':
        navigateToSettings();
        break;
      case 'support':
        navigateToSupport();
        break;
      case 'notifications':
        navigateToNotifications();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Emergency contact
  void callEmergencySupport() {
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
          'You are about to call emergency support. This should only be used for urgent safety issues or emergencies during transport.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Emergency Support',
                'Connecting to emergency support...',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[700],
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Notification methods
  void onNotificationTapped(Map<String, dynamic> notification) async {
    // Mark as read
    if (!(notification['isRead'] ?? false)) {
      await FirestoreService.markNotificationAsRead(notification['id']);
      await _loadNotifications();
    }

    // Handle notification action based on type
    final type = notification['type'] ?? '';
    final data = notification['data'] ?? {};

    switch (type) {
      case 'shipment_update':
        if (data['shipmentId'] != null) {
          navigateToTrackShipment(data['shipmentId']);
        }
        break;
      case 'new_bid':
        if (data['loadId'] != null) {
          navigateToLoadDetails(data['loadId']);
        }
        break;
      case 'bid_accepted':
        if (data['bidId'] != null) {
          navigateToBidDetails(data['bidId']);
        }
        break;
      case 'bid_rejected':
        if (data['bidId'] != null) {
          navigateToBidDetails(data['bidId']);
        }
        break;
      case 'new_load_available':
        if (data['loadId'] != null) {
          navigateToLoadDetails(data['loadId']);
        }
        break;
      case 'payment_received':
        navigateToPayments();
        break;
      default:
        break;
    }
  }

  // Load management actions
  void onLoadCardTapped(LoadModel load) {
    navigateToLoadDetails(load.id);
  }

  void onShipmentCardTapped(ShipmentModel shipment) {
    navigateToTrackShipment(shipment.id);
  }

  // Bid management actions
  void onBidCardTapped(BidModel bid) {
    navigateToBidDetails(bid.id);
  }

  void onBidStatusChanged(String bidId, BidStatus newStatus) {
    final index = activeBids.indexWhere((bid) => bid.id == bidId);
    if (index != -1) {
      activeBids[index] = activeBids[index].copyWith(status: newStatus);
    }
  }

  // Quick load posting
  void showQuickPostLoadDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Quick Post Load'),
        content: const Text(
          'Would you like to post a new load or use a template from your previous loads?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              navigateToPostLoad();
            },
            child: const Text('Use Template'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              navigateToPostLoad();
            },
            child: const Text('New Load'),
          ),
        ],
      ),
    );
  }

  // Quick bid actions
  void showQuickBidDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Quick Bid Actions'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              navigateToAvailableLoads();
            },
            child: const Text('Browse Loads'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              navigateToMyBids();
            },
            child: const Text('My Bids'),
          ),
        ],
      ),
    );
  }

  // Load management methods
  void viewAllCreatedLoads() {
    navigateToCreatedLoads();
  }

  void editLoad(LoadModel load) {
    Get.toNamed(Routes.EDIT_LOAD, arguments: load);
  }

  void deleteLoad(String loadId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Load'),
          content: const Text('Are you sure you want to delete this load? This action cannot be undone.'),
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
        isLoading.value = true;
        final success = await FirestoreService.deleteLoad(loadId);

        if (success) {
          _showSuccessSnackbar('Load deleted successfully');
          await _loadRecentLoads();
        } else {
          _showErrorSnackbar('Failed to delete load');
        }
      }
    } catch (e) {
      print('Error deleting load: $e');
      _showErrorSnackbar('Failed to delete load');
    } finally {
      isLoading.value = false;
    }
  }

  // Bid management methods
  void submitBid(String loadId, double amount, String notes) async {
    try {
      isLoading.value = true;

      final bidData = {
        'loadId': loadId,
        'amount': amount,
        'notes': notes,
        'estimatedDelivery': '2-3 days',
        'submittedAt': DateTime.now().toIso8601String(),
      };

      final success = await FirestoreService.submitBid(bidData);

      if (success) {
        _showSuccessSnackbar('Bid submitted successfully');
      } else {
        _showErrorSnackbar('Failed to submit bid');
      }
    } catch (e) {
      print('Error submitting bid: $e');
      _showErrorSnackbar('Failed to submit bid');
    } finally {
      isLoading.value = false;
    }
  }

  void withdrawBid(String bidId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Withdraw Bid'),
          content: const Text('Are you sure you want to withdraw this bid?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Withdraw'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        final success = await FirestoreService.withdrawBid(bidId);

        if (success) {
          _showSuccessSnackbar('Bid withdrawn successfully');
        } else {
          _showErrorSnackbar('Failed to withdraw bid');
        }
      }
    } catch (e) {
      print('Error withdrawing bid: $e');
      _showErrorSnackbar('Failed to withdraw bid');
    } finally {
      isLoading.value = false;
    }
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

  // Filter and sort
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
            const Text(
              'Filter & Sort',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Filter by Location'),
              onTap: () {
                // Implement location filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Filter by Date'),
              onTap: () {
                // Implement date filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort by Priority'),
              onTap: () {
                // Implement sorting
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard insights
  void showDashboardInsights() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInsightCard(
                      'Load Performance',
                      'Your loads receive an average of ${_calculateAverageBids()} bids',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                    _buildInsightCard(
                      'Success Rate',
                      '${quickStats.value?.getSuccessRate() ?? 0}% of your loads are completed',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildInsightCard(
                      'Active Engagement',
                      'You have ${activeBids.length} active bids',
                      Icons.gavel,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAverageBids() {
    if (recentLoads.isEmpty) return 0;
    final totalBids = recentLoads.fold<int>(0, (sum, load) => sum + load.bidsCount);
    return (totalBids / recentLoads.length).round();
  }
}

// Enhanced QuickStats model with bid support
class QuickStats {
  final int totalShipments;
  final int activeShipments;
  final int completedShipments;
  final double totalSavings;
  final int monthlyShipments;
  final double averageRating;
  final int totalLoads;
  final int activeBids;
  final int pendingBids;

  QuickStats({
    required this.totalShipments,
    required this.activeShipments,
    required this.completedShipments,
    required this.totalSavings,
    this.monthlyShipments = 0,
    this.averageRating = 0.0,
    this.totalLoads = 0,
    this.activeBids = 0,
    this.pendingBids = 0,
  });

  // Calculate success rate
  double getSuccessRate() {
    if (totalLoads == 0) return 0.0;
    return (completedShipments / totalLoads) * 100;
  }

  // Calculate bid acceptance rate
  double getBidAcceptanceRate() {
    if (activeBids + pendingBids == 0) return 0.0;
    return (activeBids / (activeBids + pendingBids)) * 100;
  }
}