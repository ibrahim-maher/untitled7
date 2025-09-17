import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';

// Custom exception classes for better error handling
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}

class LocationServiceException extends LocationException {
  LocationServiceException(String message) : super(message);
}

class LocationPermissionException extends LocationException {
  LocationPermissionException(String message) : super(message);
}

class TimeoutException extends LocationException {
  TimeoutException(String message) : super(message);
}

class LocationPickerHelper {
  static Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 800);

  static Future<Map<String, dynamic>?> showLocationPicker(
      BuildContext context,
      bool isPickupLocation,
      ) async {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    return await Get.bottomSheet<Map<String, dynamic>>(
      LocationPickerBottomSheet(isPickupLocation: isPickupLocation),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        if (Platform.isAndroid) {
          await Geolocator.openLocationSettings();
          // Wait a bit and check again
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }

        if (!serviceEnabled) {
          throw LocationServiceException('Location services are disabled. Please enable them in settings.');
        }
      }

      // Check location permission with more detailed handling
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionException(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Get current position with timeout and fallback accuracy
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        // Fallback to medium accuracy if high accuracy fails
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      }

      return position;
    } on LocationServiceException {
      rethrow;
    } on LocationPermissionException {
      rethrow;
    } catch (e) {
      print('Error getting current location: $e');
      throw LocationException('Unable to get current location: ${e.toString()}');
    }
  }

  static final Map<String, String> _addressCache = {};

  static Future<String> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      // Create cache key
      final cacheKey = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

      // Check cache first
      if (_addressCache.containsKey(cacheKey)) {
        return _addressCache[cacheKey]!;
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Address lookup timeout'),
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final address = _formatAddress(place);

        // Cache the result
        _addressCache[cacheKey] = address;

        // Limit cache size
        if (_addressCache.length > 50) {
          _addressCache.remove(_addressCache.keys.first);
        }

        return address;
      }
      return 'Unknown location';
    } on TimeoutException {
      return 'Address lookup timeout';
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return 'Unable to get address';
    }
  }

  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    // Build address in logical order
    if (place.name != null && place.name!.isNotEmpty && place.name != place.street) {
      addressParts.add(place.name!);
    }
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      addressParts.add(place.postalCode!);
    }

    return addressParts.join(', ');
  }

  static Future<List<Location>> searchLocation(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      List<Location> locations = await locationFromAddress(query).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Search timeout'),
      );

      return locations;
    } on TimeoutException {
      print('Search timeout for query: $query');
      return [];
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }

  static List<Map<String, dynamic>> getPopularCities() {
    return [
      // Metro Cities
      {'name': 'Mumbai, Maharashtra', 'lat': 19.0760, 'lng': 72.8777, 'category': 'Metro', 'state': 'Maharashtra'},
      {'name': 'Delhi, NCR', 'lat': 28.6139, 'lng': 77.2090, 'category': 'Metro', 'state': 'Delhi'},
      {'name': 'Bangalore, Karnataka', 'lat': 12.9716, 'lng': 77.5946, 'category': 'Metro', 'state': 'Karnataka'},
      {'name': 'Chennai, Tamil Nadu', 'lat': 13.0827, 'lng': 80.2707, 'category': 'Metro', 'state': 'Tamil Nadu'},
      {'name': 'Kolkata, West Bengal', 'lat': 22.5726, 'lng': 88.3639, 'category': 'Metro', 'state': 'West Bengal'},
      {'name': 'Hyderabad, Telangana', 'lat': 17.3850, 'lng': 78.4867, 'category': 'Metro', 'state': 'Telangana'},

      // Tier 1 Cities
      {'name': 'Pune, Maharashtra', 'lat': 18.5204, 'lng': 73.8567, 'category': 'Tier 1', 'state': 'Maharashtra'},
      {'name': 'Ahmedabad, Gujarat', 'lat': 23.0225, 'lng': 72.5714, 'category': 'Tier 1', 'state': 'Gujarat'},
      {'name': 'Surat, Gujarat', 'lat': 21.1702, 'lng': 72.8311, 'category': 'Tier 1', 'state': 'Gujarat'},
      {'name': 'Jaipur, Rajasthan', 'lat': 26.9124, 'lng': 75.7873, 'category': 'Tier 1', 'state': 'Rajasthan'},
      {'name': 'Gurgaon, Haryana', 'lat': 28.4595, 'lng': 77.0266, 'category': 'Tier 1', 'state': 'Haryana'},
      {'name': 'Noida, Uttar Pradesh', 'lat': 28.5355, 'lng': 77.3910, 'category': 'Tier 1', 'state': 'Uttar Pradesh'},
      {'name': 'Kochi, Kerala', 'lat': 9.9312, 'lng': 76.2673, 'category': 'Tier 1', 'state': 'Kerala'},
      {'name': 'Coimbatore, Tamil Nadu', 'lat': 11.0168, 'lng': 76.9558, 'category': 'Tier 1', 'state': 'Tamil Nadu'},
      {'name': 'Visakhapatnam, Andhra Pradesh', 'lat': 17.6868, 'lng': 83.2185, 'category': 'Tier 1', 'state': 'Andhra Pradesh'},
      {'name': 'Indore, Madhya Pradesh', 'lat': 22.7196, 'lng': 75.8577, 'category': 'Tier 1', 'state': 'Madhya Pradesh'},

      // Tier 2 Cities
      {'name': 'Lucknow, Uttar Pradesh', 'lat': 26.8467, 'lng': 80.9462, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Kanpur, Uttar Pradesh', 'lat': 26.4499, 'lng': 80.3319, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Nagpur, Maharashtra', 'lat': 21.1458, 'lng': 79.0882, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Thane, Maharashtra', 'lat': 19.2183, 'lng': 72.9781, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Bhopal, Madhya Pradesh', 'lat': 23.2599, 'lng': 77.4126, 'category': 'Tier 2', 'state': 'Madhya Pradesh'},
      {'name': 'Vadodara, Gujarat', 'lat': 22.3072, 'lng': 73.1812, 'category': 'Tier 2', 'state': 'Gujarat'},
      {'name': 'Agra, Uttar Pradesh', 'lat': 27.1767, 'lng': 78.0081, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Nashik, Maharashtra', 'lat': 19.9975, 'lng': 73.7898, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Faridabad, Haryana', 'lat': 28.4089, 'lng': 77.3178, 'category': 'Tier 2', 'state': 'Haryana'},
      {'name': 'Meerut, Uttar Pradesh', 'lat': 28.9845, 'lng': 77.7064, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Rajkot, Gujarat', 'lat': 22.3039, 'lng': 70.8022, 'category': 'Tier 2', 'state': 'Gujarat'},
      {'name': 'Kalyan-Dombivli, Maharashtra', 'lat': 19.2403, 'lng': 73.1305, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Vasai-Virar, Maharashtra', 'lat': 19.4912, 'lng': 72.8054, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Varanasi, Uttar Pradesh', 'lat': 25.3176, 'lng': 82.9739, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Srinagar, Jammu and Kashmir', 'lat': 34.0837, 'lng': 74.7973, 'category': 'Tier 2', 'state': 'Jammu and Kashmir'},
      {'name': 'Aurangabad, Maharashtra', 'lat': 19.8762, 'lng': 75.3433, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Dhanbad, Jharkhand', 'lat': 23.7957, 'lng': 86.4304, 'category': 'Tier 2', 'state': 'Jharkhand'},
      {'name': 'Amritsar, Punjab', 'lat': 31.6340, 'lng': 74.8723, 'category': 'Tier 2', 'state': 'Punjab'},
      {'name': 'Navi Mumbai, Maharashtra', 'lat': 19.0330, 'lng': 73.0297, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Allahabad, Uttar Pradesh', 'lat': 25.4358, 'lng': 81.8463, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Ranchi, Jharkhand', 'lat': 23.3441, 'lng': 85.3096, 'category': 'Tier 2', 'state': 'Jharkhand'},
      {'name': 'Howrah, West Bengal', 'lat': 22.5958, 'lng': 88.2636, 'category': 'Tier 2', 'state': 'West Bengal'},
      {'name': 'Jabalpur, Madhya Pradesh', 'lat': 23.1815, 'lng': 79.9864, 'category': 'Tier 2', 'state': 'Madhya Pradesh'},
      {'name': 'Gwalior, Madhya Pradesh', 'lat': 26.2183, 'lng': 78.1828, 'category': 'Tier 2', 'state': 'Madhya Pradesh'},

      // Industrial/Port Cities
      {'name': 'JNPT, Navi Mumbai', 'lat': 18.9647, 'lng': 72.9505, 'category': 'Port', 'state': 'Maharashtra'},
      {'name': 'Mundra Port, Gujarat', 'lat': 22.8394, 'lng': 69.7939, 'category': 'Port', 'state': 'Gujarat'},
      {'name': 'Chennai Port, Tamil Nadu', 'lat': 13.1067, 'lng': 80.3000, 'category': 'Port', 'state': 'Tamil Nadu'},
      {'name': 'Kandla Port, Gujarat', 'lat': 23.0333, 'lng': 70.2167, 'category': 'Port', 'state': 'Gujarat'},
      {'name': 'Paradip Port, Odisha', 'lat': 20.3102, 'lng': 86.6169, 'category': 'Port', 'state': 'Odisha'},
      {'name': 'Haldia Port, West Bengal', 'lat': 22.0333, 'lng': 88.0667, 'category': 'Port', 'state': 'West Bengal'},

      // Additional Important Cities
      {'name': 'Chandigarh, Punjab', 'lat': 30.7333, 'lng': 76.7794, 'category': 'Tier 1', 'state': 'Punjab'},
      {'name': 'Mysore, Karnataka', 'lat': 12.2958, 'lng': 76.6394, 'category': 'Tier 2', 'state': 'Karnataka'},
      {'name': 'Bareilly, Uttar Pradesh', 'lat': 28.3670, 'lng': 79.4304, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Aligarh, Uttar Pradesh', 'lat': 27.8974, 'lng': 78.0880, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Tiruchirappalli, Tamil Nadu', 'lat': 10.7905, 'lng': 78.7047, 'category': 'Tier 2', 'state': 'Tamil Nadu'},
      {'name': 'Bhubaneswar, Odisha', 'lat': 20.2961, 'lng': 85.8245, 'category': 'Tier 2', 'state': 'Odisha'},
      {'name': 'Salem, Tamil Nadu', 'lat': 11.6643, 'lng': 78.1460, 'category': 'Tier 2', 'state': 'Tamil Nadu'},
      {'name': 'Mira-Bhayandar, Maharashtra', 'lat': 19.2952, 'lng': 72.8544, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Warangal, Telangana', 'lat': 17.9669, 'lng': 79.5941, 'category': 'Tier 2', 'state': 'Telangana'},
      {'name': 'Thiruvananthapuram, Kerala', 'lat': 8.5241, 'lng': 76.9366, 'category': 'Tier 2', 'state': 'Kerala'},
      {'name': 'Guntur, Andhra Pradesh', 'lat': 16.3067, 'lng': 80.4365, 'category': 'Tier 2', 'state': 'Andhra Pradesh'},
      {'name': 'Bhiwandi, Maharashtra', 'lat': 19.3002, 'lng': 73.0636, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Saharanpur, Uttar Pradesh', 'lat': 29.9680, 'lng': 77.5552, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Gorakhpur, Uttar Pradesh', 'lat': 26.7606, 'lng': 83.3732, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Bikaner, Rajasthan', 'lat': 28.0229, 'lng': 73.3119, 'category': 'Tier 2', 'state': 'Rajasthan'},
      {'name': 'Amravati, Maharashtra', 'lat': 20.9374, 'lng': 77.7796, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Noida Extension, Uttar Pradesh', 'lat': 28.4743, 'lng': 77.5022, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Jamshedpur, Jharkhand', 'lat': 22.8046, 'lng': 86.2029, 'category': 'Tier 2', 'state': 'Jharkhand'},
      {'name': 'Bhilai, Chhattisgarh', 'lat': 21.1938, 'lng': 81.3509, 'category': 'Tier 2', 'state': 'Chhattisgarh'},
      {'name': 'Cuttack, Odisha', 'lat': 20.4625, 'lng': 85.8828, 'category': 'Tier 2', 'state': 'Odisha'},
      {'name': 'Firozabad, Uttar Pradesh', 'lat': 27.1591, 'lng': 78.3957, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Kota, Rajasthan', 'lat': 25.2138, 'lng': 75.8648, 'category': 'Tier 2', 'state': 'Rajasthan'},
      {'name': 'Bhavnagar, Gujarat', 'lat': 21.7645, 'lng': 72.1519, 'category': 'Tier 2', 'state': 'Gujarat'},
      {'name': 'Dehradun, Uttarakhand', 'lat': 30.3165, 'lng': 78.0322, 'category': 'Tier 2', 'state': 'Uttarakhand'},
      {'name': 'Durgapur, West Bengal', 'lat': 23.5204, 'lng': 87.3119, 'category': 'Tier 2', 'state': 'West Bengal'},
      {'name': 'Asansol, West Bengal', 'lat': 23.6739, 'lng': 86.9524, 'category': 'Tier 2', 'state': 'West Bengal'},
      {'name': 'Rourkela, Odisha', 'lat': 22.2604, 'lng': 84.8536, 'category': 'Tier 2', 'state': 'Odisha'},
      {'name': 'Nanded, Maharashtra', 'lat': 19.1383, 'lng': 77.3210, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Kolhapur, Maharashtra', 'lat': 16.7050, 'lng': 74.2433, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Ajmer, Rajasthan', 'lat': 26.4499, 'lng': 74.6399, 'category': 'Tier 2', 'state': 'Rajasthan'},
      {'name': 'Akola, Maharashtra', 'lat': 20.7002, 'lng': 77.0082, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Gulbarga, Karnataka', 'lat': 17.3297, 'lng': 76.8343, 'category': 'Tier 2', 'state': 'Karnataka'},
      {'name': 'Jamnagar, Gujarat', 'lat': 22.4707, 'lng': 70.0577, 'category': 'Tier 2', 'state': 'Gujarat'},
      {'name': 'Ujjain, Madhya Pradesh', 'lat': 23.1765, 'lng': 75.7885, 'category': 'Tier 2', 'state': 'Madhya Pradesh'},
      {'name': 'Loni, Uttar Pradesh', 'lat': 28.7333, 'lng': 77.2833, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Siliguri, West Bengal', 'lat': 26.7271, 'lng': 88.3953, 'category': 'Tier 2', 'state': 'West Bengal'},
      {'name': 'Jhansi, Uttar Pradesh', 'lat': 25.4484, 'lng': 78.5685, 'category': 'Tier 2', 'state': 'Uttar Pradesh'},
      {'name': 'Ulhasnagar, Maharashtra', 'lat': 19.2215, 'lng': 73.1645, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Jammu, Jammu and Kashmir', 'lat': 32.7266, 'lng': 74.8570, 'category': 'Tier 2', 'state': 'Jammu and Kashmir'},
      {'name': 'Sangli-Miraj & Kupwad, Maharashtra', 'lat': 16.8524, 'lng': 74.5815, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Mangalore, Karnataka', 'lat': 12.9141, 'lng': 74.8560, 'category': 'Tier 2', 'state': 'Karnataka'},
      {'name': 'Erode, Tamil Nadu', 'lat': 11.3410, 'lng': 77.7172, 'category': 'Tier 2', 'state': 'Tamil Nadu'},
      {'name': 'Belgaum, Karnataka', 'lat': 15.8497, 'lng': 74.4977, 'category': 'Tier 2', 'state': 'Karnataka'},
      {'name': 'Ambattur, Tamil Nadu', 'lat': 13.1143, 'lng': 80.1548, 'category': 'Tier 2', 'state': 'Tamil Nadu'},
      {'name': 'Tirunelveli, Tamil Nadu', 'lat': 8.7139, 'lng': 77.7567, 'category': 'Tier 2', 'state': 'Tamil Nadu'},
      {'name': 'Malegaon, Maharashtra', 'lat': 20.5579, 'lng': 74.5287, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Gaya, Bihar', 'lat': 24.7914, 'lng': 85.0002, 'category': 'Tier 2', 'state': 'Bihar'},
      {'name': 'Jalgaon, Maharashtra', 'lat': 21.0077, 'lng': 75.5626, 'category': 'Tier 2', 'state': 'Maharashtra'},
      {'name': 'Udaipur, Rajasthan', 'lat': 24.5854, 'lng': 73.7125, 'category': 'Tier 2', 'state': 'Rajasthan'},
      {'name': 'Maheshtala, West Bengal', 'lat': 22.5048, 'lng': 88.2482, 'category': 'Tier 2', 'state': 'West Bengal'},
    ];
  }

  static List<String> getRecentLocations() {
    // In production, this would come from SharedPreferences or Hive
    return [
      'Mumbai Central, Mumbai',
      'Andheri East, Mumbai',
      'Electronic City, Bangalore',
      'Gurgaon Sector 44, Gurgaon',
      'Noida Sector 62, Noida',
    ];
  }

  static Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  static Future<PermissionStatus> requestLocationPermission() async {
    try {
      return await Permission.location.request();
    } catch (e) {
      print('Error requesting location permission: $e');
      return PermissionStatus.denied;
    }
  }

  static void showLocationPermissionDialog(BuildContext context) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Location Permission',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FreightX needs location access to:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Find your current location')),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Suggest nearby pickup points')),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Track shipments accurately')),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please enable location access in your device settings.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Open Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showLocationServiceDialog(BuildContext context) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.location_off,
              color: Colors.red[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Location Service',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Location services are currently disabled. To use location features, please enable location services in your device settings.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You can also manually enter your location.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Enter Manually',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Enable Location',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPickerBottomSheet extends StatefulWidget {
  final bool isPickupLocation;

  const LocationPickerBottomSheet({
    Key? key,
    required this.isPickupLocation,
  }) : super(key: key);

  @override
  State<LocationPickerBottomSheet> createState() => _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<LocationPickerBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<String> _searchResults = [];
  bool _isSearching = false;
  bool _isGettingCurrentLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    LocationPickerHelper._debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    // Cancel previous timer
    LocationPickerHelper._debounceTimer?.cancel();

    // Start new timer
    LocationPickerHelper._debounceTimer = Timer(
      LocationPickerHelper._debounceDuration,
          () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    if (!mounted || query.trim().isEmpty) return;

    try {
      final results = await _simulateLocationSearch(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          _errorMessage = results.isEmpty ? 'No locations found for "$query"' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _errorMessage = 'Search failed. Please try again.';
        });
      }
    }
  }

  Future<List<String>> _simulateLocationSearch(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final popularCities = LocationPickerHelper.getPopularCities();
    final queryLower = query.toLowerCase().trim();

    // Multi-tier search algorithm
    List<Map<String, dynamic>> prioritizedResults = [];

    for (final city in popularCities) {
      final cityName = city['name']! as String;
      final cityLower = cityName.toLowerCase();
      final state = city['state']! as String;
      final stateLower = state.toLowerCase();

      int priority = 0;

      // Exact match gets highest priority
      if (cityLower.startsWith(queryLower)) {
        priority = 100;
      }
      // City name contains query
      else if (cityLower.contains(queryLower)) {
        priority = 80;
      }
      // State name contains query
      else if (stateLower.contains(queryLower)) {
        priority = 60;
      }
      // Fuzzy match on individual words
      else if (_advancedFuzzyMatch(cityName, query)) {
        priority = 40;
      }
      // Port/Metro priority boost
      if (city['category'] == 'Metro') {
        priority += 20;
      } else if (city['category'] == 'Port') {
        priority += 15;
      } else if (city['category'] == 'Tier 1') {
        priority += 10;
      }

      if (priority > 0) {
        prioritizedResults.add({
          'city': cityName,
          'priority': priority,
        });
      }
    }

    // Sort by priority and return top results
    prioritizedResults.sort((a, b) => b['priority'].compareTo(a['priority']));

    return prioritizedResults
        .take(10)
        .map((result) => result['city'] as String)
        .toList();
  }

  bool _fuzzyMatch(String cityName, String query) {
    return _advancedFuzzyMatch(cityName, query);
  }

  bool _advancedFuzzyMatch(String cityName, String query) {
    final city = cityName.toLowerCase();
    final q = query.toLowerCase();

    // Split into words for better matching
    final cityWords = city.split(RegExp(r'[,\s]+'));
    final queryWords = q.split(RegExp(r'[,\s]+'));

    // Check if any word in city starts with any word in query
    for (final queryWord in queryWords) {
      if (queryWord.length >= 2) {
        for (final cityWord in cityWords) {
          if (cityWord.startsWith(queryWord)) {
            return true;
          }

          // Check for common abbreviations
          if (_checkAbbreviations(cityWord, queryWord)) {
            return true;
          }

          // Check for phonetic similarity
          if (_checkPhoneticSimilarity(cityWord, queryWord)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _checkAbbreviations(String cityWord, String queryWord) {
    // Common city abbreviations
    final abbreviations = {
      'mumbai': ['bom', 'mum'],
      'delhi': ['del', 'ndl'],
      'bangalore': ['blr', 'bang'],
      'chennai': ['mad', 'che'],
      'kolkata': ['cal', 'ccu'],
      'hyderabad': ['hyd'],
      'ahmedabad': ['amd'],
      'coimbatore': ['cbe'],
      'thiruvananthapuram': ['tvm'],
      'visakhapatnam': ['viz'],
      'bhubaneswar': ['bbs'],
    };

    final cityAbbrevs = abbreviations[cityWord];
    return cityAbbrevs?.contains(queryWord) ?? false;
  }

  bool _checkPhoneticSimilarity(String cityWord, String queryWord) {
    if (queryWord.length < 3) return false;

    // Simple phonetic matching for common variations
    final phoneticMap = {
      'ph': 'f',
      'th': 't',
      'ch': 'c',
      'kh': 'k',
      'gh': 'g',
    };

    String normalizedCity = cityWord;
    String normalizedQuery = queryWord;

    phoneticMap.forEach((from, to) {
      normalizedCity = normalizedCity.replaceAll(from, to);
      normalizedQuery = normalizedQuery.replaceAll(from, to);
    });

    return normalizedCity.startsWith(normalizedQuery) ||
        normalizedCity.contains(normalizedQuery);
  }

  void _selectLocation(String address, {double? lat, double? lng}) {
    HapticFeedback.selectionClick();

    final locationData = {
      'address': address,
      'coordinates': lat != null && lng != null ? {'lat': lat, 'lng': lng} : null,
      'isPickup': widget.isPickupLocation,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'source': lat != null && lng != null ? 'gps' : 'manual',
    };

    Navigator.pop(context, locationData);
  }

  void _useCurrentLocation() async {
    setState(() {
      _isGettingCurrentLocation = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationPickerHelper.getCurrentLocation();

      if (position != null) {
        final address = await LocationPickerHelper.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          _selectLocation(
            address,
            lat: position.latitude,
            lng: position.longitude,
          );
        }
      } else {
        _showError('Unable to get current location');
      }
    } on LocationServiceException catch (e) {
      _showError(e.message);
      if (mounted) {
        LocationPickerHelper.showLocationServiceDialog(context);
      }
    } on LocationPermissionException catch (e) {
      _showError(e.message);
      if (mounted) {
        LocationPickerHelper.showLocationPermissionDialog(context);
      }
    } on LocationException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to get location: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Auto clear error after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.isPickupLocation
                          ? Icons.location_on_outlined
                          : Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPickupLocation
                              ? 'Pickup Location'
                              : 'Delivery Location',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Choose your ${widget.isPickupLocation ? 'pickup' : 'delivery'} point',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: _isSearching
                        ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                        : Icon(Icons.search, color: Colors.grey[600]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                      icon: Icon(Icons.clear, color: Colors.grey[600]),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current location option
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
              child: ListTile(
                leading: _isGettingCurrentLocation
                    ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
                    : Icon(
                  Icons.my_location,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  'Use Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                subtitle: const Text('Get your location automatically'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: _isGettingCurrentLocation ? null : _useCurrentLocation,
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _buildLocationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList() {
    if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final location = _searchResults[index];
          return _buildLocationTile(
            location,
            Icons.location_on,
            'Search Result',
            onTap: () => _selectLocation(location),
          );
        },
      );
    }

    if (_searchController.text.isNotEmpty && _searchResults.isEmpty && !_isSearching) {
      return _buildEmptyState(
        Icons.search_off,
        'No locations found',
        'Try searching with a different term or check spelling',
      );
    }

    if (_isSearching) {
      return _buildLoadingState();
    }

    // Show popular cities and recent locations
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent locations
          if (LocationPickerHelper.getRecentLocations().isNotEmpty) ...[
            _buildSectionHeader('Recent Locations', Icons.history),
            const SizedBox(height: 8),
            ...LocationPickerHelper.getRecentLocations().map(
                  (location) => _buildLocationTile(
                location,
                Icons.history,
                'Recent',
                onTap: () => _selectLocation(location),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Popular cities
          _buildSectionHeader('Popular Cities', Icons.location_city),
          const SizedBox(height: 8),
          ...LocationPickerHelper.getPopularCities().take(12).map(
                (cityData) => _buildLocationTile(
              cityData['name']! as String,
              Icons.location_city,
              cityData['category']! as String,
              onTap: () => _selectLocation(
                cityData['name']! as String,
                lat: cityData['lat'] as double,
                lng: cityData['lng'] as double,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTile(
      String location,
      IconData icon,
      String category, {
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Searching locations...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}