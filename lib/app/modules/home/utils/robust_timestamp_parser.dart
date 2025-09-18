import 'package:cloud_firestore/cloud_firestore.dart';

class RobustTimestampParser {
  /// Safely parse any timestamp value from Firestore
  static DateTime parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    // Handle Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }

    // Handle milliseconds since epoch (int)
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    // Handle string dates (ISO format, etc.)
    if (value is String) {
      try {
        // Try parsing ISO string
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $value, error: $e');
        return DateTime.now();
      }
    }

    // Handle seconds since epoch (some APIs use this)
    if (value is double) {
      try {
        return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
      } catch (e) {
        return DateTime.now();
      }
    }

    // If it's already a DateTime
    if (value is DateTime) {
      return value;
    }

    // Fallback for any other type
    print('Unknown timestamp type: ${value.runtimeType}, value: $value');
    return DateTime.now();
  }

  /// Safely parse nullable timestamp
  static DateTime? parseNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    try {
      return parseDateTime(value);
    } catch (e) {
      print('Error parsing nullable timestamp: $e');
      return null;
    }
  }
}