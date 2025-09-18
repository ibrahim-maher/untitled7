import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/LoadModel.dart';
import '../routes/app_pages.dart';
import '../services/firestore_service.dart';

class MyBidsController extends GetxController with GetTickerProviderStateMixin {
  // Tab controller
  late TabController tabController;

  // Observable variables
  var isLoading = false.obs;
  var isFilterApplied = false.obs;
  var searchQuery = ''.obs;

  // Bid lists - These are bids received FOR user's loads
  var allBids = <BidModel>[].obs;
  var filteredBids = <BidModel>[].obs;

  // User's loads for reference
  var userLoads = <LoadModel>[].obs;

  // Filter variables
  var selectedStatusFilter = BidStatus.pending.obs;
  var selectedMinAmount = 0.0.obs;
  var selectedMaxAmount = 100000.0.obs;
  var selectedMinRating = 0.0.obs;
  var selectedLoadIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    _loadReceivedBids();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Computed properties
  List<BidModel> get pendingBids => filteredBids.where((bid) => bid.status == BidStatus.pending).toList();
  List<BidModel> get acceptedBids => filteredBids.where((bid) => bid.status == BidStatus.accepted).toList();
  List<BidModel> get rejectedBids => filteredBids.where((bid) => bid.status == BidStatus.rejected).toList();

  int get totalBids => allBids.length;
  int get pendingBidsCount => pendingBids.length;
  int get acceptedBidsCount => acceptedBids.length;
  int get rejectedBidsCount => rejectedBids.length;

  double get averageBidAmount {
    if (allBids.isEmpty) return 0.0;
    return allBids.fold(0.0, (sum, bid) => sum + bid.bidAmount) / allBids.length;
  }

  double get bestSaving {
    if (allBids.isEmpty) return 0.0;

    // Group bids by load and find best savings
    Map<String, List<BidModel>> bidsByLoad = {};
    for (var bid in allBids) {
      bidsByLoad.putIfAbsent(bid.loadId, () => []).add(bid);
    }

    double totalSavings = 0.0;
    for (var loadBids in bidsByLoad.values) {
      if (loadBids.length > 1) {
        loadBids.sort((a, b) => a.bidAmount.compareTo(b.bidAmount));
        double saving = loadBids.last.bidAmount - loadBids.first.bidAmount;
        totalSavings += saving;
      }
    }

    return totalSavings / bidsByLoad.length;
  }

  // Load received bids for user's loads
  void _loadReceivedBids() async {
    try {
      isLoading.value = true;

      // First load user's loads
      final loads = await FirestoreService.getUserLoads(limit: 50);
      userLoads.assignAll(loads);

      // Then load all bids for those loads
      List<BidModel> receivedBids = [];
      for (var load in loads) {
        final loadBids = await FirestoreService.getLoadBids(load.id);
        receivedBids.addAll(loadBids);
      }

      allBids.assignAll(receivedBids);
      _applyFilters();
    } catch (e) {
      _showErrorSnackbar('Failed to load received bids: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh bids
  Future<void> refreshBids() async {
    _loadReceivedBids();
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
    var filtered = allBids.toList();

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((bid) {
        final query = searchQuery.value.toLowerCase();
        return bid.transporterName.toLowerCase().contains(query) ||
            bid.loadId.toLowerCase().contains(query) ||
            bid.vehicleType.toLowerCase().contains(query) ||
            bid.notes?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply advanced filters if applied
    if (isFilterApplied.value) {
      filtered = filtered.where((bid) {
        return bid.bidAmount >= selectedMinAmount.value &&
            bid.bidAmount <= selectedMaxAmount.value &&
            bid.transporterRating >= selectedMinRating.value;
      }).toList();

      if (selectedLoadIds.isNotEmpty) {
        filtered = filtered.where((bid) => selectedLoadIds.contains(bid.loadId)).toList();
      }
    }

    // Sort by created date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredBids.assignAll(filtered);
  }

  // Filter dialog
  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Bids'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount range
                Text('Bid Amount Range', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Min Amount',
                          prefixText: '₹',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: selectedMinAmount.value.toString(),
                        onChanged: (value) {
                          selectedMinAmount.value = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Amount',
                          prefixText: '₹',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: selectedMaxAmount.value.toString(),
                        onChanged: (value) {
                          selectedMaxAmount.value = double.tryParse(value) ?? 100000.0;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Minimum rating
                Text('Minimum Transporter Rating', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                Obx(() => Slider(
                  value: selectedMinRating.value,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10,
                  label: selectedMinRating.value.toStringAsFixed(1),
                  onChanged: (value) {
                    selectedMinRating.value = value;
                  },
                )),

                const SizedBox(height: 16),

                // Specific loads
                Text('Filter by Load', style: Get.textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: userLoads.length,
                    itemBuilder: (context, index) {
                      final load = userLoads[index];
                      return Obx(() => CheckboxListTile(
                        title: Text(
                          load.title,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Load #${load.id.substring(0, 8)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: selectedLoadIds.contains(load.id),
                        onChanged: (selected) {
                          if (selected == true) {
                            selectedLoadIds.add(load.id);
                          } else {
                            selectedLoadIds.remove(load.id);
                          }
                        },
                        dense: true,
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFilters();
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
              _applyFilterDialog();
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _applyFilterDialog() {
    isFilterApplied.value = true;
    _applyFilters();
  }

  void _clearFilters() {
    isFilterApplied.value = false;
    selectedMinAmount.value = 0.0;
    selectedMaxAmount.value = 100000.0;
    selectedMinRating.value = 0.0;
    selectedLoadIds.clear();
    _applyFilters();
  }

  // Bid management actions
  void acceptBid(BidModel bid) {
    Get.dialog(
      AlertDialog(
        title: const Text('Accept Bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accept bid from ${bid.transporterName}?'),
            const SizedBox(height: 8),
            Text('Amount: ₹${bid.bidAmount.toStringAsFixed(0)}'),
            Text('Vehicle: ${bid.vehicleType}'),
            Text('Rating: ${bid.transporterRating.toStringAsFixed(1)} ⭐'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '⚠️ This will reject all other pending bids for this load.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performAcceptBid(bid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Accept Bid', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performAcceptBid(BidModel bid) async {
    try {
      _showInfoSnackbar('Accepting bid...');

      final success = await FirestoreService.acceptBid(bid.id, bid.loadId);

      if (success) {
        _showSuccessSnackbar('Bid accepted successfully! Shipment created.');
        refreshBids();

        // Navigate to shipments to see the new shipment
        Future.delayed(const Duration(seconds: 2), () {
          Get.toNamed(Routes.SHIPMENTS);
        });
      } else {
        _showErrorSnackbar('Failed to accept bid');
      }
    } catch (e) {
      _showErrorSnackbar('Error accepting bid: $e');
    }
  }

  void rejectBid(BidModel bid) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Bid'),
        content: Text('Are you sure you want to reject the bid from ${bid.transporterName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performRejectBid(bid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performRejectBid(BidModel bid) async {
    try {
      _showInfoSnackbar('Rejecting bid...');

      final success = await FirestoreService.rejectBid(bid.id);

      if (success) {
        _showSuccessSnackbar('Bid rejected');
        refreshBids();
      } else {
        _showErrorSnackbar('Failed to reject bid');
      }
    } catch (e) {
      _showErrorSnackbar('Error rejecting bid: $e');
    }
  }

  // Accept best bid (lowest amount with good rating)
  void acceptBestBid() {
    if (pendingBids.isEmpty) {
      _showInfoSnackbar('No pending bids to accept');
      return;
    }

    // Find best bid (lowest price with rating > 4.0)
    var qualifiedBids = pendingBids.where((bid) => bid.transporterRating >= 4.0).toList();
    if (qualifiedBids.isEmpty) {
      qualifiedBids = pendingBids; // Fall back to all bids if none meet rating criteria
    }

    qualifiedBids.sort((a, b) => a.bidAmount.compareTo(b.bidAmount));
    final bestBid = qualifiedBids.first;

    Get.dialog(
      AlertDialog(
        title: const Text('Accept Best Bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Accept the best qualified bid?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bestBid.transporterName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Amount: ₹${bestBid.bidAmount.toStringAsFixed(0)}'),
                  Text('Rating: ${bestBid.transporterRating.toStringAsFixed(1)} ⭐'),
                  Text('Vehicle: ${bestBid.vehicleType}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performAcceptBid(bestBid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Accept Best', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Reject all pending bids
  void rejectAllPendingBids() {
    if (pendingBids.isEmpty) {
      _showInfoSnackbar('No pending bids to reject');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Reject All Pending Bids'),
        content: Text(
          'Are you sure you want to reject all ${pendingBids.length} pending bids? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performRejectAllPending();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text('Reject All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performRejectAllPending() async {
    try {
      _showInfoSnackbar('Rejecting all pending bids...');

      int successCount = 0;
      int failCount = 0;

      for (final bid in pendingBids) {
        final success = await FirestoreService.rejectBid(bid.id);
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (failCount == 0) {
        _showSuccessSnackbar('All $successCount bids rejected');
      } else {
        _showInfoSnackbar('$successCount bids rejected, $failCount failed');
      }

      refreshBids();
    } catch (e) {
      _showErrorSnackbar('Error rejecting bids: $e');
    }
  }

  // Navigation and actions
  void navigateToBidDetails(BidModel bid) {
    Get.toNamed(Routes.LOAD_DETAILS, arguments: {'loadId': bid.loadId});
  }

  void viewTransporterProfile(BidModel bid) {
    Get.toNamed(Routes.DRIVER_PROFILE, arguments: {
      'driverId': bid.transporterId,
      'driverName': bid.transporterName,
    });
  }

  void navigateToMyLoads() {
    Get.toNamed(Routes.CREATED_LOADS);
  }

  // Bid comparison helpers
  bool isLowestBid(BidModel bid) {
    final sameLoadBids = allBids.where((b) => b.loadId == bid.loadId).toList();
    if (sameLoadBids.length <= 1) return false;

    sameLoadBids.sort((a, b) => a.bidAmount.compareTo(b.bidAmount));
    return sameLoadBids.first.id == bid.id;
  }

  bool isBestRated(BidModel bid) {
    final sameLoadBids = allBids.where((b) => b.loadId == bid.loadId).toList();
    if (sameLoadBids.length <= 1) return false;

    sameLoadBids.sort((a, b) => b.transporterRating.compareTo(a.transporterRating));
    return sameLoadBids.first.id == bid.id && bid.transporterRating >= 4.5;
  }

  void showBidActions(BidModel bid) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: bid.transporterPhotoUrl?.isNotEmpty == true
                      ? NetworkImage(bid.transporterPhotoUrl!)
                      : null,
                  backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
                  child: bid.transporterPhotoUrl?.isEmpty ?? true
                      ? Icon(Icons.person, color: Get.theme.primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.transporterName,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bid: ₹${bid.bidAmount.toStringAsFixed(0)}',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${bid.transporterRating.toStringAsFixed(1)} ⭐ • ${bid.completedTrips} trips',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildActionTile(
              icon: Icons.person,
              title: 'View Transporter Profile',
              onTap: () {
                Get.back();
                viewTransporterProfile(bid);
              },
            ),

            _buildActionTile(
              icon: Icons.phone,
              title: 'Contact Transporter',
              onTap: () {
                Get.back();
                _contactTransporter(bid);
              },
            ),

            if (bid.status == BidStatus.pending) ...[
              _buildActionTile(
                icon: Icons.check_circle,
                title: 'Accept This Bid',
                onTap: () {
                  Get.back();
                  acceptBid(bid);
                },
                isPositive: true,
              ),
              _buildActionTile(
                icon: Icons.cancel,
                title: 'Reject This Bid',
                onTap: () {
                  Get.back();
                  rejectBid(bid);
                },
                isDestructive: true,
              ),
            ],

            if (bid.status == BidStatus.accepted)
              _buildActionTile(
                icon: Icons.local_shipping,
                title: 'View Shipment',
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.SHIPMENTS);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isPositive = false,
  }) {
    Color? color;
    if (isDestructive) color = Colors.red[600];
    if (isPositive) color = Colors.green[600];

    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _contactTransporter(BidModel bid) {
    // Implement contact functionality
    _showInfoSnackbar('Contact functionality to be implemented');
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