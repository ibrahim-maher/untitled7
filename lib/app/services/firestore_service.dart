import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/LoadModel.dart';
import '../data/models/user_model.dart';
import '../controllers/home_controller.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String loadsCollection = 'loads';
  static const String shipmentsCollection = 'shipments';
  static const String bidsCollection = 'bids';
  static const String trackingCollection = 'tracking';
  static const String paymentsCollection = 'payments';
  static const String notificationsCollection = 'notifications';
  static const String supportTicketsCollection = 'support_tickets';
  static const String ratingsCollection = 'ratings';
  static const String driversCollection = 'drivers';

  // User operations
  static Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<bool> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .update(user.toMap());
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Load operations
  static Future<String?> createLoad(LoadModel load) async {
    try {
      final docRef = await _firestore
          .collection(loadsCollection)
          .add(load.toMap());

      // Update the load with the generated ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      print('Error creating load: $e');
      return null;
    }
  }

  static Future<List<LoadModel>> getUserLoads({int limit = 10}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(loadsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LoadModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user loads: $e');
      return [];
    }
  }

  static Future<List<LoadModel>> getAvailableLoads({
    String? location,
    LoadType? loadType,
    VehicleType? vehicleType,
    double? maxBudget,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(loadsCollection)
          .where('status', whereIn: [LoadStatus.posted.toString(), LoadStatus.bidding.toString()])
          .orderBy('createdAt', descending: true);

      if (location != null && location.isNotEmpty) {
        query = query.where('pickupLocation', isGreaterThanOrEqualTo: location)
            .where('pickupLocation', isLessThan: location + '\uf8ff');
      }

      if (loadType != null) {
        query = query.where('loadType', isEqualTo: loadType.toString());
      }

      if (vehicleType != null) {
        query = query.where('vehicleType', isEqualTo: vehicleType.toString());
      }

      if (maxBudget != null) {
        query = query.where('budget', isLessThanOrEqualTo: maxBudget);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs
          .map((doc) => LoadModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting available loads: $e');
      return [];
    }
  }

  // NEW: Added missing method
  static Future<LoadModel?> getLoad(String loadId) async {
    return await getLoadById(loadId);
  }

  static Future<LoadModel?> getLoadById(String loadId) async {
    try {
      final doc = await _firestore
          .collection(loadsCollection)
          .doc(loadId)
          .get();

      if (doc.exists) {
        return LoadModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting load by ID: $e');
      return null;
    }
  }

  static Future<bool> updateLoad(LoadModel load) async {
    try {
      await _firestore
          .collection(loadsCollection)
          .doc(load.id)
          .update(load.toMap());
      return true;
    } catch (e) {
      print('Error updating load: $e');
      return false;
    }
  }

  // NEW: Added missing method
  static Future<bool> updateLoadStatus(String loadId, LoadStatus status) async {
    try {
      await _firestore
          .collection(loadsCollection)
          .doc(loadId)
          .update({
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating load status: $e');
      return false;
    }
  }

  static Future<bool> deleteLoad(String loadId) async {
    try {
      await _firestore
          .collection(loadsCollection)
          .doc(loadId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting load: $e');
      return false;
    }
  }

  // Shipment operations
  static Future<List<ShipmentModel>> getUserShipments({int limit = 10}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(shipmentsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ShipmentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user shipments: $e');
      return [];
    }
  }

  static Future<List<ShipmentModel>> getActiveShipments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(shipmentsCollection)
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: [
        ShipmentStatus.pickup.toString(),
        ShipmentStatus.inTransit.toString(),
      ])
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ShipmentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting active shipments: $e');
      return [];
    }
  }

  static Future<ShipmentModel?> getShipmentById(String shipmentId) async {
    try {
      final doc = await _firestore
          .collection(shipmentsCollection)
          .doc(shipmentId)
          .get();

      if (doc.exists) {
        return ShipmentModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting shipment by ID: $e');
      return null;
    }
  }

  static Future<bool> updateShipmentStatus(String shipmentId, ShipmentStatus status) async {
    try {
      await _firestore
          .collection(shipmentsCollection)
          .doc(shipmentId)
          .update({
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating shipment status: $e');
      return false;
    }
  }

  // Bid operations
  static Future<String?> createBid(BidModel bid) async {
    try {
      final docRef = await _firestore
          .collection(bidsCollection)
          .add(bid.toMap());

      // Update the bid with the generated ID
      await docRef.update({'id': docRef.id});

      // Update load bids count
      await _updateLoadBidsCount(bid.loadId);

      return docRef.id;
    } catch (e) {
      print('Error creating bid: $e');
      return null;
    }
  }

  // NEW: Added method for submitting bids with Map data
  static Future<bool> submitBid(Map<String, dynamic> bidData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final bid = BidModel(
        id: '',
        loadId: bidData['loadId'],
        transporterId: user.uid,
        transporterName: user.displayName ?? 'Unknown',
        bidAmount: bidData['amount'].toDouble(),
        vehicleType: bidData['vehicleType'] ?? 'Truck',
        vehicleNumber: bidData['vehicleNumber'] ?? '',
        estimatedPickup: DateTime.now().add(const Duration(days: 1)),
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
        status: BidStatus.pending,
        notes: bidData['notes'] ?? '',
        createdAt: DateTime.now(),
      );

      final bidId = await createBid(bid);
      return bidId != null;
    } catch (e) {
      print('Error submitting bid: $e');
      return false;
    }
  }

  // NEW: Added method for withdrawing bids
  static Future<bool> withdrawBid(String bidId) async {
    try {
      await _firestore
          .collection(bidsCollection)
          .doc(bidId)
          .update({
        'status': BidStatus.cancelled.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error withdrawing bid: $e');
      return false;
    }
  }

  static Future<List<BidModel>> getLoadBids(String loadId) async {
    try {
      final snapshot = await _firestore
          .collection(bidsCollection)
          .where('loadId', isEqualTo: loadId)
          .orderBy('bidAmount')
          .get();

      return snapshot.docs
          .map((doc) => BidModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting load bids: $e');
      return [];
    }
  }

  static Future<List<BidModel>> getUserBids({int limit = 10}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(bidsCollection)
          .where('transporterId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => BidModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting user bids: $e');
      return [];
    }
  }

  // NEW: Get active bids for user
  static Future<List<BidModel>> getActiveBids() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(bidsCollection)
          .where('transporterId', isEqualTo: user.uid)
          .where('status', isEqualTo: BidStatus.pending.toString())
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BidModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting active bids: $e');
      return [];
    }
  }

  static Future<bool> acceptBid(String bidId, String loadId) async {
    try {
      final batch = _firestore.batch();

      // Update the accepted bid
      batch.update(
        _firestore.collection(bidsCollection).doc(bidId),
        {
          'status': BidStatus.accepted.toString(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Reject all other bids for this load
      final otherBids = await _firestore
          .collection(bidsCollection)
          .where('loadId', isEqualTo: loadId)
          .where('status', isEqualTo: BidStatus.pending.toString())
          .get();

      for (final doc in otherBids.docs) {
        if (doc.id != bidId) {
          batch.update(doc.reference, {
            'status': BidStatus.rejected.toString(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Update load status
      batch.update(
        _firestore.collection(loadsCollection).doc(loadId),
        {
          'status': LoadStatus.assigned.toString(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error accepting bid: $e');
      return false;
    }
  }

  // NEW: Accept bid with loadId lookup
  static Future<bool> acceptBidById(String bidId) async {
    try {
      final bidDoc = await _firestore.collection(bidsCollection).doc(bidId).get();
      if (!bidDoc.exists) return false;

      final bidData = bidDoc.data()!;
      final loadId = bidData['loadId'];

      return await acceptBid(bidId, loadId);
    } catch (e) {
      print('Error accepting bid by ID: $e');
      return false;
    }
  }

  static Future<bool> rejectBid(String bidId) async {
    try {
      await _firestore
          .collection(bidsCollection)
          .doc(bidId)
          .update({
        'status': BidStatus.rejected.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error rejecting bid: $e');
      return false;
    }
  }

  // NEW: Get load analytics
  static Future<LoadAnalytics?> getLoadAnalytics(String loadId) async {
    try {
      // This would typically come from an analytics collection
      // For now, return mock data
      return LoadAnalytics(
        views: 45,
        shares: 3,
        inquiries: 8,
        avgBidAmount: 35000.0,
        lastViewed: DateTime.now().subtract(const Duration(hours: 2)),
      );
    } catch (e) {
      print('Error getting load analytics: $e');
      return null;
    }
  }

  // Tracking operations
  static Future<bool> addTrackingUpdate(String shipmentId, TrackingUpdate update) async {
    try {
      await _firestore
          .collection(shipmentsCollection)
          .doc(shipmentId)
          .update({
        'trackingUpdates': FieldValue.arrayUnion([update.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding tracking update: $e');
      return false;
    }
  }

  static Stream<ShipmentModel?> trackShipment(String shipmentId) {
    return _firestore
        .collection(shipmentsCollection)
        .doc(shipmentId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ShipmentModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Statistics and Analytics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Get total shipments
      final totalShipmentsSnapshot = await _firestore
          .collection(shipmentsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      // Get active shipments
      final activeShipmentsSnapshot = await _firestore
          .collection(shipmentsCollection)
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: [
        ShipmentStatus.pickup.toString(),
        ShipmentStatus.inTransit.toString(),
      ])
          .get();

      // Get completed shipments
      final completedShipmentsSnapshot = await _firestore
          .collection(shipmentsCollection)
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: ShipmentStatus.delivered.toString())
          .get();

      // Get total loads
      final totalLoadsSnapshot = await _firestore
          .collection(loadsCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      // Get active bids
      final activeBidsSnapshot = await _firestore
          .collection(bidsCollection)
          .where('transporterId', isEqualTo: user.uid)
          .where('status', isEqualTo: BidStatus.pending.toString())
          .get();

      // Get pending bids
      final pendingBidsSnapshot = await _firestore
          .collection(bidsCollection)
          .where('transporterId', isEqualTo: user.uid)
          .where('status', isEqualTo: BidStatus.pending.toString())
          .get();

      // Get monthly expenses (simplified - you might want to calculate this differently)
      final monthlyPaymentsSnapshot = await _firestore
          .collection(paymentsCollection)
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('status', isEqualTo: 'completed')
          .get();

      double totalSavings = 0;
      for (final doc in monthlyPaymentsSnapshot.docs) {
        final data = doc.data();
        totalSavings += (data['amount'] ?? 0).toDouble();
      }

      return {
        'totalShipments': totalShipmentsSnapshot.size,
        'activeShipments': activeShipmentsSnapshot.size,
        'completedShipments': completedShipmentsSnapshot.size,
        'totalSavings': totalSavings,
        'monthlyShipments': 0, // You can add more specific calculations
        'averageRating': 4.5, // Calculate from feedback collection
        'totalLoads': totalLoadsSnapshot.size, // NEW
        'activeBids': activeBidsSnapshot.size, // NEW
        'pendingBids': pendingBidsSnapshot.size, // NEW
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({int limit = 20}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Search functionality
  static Future<List<LoadModel>> searchLoads(String query) async {
    try {
      // For better search, consider using Algolia or similar service
      // This is a simple implementation
      final snapshot = await _firestore
          .collection(loadsCollection)
          .where('status', whereIn: [LoadStatus.posted.toString(), LoadStatus.bidding.toString()])
          .get();

      final loads = snapshot.docs
          .map((doc) => LoadModel.fromMap(doc.data()))
          .where((load) =>
      load.title.toLowerCase().contains(query.toLowerCase()) ||
          load.pickupLocation.toLowerCase().contains(query.toLowerCase()) ||
          load.deliveryLocation.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return loads;
    } catch (e) {
      print('Error searching loads: $e');
      return [];
    }
  }

  // Helper methods
  static Future<void> _updateLoadBidsCount(String loadId) async {
    try {
      final bidsSnapshot = await _firestore
          .collection(bidsCollection)
          .where('loadId', isEqualTo: loadId)
          .get();

      await _firestore
          .collection(loadsCollection)
          .doc(loadId)
          .update({'bidsCount': bidsSnapshot.size});
    } catch (e) {
      print('Error updating load bids count: $e');
    }
  }

  // Real-time streams
  static Stream<List<LoadModel>> getUserLoadsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(loadsCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => LoadModel.fromMap(doc.data())).toList());
  }

  static Stream<List<ShipmentModel>> getActiveShipmentsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(shipmentsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: [
      ShipmentStatus.pickup.toString(),
      ShipmentStatus.inTransit.toString(),
    ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ShipmentModel.fromMap(doc.data())).toList());
  }

  // NEW: Get active bids stream
  static Stream<List<BidModel>> getActiveBidsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(bidsCollection)
        .where('transporterId', isEqualTo: user.uid)
        .where('status', isEqualTo: BidStatus.pending.toString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => BidModel.fromMap(doc.data())).toList());
  }

  // NEW: Get load stream
  static Stream<LoadModel?> getLoadStream(String loadId) {
    return _firestore
        .collection(loadsCollection)
        .doc(loadId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return LoadModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  static Stream<List<BidModel>> getLoadBidsStream(String loadId) {
    return _firestore
        .collection(bidsCollection)
        .where('loadId', isEqualTo: loadId)
        .orderBy('bidAmount')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => BidModel.fromMap(doc.data())).toList());
  }

  // Batch operations for better performance
  static Future<bool> batchUpdateShipments(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();

      for (final update in updates) {
        final docRef = _firestore.collection(shipmentsCollection).doc(update['id']);
        batch.update(docRef, update['data']);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error in batch update: $e');
      return false;
    }
  }

  // Pagination support
  static Future<List<LoadModel>> getLoadsPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(loadsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => LoadModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting paginated loads: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getDriverRatings(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection(ratingsCollection)
          .where('driverId', isEqualTo: driverId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalRatings': 0,
          'ratingBreakdown': {
            '5': 0,
            '4': 0,
            '3': 0,
            '2': 0,
            '1': 0,
          },
        };
      }

      double totalRating = 0;
      Map<String, int> breakdown = {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final driverRating = (data['driverRating'] ?? 0).toDouble();
        totalRating += driverRating;

        final ratingKey = driverRating.toInt().toString();
        if (breakdown.containsKey(ratingKey)) {
          breakdown[ratingKey] = breakdown[ratingKey]! + 1;
        }
      }

      return {
        'averageRating': totalRating / snapshot.docs.length,
        'totalRatings': snapshot.docs.length,
        'ratingBreakdown': breakdown,
      };
    } catch (e) {
      print('Error getting driver ratings: $e');
      return {
        'averageRating': 0.0,
        'totalRatings': 0,
        'ratingBreakdown': {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
      };
    }
  }

  static Future<bool> updateDriverRating(String driverId, double newRating) async {
    try {
      // Get current driver data
      final driverDoc = await _firestore
          .collection(driversCollection)
          .doc(driverId)
          .get();

      if (!driverDoc.exists) {
        // Create driver profile if doesn't exist
        await _firestore
            .collection(driversCollection)
            .doc(driverId)
            .set({
          'id': driverId,
          'averageRating': newRating,
          'totalRatings': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }

      final currentData = driverDoc.data()!;
      final currentAverage = (currentData['averageRating'] ?? 0.0).toDouble();
      final currentTotal = (currentData['totalRatings'] ?? 0).toInt();

      // Calculate new average
      final newTotal = currentTotal + 1;
      final newAverage = ((currentAverage * currentTotal) + newRating) / newTotal;

      await _firestore
          .collection(driversCollection)
          .doc(driverId)
          .update({
        'averageRating': newAverage,
        'totalRatings': newTotal,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating driver rating: $e');
      return false;
    }
  }

  static Future<bool> saveShipmentRating(Map<String, dynamic> ratingData) async {
    try {
      final docRef = await _firestore
          .collection(ratingsCollection)
          .add({
        ...ratingData,
        'id': '', // Will be updated below
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update with the generated ID
      await docRef.update({'id': docRef.id});

      return true;
    } catch (e) {
      print('Error saving shipment rating: $e');
      return false;
    }
  }

  static Stream<List<ShipmentModel>> getUserShipmentsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(shipmentsCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ShipmentModel.fromMap(doc.data())).toList());
  }

  static Future<bool> updateShipment(String shipmentId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(shipmentsCollection)
          .doc(shipmentId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating shipment: $e');
      return false;
    }
  }
}

// NEW: LoadAnalytics model for analytics data
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