import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../data/models/LoadModel.dart';
import '../services/firestore_service.dart';

class RateShipmentController extends GetxController {
  final TextEditingController commentsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var isUploadingPhoto = false.obs;
  var shipment = Rxn<ShipmentModel>();

  // Rating variables
  var driverRating = 0.obs;
  var timelinessRating = 0.obs;
  var communicationRating = 0.obs;
  var handlingRating = 0.obs;
  var overallRating = 0.obs;

  // Feedback options
  var feedbackOptions = [
    'Professional Driver',
    'On-time Delivery',
    'Good Communication',
    'Careful Handling',
    'Clean Vehicle',
    'Helpful Attitude',
    'Smooth Process',
    'Fair Pricing',
    'Courteous Behavior',
    'Safe Driving',
    'Quick Response',
    'Problem Solving',
  ].obs;

  var selectedFeedback = <String>[].obs;
  var uploadedPhotos = <String>[].obs;
  var localPhotos = <File>[].obs;

  var canSubmit = false.obs;
  var charactersCount = 0.obs;

  String get shipmentId => Get.arguments?['shipmentId'] ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadShipmentData();
    _setupListeners();
  }

  @override
  void onClose() {
    commentsController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    // Watch for changes to enable/disable submit button
    ever(driverRating, (_) => _checkCanSubmit());
    ever(overallRating, (_) => _checkCanSubmit());

    // Watch comments character count
    commentsController.addListener(() {
      charactersCount.value = commentsController.text.length;
    });
  }

  void _loadShipmentData() async {
    try {
      isLoading.value = true;

      // Get shipment from arguments or load from Firestore
      final shipmentData = Get.arguments?['shipment'] as ShipmentModel?;
      if (shipmentData != null) {
        shipment.value = shipmentData;
      } else if (shipmentId.isNotEmpty) {
        final data = await FirestoreService.getShipmentById(shipmentId);
        shipment.value = data;
      }

      if (shipment.value == null) {
        throw Exception('Shipment not found');
      }
    } catch (e) {
      print('Error loading shipment: $e');
      _showErrorSnackbar('Failed to load shipment details');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  void setDriverRating(int rating) {
    driverRating.value = rating;
    _triggerHapticFeedback();
  }

  void setTimelinessRating(int rating) {
    timelinessRating.value = rating;
    _triggerHapticFeedback();
  }

  void setCommunicationRating(int rating) {
    communicationRating.value = rating;
    _triggerHapticFeedback();
  }

  void setHandlingRating(int rating) {
    handlingRating.value = rating;
    _triggerHapticFeedback();
  }

  void setOverallRating(int rating) {
    overallRating.value = rating;
    _triggerHapticFeedback();
  }

  void toggleFeedback(String feedback) {
    if (selectedFeedback.contains(feedback)) {
      selectedFeedback.remove(feedback);
    } else {
      selectedFeedback.add(feedback);
    }
    _triggerHapticFeedback();
  }

  void _checkCanSubmit() {
    canSubmit.value = driverRating.value > 0 && overallRating.value > 0;
  }

  // Photo upload functionality
  Future<void> uploadPhoto() async {
    try {
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        isUploadingPhoto.value = true;

        for (final pickedFile in pickedFiles) {
          if (uploadedPhotos.length + localPhotos.length >= 5) {
            _showWarningSnackbar('Maximum 5 photos allowed');
            break;
          }

          final file = File(pickedFile.path);
          localPhotos.add(file);

          // In production, upload to cloud storage
          // final downloadUrl = await StorageService.uploadImage(file);
          // uploadedPhotos.add(downloadUrl);

          // For now, add local path as placeholder
          uploadedPhotos.add(pickedFile.path);
        }
      }
    } catch (e) {
      print('Error uploading photo: $e');
      _showErrorSnackbar('Failed to upload photo');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> capturePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (uploadedPhotos.length >= 5) {
          _showWarningSnackbar('Maximum 5 photos allowed');
          return;
        }

        isUploadingPhoto.value = true;
        final file = File(pickedFile.path);
        localPhotos.add(file);
        uploadedPhotos.add(pickedFile.path);
      }
    } catch (e) {
      print('Error capturing photo: $e');
      _showErrorSnackbar('Failed to capture photo');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  void removePhoto(int index) {
    if (index < uploadedPhotos.length) {
      uploadedPhotos.removeAt(index);
      if (index < localPhotos.length) {
        localPhotos.removeAt(index);
      }
      _triggerHapticFeedback();
    }
  }

  // Submit rating with enhanced validation and error handling
  Future<void> submitRating() async {
    if (!canSubmit.value || isSubmitting.value) return;

    // Validate ratings
    if (!_validateRatings()) {
      return;
    }

    try {
      isSubmitting.value = true;

      // Upload photos first if any
      List<String> photoUrls = [];
      if (localPhotos.isNotEmpty) {
        for (final photo in localPhotos) {
          // In production, upload to cloud storage
          // final url = await StorageService.uploadImage(photo);
          // photoUrls.add(url);
          photoUrls.add(photo.path); // Placeholder
        }
      }

      final ratingData = {
        'shipmentId': shipmentId,
        'loadId': shipment.value?.loadId ?? '',
        'driverId': shipment.value?.transporterId ?? '',
        'driverRating': driverRating.value,
        'timelinessRating': timelinessRating.value,
        'communicationRating': communicationRating.value,
        'handlingRating': handlingRating.value,
        'overallRating': overallRating.value,
        'averageRating': _calculateAverageRating(),
        'selectedFeedback': selectedFeedback.toList(),
        'comments': commentsController.text.trim(),
        'photoUrls': photoUrls,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'userId': 'current_user_id', // Replace with actual user ID
        'userName': 'Current User', // Replace with actual user name
        'shipmentAmount': shipment.value?.totalAmount ?? 0,
        'route': {
          'pickup': shipment.value?.pickupLocation ?? '',
          'delivery': shipment.value?.deliveryLocation ?? '',
        },
      };

      // Save rating to Firestore
      await FirestoreService.saveShipmentRating(ratingData);

      // Update shipment with rating
      await _updateShipmentRating();

      // Update driver's average rating
      await _updateDriverRating();

      _showSuccessSnackbar('Thank you for your feedback!');

      // Navigate back with result
      Get.back(result: {
        'rated': true,
        'overallRating': overallRating.value,
      });

    } catch (e) {
      print('Error submitting rating: $e');
      _showErrorSnackbar('Failed to submit rating. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _validateRatings() {
    if (overallRating.value == 0) {
      _showWarningSnackbar('Please rate your overall experience');
      return false;
    }

    if (driverRating.value == 0) {
      _showWarningSnackbar('Please rate your driver');
      return false;
    }

    if (commentsController.text.length > 500) {
      _showWarningSnackbar('Comments cannot exceed 500 characters');
      return false;
    }

    return true;
  }

  double _calculateAverageRating() {
    final ratings = [
      driverRating.value,
      timelinessRating.value > 0 ? timelinessRating.value : overallRating.value,
      communicationRating.value > 0 ? communicationRating.value : overallRating.value,
      handlingRating.value > 0 ? handlingRating.value : overallRating.value,
      overallRating.value,
    ];

    final validRatings = ratings.where((rating) => rating > 0).toList();
    if (validRatings.isEmpty) return 0;

    return validRatings.reduce((a, b) => a + b) / validRatings.length;
  }

  Future<void> _updateShipmentRating() async {
    if (shipment.value != null) {
      final updateData = {
        'rating': overallRating.value,
        'averageRating': _calculateAverageRating(),
        'isRated': true,
        'ratedAt': DateTime.now(),
      };

      await FirestoreService.updateShipment(shipmentId, updateData);
    }
  }

  Future<void> _updateDriverRating() async {
    if (shipment.value?.transporterId != null) {
      // In production, update driver's overall rating
      // await FirestoreService.updateDriverRating(
      //   shipment.value!.transporterId!,
      //   driverRating.value,
      // );
    }
  }

  void skipRating() {
    Get.dialog(
      AlertDialog(
        title: const Text('Skip Rating?'),
        content: const Text(
          'Your feedback helps us improve our service. Are you sure you want to skip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Rating'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(result: {'rated': false}); // Go back to previous screen
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void refreshData() {
    _loadShipmentData();
  }

  // Enhanced notification methods
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[700],
      icon: const Icon(Icons.error_outline, color: Colors.red),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _showWarningSnackbar(String message) {
    Get.snackbar(
      'Warning',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[700],
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.orange),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _triggerHapticFeedback() {
    // Add haptic feedback for better UX
    // HapticFeedback.lightImpact();
  }

  // Utility methods for rating analysis
  bool get hasHighRating => overallRating.value >= 4;
  bool get hasLowRating => overallRating.value > 0 && overallRating.value <= 2;
  bool get isPositiveFeedback => selectedFeedback.length >= 3;

  String get ratingCategory {
    if (overallRating.value == 0) return 'Not Rated';
    if (overallRating.value <= 2) return 'Needs Improvement';
    if (overallRating.value == 3) return 'Average';
    if (overallRating.value == 4) return 'Good';
    return 'Excellent';
  }

  Map<String, dynamic> get ratingsSummary => {
    'overall': overallRating.value,
    'driver': driverRating.value,
    'timeliness': timelinessRating.value,
    'communication': communicationRating.value,
    'handling': handlingRating.value,
    'average': _calculateAverageRating(),
    'category': ratingCategory,
    'feedback_count': selectedFeedback.length,
    'has_comments': commentsController.text.trim().isNotEmpty,
    'has_photos': uploadedPhotos.isNotEmpty,
  };
}

class RateShipmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RateShipmentController>(() => RateShipmentController());
  }
}