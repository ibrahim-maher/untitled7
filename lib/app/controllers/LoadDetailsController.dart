import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../data/models/LoadModel.dart';
import '../services/firestore_service.dart';
import '../routes/app_pages.dart';

class LoadDetailsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var load = Rxn<LoadModel>();
  var bids = <BidModel>[].obs;
  var canDeleteLoad = false.obs;
  var canEditLoad = false.obs;
  var analytics = Rxn<LoadAnalytics>();
  var notifications = <Map<String, dynamic>>[].obs;

  // Load ID from route parameters
  String get loadId => Get.parameters['id'] ?? Get.arguments?['loadId'] ?? '';

  // Real-time listeners
  StreamSubscription? _loadSubscription;
  StreamSubscription? _bidsSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _setupRealTimeListeners();
  }

  @override
  void onClose() {
    _loadSubscription?.cancel();
    _bidsSubscription?.cancel();
    super.onClose();
  }

  void _loadData() async {
    if (loadId.isEmpty) {
      _showErrorSnackbar('Load ID not provided');
      Get.back();
      return;
    }

    try {
      isLoading.value = true;

      // Load the load details
      await _loadLoadDetails();

      // Load analytics
      await _loadAnalytics();

      // Check permissions
      _checkPermissions();

    } catch (e) {
      print('Error loading load details: $e');
      _showErrorSnackbar('Failed to load load details');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealTimeListeners() {
    // Listen to load updates
    _loadSubscription = FirestoreService.getLoadStream(loadId).listen(
          (loadData) {
        if (loadData != null) {
          load.value = loadData;
          _checkPermissions();
        }
      },
      onError: (error) {
        print('Error in load stream: $error');
      },
    );

    // Listen to bids updates
    _bidsSubscription = FirestoreService.getLoadBidsStream(loadId).listen(
          (bidsData) {
        bids.assignAll(bidsData as Iterable<BidModel>);
      },
      onError: (error) {
        print('Error in bids stream: $error');
      },
    );
  }

  Future<void> _loadLoadDetails() async {
    try {
      final loadData = await FirestoreService.getLoad(loadId);
      if (loadData != null) {
        load.value = loadData;
      } else {
        throw Exception('Load not found');
      }
    } catch (e) {
      throw Exception('Failed to load load details: $e');
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final analyticsData = await FirestoreService.getLoadAnalytics(loadId);
      analytics.value = analyticsData as LoadAnalytics?;
    } catch (e) {
      print('Error loading analytics: $e');
    }
  }

  void _checkPermissions() {
    final currentLoad = load.value;
    if (currentLoad == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == currentLoad.userId;

    // Can delete if owner and load is not yet assigned or completed
    canDeleteLoad.value = isOwner && (
        currentLoad.status == LoadStatus.posted ||
            currentLoad.status == LoadStatus.bidding
    );

    // Can edit if owner and load is not in progress or completed
    canEditLoad.value = isOwner && (
        currentLoad.status == LoadStatus.posted ||
            currentLoad.status == LoadStatus.bidding
    );
  }

  // Refresh data
  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;
      await Future.wait([
        _loadLoadDetails(),
        _loadAnalytics(),
      ]);
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
      case 'edit':
        editLoad();
        break;
      case 'duplicate':
        duplicateLoad();
        break;
      case 'share':
        shareLoad();
        break;
      case 'delete':
        _confirmDeleteLoad();
        break;
      case 'analytics':
        viewAnalytics();
        break;
      case 'export':
        exportLoadData();
        break;
    }
  }

  // Load management actions
  void editLoad() {
    if (load.value == null || !canEditLoad.value) return;

    Get.toNamed(Routes.POST_LOAD, arguments: {
      'mode': 'edit',
      'load': load.value,
    });
  }

  void duplicateLoad() async {
    if (load.value == null) return;

    try {
      _showInfoSnackbar('Creating duplicate load...');

      final duplicatedLoad = load.value!.copyWith(
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
        Get.toNamed(Routes.LOAD_DETAILS, parameters: {'id': newLoadId});
      } else {
        _showErrorSnackbar('Failed to duplicate load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to duplicate load');
    }
  }

  void shareLoad() async {
    if (load.value == null) return;

    final currentLoad = load.value!;
    final shareText = '''
🚚 Load Available for Transport

📦 Load: ${currentLoad.title}
🏷️ Type: ${currentLoad.loadType.displayName}
⚖️ Weight: ${currentLoad.weight} kg
📍 Route: ${currentLoad.pickupLocation} → ${currentLoad.deliveryLocation}
💰 Budget: ₹${currentLoad.budget.toStringAsFixed(0)}
📅 Pickup: ${_formatDate(currentLoad.pickupDate)}

👤 Contact: ${currentLoad.contactPerson}
📞 Phone: ${currentLoad.contactPhone}

Download FreightFlow App to bid on this load.
Load ID: ${currentLoad.id}
''';

    try {
      await Share.share(
        shareText,
        subject: 'Load Available - ${currentLoad.title}',
      );
    } catch (e) {
      _showErrorSnackbar('Failed to share load');
    }
  }

  void _confirmDeleteLoad() {
    if (!canDeleteLoad.value) {
      _showErrorSnackbar('Cannot delete this load');
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Delete Load'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this load? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            if (bids.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This load has ${bids.length} bid(s). Deleting will notify all bidders.',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
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
              _deleteLoad();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteLoad() async {
    try {
      _showInfoSnackbar('Deleting load...');

      final success = await FirestoreService.deleteLoad(loadId);

      if (success) {
        _showSuccessSnackbar('Load deleted successfully');
        Get.back(); // Return to previous screen
      } else {
        _showErrorSnackbar('Failed to delete load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete load');
    }
  }

  // Load status management
  void pauseLoad() async {
    if (load.value == null) return;

    try {
      _showInfoSnackbar('Pausing load...');

      final success = await FirestoreService.updateLoadStatus(
        loadId,
        LoadStatus.draft, // Use draft as paused state
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

  void activateLoad() async {
    if (load.value == null) return;

    try {
      _showInfoSnackbar('Activating load...');

      final success = await FirestoreService.updateLoadStatus(
        loadId,
        LoadStatus.posted,
      );

      if (success) {
        _showSuccessSnackbar('Load activated successfully');
      } else {
        _showErrorSnackbar('Failed to activate load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to activate load');
    }
  }

  void closeLoad() async {
    if (load.value == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Mark Load as Complete'),
        content: const Text(
          'Are you sure you want to mark this load as complete? This will close the load for new bids.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _completeLoad();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _completeLoad() async {
    try {
      _showInfoSnackbar('Marking load as complete...');

      final success = await FirestoreService.updateLoadStatus(
        loadId,
        LoadStatus.completed,
      );

      if (success) {
        _showSuccessSnackbar('Load marked as complete');
      } else {
        _showErrorSnackbar('Failed to complete load');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to complete load');
    }
  }

  // Contact and communication
  void callContactPerson() async {
    final currentLoad = load.value;
    if (currentLoad == null || currentLoad.contactPhone!.isEmpty) {
      _showErrorSnackbar('Contact phone number not available');
      return;
    }

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: currentLoad.contactPhone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to make phone call');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to initiate call');
    }
  }

  void sendMessage() {
    Get.toNamed(Routes.CHAT, arguments: {
      'loadId': loadId,
      'contactPerson': load.value?.contactPerson,
    });
  }

  // Bid management
  void viewAllBids() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Bids',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${bids.length} bids received',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (bids.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gavel, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No bids yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Transporters will start bidding soon',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    return _buildDetailedBidItem(bid, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBidItem(BidModel bid, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: Theme.of(Get.context!).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          bid.transporterName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 16),
                const SizedBox(width: 4),
                Text('${bid.rating}'),
                const SizedBox(width: 12),
                Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(bid.vehicleType),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('ETA: ${bid.estimatedDelivery}'),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${bid.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            if (load.value?.status == LoadStatus.bidding ||
                load.value?.status == LoadStatus.posted)
              SizedBox(
                height: 28,
                child: ElevatedButton(
                  onPressed: () => _acceptBid(bid),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Accept'),
                ),
              ),
          ],
        ),
        onTap: () => _viewBidDetails(bid),
      ),
    );
  }

  void _viewBidDetails(BidModel bid) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.local_shipping,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.transporterName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text('${bid.rating} rating'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildBidDetailItem('Bid Amount', '₹${bid.amount.toStringAsFixed(0)}'),
            _buildBidDetailItem('Vehicle Type', bid.vehicleType),
            _buildBidDetailItem('Estimated Delivery', bid.estimatedDelivery),
            _buildBidDetailItem('Submitted', _formatDateTime(bid.submittedAt)),
            if (bid.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(bid.notes),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactTransporter(bid),
                    icon: const Icon(Icons.phone),
                    label: const Text('Contact'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _acceptBid(bid);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _contactTransporter(BidModel bid) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: bid.transporterPhone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to make phone call');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to initiate call');
    }
  }

  void _acceptBid(BidModel bid) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to accept the bid from ${bid.transporterName} for ₹${bid.amount.toStringAsFixed(0)}?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This will:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Create a shipment'),
                  const Text('• Notify the transporter'),
                  const Text('• Close bidding for other transporters'),
                  const Text('• Start tracking the delivery'),
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
              _processBidAcceptance(bid);
            },
            child: const Text('Accept Bid'),
          ),
        ],
      ),
    );
  }

  void _processBidAcceptance(BidModel bid) async {
    try {
      _showInfoSnackbar('Processing bid acceptance...');

      final success = await FirestoreService.acceptBid(loadId, bid.id);

      if (success) {
        _showSuccessSnackbar('Bid accepted! Shipment created.');
        Get.offNamed(Routes.SHIPMENTS);
      } else {
        _showErrorSnackbar('Failed to accept bid');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to accept bid');
    }
  }

  // Analytics and insights
  void viewAnalytics() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              'Load Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAnalyticsItem(
                      'Views',
                      '${analytics.value?.views ?? 0}',
                      Icons.visibility,
                    ),
                    _buildAnalyticsItem(
                      'Bids Received',
                      '${bids.length}',
                      Icons.gavel,
                    ),
                    _buildAnalyticsItem(
                      'Average Bid',
                      '₹${_calculateAverageBid()}',
                      Icons.trending_up,
                    ),
                    _buildAnalyticsItem(
                      'Days Active',
                      '${DateTime.now().difference(load.value?.createdAt ?? DateTime.now()).inDays}',
                      Icons.calendar_today,
                    ),
                    _buildAnalyticsItem(
                      'Response Rate',
                      '${_calculateResponseRate()}%',
                      Icons.percent,
                    ),
                    _buildAnalyticsItem(
                      'Engagement Score',
                      '${_calculateEngagementScore()}/10',
                      Icons.thumb_up,
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

  Widget _buildAnalyticsItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(Get.context!).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAverageBid() {
    if (bids.isEmpty) return '0';
    final total = bids.fold<double>(0, (sum, bid) => sum + bid.amount);
    return (total / bids.length).toStringAsFixed(0);
  }

  String _calculateResponseRate() {
    final views = analytics.value?.views ?? 0;
    if (views == 0) return '0';
    return ((bids.length / views) * 100).toStringAsFixed(1);
  }

  String _calculateEngagementScore() {
    // Simple engagement scoring based on views, bids, and other factors
    int score = 0;

    // Base score from bids
    score += (bids.length * 2).clamp(0, 4);

    // Views contribution
    final views = analytics.value?.views ?? 0;
    if (views > 10) score += 2;
    else if (views > 5) score += 1;

    // Recency bonus
    final daysSinceCreated = DateTime.now().difference(load.value?.createdAt ?? DateTime.now()).inDays;
    if (daysSinceCreated <= 1) score += 2;
    else if (daysSinceCreated <= 3) score += 1;

    // Response rate bonus
    if (bids.isNotEmpty && views > 0) {
      final responseRate = (bids.length / views) * 100;
      if (responseRate > 20) score += 2;
      else if (responseRate > 10) score += 1;
    }

    return score.clamp(0, 10).toString();
  }

  void exportLoadData() async {
    try {
      _showInfoSnackbar('Preparing export...');

      // In production, generate PDF or Excel file
      await Future.delayed(const Duration(seconds: 2));

      _showSuccessSnackbar('Export feature coming soon');
    } catch (e) {
      _showErrorSnackbar('Failed to export data');
    }
  }

  // Utility methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[700],
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 4),
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
      duration: const Duration(seconds: 3),
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
      duration: const Duration(seconds: 2),
    );
  }
}

// Supporting models
class BidModel {
  final String id;
  final String transporterId;
  final String transporterName;
  final String transporterPhone;
  final String vehicleType;
  final double amount;
  final double rating;
  final String estimatedDelivery;
  final String notes;
  final DateTime submittedAt;
  final BidStatus status;

  BidModel({
    required this.id,
    required this.transporterId,
    required this.transporterName,
    required this.transporterPhone,
    required this.vehicleType,
    required this.amount,
    required this.rating,
    required this.estimatedDelivery,
    required this.notes,
    required this.submittedAt,
    required this.status,
  });

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'] ?? '',
      transporterId: map['transporterId'] ?? '',
      transporterName: map['transporterName'] ?? '',
      transporterPhone: map['transporterPhone'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      estimatedDelivery: map['estimatedDelivery'] ?? '',
      notes: map['notes'] ?? '',
      submittedAt: DateTime.fromMillisecondsSinceEpoch(map['submittedAt'] ?? 0),
      status: BidStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => BidStatus.pending,
      ),
    );
  }
}

enum BidStatus { pending, accepted, rejected, expired }

class LoadAnalytics {
  final int views;
  final int shares;
  final int inquiries;
  final double avgBidAmount;
  final DateTime lastViewed;

  LoadAnalytics({
    required this.views,
    required this.shares,
    required this.inquiries,
    required this.avgBidAmount,
    required this.lastViewed,
  });

  factory LoadAnalytics.fromMap(Map<String, dynamic> map) {
    return LoadAnalytics(
      views: map['views'] ?? 0,
      shares: map['shares'] ?? 0,
      inquiries: map['inquiries'] ?? 0,
      avgBidAmount: (map['avgBidAmount'] ?? 0).toDouble(),
      lastViewed: DateTime.fromMillisecondsSinceEpoch(map['lastViewed'] ?? 0),
    );
  }
}