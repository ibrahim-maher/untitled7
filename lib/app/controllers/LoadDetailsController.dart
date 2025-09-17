// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../data/models/LoadModel.dart';
//
// class LoadDetailsController extends GetxController {
//   // Observable variables
//   var isLoading = false.obs;
//   var load = Rxn<LoadModel>();
//   var bids = <Map<String, dynamic>>[].obs;
//   var canDeleteLoad = false.obs;
//
//   // Load ID from route parameters
//   String get loadId => Get.parameters['id'] ?? Get.arguments?['loadId'] ?? '';
//
//   @override
//   void onInit() {
//     super.onInit();
//     _loadData();
//   }
//
//   void _loadData() async {
//     if (loadId.isEmpty) {
//       _showErrorSnackbar('Load ID not provided');
//       Get.back();
//       return;
//     }
//
//     try {
//       isLoading.value = true;
//
//       // Load the load details
//       await _loadLoadDetails();
//
//       // Load bids if load is active
//       if (load.value?.status == LoadStatus.active) {
//         await _loadBids();
//       }
//
//       // Check if user can delete load
//       _checkDeletePermission();
//
//     } catch (e) {
//       print('Error loading load details: $e');
//       _showErrorSnackbar('Failed to load load details');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _loadLoadDetails() async {
//     try {
//       // In production, load from Firestore
//       // For now, create mock data based on loadId
//       await Future.delayed(const Duration(seconds: 1));
//
//       final mockLoad = LoadModel(
//         id: loadId,
//         userId: 'current_user_id',
//         materialType: 'Electronics',
//         weight: 2500.0,
//         length: 8.0,
//         width: 6.0,
//         height: 4.0,
//         pickupLocation: 'Mumbai, Maharashtra',
//         deliveryLocation: 'Delhi, India',
//         pickupDate: DateTime.now().add(const Duration(days: 2)),
//         deliveryDate: DateTime.now().add(const Duration(days: 5)),
//         vehicleType: 'Truck (10-Wheeler)',
//         budget: 45000.0,
//         description: 'Electronic goods shipment - handle with care',
//         status: LoadStatus.active,
//         loadType: LoadType.fullLoad,
//         distance: 1200.0,
//         specialRequirements: ['Temperature Controlled', 'GPS Tracking', 'Insurance Required'],
//         insuranceRequired: true,
//         loadingHelp: true,
//         isFragile: true,
//         contactPerson: 'Rajesh Kumar',
//         contactPhone: '+91 98765 43210',
//         paymentTerms: 'Net 30 days',
//         routeType: 'Highway',
//         createdAt: DateTime.now().subtract(const Duration(days: 1)),
//         updatedAt: DateTime.now(),
//       );
//
//       load.value = mockLoad;
//     } catch (e) {
//       throw Exception('Failed to load load details: $e');
//     }
//   }
//
//   Future<void> _loadBids() async {
//     try {
//       // In production, load actual bids from Firestore
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       final mockBids = [
//         {
//           'id': 'bid_001',
//           'transporterId': 'trans_001',
//           'transporterName': 'Swift Logistics',
//           'vehicleType': 'Truck (10-Wheeler)',
//           'amount': 42000,
//           'rating': 4.8,
//           'estimatedDelivery': '3 days',
//           'submittedAt': DateTime.now().subtract(const Duration(hours: 2)),
//         },
//         {
//           'id': 'bid_002',
//           'transporterId': 'trans_002',
//           'transporterName': 'Express Movers',
//           'vehicleType': 'Truck (12-Wheeler)',
//           'amount': 44000,
//           'rating': 4.6,
//           'estimatedDelivery': '4 days',
//           'submittedAt': DateTime.now().subtract(const Duration(hours: 1)),
//         },
//         {
//           'id': 'bid_003',
//           'transporterId': 'trans_003',
//           'transporterName': 'Metro Transport',
//           'vehicleType': 'Truck (10-Wheeler)',
//           'amount': 43500,
//           'rating': 4.7,
//           'estimatedDelivery': '3 days',
//           'submittedAt': DateTime.now().subtract(const Duration(minutes: 30)),
//         },
//       ];
//
//       bids.assignAll(mockBids);
//     } catch (e) {
//       print('Error loading bids: $e');
//     }
//   }
//
//   void _checkDeletePermission() {
//     final currentLoad = load.value;
//     if (currentLoad == null) return;
//
//     // Can delete if load is not yet assigned or completed
//     canDeleteLoad.value = currentLoad.status == LoadStatus.active ||
//         currentLoad.status == LoadStatus.paused;
//   }
//
//   // Menu actions
//   void onMenuSelected(String value) {
//     switch (value) {
//       case 'edit':
//         editLoad();
//         break;
//       case 'duplicate':
//         duplicateLoad();
//         break;
//       case 'share':
//         shareLoad();
//         break;
//       case 'delete':
//         _confirmDeleteLoad();
//         break;
//     }
//   }
//
//   // Load management actions
//   void editLoad() {
//     if (load.value == null) return;
//
//     Get.toNamed(Routes.POST_LOAD, arguments: {
//       'mode': 'edit',
//       'load': load.value,
//     });
//   }
//
//   void duplicateLoad() async {
//     if (load.value == null) return;
//
//     try {
//       // Show loading
//       _showInfoSnackbar('Creating duplicate load...');
//
//       // In production, create a copy in Firestore
//       await Future.delayed(const Duration(seconds: 1));
//
//       _showSuccessSnackbar('Load duplicated successfully');
//
//       // Navigate to the new load or edit screen
//       Get.toNamed(Routes.POST_LOAD, arguments: {
//         'mode': 'duplicate',
//         'originalLoad': load.value,
//       });
//     } catch (e) {
//       _showErrorSnackbar('Failed to duplicate load');
//     }
//   }
//
//   void shareLoad() {
//     if (load.value == null) return;
//
//     final currentLoad = load.value!;
//     final shareText = '''
// Load Available for Transport
//
// Material: ${currentLoad.materialType}
// Weight: ${currentLoad.weight} kg
// Route: ${currentLoad.pickupLocation} → ${currentLoad.deliveryLocation}
// Budget: ₹${currentLoad.budget}
// Pickup Date: ${currentLoad.pickupDate.day}/${currentLoad.pickupDate.month}/${currentLoad.pickupDate.year}
//
// Contact: ${currentLoad.contactPerson}
// Phone: ${currentLoad.contactPhone}
//
// Download FreightFlow App to bid on this load.
// ''';
//
//     // In production, use share_plus package
//     _showInfoSnackbar('Share functionality would open here');
//     print('Share text: $shareText');
//   }
//
//   void _confirmDeleteLoad() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Delete Load'),
//         content: const Text(
//           'Are you sure you want to delete this load? This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               _deleteLoad();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _deleteLoad() async {
//     try {
//       _showInfoSnackbar('Deleting load...');
//
//       // In production, delete from Firestore
//       await Future.delayed(const Duration(seconds: 1));
//
//       _showSuccessSnackbar('Load deleted successfully');
//       Get.back(); // Return to previous screen
//     } catch (e) {
//       _showErrorSnackbar('Failed to delete load');
//     }
//   }
//
//   // Load status management
//   void pauseLoad() async {
//     if (load.value == null) return;
//
//     try {
//       _showInfoSnackbar('Pausing load...');
//
//       // In production, update status in Firestore
//       await Future.delayed(const Duration(seconds: 1));
//
//       load.value = load.value!.copyWith(status: LoadStatus.paused);
//       _checkDeletePermission();
//
//       _showSuccessSnackbar('Load paused successfully');
//     } catch (e) {
//       _showErrorSnackbar('Failed to pause load');
//     }
//   }
//
//   void activateLoad() async {
//     if (load.value == null) return;
//
//     try {
//       _showInfoSnackbar('Activating load...');
//
//       // In production, update status in Firestore
//       await Future.delayed(const Duration(seconds: 1));
//
//       load.value = load.value!.copyWith(status: LoadStatus.active);
//       _checkDeletePermission();
//
//       _showSuccessSnackbar('Load activated successfully');
//     } catch (e) {
//       _showErrorSnackbar('Failed to activate load');
//     }
//   }
//
//   void closeLoad() async {
//     if (load.value == null) return;
//
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Mark Load as Complete'),
//         content: const Text(
//           'Are you sure you want to mark this load as complete? This will close the load for new bids.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               _completeLoad();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             child: const Text('Complete', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _completeLoad() async {
//     try {
//       _showInfoSnackbar('Marking load as complete...');
//
//       // In production, update status in Firestore
//       await Future.delayed(const Duration(seconds: 1));
//
//       load.value = load.value!.copyWith(status: LoadStatus.completed);
//       _checkDeletePermission();
//
//       _showSuccessSnackbar('Load marked as complete');
//     } catch (e) {
//       _showErrorSnackbar('Failed to complete load');
//     }
//   }
//
//   // Contact and communication
//   void callContactPerson() async {
//     final currentLoad = load.value;
//     if (currentLoad == null || currentLoad.contactPhone.isEmpty) {
//       _showErrorSnackbar('Contact phone number not available');
//       return;
//     }
//
//     try {
//       final Uri phoneUri = Uri(scheme: 'tel', path: currentLoad.contactPhone);
//       if (await canLaunchUrl(phoneUri)) {
//         await launchUrl(phoneUri);
//       } else {
//         _showErrorSnackbar('Unable to make phone call');
//       }
//     } catch (e) {
//       _showErrorSnackbar('Failed to initiate call');
//     }
//   }
//
//   // Bid management
//   void viewAllBids() {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.8,
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'All Bids',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${bids.length} bids received',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: bids.length,
//                 itemBuilder: (context, index) {
//                   final bid = bids[index];
//                   return _buildDetailedBidItem(bid, index);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailedBidItem(Map<String, dynamic> bid, int index) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       child: ListTile(
//         leading: CircleAvatar(
//           child: Text('${index + 1}'),
//         ),
//         title: Text(bid['transporterName']),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${bid['rating']} ⭐ • ${bid['vehicleType']}'),
//             Text('ETA: ${bid['estimatedDelivery']}'),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               '₹${bid['amount']}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             TextButton(
//               onPressed: () => _acceptBid(bid),
//               child: const Text('Accept'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _acceptBid(Map<String, dynamic> bid) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Accept Bid'),
//         content: Text(
//           'Do you want to accept the bid from ${bid['transporterName']} for ₹${bid['amount']}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               _processBidAcceptance(bid);
//             },
//             child: const Text('Accept Bid'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _processBidAcceptance(Map<String, dynamic> bid) async {
//     try {
//       _showInfoSnackbar('Processing bid acceptance...');
//
//       // In production, create shipment and update load status
//       await Future.delayed(const Duration(seconds: 2));
//
//       _showSuccessSnackbar('Bid accepted! Shipment created.');
//
//       // Navigate to shipment tracking or details
//       Get.toNamed(Routes.SHIPMENTS);
//     } catch (e) {
//       _showErrorSnackbar('Failed to accept bid');
//     }
//   }
//
//   // Analytics and insights
//   void viewAnalytics() {
//     Get.bottomSheet(
//       Container(
//         height: Get.height * 0.6,
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             const Text(
//               'Load Analytics',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Column(
//                 children: [
//                   _buildAnalyticsItem('Views', '${(bids.length * 3 + 15)}', Icons.visibility),
//                   _buildAnalyticsItem('Bids Received', '${bids.length}', Icons.gavel),
//                   _buildAnalyticsItem('Average Bid', '₹${_calculateAverageBid()}', Icons.trending_up),
//                   _buildAnalyticsItem('Days Active', '${DateTime.now().difference(load.value?.createdAt ?? DateTime.now()).inDays}', Icons.calendar_today),
//                   _buildAnalyticsItem('Response Rate', '${((bids.length / (bids.length * 3 + 15)) * 100).toStringAsFixed(1)}%', Icons.percent),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnalyticsItem(String label, String value, IconData icon) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.blue[600]),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _calculateAverageBid() {
//     if (bids.isEmpty) return '0';
//
//     final total = bids.fold<double>(0, (sum, bid) => sum + bid['amount']);
//     return (total / bids.length).toStringAsFixed(0);
//   }
//
//   // Helper methods
//   void _showErrorSnackbar(String message) {
//     Get.snackbar(
//       'Error',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red[100],
//       colorText: Colors.red[700],
//       icon: const Icon(Icons.error, color: Colors.red),
//     );
//   }
//
//   void _showSuccessSnackbar(String message) {
//     Get.snackbar(
//       'Success',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green[100],
//       colorText: Colors.green[700],
//       icon: const Icon(Icons.check_circle, color: Colors.green),
//     );
//   }
//
//   void _showInfoSnackbar(String message) {
//     Get.snackbar(
//       'Info',
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.blue[100],
//       colorText: Colors.blue[700],
//       icon: const Icon(Icons.info, color: Colors.blue),
//     );
//   }
// }