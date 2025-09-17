import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/LoadModel.dart';
import '../routes/app_pages.dart';
import '../services/firestore_service.dart';


class ShipmentDetailsController extends GetxController {
  var isLoading = false.obs;
  var shipment = Rxn<ShipmentModel>();

  String get shipmentId => Get.arguments?['shipmentId'] ?? '';

  @override
  void onInit() {
    super.onInit();
    if (shipmentId.isNotEmpty) {
      _loadShipmentDetails();
    } else {
      _showErrorSnackbar('Invalid shipment ID');
      Get.back();
    }
  }

  void _loadShipmentDetails() async {
    try {
      isLoading.value = true;
      final shipmentData = await FirestoreService.getShipmentById(shipmentId);
      if (shipmentData != null) {
        shipment.value = shipmentData;
      } else {
        throw Exception('Shipment not found');
      }
    } catch (e) {
      print('Error loading shipment details: $e');
      _showErrorSnackbar('Failed to load shipment details');
    } finally {
      isLoading.value = false;
    }
  }

  void onMenuSelected(String value) {
    switch (value) {
      case 'track':
        trackShipment();
        break;
      case 'documents':
        viewAllDocuments();
        break;
      case 'support':
        Get.toNamed(Routes.SUPPORT, arguments: {
          'shipmentId': shipmentId,
          'shipment': shipment.value,
        });
        break;
    }
  }

  void shareShipment() {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    final shareText = '''
Shipment Details

ID: #${currentShipment.id.substring(0, 8)}
From: ${currentShipment.pickupLocation}
To: ${currentShipment.deliveryLocation}
Status: ${currentShipment.status.displayName}
Amount: ₹${currentShipment.totalAmount.toStringAsFixed(0)}
''';

    Get.snackbar(
      'Shared',
      'Shipment details copied to share',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void callDriver() async {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: currentShipment.driverPhone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Unable to make phone call');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to initiate call');
    }
  }

  void messageDriver() {
    final currentShipment = shipment.value;
    if (currentShipment == null) return;

    Get.toNamed(Routes.CHAT, arguments: {
      'recipientId': currentShipment.transporterId,
      'recipientName': currentShipment.driverName,
      'shipmentId': shipmentId,
    });
  }

  void trackShipment() {
    Get.toNamed(Routes.TRACK_SHIPMENT, parameters: {'id': shipmentId});
  }

  void reportIssue() {
    Get.toNamed(Routes.SUPPORT, arguments: {
      'issueType': 'shipment_issue',
      'shipmentId': shipmentId,
      'shipment': shipment.value,
    });
  }

  void rateExperience() {
    Get.toNamed(Routes.RATE_SHIPMENT, arguments: {
      'shipmentId': shipmentId,
      'shipment': shipment.value,
    });
  }

  void makePayment() {
    Get.toNamed(Routes.PAYMENTS, arguments: {
      'shipmentId': shipmentId,
      'amount': shipment.value?.totalAmount ?? 0,
    });
  }

  void viewAllDocuments() {
    final currentShipment = shipment.value;
    if (currentShipment == null || currentShipment.documents.isEmpty) {
      _showErrorSnackbar('No documents available');
      return;
    }

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
              'Shipment Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...currentShipment.documents.map((doc) => ListTile(
              leading: const Icon(Icons.description),
              title: Text(doc.split('/').last),
              trailing: const Icon(Icons.download),
              onTap: () => downloadDocument(doc),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void downloadDocuments() {
    _showSuccessSnackbar('Downloading all documents...');
  }

  void downloadDocument(String documentUrl) {
    _showSuccessSnackbar('Downloading document...');
  }

  void viewDocument(String documentUrl) {
    Get.toNamed(Routes.DELIVERY_PROOF, arguments: {
      'proofUrl': documentUrl,
      'shipmentId': shipmentId,
    });
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
}

class ShipmentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipmentDetailsController>(() => ShipmentDetailsController());
  }
}