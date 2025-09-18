// Add these dependencies to pubspec.yaml:
// dependencies:
//   country_code_picker: ^3.0.0
//   phone_numbers_parser: ^8.1.0
//   geolocator: ^9.0.2
//   shared_preferences: ^2.2.2
//   image_picker: ^1.0.4
//   firebase_auth: ^4.0.0
//   cloud_firestore: ^4.0.0

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/LoadModel.dart';
import '../services/firestore_service.dart';

// Enhanced model classes for PostLoadController
class LoadTypeModel {
  final String id;
  final String displayName;

  LoadTypeModel(this.id, this.displayName);

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
  };

  factory LoadTypeModel.fromJson(Map<String, dynamic> json) => LoadTypeModel(
    json['id'],
    json['displayName'],
  );
}

class VehicleTypeModel {
  final String id;
  final String icon;
  final String displayName;
  final String capacity;
  final double maxWeight;

  VehicleTypeModel(this.id, this.icon, this.displayName, this.capacity, this.maxWeight);

  Map<String, dynamic> toJson() => {
    'id': id,
    'icon': icon,
    'displayName': displayName,
    'capacity': capacity,
    'maxWeight': maxWeight,
  };

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) => VehicleTypeModel(
    json['id'],
    json['icon'],
    json['displayName'],
    json['capacity'],
    json['maxWeight']?.toDouble() ?? 0.0,
  );
}

class PostLoadController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Basic Information
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Load Details
  final RxList<LoadTypeModel> loadTypes = <LoadTypeModel>[
    LoadTypeModel('general', 'General Goods'),
    LoadTypeModel('electronics', 'Electronics'),
    LoadTypeModel('furniture', 'Furniture'),
    LoadTypeModel('automotive', 'Automotive'),
    LoadTypeModel('construction', 'Construction Materials'),
    LoadTypeModel('chemical', 'Chemicals'),
    LoadTypeModel('textile', 'Textiles'),
    LoadTypeModel('food', 'Food & Beverages'),
    LoadTypeModel('pharmaceutical', 'Medical Supplies'),
    LoadTypeModel('documents', 'Documents'),
    LoadTypeModel('fragile', 'Fragile Items'),
    LoadTypeModel('agriculture', 'Bulk Materials'),
  ].obs;

  final RxList<VehicleTypeModel> vehicleTypes = <VehicleTypeModel>[
    VehicleTypeModel('bike', '🏍️', 'Bike/Scooter', 'Up to 20 kg', 20.0),
    VehicleTypeModel('auto', '🛺', 'Auto Rickshaw', 'Up to 100 kg', 100.0),
    VehicleTypeModel('pickup', '🛻', 'Pickup Truck', 'Up to 1 ton', 1000.0),
    VehicleTypeModel('miniTruck', '🚚', 'Mini Truck', 'Up to 2 tons', 2000.0),
    VehicleTypeModel('truck', '🚛', 'Truck', 'Up to 10 tons', 10000.0),
    VehicleTypeModel('trailer', '🚛', 'Trailer', 'Up to 25 tons', 25000.0),
    VehicleTypeModel('container', '📦', 'Container', 'Up to 30 tons', 30000.0),
    VehicleTypeModel('van', '🚐', 'Van', 'Up to 1.5 tons', 1500.0),
    VehicleTypeModel('tempo', '🚚', 'Tempo', 'Up to 3 tons', 3000.0),
    VehicleTypeModel('refrigeratedTruck', '🚚', 'Refrigerated Truck', 'Up to 10 tons', 10000.0),
  ].obs;

  final Rx<LoadTypeModel?> selectedLoadType = Rx<LoadTypeModel?>(null);
  final Rx<VehicleTypeModel?> selectedVehicleType = Rx<VehicleTypeModel?>(null);

  final TextEditingController weightController = TextEditingController();
  final TextEditingController dimensionsController = TextEditingController();

  // Enhanced Location Management
  final RxString pickupLocation = ''.obs;
  final RxString deliveryLocation = ''.obs;
  final RxBool isPickupLocationSelected = false.obs;
  final RxBool isDeliveryLocationSelected = false.obs;
  final RxMap<String, dynamic> pickupCoordinates = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> deliveryCoordinates = <String, dynamic>{}.obs;
  final RxDouble calculatedDistance = 0.0.obs;
  final RxString estimatedTravelTime = ''.obs;

  // Date & Time
  final Rx<DateTime?> selectedPickupDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedDeliveryDate = Rx<DateTime?>(null);
  final RxBool isUrgent = false.obs;
  final RxBool isFlexibleTiming = false.obs;

  // Budget
  final TextEditingController budgetController = TextEditingController();
  final RxDouble estimatedCost = 0.0.obs;
  final RxDouble minEstimatedCost = 0.0.obs;
  final RxDouble maxEstimatedCost = 0.0.obs;
  final RxString budgetRange = 'Enter your budget'.obs;

  // Requirements
  final RxList<String> commonRequirements = <String>[
    'Loading/Unloading help',
    'GPS tracking',
    'Insurance coverage',
    'Express delivery',
    'Fragile handling',
    'Temperature controlled',
    'Documentation support',
    'Warehouse facility',
    'Packaging service',
    'Real-time updates',
    'Multiple pickup points',
    'Weekend delivery',
    'Night delivery',
    'Return trip available',
  ].obs;

  final RxList<String> requirements = <String>[].obs;
  final TextEditingController specialInstructionsController = TextEditingController();

  // Enhanced Contact Information with Comprehensive Country Support
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final RxString selectedCountryCode = '+91'.obs; // Default to India
  final RxString selectedCountryDialCode = 'IN'.obs;
  final RxString selectedCountryFlag = '🇮🇳'.obs;
  final RxString selectedCountryName = 'India'.obs;
  final RxBool isPhoneValid = false.obs;
  final RxString phoneValidationMessage = ''.obs;

  // Additional Contact Options
  final TextEditingController alternatePhoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxBool hasAlternateContact = false.obs;

  // Images
  final RxList<String> selectedImages = <String>[].obs;
  final RxList<Map<String, dynamic>> imageMetadata = <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCalculatingCost = false.obs;
  final RxBool isValidatingPhone = false.obs;

  // Form validation states
  final RxBool isFormValid = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Advanced features
  final RxBool enableNotifications = true.obs;
  final RxBool shareLocationWithTransporter = true.obs;
  final RxBool allowBidNegotiation = true.obs;
  final RxString preferredLanguage = 'en'.obs;

  // Load posting history and preferences
  final RxList<Map<String, dynamic>> loadPostingHistory = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> userPreferences = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
    _loadUserPreferences();
    _setupFormValidation();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _disposeControllers() {
    titleController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    dimensionsController.dispose();
    budgetController.dispose();
    specialInstructionsController.dispose();
    contactPersonController.dispose();
    contactPhoneController.dispose();
    alternatePhoneController.dispose();
    emailController.dispose();
  }

  void _initializeForm() {
    // Set default pickup date to tomorrow
    selectedPickupDate.value = DateTime.now().add(const Duration(days: 1));
    _loadLastUsedSettings();
  }

  void _setupFormValidation() {
    // Listen to form changes for real-time validation
    ever(selectedLoadType, (_) => _validateForm());
    ever(selectedVehicleType, (_) => _validateForm());
    ever(isPickupLocationSelected, (_) => _validateForm());
    ever(isDeliveryLocationSelected, (_) => _validateForm());
    ever(selectedPickupDate, (_) => _validateForm());
    ever(isPhoneValid, (_) => _validateForm());

    // Listen to text field changes
    weightController.addListener(() {
      _validateWeight(weightController.text);
      _calculateEstimatedCost();
    });
    budgetController.addListener(() {
      _validateBudget(budgetController.text);
      _updateBudgetRange();
    });
    contactPhoneController.addListener(() => _validatePhoneNumber());
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      if (prefsJson != null) {
        userPreferences.value = json.decode(prefsJson);
        _applyUserPreferences();
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  void _applyUserPreferences() {
    final prefs = userPreferences.value;
    if (prefs.isNotEmpty) {
      selectedCountryCode.value = prefs['country_code'] ?? '+91';
      selectedCountryDialCode.value = prefs['country_dial_code'] ?? 'IN';
      selectedCountryFlag.value = prefs['country_flag'] ?? '🇮🇳';
      selectedCountryName.value = prefs['country_name'] ?? 'India';
      preferredLanguage.value = prefs['preferred_language'] ?? 'en';
      enableNotifications.value = prefs['enable_notifications'] ?? true;
      shareLocationWithTransporter.value = prefs['share_location'] ?? true;
      allowBidNegotiation.value = prefs['allow_negotiation'] ?? true;
    }
  }

  Future<void> _saveUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userPreferences.value = {
        'country_code': selectedCountryCode.value,
        'country_dial_code': selectedCountryDialCode.value,
        'country_flag': selectedCountryFlag.value,
        'country_name': selectedCountryName.value,
        'preferred_language': preferredLanguage.value,
        'enable_notifications': enableNotifications.value,
        'share_location': shareLocationWithTransporter.value,
        'allow_negotiation': allowBidNegotiation.value,
        'last_updated': DateTime.now().toIso8601String(),
      };
      await prefs.setString('user_preferences', json.encode(userPreferences.value));
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
    }
  }

  Future<void> _loadLastUsedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSettingsJson = prefs.getString('last_load_settings');
      if (lastSettingsJson != null) {
        final settings = json.decode(lastSettingsJson);

        if (settings['contact_person'] != null) {
          contactPersonController.text = settings['contact_person'];
        }
        if (settings['contact_phone'] != null) {
          contactPhoneController.text = settings['contact_phone'];
        }
        if (settings['email'] != null) {
          emailController.text = settings['email'];
        }
      }
    } catch (e) {
      debugPrint('Error loading last used settings: $e');
    }
  }

  // Selection methods
  void selectLoadType(LoadTypeModel loadType) {
    selectedLoadType.value = loadType;
    _calculateEstimatedCost();
    _saveFieldData('load_type', loadType.toJson());
  }

  void selectVehicleType(VehicleTypeModel vehicleType) {
    selectedVehicleType.value = vehicleType;
    _calculateEstimatedCost();
    _saveFieldData('vehicle_type', vehicleType.toJson());
  }

  void toggleRequirement(String requirement) {
    if (requirements.contains(requirement)) {
      requirements.remove(requirement);
    } else {
      requirements.add(requirement);
    }
    _calculateEstimatedCost();
  }

  // Country Code and Phone Validation
  void onCountryChanged(CountryCode countryCode) {
    selectedCountryCode.value = countryCode.dialCode!;
    selectedCountryDialCode.value = countryCode.code!;
    selectedCountryFlag.value = countryCode.flagUri ?? '';
    selectedCountryName.value = countryCode.name ?? '';

    isPhoneValid.value = false;
    phoneValidationMessage.value = '';

    if (contactPhoneController.text.isNotEmpty) {
      _validatePhoneNumber();
    }

    _saveUserPreferences();
  }

  void _validatePhoneNumber() async {
    final phoneText = contactPhoneController.text.trim();

    if (phoneText.isEmpty) {
      isPhoneValid.value = false;
      phoneValidationMessage.value = '';
      return;
    }

    isValidatingPhone.value = true;

    try {
      final cleanPhone = phoneText.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanPhone.length < 4) {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'Phone number too short';
        return;
      }

      try {
        final fullNumber = '${selectedCountryCode.value}$cleanPhone';
        final phoneNumber = PhoneNumber.parse(fullNumber);

        if (phoneNumber.isValid()) {
          isPhoneValid.value = true;
          phoneValidationMessage.value = 'Valid phone number';
        } else {
          _performManualValidation(cleanPhone);
        }
      } catch (e) {
        _performManualValidation(cleanPhone);
      }
    } catch (e) {
      isPhoneValid.value = false;
      phoneValidationMessage.value = 'Invalid phone number format';
    } finally {
      isValidatingPhone.value = false;
    }
  }

  void _performManualValidation(String cleanPhone) {
    final countryCode = selectedCountryDialCode.value;

    switch (countryCode) {
      case 'IN': // India
        _validateIndianPhone(cleanPhone);
        break;
      case 'US': // United States
      case 'CA': // Canada
        _validateUSCanadaPhone(cleanPhone);
        break;
      case 'GB': // United Kingdom
        _validateUKPhone(cleanPhone);
        break;
      case 'AU': // Australia
        _validateAustralianPhone(cleanPhone);
        break;
      case 'AE': // UAE
        _validateUAEPhone(cleanPhone);
        break;
      case 'EG': // Egypt
        _validateEgyptianPhone(cleanPhone);
        break;
      default:
        _validateGenericPhone(cleanPhone);
    }
  }

  void _validateIndianPhone(String cleanPhone) {
    if (cleanPhone.length == 10) {
      final mobileRegex = RegExp(r'^[6-9]\d{9}$');
      if (mobileRegex.hasMatch(cleanPhone)) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid Indian mobile number';
      } else {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'Indian mobile numbers start with 6, 7, 8, or 9';
      }
    } else {
      isPhoneValid.value = false;
      phoneValidationMessage.value = 'Indian numbers should be 10 digits';
    }
  }

  void _validateUSCanadaPhone(String cleanPhone) {
    if (cleanPhone.length == 10) {
      final usRegex = RegExp(r'^[2-9]\d{2}[2-9]\d{6}$');
      if (usRegex.hasMatch(cleanPhone)) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid ${selectedCountryName.value} phone number';
      } else {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'Invalid ${selectedCountryName.value} phone format';
      }
    } else {
      isPhoneValid.value = false;
      phoneValidationMessage.value = '${selectedCountryName.value} numbers should be 10 digits';
    }
  }

  void _validateUKPhone(String cleanPhone) {
    if (cleanPhone.length >= 10 && cleanPhone.length <= 11) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }
      if (cleanPhone.length >= 9 && cleanPhone.length <= 10) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid UK phone number';
      } else {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'UK numbers should be 10-11 digits';
      }
    } else {
      isPhoneValid.value = false;
      phoneValidationMessage.value = 'UK numbers should be 10-11 digits';
    }
  }

  void _validateAustralianPhone(String cleanPhone) {
    if (cleanPhone.length == 9) {
      final mobileRegex = RegExp(r'^[45]\d{8}$');
      final landlineRegex = RegExp(r'^[2378]\d{8}$');
      if (mobileRegex.hasMatch(cleanPhone) || landlineRegex.hasMatch(cleanPhone)) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid Australian phone number';
      } else {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'Invalid Australian phone format';
      }
    } else {
      isPhoneValid.value = false;
      phoneValidationMessage.value = 'Australian numbers should be 9 digits';
    }
  }

  void _validateUAEPhone(String cleanPhone) {
    if (cleanPhone.length == 9) {
      final uaeRegex = RegExp(r'^[245679]\d{8}$');
      if (uaeRegex.hasMatch(cleanPhone)) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid UAE phone number';
      } else {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'UAE mobile numbers start with 2, 4, 5, 6, 7, or 9';
      }
    } else {
      isPhoneValid.value = false;
      phoneValidationMessage.value = 'UAE numbers should be 9 digits';
    }
  }

  void _validateEgyptianPhone(String cleanPhone) {
    if (cleanPhone.length == 10) {
      final landlineRegex = RegExp(r'^[23]\d{8}$');
      if (landlineRegex.hasMatch(cleanPhone)) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid Egyptian landline number';
        return;
      }
    }

    if (cleanPhone.length == 11) {
      final mobileRegex = RegExp(r'^1[0125]\d{8}$');
      if (mobileRegex.hasMatch(cleanPhone)) {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Valid Egyptian mobile number';
        return;
      }
    }

    isPhoneValid.value = false;
    phoneValidationMessage.value = 'Egyptian mobile: 11 digits (starts with 10, 11, 12, 15), landline: 10 digits';
  }

  void _validateGenericPhone(String cleanPhone) {
    if (cleanPhone.length >= 7 && cleanPhone.length <= 15) {
      if (RegExp(r'^0+$|^1+$').hasMatch(cleanPhone)) {
        isPhoneValid.value = false;
        phoneValidationMessage.value = 'Invalid phone number format';
      } else {
        isPhoneValid.value = true;
        phoneValidationMessage.value = 'Phone number appears valid';
      }
    } else {
      isPhoneValid.value = false;
      phoneValidationMessage.value = 'Phone numbers should be 7-15 digits';
    }
  }

  // Enhanced Location Methods
  void calculateDistance() {
    if (pickupCoordinates.isNotEmpty && deliveryCoordinates.isNotEmpty) {
      final double pickupLat = pickupCoordinates['lat']?.toDouble() ?? 0.0;
      final double pickupLng = pickupCoordinates['lng']?.toDouble() ?? 0.0;
      final double deliveryLat = deliveryCoordinates['lat']?.toDouble() ?? 0.0;
      final double deliveryLng = deliveryCoordinates['lng']?.toDouble() ?? 0.0;

      if (pickupLat != 0.0 && pickupLng != 0.0 && deliveryLat != 0.0 && deliveryLng != 0.0) {
        final double distance = _calculateHaversineDistance(
          pickupLat,
          pickupLng,
          deliveryLat,
          deliveryLng,
        );
        calculatedDistance.value = distance;
        _calculateEstimatedTravelTime(distance);
        _calculateEstimatedCost();
      }
    }
  }

  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _calculateEstimatedTravelTime(double distance) {
    if (distance <= 0) {
      estimatedTravelTime.value = '';
      return;
    }

    double averageSpeed = 45.0; // Default speed

    if (selectedVehicleType.value != null) {
      switch (selectedVehicleType.value!.id) {
        case 'bike':
          averageSpeed = 35.0;
          break;
        case 'auto':
          averageSpeed = 30.0;
          break;
        case 'pickup':
        case 'van':
          averageSpeed = 40.0;
          break;
        case 'miniTruck':
          averageSpeed = 35.0;
          break;
        case 'truck':
        case 'tempo':
          averageSpeed = 45.0;
          break;
        case 'trailer':
        case 'container':
          averageSpeed = 50.0;
          break;
      }
    }

    final double hours = distance / averageSpeed;

    if (hours < 1) {
      final int minutes = (hours * 60).round();
      estimatedTravelTime.value = '${minutes} min';
    } else if (hours < 24) {
      final int wholeHours = hours.floor();
      final int minutes = ((hours - wholeHours) * 60).round();
      if (minutes == 0) {
        estimatedTravelTime.value = '${wholeHours}h';
      } else {
        estimatedTravelTime.value = '${wholeHours}h ${minutes}m';
      }
    } else {
      final int days = (hours / 24).floor();
      final int remainingHours = (hours % 24).round();
      estimatedTravelTime.value = '${days}d ${remainingHours}h';
    }
  }

  // Date selection methods
  Future<void> selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedPickupDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedPickupDate.value = picked;

      if (calculatedDistance.value > 0) {
        int deliveryDays = 1;
        if (calculatedDistance.value > 500) {
          deliveryDays = 3;
        } else if (calculatedDistance.value > 200) {
          deliveryDays = 2;
        }

        selectedDeliveryDate.value = picked.add(Duration(days: deliveryDays));
      }
    }
  }

  Future<void> selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDeliveryDate.value ??
          (selectedPickupDate.value?.add(const Duration(days: 1)) ??
              DateTime.now().add(const Duration(days: 2))),
      firstDate: selectedPickupDate.value ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDeliveryDate.value = picked;
    }
  }

  // Enhanced Cost Calculation
  void _calculateEstimatedCost() {
    isCalculatingCost.value = true;

    try {
      final weight = double.tryParse(weightController.text) ?? 0.0;
      final distance = calculatedDistance.value;

      if (weight == 0.0 || distance == 0.0) {
        estimatedCost.value = 0.0;
        minEstimatedCost.value = 0.0;
        maxEstimatedCost.value = 0.0;
        return;
      }

      double baseRate = 15.0; // Default rate per km
      double weightMultiplier = 1.0;
      double vehicleMultiplier = 1.0;

      if (selectedVehicleType.value != null) {
        switch (selectedVehicleType.value!.id) {
          case 'bike':
            baseRate = 8.0;
            vehicleMultiplier = 0.8;
            break;
          case 'auto':
            baseRate = 10.0;
            vehicleMultiplier = 0.9;
            break;
          case 'pickup':
            baseRate = 12.0;
            vehicleMultiplier = 1.0;
            break;
          case 'miniTruck':
            baseRate = 15.0;
            vehicleMultiplier = 1.1;
            break;
          case 'van':
            baseRate = 14.0;
            vehicleMultiplier = 1.05;
            break;
          case 'truck':
            baseRate = 18.0;
            vehicleMultiplier = 1.2;
            break;
          case 'tempo':
            baseRate = 16.0;
            vehicleMultiplier = 1.15;
            break;
          case 'trailer':
            baseRate = 25.0;
            vehicleMultiplier = 1.4;
            break;
          case 'container':
            baseRate = 30.0;
            vehicleMultiplier = 1.6;
            break;
        }
      }

      double distanceMultiplier = 1.0;
      if (distance > 1000) {
        distanceMultiplier = 0.8;
      } else if (distance > 500) {
        distanceMultiplier = 0.9;
      } else if (distance < 50) {
        distanceMultiplier = 1.3;
      }

      if (weight > 5000) {
        weightMultiplier = 1.5;
      } else if (weight > 2000) {
        weightMultiplier = 1.3;
      } else if (weight > 1000) {
        weightMultiplier = 1.2;
      } else if (weight > 500) {
        weightMultiplier = 1.1;
      }

      double baseCost = distance * baseRate * distanceMultiplier * vehicleMultiplier * weightMultiplier;

      double loadTypeMultiplier = 1.0;
      if (selectedLoadType.value != null) {
        switch (selectedLoadType.value!.id) {
          case 'chemical':
          case 'pharmaceutical':
            loadTypeMultiplier = 1.4;
            break;
          case 'electronics':
          case 'fragile':
            loadTypeMultiplier = 1.3;
            break;
          case 'automotive':
          case 'furniture':
            loadTypeMultiplier = 1.2;
            break;
          case 'food':
            loadTypeMultiplier = 1.15;
            break;
          case 'documents':
            loadTypeMultiplier = 0.9;
            break;
          case 'agriculture':
            loadTypeMultiplier = 0.85;
            break;
        }
      }

      baseCost *= loadTypeMultiplier;

      if (isUrgent.value) {
        baseCost *= 1.4;
      }

      double requirementMultiplier = 1.0;
      for (final requirement in requirements) {
        switch (requirement) {
          case 'Insurance coverage':
            requirementMultiplier += 0.08;
            break;
          case 'GPS tracking':
            requirementMultiplier += 0.05;
            break;
          case 'Loading/Unloading help':
            requirementMultiplier += 0.12;
            break;
          case 'Temperature controlled':
            requirementMultiplier += 0.25;
            break;
          case 'Express delivery':
            requirementMultiplier += 0.20;
            break;
          case 'Fragile handling':
            requirementMultiplier += 0.15;
            break;
          case 'Packaging service':
            requirementMultiplier += 0.10;
            break;
          case 'Weekend delivery':
            requirementMultiplier += 0.18;
            break;
          case 'Night delivery':
            requirementMultiplier += 0.22;
            break;
          default:
            requirementMultiplier += 0.05;
        }
      }

      baseCost *= requirementMultiplier;

      final now = DateTime.now();
      final pickupDate = selectedPickupDate.value;
      if (pickupDate != null) {
        final daysDifference = pickupDate.difference(now).inDays;
        if (daysDifference < 1) {
          baseCost *= 1.5;
        } else if (daysDifference < 3) {
          baseCost *= 1.2;
        }
      }

      estimatedCost.value = baseCost;
      minEstimatedCost.value = baseCost * 0.85;
      maxEstimatedCost.value = baseCost * 1.25;

      const double minimumCost = 100.0;
      if (estimatedCost.value < minimumCost) {
        estimatedCost.value = minimumCost;
        minEstimatedCost.value = minimumCost * 0.9;
        maxEstimatedCost.value = minimumCost * 1.1;
      }

    } catch (e) {
      estimatedCost.value = 0.0;
      minEstimatedCost.value = 0.0;
      maxEstimatedCost.value = 0.0;
    } finally {
      isCalculatingCost.value = false;
    }
  }

  void _updateBudgetRange() {
    final budgetText = budgetController.text.trim();
    if (budgetText.isEmpty) {
      budgetRange.value = 'Enter your budget';
      return;
    }

    final budget = double.tryParse(budgetText);
    if (budget == null) {
      budgetRange.value = 'Invalid budget';
      return;
    }

    if (estimatedCost.value > 0) {
      final difference = budget - estimatedCost.value;
      final percentage = (difference / estimatedCost.value * 100);

      if (percentage > 20) {
        budgetRange.value = 'Above market rate (+${percentage.toStringAsFixed(0)}%)';
      } else if (percentage > 10) {
        budgetRange.value = 'Good budget (+${percentage.toStringAsFixed(0)}%)';
      } else if (percentage > -10) {
        budgetRange.value = 'Market rate';
      } else if (percentage > -20) {
        budgetRange.value = 'Below market rate (${percentage.toStringAsFixed(0)}%)';
      } else {
        budgetRange.value = 'Very low budget (${percentage.toStringAsFixed(0)}%)';
      }
    } else {
      budgetRange.value = '₹${budget.toStringAsFixed(0)}';
    }
  }

  // Image management
  Future<void> addImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // In production, you would upload to a server and get URL
        final imageUrl = 'file://${pickedFile.path}';
        selectedImages.add(imageUrl);
        imageMetadata.add({
          'url': imageUrl,
          'path': pickedFile.path,
          'timestamp': DateTime.now().toIso8601String(),
          'size': '${(await pickedFile.length())} bytes',
          'format': pickedFile.path.split('.').last,
        });

        Get.snackbar(
          'Success',
          'Image added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }

  void removeImage(String imageUrl) {
    final index = selectedImages.indexOf(imageUrl);
    if (index != -1) {
      selectedImages.removeAt(index);
      if (index < imageMetadata.length) {
        imageMetadata.removeAt(index);
      }
    }
  }

  // Validation methods
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      fieldErrors['title'] = 'Load title is required';
      return fieldErrors['title'];
    }
    if (value.trim().length < 3) {
      fieldErrors['title'] = 'Title must be at least 3 characters';
      return fieldErrors['title'];
    }
    if (value.trim().length > 100) {
      fieldErrors['title'] = 'Title cannot exceed 100 characters';
      return fieldErrors['title'];
    }
    fieldErrors.remove('title');
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      fieldErrors['weight'] = 'Weight is required';
      return fieldErrors['weight'];
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      fieldErrors['weight'] = 'Please enter a valid weight';
      return fieldErrors['weight'];
    }
    if (weight > 50000) {
      fieldErrors['weight'] = 'Weight cannot exceed 50,000 kg';
      return fieldErrors['weight'];
    }

    if (selectedVehicleType.value != null) {
      final maxCapacity = selectedVehicleType.value!.maxWeight;
      if (weight > maxCapacity) {
        fieldErrors['weight'] = 'Weight exceeds ${selectedVehicleType.value!.displayName} capacity (${maxCapacity.toStringAsFixed(0)} kg)';
        return fieldErrors['weight'];
      }
    }

    fieldErrors.remove('weight');
    return null;
  }

  String? _validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      fieldErrors['budget'] = 'Budget is required';
      return fieldErrors['budget'];
    }
    final budget = double.tryParse(value);
    if (budget == null || budget <= 0) {
      fieldErrors['budget'] = 'Please enter a valid budget';
      return fieldErrors['budget'];
    }
    if (budget < 50) {
      fieldErrors['budget'] = 'Minimum budget is ₹50';
      return fieldErrors['budget'];
    }
    if (budget > 1000000) {
      fieldErrors['budget'] = 'Maximum budget is ₹10,00,000';
      return fieldErrors['budget'];
    }
    fieldErrors.remove('budget');
    return null;
  }

  String? validateContactPerson(String? value) {
    if (value == null || value.trim().isEmpty) {
      fieldErrors['contact_person'] = 'Contact person name is required';
      return fieldErrors['contact_person'];
    }
    if (value.trim().length < 2) {
      fieldErrors['contact_person'] = 'Name must be at least 2 characters';
      return fieldErrors['contact_person'];
    }
    if (value.trim().length > 50) {
      fieldErrors['contact_person'] = 'Name cannot exceed 50 characters';
      return fieldErrors['contact_person'];
    }

    final nameRegex = RegExp(r"^[a-zA-Z\s\-\.\']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      fieldErrors['contact_person'] = 'Name can only contain letters, spaces, hyphens, periods, and apostrophes';
      return fieldErrors['contact_person'];
    }

    fieldErrors.remove('contact_person');
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      fieldErrors['email'] = 'Please enter a valid email address';
      return fieldErrors['email'];
    }

    fieldErrors.remove('email');
    return null;
  }

  String getFormattedPhoneNumber() {
    final phone = contactPhoneController.text.trim();
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '${selectedCountryCode.value} $cleanPhone';
  }

  void _saveFieldData(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('load_field_$key', json.encode(value));
    } catch (e) {
      debugPrint('Error saving field data: $e');
    }
  }

  void _validateForm() {
    bool isValid = true;

    if (selectedLoadType.value == null) isValid = false;
    if (selectedVehicleType.value == null) isValid = false;
    if (!isPickupLocationSelected.value) isValid = false;
    if (!isDeliveryLocationSelected.value) isValid = false;
    if (selectedPickupDate.value == null) isValid = false;
    if (!isPhoneValid.value) isValid = false;

    if (validateTitle(titleController.text) != null) isValid = false;
    if (_validateWeight(weightController.text) != null) isValid = false;
    if (_validateBudget(budgetController.text) != null) isValid = false;
    if (validateContactPerson(contactPersonController.text) != null) isValid = false;
    if (validateEmail(emailController.text) != null) isValid = false;

    isFormValid.value = isValid;
  }

  bool validateForm() {
    _validateForm();

    if (!isFormValid.value) {
      if (selectedLoadType.value == null) {
        _showValidationError('Please select a load type');
        return false;
      }

      if (selectedVehicleType.value == null) {
        _showValidationError('Please select a vehicle type');
        return false;
      }

      if (!isPickupLocationSelected.value) {
        _showValidationError('Please select a pickup location');
        return false;
      }

      if (!isDeliveryLocationSelected.value) {
        _showValidationError('Please select a delivery location');
        return false;
      }

      if (selectedPickupDate.value == null) {
        _showValidationError('Please select a pickup date');
        return false;
      }

      if (!isPhoneValid.value) {
        _showValidationError('Please enter a valid phone number');
        return false;
      }

      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      icon: const Icon(Icons.error_outline, color: Colors.red),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Helper methods to convert from controller models to LoadModel enums
  LoadType _convertStringToLoadType(String loadTypeId) {
    switch (loadTypeId) {
      case 'general':
        return LoadType.general;
      case 'electronics':
        return LoadType.electronics;
      case 'furniture':
        return LoadType.furniture;
      case 'automotive':
        return LoadType.automotive;
      case 'construction':
        return LoadType.construction;
      case 'chemical':
        return LoadType.chemical;
      case 'textile':
        return LoadType.textile;
      case 'food':
        return LoadType.food;
      case 'pharmaceutical':
        return LoadType.pharmaceutical;
      case 'documents':
        return LoadType.documents;
      case 'fragile':
        return LoadType.fragile;
      case 'agriculture':
        return LoadType.agriculture;
      default:
        return LoadType.general;
    }
  }

  VehicleType _convertStringToVehicleType(String vehicleTypeId) {
    switch (vehicleTypeId) {
      case 'bike':
        return VehicleType.bike;
      case 'auto':
        return VehicleType.auto;
      case 'pickup':
        return VehicleType.pickup;
      case 'miniTruck':
        return VehicleType.miniTruck;
      case 'truck':
        return VehicleType.truck;
      case 'trailer':
        return VehicleType.trailer;
      case 'container':
        return VehicleType.container;
      case 'van':
        return VehicleType.van;
      case 'tempo':
        return VehicleType.tempo;
      case 'refrigeratedTruck':
        return VehicleType.refrigeratedTruck;
      default:
        return VehicleType.truck;
    }
  }

  // MAIN FIX: Properly integrated Firestore saving
  Future<void> postLoad() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Posting your load...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final formattedPhone = getFormattedPhoneNumber();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Convert coordinates properly for LoadModel
      Map<String, double>? pickupCoords;
      Map<String, double>? deliveryCoords;

      if (pickupCoordinates.isNotEmpty) {
        pickupCoords = {
          'lat': (pickupCoordinates['lat'] ?? 0.0).toDouble(),
          'lng': (pickupCoordinates['lng'] ?? 0.0).toDouble(),
        };
      }

      if (deliveryCoordinates.isNotEmpty) {
        deliveryCoords = {
          'lat': (deliveryCoordinates['lat'] ?? 0.0).toDouble(),
          'lng': (deliveryCoordinates['lng'] ?? 0.0).toDouble(),
        };
      }

      // Create LoadModel instance for Firestore
      final loadModel = LoadModel(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        title: titleController.text.trim(),
        pickupLocation: pickupLocation.value,
        deliveryLocation: deliveryLocation.value,
        loadType: _convertStringToLoadType(selectedLoadType.value!.id),
        weight: double.parse(weightController.text),
        dimensions: dimensionsController.text.trim(),
        vehicleType: _convertStringToVehicleType(selectedVehicleType.value!.id),
        budget: double.parse(budgetController.text),
        pickupDate: selectedPickupDate.value!,
        deliveryDate: selectedDeliveryDate.value,
        status: LoadStatus.posted,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        bidsCount: 0,
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        requirements: requirements.toList(),
        contactPerson: contactPersonController.text.trim(),
        contactPhone: formattedPhone,
        isUrgent: isUrgent.value,
        distance: calculatedDistance.value > 0 ? calculatedDistance.value : null,
        pickupCoordinates: pickupCoords,
        deliveryCoordinates: deliveryCoords,
        minBudget: minEstimatedCost.value > 0 ? minEstimatedCost.value : null,
        maxBudget: maxEstimatedCost.value > 0 ? maxEstimatedCost.value : null,
        specialInstructions: specialInstructionsController.text.trim().isNotEmpty
            ? specialInstructionsController.text.trim()
            : null,
        images: selectedImages.toList(),
        isActive: true,
        viewCount: 0,
      );

      // Save to Firestore using FirestoreService
      final loadId = await FirestoreService.createLoad(loadModel);

      if (loadId == null) {
        throw Exception('Failed to create load in database');
      }

      // Create local history data (optional - for offline use)
      final loadData = {
        'id': loadId, // Use the actual Firestore document ID
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'loadType': selectedLoadType.value!.toJson(),
        'vehicleType': selectedVehicleType.value!.toJson(),
        'weight': double.parse(weightController.text),
        'dimensions': dimensionsController.text.trim(),
        'pickupLocation': {
          'address': pickupLocation.value,
          'coordinates': pickupCoordinates.value,
        },
        'deliveryLocation': {
          'address': deliveryLocation.value,
          'coordinates': deliveryCoordinates.value,
        },
        'distance': calculatedDistance.value,
        'estimatedTravelTime': estimatedTravelTime.value,
        'pickupDate': selectedPickupDate.value!.toIso8601String(),
        'deliveryDate': selectedDeliveryDate.value?.toIso8601String(),
        'isUrgent': isUrgent.value,
        'isFlexibleTiming': isFlexibleTiming.value,
        'budget': double.parse(budgetController.text),
        'estimatedCost': estimatedCost.value,
        'costRange': {
          'min': minEstimatedCost.value,
          'max': maxEstimatedCost.value,
        },
        'requirements': requirements.toList(),
        'specialInstructions': specialInstructionsController.text.trim(),
        'contactInfo': {
          'contactPerson': contactPersonController.text.trim(),
          'primaryPhone': formattedPhone,
          'alternatePhone': hasAlternateContact.value ? alternatePhoneController.text.trim() : null,
          'email': emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
          'countryCode': selectedCountryCode.value,
          'countryDialCode': selectedCountryDialCode.value,
          'countryName': selectedCountryName.value,
        },
        'images': selectedImages.toList(),
        'imageMetadata': imageMetadata.toList(),
        'preferences': {
          'enableNotifications': enableNotifications.value,
          'shareLocationWithTransporter': shareLocationWithTransporter.value,
          'allowBidNegotiation': allowBidNegotiation.value,
          'preferredLanguage': preferredLanguage.value,
        },
        'metadata': {
          'createdAt': DateTime.now().toIso8601String(),
          'platform': 'mobile',
          'version': '1.0.0',
          'userAgent': 'FreightFlow Flutter App',
        },
        'status': 'active',
        'bidCount': 0,
        'viewCount': 0,
      };

      // Add to local history
      loadPostingHistory.insert(0, loadData);
      await _saveLastUsedSettings();

      Get.back(); // Close progress dialog

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green[600], size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Load Posted Successfully!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your load has been posted and is now live on the platform.'),
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
                    Text('Load ID: $loadId', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Estimated Cost: ₹${estimatedCost.value.toStringAsFixed(0)}'),
                    Text('Expected Bids: ${_calculateExpectedBids()}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('You will receive notifications when transporters submit bids.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('View My Loads'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _resetForm();
              },
              child: const Text('Post Another Load'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to post load: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.error_outline, color: Colors.red),
        mainButton: TextButton(
          onPressed: () => postLoad(),
          child: const Text('Retry', style: TextStyle(color: Colors.red)),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveLastUsedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = {
        'contact_person': contactPersonController.text.trim(),
        'contact_phone': contactPhoneController.text.trim(),
        'email': emailController.text.trim(),
        'country_code': selectedCountryCode.value,
        'country_dial_code': selectedCountryDialCode.value,
        'requirements': requirements.toList(),
        'preferences': {
          'enableNotifications': enableNotifications.value,
          'shareLocationWithTransporter': shareLocationWithTransporter.value,
          'allowBidNegotiation': allowBidNegotiation.value,
        },
        'last_saved': DateTime.now().toIso8601String(),
      };
      await prefs.setString('last_load_settings', json.encode(settings));
    } catch (e) {
      debugPrint('Error saving last used settings: $e');
    }
  }

  int _calculateExpectedBids() {
    int baseBids = 3;

    if (calculatedDistance.value > 100 && calculatedDistance.value < 500) {
      baseBids += 2;
    }

    if (selectedVehicleType.value?.id == 'truck' || selectedVehicleType.value?.id == 'miniTruck') {
      baseBids += 2;
    }

    if (estimatedCost.value > 0) {
      final budget = double.tryParse(budgetController.text) ?? 0;
      if (budget >= estimatedCost.value) {
        baseBids += 1;
      }
      if (budget >= estimatedCost.value * 1.2) {
        baseBids += 2;
      }
    }

    if (isUrgent.value) {
      baseBids += 1;
    }

    return math.min(baseBids, 8);
  }

  void _resetForm() {
    titleController.clear();
    descriptionController.clear();
    weightController.clear();
    dimensionsController.clear();
    budgetController.clear();
    specialInstructionsController.clear();

    selectedLoadType.value = null;
    selectedVehicleType.value = null;

    pickupLocation.value = '';
    deliveryLocation.value = '';
    isPickupLocationSelected.value = false;
    isDeliveryLocationSelected.value = false;
    pickupCoordinates.clear();
    deliveryCoordinates.clear();
    calculatedDistance.value = 0.0;
    estimatedTravelTime.value = '';

    selectedPickupDate.value = DateTime.now().add(const Duration(days: 1));
    selectedDeliveryDate.value = null;

    requirements.clear();
    selectedImages.clear();
    imageMetadata.clear();

    isUrgent.value = false;
    isFlexibleTiming.value = false;
    hasAlternateContact.value = false;

    estimatedCost.value = 0.0;
    minEstimatedCost.value = 0.0;
    maxEstimatedCost.value = 0.0;
    budgetRange.value = 'Enter your budget';

    fieldErrors.clear();
    isFormValid.value = false;
  }
}