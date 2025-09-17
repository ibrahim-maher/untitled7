import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/LoadModel.dart';

class LocationService {
  static final Dio _dio = Dio();
  static final GetStorage _storage = GetStorage();

  // Replace with your Google Places API key
  static const String _googleApiKey = 'AIzaSyDVm7wLX3Be0OHJypf0sDsIxSR3SnJ0Q4s';
  static const String _placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Storage keys
  static const String _recentLocationsKey = 'recent_locations';
  static const String _favoriteLocationsKey = 'favorite_locations';

  /// Get current device location
  static Future<LocationModel?> getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return LocationModel(
          id: 'current_${DateTime.now().millisecondsSinceEpoch}',
          address: _buildAddressFromPlacemark(placemark),
          city: placemark.locality ?? '',
          state: placemark.administrativeArea ?? '',
          country: placemark.country ?? '',
          postalCode: placemark.postalCode,
          latitude: position.latitude,
          longitude: position.longitude,
          formattedAddress: _buildFormattedAddress(placemark),
          type: LocationType.custom,
        );
      }

      return null;
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }

  /// Search for places using Google Places API
  static Future<List<LocationSearchResult>> searchPlaces(
      String query, {
        String? sessionToken,
        LocationBounds? bounds,
        String? countryCode = 'IN',
      }) async {
    try {
      if (query.trim().isEmpty) return [];

      final response = await _dio.get(
        '$_placesBaseUrl/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _googleApiKey,
          'sessiontoken': sessionToken ?? _generateSessionToken(),
          'components': countryCode != null ? 'country:$countryCode' : null,
          'types': 'geocode',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final predictions = response.data['predictions'] as List;
        return predictions
            .map((prediction) => LocationSearchResult.fromMap(prediction))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Get place details from place ID
  static Future<LocationModel?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        '$_placesBaseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _googleApiKey,
          'fields': 'place_id,formatted_address,geometry,address_components,name',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final result = response.data['result'];
        return _buildLocationFromPlaceDetails(result);
      }

      return null;
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  /// Get distance between two locations
  static double calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get route distance and duration using Google Directions API
  static Future<Map<String, dynamic>?> getRouteInfo(
      LocationModel origin,
      LocationModel destination,
      ) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': _googleApiKey,
          'mode': 'driving',
          'units': 'metric',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final routes = response.data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes.first;
          final leg = route['legs'][0];

          return {
            'distance': leg['distance']['text'],
            'distanceValue': leg['distance']['value'], // in meters
            'duration': leg['duration']['text'],
            'durationValue': leg['duration']['value'], // in seconds
            'polyline': route['overview_polyline']['points'],
          };
        }
      }

      return null;
    } catch (e) {
      print('Error getting route info: $e');
      return null;
    }
  }

  /// Save location to recent locations
  static Future<void> saveToRecentLocations(LocationModel location) async {
    try {
      final recentLocations = getRecentLocations();

      // Remove if already exists
      recentLocations.removeWhere((loc) => loc.id == location.id);

      // Add to beginning
      recentLocations.insert(0, location.copyWith(
        lastUsed: DateTime.now(),
        type: LocationType.recent,
      ));

      // Keep only last 10
      if (recentLocations.length > 10) {
        recentLocations.removeRange(10, recentLocations.length);
      }

      // Save to storage
      final locationsJson = recentLocations.map((loc) => loc.toMap()).toList();
      await _storage.write(_recentLocationsKey, locationsJson);
    } catch (e) {
      print('Error saving recent location: $e');
    }
  }

  /// Get recent locations
  static List<LocationModel> getRecentLocations() {
    try {
      final locationsJson = _storage.read(_recentLocationsKey) as List?;
      if (locationsJson != null) {
        return locationsJson
            .map((json) => LocationModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting recent locations: $e');
      return [];
    }
  }

  /// Save location to favorites
  static Future<void> saveToFavorites(LocationModel location) async {
    try {
      final favorites = getFavoriteLocations();

      // Check if already exists
      if (!favorites.any((loc) => loc.id == location.id)) {
        favorites.add(location);

        final favoritesJson = favorites.map((loc) => loc.toMap()).toList();
        await _storage.write(_favoriteLocationsKey, favoritesJson);
      }
    } catch (e) {
      print('Error saving favorite location: $e');
    }
  }

  /// Get favorite locations
  static List<LocationModel> getFavoriteLocations() {
    try {
      final locationsJson = _storage.read(_favoriteLocationsKey) as List?;
      if (locationsJson != null) {
        return locationsJson
            .map((json) => LocationModel.fromMap(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting favorite locations: $e');
      return [];
    }
  }

  /// Remove from favorites
  static Future<void> removeFromFavorites(String locationId) async {
    try {
      final favorites = getFavoriteLocations();
      favorites.removeWhere((loc) => loc.id == locationId);

      final favoritesJson = favorites.map((loc) => loc.toMap()).toList();
      await _storage.write(_favoriteLocationsKey, favoritesJson);
    } catch (e) {
      print('Error removing favorite location: $e');
    }
  }

  /// Get popular cities in India
  static List<LocationModel> getPopularCities() {
    return [
      LocationModel(
        id: 'mumbai',
        address: 'Mumbai',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        latitude: 19.0760,
        longitude: 72.8777,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'delhi',
        address: 'New Delhi',
        city: 'New Delhi',
        state: 'Delhi',
        country: 'India',
        latitude: 28.6139,
        longitude: 77.2090,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'bangalore',
        address: 'Bangalore',
        city: 'Bangalore',
        state: 'Karnataka',
        country: 'India',
        latitude: 12.9716,
        longitude: 77.5946,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'chennai',
        address: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        latitude: 13.0827,
        longitude: 80.2707,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'kolkata',
        address: 'Kolkata',
        city: 'Kolkata',
        state: 'West Bengal',
        country: 'India',
        latitude: 22.5726,
        longitude: 88.3639,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'hyderabad',
        address: 'Hyderabad',
        city: 'Hyderabad',
        state: 'Telangana',
        country: 'India',
        latitude: 17.3850,
        longitude: 78.4867,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'pune',
        address: 'Pune',
        city: 'Pune',
        state: 'Maharashtra',
        country: 'India',
        latitude: 18.5204,
        longitude: 73.8567,
        type: LocationType.popular,
      ),
      LocationModel(
        id: 'ahmedabad',
        address: 'Ahmedabad',
        city: 'Ahmedabad',
        state: 'Gujarat',
        country: 'India',
        latitude: 23.0225,
        longitude: 72.5714,
        type: LocationType.popular,
      ),
    ];
  }

  // Private helper methods
  static String _buildAddressFromPlacemark(Placemark placemark) {
    List<String> parts = [];

    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    }
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }

    return parts.join(', ');
  }

  static String _buildFormattedAddress(Placemark placemark) {
    List<String> parts = [];

    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    }
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }

    return parts.join(', ');
  }

  static LocationModel _buildLocationFromPlaceDetails(Map<String, dynamic> place) {
    final geometry = place['geometry']['location'];
    final addressComponents = place['address_components'] as List;

    String city = '';
    String state = '';
    String country = '';
    String postalCode = '';

    for (final component in addressComponents) {
      final types = component['types'] as List;

      if (types.contains('locality')) {
        city = component['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        state = component['long_name'];
      } else if (types.contains('country')) {
        country = component['long_name'];
      } else if (types.contains('postal_code')) {
        postalCode = component['long_name'];
      }
    }

    return LocationModel(
      id: place['place_id'],
      address: place['name'] ?? '',
      city: city,
      state: state,
      country: country,
      postalCode: postalCode.isEmpty ? null : postalCode,
      latitude: geometry['lat'].toDouble(),
      longitude: geometry['lng'].toDouble(),
      formattedAddress: place['formatted_address'],
      type: LocationType.custom,
    );
  }

  static String _generateSessionToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}