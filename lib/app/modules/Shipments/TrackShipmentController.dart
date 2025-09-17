import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../data/models/LoadModel.dart';
import '../../routes/app_pages.dart';
import '../../services/firestore_service.dart';

class TrackShipmentController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var shipment = Rxn<ShipmentModel>();
  var trackingUpdates = <TrackingUpdate>[].obs;
  var estimatedDeliveryTime = Rxn<DateTime>();

  // Streams
  StreamSubscription? _shipmentSubscription;

  // Get shipment ID from route parameters
  String get shipmentId => Get.parameters['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    if (shipmentId.isNotEmpty) {
      _initializeTracking();
      _setupRealTimeTracking();
    } else {
      _showErrorSnackbar('Invalid shipment ID');
      Get.back();
    }
  }

  @override
  void onClose() {
    _shipmentSubscription?.cancel();
    super.onClose();
  }

  void _initializeTracking() async {
    try {
      isLoading.value = true;
      await _loadShipmentDetails();
    } catch (e) {
      print('Error initializing tracking: $e');
      _showErrorSnackbar('Failed to load shipment details');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRealTimeTracking() {
    _shipmentSubscription = FirestoreService.trackShipment(shipmentId).listen(
          (updatedShipment) {
        if (updatedShipment != null) {
          shipment.value = updatedShipment;
          trackingUpdates.value = updatedShipment.trackingUpdates;
          _calculateEstimatedDelivery();
        }
      },
      onError: (error) {
        print('Error in tracking stream: $error');
        _showErrorSnackbar('Failed to sync tracking data');
      },
    );
  }

  Future<void> _loadShipmentDetails() async {
    try {
      final shipmentData = await FirestoreService.getShipmentById(shipmentId);
      if (shipmentData != null) {
        shipment.value = shipmentData;
        trackingUpdates.value = shipmentData.trackingUpdates;
        _calculateEstimatedDelivery();
      } else {
        throw Exception('Shipment not found');
      }
    } catch (e) {
      print('Error loading shipment details: $e');
      throw e;
    }
  }

  void _calculateEstimatedDelivery() {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    // FIXED: Handle all ShipmentStatus cases including pickedUp
    switch (currentShipment.status) {
      case ShipmentStatus.pending:
      case ShipmentStatus.confirmed:
      case ShipmentStatus.accepted:
        estimatedDeliveryTime.value = DateTime.now().add(const Duration(hours: 24));
        break;
      case ShipmentStatus.pickup:
        estimatedDeliveryTime.value = DateTime.now().add(const Duration(hours: 18));
        break;
      case ShipmentStatus.pickedUp: // FIXED: Added missing case
      case ShipmentStatus.loaded:
        estimatedDeliveryTime.value = DateTime.now().add(const Duration(hours: 12));
        break;
      case ShipmentStatus.inTransit:
        estimatedDeliveryTime.value = DateTime.now().add(const Duration(hours: 6));
        break;
      case ShipmentStatus.delivered:
      case ShipmentStatus.completed:
      // FIXED: Use actualDelivery instead of deliveredAt
        estimatedDeliveryTime.value = currentShipment.actualDelivery ?? DateTime.now();
        break;
      case ShipmentStatus.cancelled:
        estimatedDeliveryTime.value = null;
        break;
    }
  }

  // Refresh tracking data
  Future<void> refreshTracking() async {
    try {
      isRefreshing.value = true;
      await _loadShipmentDetails();
      _showSuccessSnackbar('Tracking data refreshed');
    } catch (e) {
      print('Error refreshing tracking: $e');
      _showErrorSnackbar('Failed to refresh tracking data');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Communication methods
  void callDriver() async {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    final phoneNumber = currentShipment.driverPhone;
    if (phoneNumber.isNotEmpty) {
      try {
        final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          _showErrorSnackbar('Unable to make phone call');
        }
      } catch (e) {
        print('Error making phone call: $e');
        _showErrorSnackbar('Failed to initiate call');
      }
    } else {
      _showErrorSnackbar('Driver phone number not available');
    }
  }

  void messageDriver() {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    // Navigate to chat/messaging screen
    Get.toNamed(Routes.CHAT, arguments: {
      'recipientId': currentShipment.transporterId, // FIXED: Use transporterId instead of driverId
      'recipientName': currentShipment.driverName,
      'shipmentId': shipmentId,
    });
  }

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
          'You are about to contact emergency support. This should only be used for urgent safety issues or emergencies during transport.\n\nDo you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _callEmergencyNumber();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Call Emergency', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergencyNumber() async {
    const emergencyNumber = '911'; // Replace with your emergency support number
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: emergencyNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to call emergency support');
      }
    } catch (e) {
      print('Error calling emergency: $e');
      _showErrorSnackbar('Failed to call emergency support');
    }
  }

  // Sharing functionality
  void shareTracking() {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    final trackingUrl = 'https://yourapp.com/track/${currentShipment.id}';
    final shareText = '''
🚛 Shipment Tracking Update

📦 Shipment: #${currentShipment.id.substring(0, 8)}
📍 From: ${currentShipment.pickupLocation}
📍 To: ${currentShipment.deliveryLocation}
🚚 Status: ${currentShipment.status.displayName}
👨‍💼 Driver: ${currentShipment.driverName}

Track live: $trackingUrl
    '''.trim();

    // Use share_plus plugin in production
    Get.snackbar(
      'Tracking Shared',
      'Tracking details copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    // For now, just show the share text
    Get.dialog(
      AlertDialog(
        title: const Text('Share Tracking'),
        content: SingleChildScrollView(
          child: Text(shareText),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Copy to clipboard logic here
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  // Shipment actions
  void reportIssue() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('What type of issue would you like to report?'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text('Delay'),
              subtitle: const Text('Shipment is delayed'),
              onTap: () => _reportIssue('delay'),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Damage'),
              subtitle: const Text('Load appears damaged'),
              onTap: () => _reportIssue('damage'),
            ),
            ListTile(
              leading: const Icon(Icons.location_off, color: Colors.blue),
              title: const Text('Wrong Location'),
              subtitle: const Text('Incorrect pickup/delivery location'),
              onTap: () => _reportIssue('location'),
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.grey),
              title: const Text('Other'),
              subtitle: const Text('Other issues'),
              onTap: () => _reportIssue('other'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _reportIssue(String issueType) {
    Get.back(); // Close the issue selection dialog

    // Navigate to support/issue reporting screen
    Get.toNamed(Routes.SUPPORT, arguments: {
      'issueType': issueType,
      'shipmentId': shipmentId,
      'shipment': shipment.value,
    });

    _showSuccessSnackbar('Issue report initiated');
  }

  void requestCallback() {
    Get.dialog(
      AlertDialog(
        title: const Text('Request Callback'),
        content: const Text(
          'Our customer support team will call you within 15 minutes to assist with your shipment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _requestCallback();
            },
            child: const Text('Request Call'),
          ),
        ],
      ),
    );
  }

  void _requestCallback() {
    // In production, send callback request to support system
    _showSuccessSnackbar('Callback requested. We\'ll call you within 15 minutes.');
  }

  // Update delivery instructions
  void updateDeliveryInstructions() {
    final controller = TextEditingController(
      text: shipment.value?.notes ?? '', // FIXED: Use notes instead of deliveryInstructions
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Update Delivery Instructions'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter special delivery instructions...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _saveDeliveryInstructions(controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDeliveryInstructions(String instructions) async {
    try {
      // In production, update shipment with new delivery instructions
      _showSuccessSnackbar('Delivery instructions updated');
    } catch (e) {
      print('Error saving delivery instructions: $e');
      _showErrorSnackbar('Failed to update instructions');
    }
  }

  // Rate and review after delivery
  void rateShipment() {
    if (shipment.value?.status != ShipmentStatus.delivered &&
        shipment.value?.status != ShipmentStatus.completed) {
      _showErrorSnackbar('Shipment must be delivered to rate');
      return;
    }

    Get.toNamed(Routes.RATE_SHIPMENT, arguments: {
      'shipmentId': shipmentId,
      'shipment': shipment.value,
    });
  }

  // Document and proof management
  void viewDeliveryProof() {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    // FIXED: Check documents list instead of deliveryProofUrl
    if (currentShipment.documents.isNotEmpty) {
      Get.toNamed(Routes.DELIVERY_PROOF, arguments: {
        'proofUrl': currentShipment.documents.first, // Use first document as proof
        'shipmentId': shipmentId,
      });
    } else {
      _showErrorSnackbar('Delivery proof not available yet');
    }
  }

  void downloadDocuments() {
    Get.dialog(
      AlertDialog(
        title: const Text('Download Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Invoice'),
              trailing: const Icon(Icons.download),
              onTap: () => _downloadDocument('invoice'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Shipment Summary'),
              trailing: const Icon(Icons.download),
              onTap: () => _downloadDocument('summary'),
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Delivery Proof'),
              trailing: const Icon(Icons.download),
              onTap: () => _downloadDocument('proof'),
            ),
          ],
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

  void _downloadDocument(String documentType) {
    Get.back();
    _showSuccessSnackbar('Downloading $documentType...');
    // Implement actual document download logic
  }

  // Navigation methods
  void navigateToShipmentDetails() {
    Get.toNamed(Routes.SHIPMENT_DETAILS, arguments: shipment.value);
  }

  void navigateToLoadDetails() {
    final currentShipment = shipment.value;
    if (currentShipment != null) {
      Get.toNamed(Routes.LOAD_DETAILS, parameters: {'id': currentShipment.loadId});
    }
  }

  void navigateToDriverProfile() {
    final currentShipment = shipment.value;
    if (currentShipment != null) {
      Get.toNamed(Routes.DRIVER_PROFILE, arguments: {
        'driverId': currentShipment.transporterId, // FIXED: Use transporterId
        'driverName': currentShipment.driverName,
      });
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

  // Status update methods (for driver/admin use)
  Future<void> updateShipmentStatus(ShipmentStatus newStatus) async {
    try {
      final success = await FirestoreService.updateShipmentStatus(shipmentId, newStatus);
      if (success) {
        _showSuccessSnackbar('Status updated successfully');
      } else {
        _showErrorSnackbar('Failed to update status');
      }
    } catch (e) {
      print('Error updating shipment status: $e');
      _showErrorSnackbar('Failed to update status');
    }
  }

  Future<void> addTrackingUpdate(String message, {String? location}) async {
    try {
      // FIXED: Use proper TrackingUpdate model from LoadModel.dart
      final update = TrackingUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: shipment.value?.status ?? ShipmentStatus.pending,
        location: location ?? '',
        description: message,
        timestamp: DateTime.now(),
      );

      final success = await FirestoreService.addTrackingUpdate(shipmentId, update);
      if (success) {
        _showSuccessSnackbar('Tracking update added');
      } else {
        _showErrorSnackbar('Failed to add update');
      }
    } catch (e) {
      print('Error adding tracking update: $e');
      _showErrorSnackbar('Failed to add update');
    }
  }
}