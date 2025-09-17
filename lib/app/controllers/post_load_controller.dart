import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../generated/l10n/app_localizations.dart';
import 'auth_controller.dart';
import '../data/models/LoadModel.dart';
import '../services/firestore_service.dart';
import '../routes/app_pages.dart';

class PostLoadController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Form Controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController dimensionsController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController specialInstructionsController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var isPickupLocationSelected = false.obs;
  var isDeliveryLocationSelected = false.obs;
  var selectedLoadType = LoadType.general.obs;
  var selectedVehicleType = VehicleType.truck.obs;
  var selectedPickupDate = DateTime.now().obs;
  var selectedDeliveryDate = Rxn<DateTime>();
  var isUrgent = false.obs;
  var pickupLocation = ''.obs;
  var deliveryLocation = ''.obs;
  var pickupCoordinates = Rxn<Map<String, double>>();
  var deliveryCoordinates = Rxn<Map<String, double>>();
  var selectedImages = <String>[].obs;
  var requirements = <String>[].obs;

  // Available options
  final List<LoadType> loadTypes = LoadType.values;
  final List<VehicleType> vehicleTypes = VehicleType.values;
  final List<String> commonRequirements = [
    'Loading assistance required',
    'Unloading assistance required',
    'Insurance coverage needed',
    'Fragile items - handle with care',
    'Temperature controlled transport',
    'Express delivery required',
    'Documentation support needed',
    'Multi-stop delivery',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initializeForm() {
    // Set default pickup date to tomorrow
    selectedPickupDate.value = DateTime.now().add(const Duration(days: 1));

    // Pre-fill contact information if available
    final user = _authController.currentUser.value;
    if (user != null) {
      contactPersonController.text = user.name;
      // Add phone number if available in user model
    }
  }

  void _disposeControllers() {
    titleController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    dimensionsController.dispose();
    budgetController.dispose();
    contactPersonController.dispose();
    contactPhoneController.dispose();
    specialInstructionsController.dispose();
  }

  // Validation methods
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Load title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Please enter a valid weight';
    }
    if (weight > 50000) {
      return 'Weight cannot exceed 50,000 kg';
    }
    return null;
  }

  String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget is required';
    }
    final budget = double.tryParse(value);
    if (budget == null || budget <= 0) {
      return 'Please enter a valid budget';
    }
    if (budget < 100) {
      return 'Minimum budget is ₹100';
    }
    return null;
  }

  String? validateContactPerson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact person name is required';
    }
    return null;
  }

  String? validateContactPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact phone is required';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Location selection
  void selectPickupLocation() async {
    // This would open a location picker
    // For now, showing a placeholder
    final location = await _showLocationPicker('Select Pickup Location');
    if (location != null) {
      pickupLocation.value = location['address'] ?? '';
      pickupCoordinates.value = location['coordinates'];
      isPickupLocationSelected.value = true;
    }
  }

  void selectDeliveryLocation() async {
    final location = await _showLocationPicker('Select Delivery Location');
    if (location != null) {
      deliveryLocation.value = location['address'] ?? '';
      deliveryCoordinates.value = location['coordinates'];
      isDeliveryLocationSelected.value = true;
    }
  }

  Future<Map<String, dynamic>?> _showLocationPicker(String title) async {
    // Placeholder for location picker
    // In a real app, this would integrate with Google Places API
    return await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: Text(title),
        content: const SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.my_location),
                title: Text('Use Current Location'),
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Search Location'),
              ),
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Select on Map'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Mock location data
              Get.back(result: {
                'address': 'Mumbai, Maharashtra, India',
                'coordinates': {'lat': 19.0760, 'lng': 72.8777},
              });
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  // Date selection
  void selectPickupDate() async {
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: selectedPickupDate.value,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (date != null) {
      selectedPickupDate.value = date;

      // Auto-set delivery date if not set
      if (selectedDeliveryDate.value == null) {
        selectedDeliveryDate.value = date.add(const Duration(days: 2));
      }
    }
  }

  void selectDeliveryDate() async {
    final minDate = selectedPickupDate.value.add(const Duration(hours: 1));
    final date = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: selectedDeliveryDate.value ?? minDate,
        firstDate: minDate,
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (date != null) {
      selectedDeliveryDate.value = date;
    }
  }

  // Load type and vehicle type selection
  void selectLoadType(LoadType type) {
    selectedLoadType.value = type;

    // Auto-suggest vehicle type based on load type
    _suggestVehicleType(type);
  }

  void selectVehicleType(VehicleType type) {
    selectedVehicleType.value = type;
  }

  void _suggestVehicleType(LoadType loadType) {
    switch (loadType) {
      case LoadType.electronics:
      case LoadType.pharmaceutical:
        selectedVehicleType.value = VehicleType.van;
        break;
      case LoadType.construction:
      case LoadType.chemical:
        selectedVehicleType.value = VehicleType.truck;
        break;
      case LoadType.furniture:
        selectedVehicleType.value = VehicleType.lorry;
        break;
      case LoadType.documents:
        selectedVehicleType.value = VehicleType.bike;
        break;
      default:
        selectedVehicleType.value = VehicleType.truck;
        break;
    }
  }

  // Requirements management
  void toggleRequirement(String requirement) {
    if (requirements.contains(requirement)) {
      requirements.remove(requirement);
    } else {
      requirements.add(requirement);
    }
  }

  void addCustomRequirement(String requirement) {
    if (requirement.trim().isNotEmpty && !requirements.contains(requirement)) {
      requirements.add(requirement.trim());
    }
  }

  // Image handling
  void addImage() async {
    // Placeholder for image picker
    // In real implementation, use image_picker package
    Get.snackbar(
      'Info',
      'Image picker will be implemented with image_picker package',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeImage(String imageUrl) {
    selectedImages.remove(imageUrl);
  }

  // Form submission
  void postLoad() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackbar('Please login to post a load');
        return;
      }

      final load = LoadModel(
        id: '', // Will be set by Firestore
        userId: user.uid,
        title: titleController.text.trim(),
        pickupLocation: pickupLocation.value,
        deliveryLocation: deliveryLocation.value,
        loadType: selectedLoadType.value,
        weight: double.parse(weightController.text),
        dimensions: dimensionsController.text.trim(),
        vehicleType: selectedVehicleType.value,
        budget: double.parse(budgetController.text),
        pickupDate: selectedPickupDate.value,
        deliveryDate: selectedDeliveryDate.value,
        status: LoadStatus.posted,
        createdAt: DateTime.now(),
        description: descriptionController.text.trim().isNotEmpty
            ? descriptionController.text.trim()
            : null,
        requirements: requirements,
        contactPerson: contactPersonController.text.trim(),
        contactPhone: contactPhoneController.text.trim(),
        isUrgent: isUrgent.value,
        pickupCoordinates: pickupCoordinates.value,
        deliveryCoordinates: deliveryCoordinates.value,
        specialInstructions: specialInstructionsController.text.trim().isNotEmpty
            ? specialInstructionsController.text.trim()
            : null,
        images: selectedImages,
      );

      final loadId = await FirestoreService.createLoad(load);

      if (loadId != null) {
        _showSuccessSnackbar('Load posted successfully!');

        // Navigate to load details or back to home
        // Get.offNamed(Routes.LOAD_DETAILS, parameters: {'id': loadId});
      } else {
        _showErrorSnackbar('Failed to post load. Please try again.');
      }

    } catch (e) {
      print('Error posting load: $e');
      _showErrorSnackbar('An error occurred while posting the load');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!isPickupLocationSelected.value) {
      _showErrorSnackbar('Please select pickup location');
      return false;
    }

    if (!isDeliveryLocationSelected.value) {
      _showErrorSnackbar('Please select delivery location');
      return false;
    }

    if (selectedPickupDate.value.isBefore(DateTime.now())) {
      _showErrorSnackbar('Pickup date cannot be in the past');
      return false;
    }

    if (selectedDeliveryDate.value != null &&
        selectedDeliveryDate.value!.isBefore(selectedPickupDate.value)) {
      _showErrorSnackbar('Delivery date cannot be before pickup date');
      return false;
    }

    return true;
  }

  // Save as draft
  void saveAsDraft() async {
    try {
      isLoading.value = true;

      // Save form data to local storage or Firestore as draft
      Get.snackbar(
        'Draft Saved',
        'Load saved as draft successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[700],
      );

    } catch (e) {
      _showErrorSnackbar('Failed to save draft');
    } finally {
      isLoading.value = false;
    }
  }

  // Load from template
  void loadFromTemplate() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Load Template',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Choose from your recent loads or create a new template'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recent Load #1'),
              subtitle: const Text('Electronics - Mumbai to Delhi'),
              onTap: () {
                Get.back();
                _loadTemplateData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create New Template'),
              onTap: () {
                Get.back();
                // Navigate to template creation
              },
            ),
          ],
        ),
      ),
    );
  }

  void _loadTemplateData() {
    // Load template data into form
    titleController.text = 'Electronics Shipment';
    selectedLoadType.value = LoadType.electronics;
    selectedVehicleType.value = VehicleType.van;
    weightController.text = '500';
    dimensionsController.text = '4x3x2 feet';

    Get.snackbar(
      'Template Loaded',
      'Form filled with template data',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Utility methods
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

  // Calculate estimated cost
  double calculateEstimatedCost() {
    final weight = double.tryParse(weightController.text) ?? 0;
    final distance = 500.0; // Mock distance in km

    // Basic cost calculation formula
    double baseCost = weight * 10; // ₹10 per kg
    double distanceCost = distance * 5; // ₹5 per km
    double vehicleMultiplier = _getVehicleMultiplier();

    return (baseCost + distanceCost) * vehicleMultiplier;
  }

  double _getVehicleMultiplier() {
    switch (selectedVehicleType.value) {
      case VehicleType.bike:
        return 0.5;
      case VehicleType.auto:
        return 0.7;
      case VehicleType.miniTruck:
        return 1.0;
      case VehicleType.truck:
        return 1.2;
      case VehicleType.lorry:
        return 1.5;
      case VehicleType.container:
        return 2.0;
      default:
        return 1.0;
    }
  }
}