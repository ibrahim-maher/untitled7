import 'package:cloud_firestore/cloud_firestore.dart';

class LoadModel {
  final String id;
  final String userId; // Owner of the load
  final String title;
  final String pickupLocation;
  final String deliveryLocation;
  final LoadType loadType;
  final double weight;
  final String dimensions;
  final VehicleType vehicleType;
  final double budget;
  final DateTime pickupDate;
  final DateTime? deliveryDate;
  final LoadStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int bidsCount;
  final String? description;
  final List<String> requirements;
  final String? contactPerson;
  final String? contactPhone;
  final bool isUrgent;
  final double? distance;
  final Map<String, double>? pickupCoordinates; // {lat: 0.0, lng: 0.0}
  final Map<String, double>? deliveryCoordinates;
  final double? minBudget;
  final double? maxBudget;
  final String? specialInstructions;
  final List<String> images; // URLs to load images
  final bool isActive;

  LoadModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.loadType,
    required this.weight,
    required this.dimensions,
    required this.vehicleType,
    required this.budget,
    required this.pickupDate,
    this.deliveryDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.bidsCount = 0,
    this.description,
    this.requirements = const [],
    this.contactPerson,
    this.contactPhone,
    this.isUrgent = false,
    this.distance,
    this.pickupCoordinates,
    this.deliveryCoordinates,
    this.minBudget,
    this.maxBudget,
    this.specialInstructions,
    this.images = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'loadType': loadType.toString(),
      'weight': weight,
      'dimensions': dimensions,
      'vehicleType': vehicleType.toString(),
      'budget': budget,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'bidsCount': bidsCount,
      'description': description,
      'requirements': requirements,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'isUrgent': isUrgent,
      'distance': distance,
      'pickupCoordinates': pickupCoordinates,
      'deliveryCoordinates': deliveryCoordinates,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'specialInstructions': specialInstructions,
      'images': images,
      'isActive': isActive,
    };
  }

  factory LoadModel.fromMap(Map<String, dynamic> map) {
    return LoadModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      deliveryLocation: map['deliveryLocation'] ?? '',
      loadType: LoadType.values.firstWhere(
            (e) => e.toString() == map['loadType'],
        orElse: () => LoadType.general,
      ),
      weight: (map['weight'] ?? 0).toDouble(),
      dimensions: map['dimensions'] ?? '',
      vehicleType: VehicleType.values.firstWhere(
            (e) => e.toString() == map['vehicleType'],
        orElse: () => VehicleType.truck,
      ),
      budget: (map['budget'] ?? 0).toDouble(),
      pickupDate: (map['pickupDate'] as Timestamp).toDate(),
      deliveryDate: map['deliveryDate'] != null
          ? (map['deliveryDate'] as Timestamp).toDate()
          : null,
      status: LoadStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => LoadStatus.posted,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      bidsCount: map['bidsCount'] ?? 0,
      description: map['description'],
      requirements: List<String>.from(map['requirements'] ?? []),
      contactPerson: map['contactPerson'],
      contactPhone: map['contactPhone'],
      isUrgent: map['isUrgent'] ?? false,
      distance: map['distance']?.toDouble(),
      pickupCoordinates: map['pickupCoordinates'] != null
          ? Map<String, double>.from(map['pickupCoordinates'])
          : null,
      deliveryCoordinates: map['deliveryCoordinates'] != null
          ? Map<String, double>.from(map['deliveryCoordinates'])
          : null,
      minBudget: map['minBudget']?.toDouble(),
      maxBudget: map['maxBudget']?.toDouble(),
      specialInstructions: map['specialInstructions'],
      images: List<String>.from(map['images'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  LoadModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? pickupLocation,
    String? deliveryLocation,
    LoadType? loadType,
    double? weight,
    String? dimensions,
    VehicleType? vehicleType,
    double? budget,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    LoadStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? bidsCount,
    String? description,
    List<String>? requirements,
    String? contactPerson,
    String? contactPhone,
    bool? isUrgent,
    double? distance,
    Map<String, double>? pickupCoordinates,
    Map<String, double>? deliveryCoordinates,
    double? minBudget,
    double? maxBudget,
    String? specialInstructions,
    List<String>? images,
    bool? isActive,
  }) {
    return LoadModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      loadType: loadType ?? this.loadType,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      vehicleType: vehicleType ?? this.vehicleType,
      budget: budget ?? this.budget,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bidsCount: bidsCount ?? this.bidsCount,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      isUrgent: isUrgent ?? this.isUrgent,
      distance: distance ?? this.distance,
      pickupCoordinates: pickupCoordinates ?? this.pickupCoordinates,
      deliveryCoordinates: deliveryCoordinates ?? this.deliveryCoordinates,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Enums
enum ShipmentStatus {
  pending,
  confirmed,
  pickedUp,
  inTransit,
  delivered,
  pickup,
  loaded,
  accepted,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ShipmentStatus.pending:
        return 'Pending';
      case ShipmentStatus.confirmed:
        return 'Confirmed';
      case ShipmentStatus.accepted:
        return 'Accepted';
      case ShipmentStatus.pickup:
        return 'Pickup Scheduled';
      case ShipmentStatus.pickedUp:
        return 'Picked Up';
      case ShipmentStatus.loaded:
        return 'Loaded';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.completed:
        return 'Completed';
      case ShipmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentStatus {
  pending,
  partial,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// Tracking Update Model
class TrackingUpdate {
  final String id;
  final ShipmentStatus status;
  final String location;
  final String description;
  final DateTime timestamp;
  final Map<String, double>? coordinates;
  final List<String> photos;

  TrackingUpdate({
    required this.id,
    required this.status,
    required this.location,
    required this.description,
    required this.timestamp,
    this.coordinates,
    this.photos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.toString(),
      'location': location,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'coordinates': coordinates,
      'photos': photos,
    };
  }

  factory TrackingUpdate.fromMap(Map<String, dynamic> map) {
    return TrackingUpdate(
      id: map['id'] ?? '',
      status: ShipmentStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => ShipmentStatus.pending,
      ),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      coordinates: map['coordinates'] != null
          ? Map<String, double>.from(map['coordinates'])
          : null,
      photos: List<String>.from(map['photos'] ?? []),
    );
  }
}

// Main Shipment Model
class ShipmentModel {
  final String id;
  final String loadId;
  final String userId; // Customer/Load owner
  final String transporterId; // Transporter
  final ShipmentStatus status;
  final String pickupLocation;
  final String deliveryLocation;
  final String driverName;
  final String driverPhone;
  final String? driverPhotoUrl;
  final String vehicleNumber;
  final String vehicleType;
  final DateTime? estimatedPickup;
  final DateTime? actualPickup;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final List<TrackingUpdate> trackingUpdates;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final String? notes;
  final List<String> documents; // URLs to documents
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, double>? currentLocation; // Current GPS location
  final String? currentAddress;
  final double? completionPercentage;
  final List<String> photos; // Photo updates during transport
  final String? cancellationReason;
  final double? customerRating;
  final double? transporterRating;
  final String? customerFeedback;
  final String? transporterFeedback;

  ShipmentModel({
    required this.id,
    required this.loadId,
    required this.userId,
    required this.transporterId,
    required this.status,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.driverName,
    required this.driverPhone,
    this.driverPhotoUrl,
    required this.vehicleNumber,
    required this.vehicleType,
    this.estimatedPickup,
    this.actualPickup,
    this.estimatedDelivery,
    this.actualDelivery,
    this.trackingUpdates = const [],
    required this.totalAmount,
    required this.paymentStatus,
    this.notes,
    this.documents = const [],
    required this.createdAt,
    this.updatedAt,
    this.currentLocation,
    this.currentAddress,
    this.completionPercentage,
    this.photos = const [],
    this.cancellationReason,
    this.customerRating,
    this.transporterRating,
    this.customerFeedback,
    this.transporterFeedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loadId': loadId,
      'userId': userId,
      'transporterId': transporterId,
      'status': status.toString(),
      'pickupLocation': pickupLocation,
      'deliveryLocation': deliveryLocation,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverPhotoUrl': driverPhotoUrl,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'estimatedPickup': estimatedPickup != null ? Timestamp.fromDate(estimatedPickup!) : null,
      'actualPickup': actualPickup != null ? Timestamp.fromDate(actualPickup!) : null,
      'estimatedDelivery': estimatedDelivery != null ? Timestamp.fromDate(estimatedDelivery!) : null,
      'actualDelivery': actualDelivery != null ? Timestamp.fromDate(actualDelivery!) : null,
      'trackingUpdates': trackingUpdates.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus.toString(),
      'notes': notes,
      'documents': documents,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'currentLocation': currentLocation,
      'currentAddress': currentAddress,
      'completionPercentage': completionPercentage,
      'photos': photos,
      'cancellationReason': cancellationReason,
      'customerRating': customerRating,
      'transporterRating': transporterRating,
      'customerFeedback': customerFeedback,
      'transporterFeedback': transporterFeedback,
    };
  }

  factory ShipmentModel.fromMap(Map<String, dynamic> map) {
    return ShipmentModel(
      id: map['id'] ?? '',
      loadId: map['loadId'] ?? '',
      userId: map['userId'] ?? '',
      transporterId: map['transporterId'] ?? '',
      status: ShipmentStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => ShipmentStatus.pending,
      ),
      pickupLocation: map['pickupLocation'] ?? '',
      deliveryLocation: map['deliveryLocation'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      driverPhotoUrl: map['driverPhotoUrl'],
      vehicleNumber: map['vehicleNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      estimatedPickup: map['estimatedPickup'] != null
          ? (map['estimatedPickup'] as Timestamp).toDate()
          : null,
      actualPickup: map['actualPickup'] != null
          ? (map['actualPickup'] as Timestamp).toDate()
          : null,
      estimatedDelivery: map['estimatedDelivery'] != null
          ? (map['estimatedDelivery'] as Timestamp).toDate()
          : null,
      actualDelivery: map['actualDelivery'] != null
          ? (map['actualDelivery'] as Timestamp).toDate()
          : null,
      trackingUpdates: (map['trackingUpdates'] as List<dynamic>?)
          ?.map((e) => TrackingUpdate.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
            (e) => e.toString() == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      notes: map['notes'],
      documents: List<String>.from(map['documents'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      currentLocation: map['currentLocation'] != null
          ? Map<String, double>.from(map['currentLocation'])
          : null,
      currentAddress: map['currentAddress'],
      completionPercentage: map['completionPercentage']?.toDouble(),
      photos: List<String>.from(map['photos'] ?? []),
      cancellationReason: map['cancellationReason'],
      customerRating: map['customerRating']?.toDouble(),
      transporterRating: map['transporterRating']?.toDouble(),
      customerFeedback: map['customerFeedback'],
      transporterFeedback: map['transporterFeedback'],
    );
  }
}

class BidModel {
  final String id;
  final String loadId;
  final String transporterId;
  final String transporterName;
  final String? transporterPhotoUrl;
  final double bidAmount;
  final String vehicleType;
  final String vehicleNumber;
  final DateTime estimatedPickup;
  final DateTime estimatedDelivery;
  final BidStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double transporterRating;
  final int completedTrips;
  final List<String> vehiclePhotos;
  final String? licenseNumber;
  final String? insuranceDetails;
  final double? negotiatedAmount;
  final String? rejectionReason;
  final bool isCounterOffer;
  final String? additionalServices; // Insurance, loading/unloading, etc.

  BidModel({
    required this.id,
    required this.loadId,
    required this.transporterId,
    required this.transporterName,
    this.transporterPhotoUrl,
    required this.bidAmount,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.estimatedPickup,
    required this.estimatedDelivery,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.transporterRating = 0.0,
    this.completedTrips = 0,
    this.vehiclePhotos = const [],
    this.licenseNumber,
    this.insuranceDetails,
    this.negotiatedAmount,
    this.rejectionReason,
    this.isCounterOffer = false,
    this.additionalServices,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loadId': loadId,
      'transporterId': transporterId,
      'transporterName': transporterName,
      'transporterPhotoUrl': transporterPhotoUrl,
      'bidAmount': bidAmount,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'estimatedPickup': Timestamp.fromDate(estimatedPickup),
      'estimatedDelivery': Timestamp.fromDate(estimatedDelivery),
      'status': status.toString(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'transporterRating': transporterRating,
      'completedTrips': completedTrips,
      'vehiclePhotos': vehiclePhotos,
      'licenseNumber': licenseNumber,
      'insuranceDetails': insuranceDetails,
      'negotiatedAmount': negotiatedAmount,
      'rejectionReason': rejectionReason,
      'isCounterOffer': isCounterOffer,
      'additionalServices': additionalServices,
    };
  }

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'] ?? '',
      loadId: map['loadId'] ?? '',
      transporterId: map['transporterId'] ?? '',
      transporterName: map['transporterName'] ?? '',
      transporterPhotoUrl: map['transporterPhotoUrl'],
      bidAmount: (map['bidAmount'] ?? 0).toDouble(),
      vehicleType: map['vehicleType'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      estimatedPickup: (map['estimatedPickup'] as Timestamp).toDate(),
      estimatedDelivery: (map['estimatedDelivery'] as Timestamp).toDate(),
      status: BidStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => BidStatus.pending,
      ),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      transporterRating: (map['transporterRating'] ?? 0).toDouble(),
      completedTrips: map['completedTrips'] ?? 0,
      vehiclePhotos: List<String>.from(map['vehiclePhotos'] ?? []),
      licenseNumber: map['licenseNumber'],
      insuranceDetails: map['insuranceDetails'],
      negotiatedAmount: map['negotiatedAmount']?.toDouble(),
      rejectionReason: map['rejectionReason'],
      isCounterOffer: map['isCounterOffer'] ?? false,
      additionalServices: map['additionalServices'],
    );
  }
}

// Enhanced UserModel for freight transport
class UserModelExtended {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserType userType; // Customer or Transporter
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final String? panNumber;
  final bool isVerified;
  final double rating;
  final int totalTrips;
  final List<String> documents; // KYC documents
  final Map<String, dynamic>? preferences;
  final bool isOnline; // For transporters
  final DateTime? lastActive;

  UserModelExtended({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    required this.userType,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.gstNumber,
    this.panNumber,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.documents = const [],
    this.preferences,
    this.isOnline = false,
    this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'userType': userType.toString(),
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'gstNumber': gstNumber,
      'panNumber': panNumber,
      'isVerified': isVerified,
      'rating': rating,
      'totalTrips': totalTrips,
      'documents': documents,
      'preferences': preferences,
      'isOnline': isOnline,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }

  factory UserModelExtended.fromMap(Map<String, dynamic> map) {
    return UserModelExtended(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      userType: UserType.values.firstWhere(
            (e) => e.toString() == map['userType'],
        orElse: () => UserType.customer,
      ),
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      pincode: map['pincode'],
      gstNumber: map['gstNumber'],
      panNumber: map['panNumber'],
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      totalTrips: map['totalTrips'] ?? 0,
      documents: List<String>.from(map['documents'] ?? []),
      preferences: map['preferences'],
      isOnline: map['isOnline'] ?? false,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
    );
  }
}

// Enums
enum LoadType {
  general,
  electronics,
  furniture,
  automotive,
  food,
  pharmaceutical,
  textile,
  chemical,
  construction,
  agriculture,
  hazardous,
  fragile,
  refrigerated,
  liquid,
  documents,
}

enum VehicleType {
  miniTruck,
  truck,
  lorry,
  container,
  trailer,
  tempo,
  pickup,
  bike,
  auto,
  van,
  refrigeratedTruck,
  tanker,
}

enum LoadStatus {
  posted,
  bidding,
  assigned,
  inProgress,
  completed,
  cancelled,
  expired, draft, active,
}


enum BidStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  expired,
  negotiating,
}



enum UserType {
  customer,
  transporter,
  admin,
  agent,
}

// Extension methods for better UI display
extension LoadTypeExtension on LoadType {
  String get displayName {
    switch (this) {
      case LoadType.general:
        return 'General Goods';
      case LoadType.electronics:
        return 'Electronics';
      case LoadType.furniture:
        return 'Furniture';
      case LoadType.automotive:
        return 'Automotive Parts';
      case LoadType.food:
        return 'Food & Beverages';
      case LoadType.pharmaceutical:
        return 'Pharmaceutical';
      case LoadType.textile:
        return 'Textile';
      case LoadType.chemical:
        return 'Chemical';
      case LoadType.construction:
        return 'Construction Material';
      case LoadType.agriculture:
        return 'Agriculture Products';
      case LoadType.hazardous:
        return 'Hazardous Materials';
      case LoadType.fragile:
        return 'Fragile Items';
      case LoadType.refrigerated:
        return 'Refrigerated Goods';
      case LoadType.liquid:
        return 'Liquid Materials';
      case LoadType.documents:
        return 'Documents';
    }
  }

  String get icon {
    switch (this) {
      case LoadType.general:
        return '📦';
      case LoadType.electronics:
        return '🔌';
      case LoadType.furniture:
        return '🪑';
      case LoadType.automotive:
        return '🚗';
      case LoadType.food:
        return '🍎';
      case LoadType.pharmaceutical:
        return '💊';
      case LoadType.textile:
        return '👕';
      case LoadType.chemical:
        return '⚗️';
      case LoadType.construction:
        return '🏗️';
      case LoadType.agriculture:
        return '🌾';
      case LoadType.hazardous:
        return '☢️';
      case LoadType.fragile:
        return '🔸';
      case LoadType.refrigerated:
        return '❄️';
      case LoadType.liquid:
        return '🌊';
      case LoadType.documents:
        return '📄';
    }
  }
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.miniTruck:
        return 'Mini Truck';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.lorry:
        return 'Lorry';
      case VehicleType.container:
        return 'Container';
      case VehicleType.trailer:
        return 'Trailer';
      case VehicleType.tempo:
        return 'Tempo';
      case VehicleType.pickup:
        return 'Pickup';
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.auto:
        return 'Auto Rickshaw';
      case VehicleType.van:
        return 'Van';
      case VehicleType.refrigeratedTruck:
        return 'Refrigerated Truck';
      case VehicleType.tanker:
        return 'Tanker';
    }
  }

  String get icon {
    switch (this) {
      case VehicleType.miniTruck:
        return '🚚';
      case VehicleType.truck:
        return '🚛';
      case VehicleType.lorry:
        return '🚛';
      case VehicleType.container:
        return '📦';
      case VehicleType.trailer:
        return '🚛';
      case VehicleType.tempo:
        return '🚐';
      case VehicleType.pickup:
        return '🛻';
      case VehicleType.bike:
        return '🏍️';
      case VehicleType.auto:
        return '🛺';
      case VehicleType.van:
        return '🚐';
      case VehicleType.refrigeratedTruck:
        return '🚛❄️';
      case VehicleType.tanker:
        return '🚛🌊';
    }
  }
}

extension LoadStatusExtension on LoadStatus {
  String get displayName {
    switch (this) {
      case LoadStatus.posted:
        return 'Posted';
      case LoadStatus.bidding:
        return 'Receiving Bids';
      case LoadStatus.assigned:
        return 'Assigned';
      case LoadStatus.inProgress:
        return 'In Progress';
      case LoadStatus.completed:
        return 'Completed';
      case LoadStatus.cancelled:
        return 'Cancelled';
      case LoadStatus.expired:
        return 'Expired';
      case LoadStatus.draft:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LoadStatus.active:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}



class LocationModel {
  final String id;
  final String address;
  final String city;
  final String state;
  final String country;
  final String? postalCode;
  final double latitude;
  final double longitude;
  final String? formattedAddress;
  final LocationType type;
  final DateTime? lastUsed;

  LocationModel({
    required this.id,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.postalCode,
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
    this.type = LocationType.custom,
    this.lastUsed,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postalCode'],
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      formattedAddress: map['formattedAddress'],
      type: LocationType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => LocationType.custom,
      ),
      lastUsed: map['lastUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUsed'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'type': type.toString(),
      'lastUsed': lastUsed?.millisecondsSinceEpoch,
    };
  }

  String get displayAddress {
    return formattedAddress ?? '$address, $city, $state';
  }

  String get shortAddress {
    return '$city, $state';
  }

  LocationModel copyWith({
    String? id,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? formattedAddress,
    LocationType? type,
    DateTime? lastUsed,
  }) {
    return LocationModel(
      id: id ?? this.id,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      type: type ?? this.type,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LocationModel(id: $id, address: $address, city: $city, state: $state)';
  }
}

enum LocationType {
  home,
  work,
  warehouse,
  depot,
  custom,
  recent,
  popular,
}

extension LocationTypeExtension on LocationType {
  String get displayName {
    switch (this) {
      case LocationType.home:
        return 'Home';
      case LocationType.work:
        return 'Work';
      case LocationType.warehouse:
        return 'Warehouse';
      case LocationType.depot:
        return 'Depot';
      case LocationType.custom:
        return 'Custom';
      case LocationType.recent:
        return 'Recent';
      case LocationType.popular:
        return 'Popular';
    }
  }

  String get icon {
    switch (this) {
      case LocationType.home:
        return '🏠';
      case LocationType.work:
        return '🏢';
      case LocationType.warehouse:
        return '🏭';
      case LocationType.depot:
        return '🚛';
      case LocationType.custom:
        return '📍';
      case LocationType.recent:
        return '🕒';
      case LocationType.popular:
        return '⭐';
    }
  }
}

class LocationSearchResult {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;
  final LocationType type;

  LocationSearchResult({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
    this.type = LocationType.custom,
  });

  factory LocationSearchResult.fromMap(Map<String, dynamic> map) {
    return LocationSearchResult(
      placeId: map['place_id'] ?? '',
      mainText: map['structured_formatting']['main_text'] ?? '',
      secondaryText: map['structured_formatting']['secondary_text'] ?? '',
      fullText: map['description'] ?? '',
      type: LocationType.custom,
    );
  }

  String get displayText => fullText.isNotEmpty ? fullText : '$mainText, $secondaryText';
}

class LocationBounds {
  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;

  LocationBounds({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });

  factory LocationBounds.fromMap(Map<String, dynamic> map) {
    return LocationBounds(
      northEastLat: map['northeast']['lat']?.toDouble() ?? 0.0,
      northEastLng: map['northeast']['lng']?.toDouble() ?? 0.0,
      southWestLat: map['southwest']['lat']?.toDouble() ?? 0.0,
      southWestLng: map['southwest']['lng']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'northeast': {
        'lat': northEastLat,
        'lng': northEastLng,
      },
      'southwest': {
        'lat': southWestLat,
        'lng': southWestLng,
      },
    };
  }
}