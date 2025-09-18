import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  static final Map<String, String> _addressCache = {};
  static const String _recentLocationsKey = 'recent_locations';
  static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY'; // Add your API key here

  static Future<Map<String, dynamic>?> showLocationPicker(
      BuildContext context,
      bool isPickupLocation,
      ) async {
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

  // New method to show Google Maps picker
  static Future<Map<String, dynamic>?> showMapLocationPicker(
      BuildContext context,
      bool isPickupLocation, {
        LatLng? initialLocation,
      }) async {
    HapticFeedback.lightImpact();

    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapLocationPicker(
          isPickupLocation: isPickupLocation,
          initialLocation: initialLocation,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (Platform.isAndroid) {
          await Geolocator.openLocationSettings();
          await Future.delayed(const Duration(seconds: 1));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }

        if (!serviceEnabled) {
          throw LocationServiceException(
            'Location services are disabled. Please enable them in settings.',
          );
        }
      }

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

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
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
      throw LocationException('Unable to get current location: ${e.toString()}');
    }
  }

  static Future<String> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      final cacheKey = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

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

        _addressCache[cacheKey] = address;

        if (_addressCache.length > 50) {
          _addressCache.remove(_addressCache.keys.first);
        }

        return address;
      }
      return 'Unknown location';
    } on TimeoutException {
      return 'Address lookup timeout';
    } catch (e) {
      return 'Unable to get address';
    }
  }

  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];

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

  static Future<List<Map<String, dynamic>>> searchLocationWithAPI(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      // Use Google Places API if key is configured
      if (_apiKey != 'YOUR_GOOGLE_PLACES_API_KEY') {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey&types=address',
        );

        final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Search timeout'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final predictions = data['predictions'] as List;

          List<Map<String, dynamic>> results = [];
          for (final prediction in predictions.take(15)) {
            results.add({
              'address': prediction['description'],
              'placeId': prediction['place_id'],
              'types': prediction['types'],
            });
          }
          return results;
        }
      }

      // Fallback to geocoding search
      return await _searchLocationLocal(query);
    } catch (e) {
      // Fallback to local search on API failure
      return await _searchLocationLocal(query);
    }
  }

  static Future<List<Map<String, dynamic>>> _searchLocationLocal(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // Use geocoding to search for locations
      List<Location> locations = await locationFromAddress(query);

      List<Map<String, dynamic>> results = [];

      for (final location in locations.take(10)) {
        try {
          final address = await getAddressFromCoordinates(
            location.latitude,
            location.longitude,
          );

          results.add({
            'address': address,
            'lat': location.latitude,
            'lng': location.longitude,
            'priority': 50,
            'category': 'Search Result',
          });
        } catch (e) {
          // Skip locations that can't be reverse geocoded
          continue;
        }
      }

      return results;
    } catch (e) {
      // Return empty list if geocoding fails
      return [];
    }
  }

  static Future<List<String>> getRecentLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentLocations = prefs.getStringList(_recentLocationsKey) ?? [];
      return recentLocations;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveRecentLocation(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentLocations = prefs.getStringList(_recentLocationsKey) ?? [];

      // Remove if already exists
      recentLocations.remove(location);

      // Add to beginning
      recentLocations.insert(0, location);

      // Keep only last 10
      if (recentLocations.length > 10) {
        recentLocations = recentLocations.take(10).toList();
      }

      await prefs.setStringList(_recentLocationsKey, recentLocations);
    } catch (e) {
      // Ignore errors in saving recent locations
    }
  }

  static Future<Map<String, dynamic>?> getLocationDetails(String placeId) async {
    if (_apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') return null;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey&fields=geometry,formatted_address',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];

        if (result != null) {
          final geometry = result['geometry'];
          final location = geometry['location'];

          return {
            'address': result['formatted_address'],
            'lat': location['lat'],
            'lng': location['lng'],
          };
        }
      }
    } catch (e) {
      // Return null on error
    }

    return null;
  }

  static Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  static Future<PermissionStatus> requestLocationPermission() async {
    try {
      return await Permission.location.request();
    } catch (e) {
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
              'FreightFlow needs location access to:',
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

// Enhanced Location Picker Bottom Sheet with Map Option
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

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentLocations = [];
  bool _isSearching = false;
  bool _isGettingCurrentLocation = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecentLocations();

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

  Future<void> _loadRecentLocations() async {
    final recent = await LocationPickerHelper.getRecentLocations();
    setState(() {
      _recentLocations = recent;
    });
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

    LocationPickerHelper._debounceTimer?.cancel();
    LocationPickerHelper._debounceTimer = Timer(
      LocationPickerHelper._debounceDuration,
          () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    if (!mounted || query.trim().isEmpty) return;

    try {
      final results = await LocationPickerHelper.searchLocationWithAPI(query);

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

  void _selectLocation(String address, {double? lat, double? lng, String? placeId}) async {
    HapticFeedback.selectionClick();

    // If we have a placeId but no coordinates, get details from API
    if (placeId != null && lat == null && lng == null) {
      final details = await LocationPickerHelper.getLocationDetails(placeId);
      if (details != null) {
        lat = details['lat'];
        lng = details['lng'];
        address = details['address'] ?? address;
      }
    }

    // Save to recent locations
    await LocationPickerHelper.saveRecentLocation(address);

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

  void _openMapPicker() async {
    HapticFeedback.lightImpact();

    // Get current location as initial position for the map
    LatLng? initialLocation;
    try {
      final position = await LocationPickerHelper.getCurrentLocation();
      if (position != null) {
        initialLocation = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      // Use default location if can't get current location
      initialLocation = const LatLng(20.5937, 78.9629); // Center of India
    }

    final result = await LocationPickerHelper.showMapLocationPicker(
      context,
      widget.isPickupLocation,
      initialLocation: initialLocation,
    );

    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

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

            // Quick action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Current location option
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: InkWell(
                        onTap: _isGettingCurrentLocation ? null : _useCurrentLocation,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              _isGettingCurrentLocation
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
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Current\nLocation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Map picker option
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green[200]!,
                        ),
                      ),
                      child: InkWell(
                        onTap: _openMapPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              Icon(
                                Icons.map,
                                color: Colors.green[600],
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select on\nMap',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
          final result = _searchResults[index];
          return _buildLocationTile(
            result['address'] ?? '',
            Icons.location_on,
            result['category'] ?? 'Location',
            onTap: () => _selectLocation(
              result['address'] ?? '',
              lat: result['lat'],
              lng: result['lng'],
              placeId: result['placeId'],
            ),
          );
        },
      );
    }

    if (_searchController.text.isNotEmpty &&
        _searchResults.isEmpty &&
        !_isSearching) {
      return _buildEmptyState(
        Icons.search_off,
        'No locations found',
        'Try searching with a different term or check spelling',
      );
    }

    if (_isSearching) {
      return _buildLoadingState();
    }

    // Show only recent locations
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent locations
          if (_recentLocations.isNotEmpty) ...[
            _buildSectionHeader('Recent Locations', Icons.history),
            const SizedBox(height: 8),
            ..._recentLocations.map(
                  (location) => _buildLocationTile(
                location,
                Icons.history,
                'Recent',
                onTap: () => _selectLocation(location),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Empty state for no recent locations
            const SizedBox(height: 40),
            _buildEmptyState(
              Icons.history,
              'No recent locations',
              'Start searching for locations or use current location to build your history',
            ),
          ],
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

// Google Maps Location Picker Widget
class GoogleMapLocationPicker extends StatefulWidget {
  final bool isPickupLocation;
  final LatLng? initialLocation;

  const GoogleMapLocationPicker({
    Key? key,
    required this.isPickupLocation,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<GoogleMapLocationPicker> createState() => _GoogleMapLocationPickerState();
}

class _GoogleMapLocationPickerState extends State<GoogleMapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(20.5937, 78.9629); // Default to center of India
  String _selectedAddress = 'Select location on map';
  bool _isLoadingAddress = false;
  bool _isConfirming = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation!;
      _updateAddress(_selectedLocation);
    }
    _updateMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _updateMarker();
    });
    _updateAddress(location);
  }

  void _updateMarker() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
          _updateAddress(newPosition);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(
          widget.isPickupLocation ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      ),
    );
  }

  Future<void> _updateAddress(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final address = await LocationPickerHelper.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress = 'Unknown location';
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationPickerHelper.getCurrentLocation();
      if (position != null) {
        final newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedLocation = newLocation;
          _updateMarker();
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 16),
        );

        _updateAddress(newLocation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmLocation() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      // Save to recent locations
      await LocationPickerHelper.saveRecentLocation(_selectedAddress);

      final locationData = {
        'address': _selectedAddress,
        'coordinates': {
          'lat': _selectedLocation.latitude,
          'lng': _selectedLocation.longitude,
        },
        'isPickup': widget.isPickupLocation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'map',
      };

      Navigator.pop(context, locationData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPickupLocation ? 'Select Pickup Location' : 'Select Delivery Location',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location, size: 20),
            label: const Text('My Location'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            mapType: MapType.normal,
          ),

          // Address display panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isPickupLocation ? Icons.location_on : Icons.location_on,
                    color: widget.isPickupLocation ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPickupLocation ? 'Pickup Location' : 'Delivery Location',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_isLoadingAddress)
                          Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Getting address...'),
                            ],
                          )
                        else
                          Text(
                            _selectedAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: _isConfirming
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Confirming...'),
                ],
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instructions card
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap on the map or drag the marker to select your location',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}