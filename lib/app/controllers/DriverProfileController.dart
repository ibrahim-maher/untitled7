import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes/app_pages.dart';

class DriverProfileController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var driverName = ''.obs;
  var driverPhone = ''.obs;
  var driverPhotoUrl = ''.obs;
  var isOnline = false.obs;
  var isVerified = false.obs;
  var totalTrips = 0.obs;
  var yearsExperience = 0.obs;
  var successRate = 0.0.obs;
  var averageRating = 0.0.obs;
  var totalReviews = 0.obs;

  // Rating breakdown
  var rating5Count = 0.obs;
  var rating4Count = 0.obs;
  var rating3Count = 0.obs;
  var rating2Count = 0.obs;
  var rating1Count = 0.obs;

  // Vehicle information
  var vehicleType = ''.obs;
  var vehicleNumber = ''.obs;
  var vehicleCapacity = ''.obs;
  var vehicleYear = 0.obs;
  var hasInsurance = false.obs;
  var hasTransportLicense = false.obs;

  // Recent trips
  var recentTrips = <Map<String, dynamic>>[].obs;

  String get driverId => Get.arguments?['driverId'] ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadDriverProfile();
  }

  void _loadDriverProfile() async {
    try {
      isLoading.value = true;

      // Get driver info from arguments or load from Firestore
      final args = Get.arguments ?? {};
      driverName.value = args['driverName'] ?? 'Driver Name';

      // In production, load actual driver data from Firestore
      await _mockLoadDriverData();

    } catch (e) {
      print('Error loading driver profile: $e');
      _showErrorSnackbar('Failed to load driver profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _mockLoadDriverData() async {
    // Mock data - replace with actual Firestore loading
    await Future.delayed(const Duration(seconds: 1));

    driverPhone.value = '+91 98765 43210';
    driverPhotoUrl.value = '';
    isOnline.value = true;
    isVerified.value = true;
    totalTrips.value = 245;
    yearsExperience.value = 5;
    successRate.value = 96.8;
    averageRating.value = 4.6;
    totalReviews.value = 89;

    // Rating breakdown
    rating5Count.value = 56;
    rating4Count.value = 22;
    rating3Count.value = 8;
    rating2Count.value = 2;
    rating1Count.value = 1;

    // Vehicle info
    vehicleType.value = 'Medium Truck';
    vehicleNumber.value = 'MH 12 AB 1234';
    vehicleCapacity.value = '5 Tons';
    vehicleYear.value = 2020;
    hasInsurance.value = true;
    hasTransportLicense.value = true;

    // Recent trips
    recentTrips.addAll([
      {
        'from': 'Mumbai',
        'to': 'Pune',
        'date': 'Mar 10, 2024',
        'rating': 5,
        'amount': 8500,
      },
      {
        'from': 'Delhi',
        'to': 'Jaipur',
        'date': 'Mar 8, 2024',
        'rating': 4,
        'amount': 12000,
      },
      {
        'from': 'Bangalore',
        'to': 'Chennai',
        'date': 'Mar 5, 2024',
        'rating': 5,
        'amount': 15000,
      },
    ]);
  }

  void callDriver() async {
    if (driverPhone.value.isNotEmpty) {
      try {
        final Uri phoneUri = Uri(scheme: 'tel', path: driverPhone.value);
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
      _showErrorSnackbar('Phone number not available');
    }
  }

  void messageDriver() {
    Get.toNamed(Routes.CHAT, arguments: {
      'recipientId': driverId,
      'recipientName': driverName.value,
    });
  }

  void viewAllReviews() {
    Get.snackbar(
      'Reviews',
      'Viewing all reviews for ${driverName.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // In production, navigate to reviews screen
  }

  void viewAllTrips() {
    Get.snackbar(
      'Trip History',
      'Viewing complete trip history',
      snackPosition: SnackPosition.BOTTOM,
    );
    // In production, navigate to trip history screen
  }

  void reportDriver() {
    Get.dialog(
      AlertDialog(
        title: const Text('Report Driver'),
        content: const Text(
          'Are you sure you want to report this driver? This action should only be taken for serious violations or safety concerns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _submitDriverReport();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _submitDriverReport() {
    Get.toNamed(Routes.SUPPORT, arguments: {
      'issueType': 'driver_report',
      'driverId': driverId,
      'driverName': driverName.value,
    });

    _showSuccessSnackbar('Report submitted successfully');
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

class DriverProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
  }
}