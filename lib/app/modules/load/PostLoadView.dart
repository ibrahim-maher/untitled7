import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/data/models/LoadModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../controllers/post_load_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';

class PostLoadView extends GetView<PostLoadController> {
  const PostLoadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Post Load'),
        elevation: 0,

      ),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: LoadingWidget(message: 'Posting your load...'))
            : Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                _buildProgressIndicator(context, l10n),
                const SizedBox(height: 24),

                // Basic Information Section
                _buildSectionCard(
                  context,
                  'Basic Information',
                  Icons.info_outline,
                  [
                    CustomTextField(
                      label: 'Load Title *',
                      hint: 'e.g., Electronics Shipment, Furniture Move',
                      controller: controller.titleController,
                      validator: controller.validateTitle,
                      prefixIcon: const Icon(Icons.title),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      hint: 'Describe your load in detail',
                      controller: controller.descriptionController,
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ],
                ),

                // Load Details Section
                _buildSectionCard(
                  context,
                  'Load Details',
                  Icons.inventory,
                  [
                    _buildLoadTypeSelector(context),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Weight (kg) *',
                            hint: '0',
                            controller: controller.weightController,
                            keyboardType: TextInputType.number,
                            validator: controller.validateWeight,
                            prefixIcon: const Icon(Icons.fitness_center),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'Dimensions',
                            hint: 'L x W x H (feet)',
                            controller: controller.dimensionsController,
                            prefixIcon: const Icon(Icons.straighten),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildVehicleTypeSelector(context),
                  ],
                ),

                // Location Section
                _buildSectionCard(
                  context,
                  'Pickup & Delivery',
                  Icons.location_on,
                  [
                    _buildLocationSelector(
                      context,
                      'Pickup Location *',
                      controller.pickupLocation.value,
                      controller.isPickupLocationSelected.value,
                      controller.selectPickupLocation,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildLocationSelector(
                      context,
                      'Delivery Location *',
                      controller.deliveryLocation.value,
                      controller.isDeliveryLocationSelected.value,
                      controller.selectDeliveryLocation,
                      Icons.location_on,
                    ),
                  ],
                ),

                // Date & Time Section
                _buildSectionCard(
                  context,
                  'Schedule',
                  Icons.schedule,
                  [
                    _buildDateSelector(
                      context,
                      'Pickup Date *',
                      controller.selectedPickupDate.value,
                      controller.selectPickupDate,
                    ),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      context,
                      'Preferred Delivery Date',
                      controller.selectedDeliveryDate.value,
                      controller.selectDeliveryDate,
                      isOptional: true,
                    ),
                    const SizedBox(height: 16),
                    _buildUrgentToggle(context),
                  ],
                ),

                // Budget Section
                _buildSectionCard(
                  context,
                  'Budget',
                  Icons.currency_rupee,
                  [
                    CustomTextField(
                      label: 'Budget (₹) *',
                      hint: '0',
                      controller: controller.budgetController,
                      keyboardType: TextInputType.number,
                      validator: controller.validateBudget,
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                    const SizedBox(height: 12),
                    // Obx(() => _buildEstimatedCost(context)),
                  ],
                ),

                // Requirements Section
                _buildSectionCard(
                  context,
                  'Special Requirements',
                  Icons.checklist,
                  [
                    _buildRequireme`ntsList(context),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Additional Instructions',
                      hint: 'Any special handling instructions',
                      controller: controller.specialInstructionsController,
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.note),
                    ),
                  ],
                ),

                // Contact Information Section
                _buildSectionCard(
                  context,
                  'Contact Information',
                  Icons.contact_phone,
                  [
                    CustomTextField(
                      label: 'Contact Person *',
                      hint: 'Full name',
                      controller: controller.contactPersonController,
                      validator: controller.validateContactPerson,
                      prefixIcon: const Icon(Icons.person),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Contact Phone *',
                      hint: '+91 9876543210',
                      controller: controller.contactPhoneController,
                      keyboardType: TextInputType.phone,
                      validator: controller.validateContactPhone,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ],
                ),

                // Images Section
                _buildSectionCard(
                  context,
                  'Load Images (Optional)',
                  Icons.image,
                  [
                    _buildImageSelector(context),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'Post Load',
                  onPressed: controller.postLoad,
                  isLoading: controller.isLoading.value,
                ),

                const SizedBox(height: 16),

                // Terms and conditions
                Text(
                  'By posting this load, you agree to our Terms of Service and Privacy Policy.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fill in the details below to post your load and receive bids from transporters',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      BuildContext context,
      String title,
      IconData icon,
      List<Widget> children,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Load Type *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.loadTypes.map((loadType) {
            final isSelected = controller.selectedLoadType.value == loadType;
            return FilterChip(
              label: Text(loadType.displayName),
              selected: isSelected,
              onSelected: (_) => controller.selectLoadType(loadType),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildVehicleTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Vehicle Type *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.vehicleTypes.map((vehicleType) {
            final isSelected = controller.selectedVehicleType.value == vehicleType;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vehicleType.icon),
                  const SizedBox(width: 4),
                  Text(vehicleType.displayName),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => controller.selectVehicleType(vehicleType),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildLocationSelector(
      BuildContext context,
      String label,
      String value,
      bool isSelected,
      VoidCallback onTap,
      IconData icon,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? value : 'Tap to select location',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.black87 : Colors.grey[500],
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
      BuildContext context,
      String label,
      DateTime? date,
      VoidCallback onTap, {
        bool isOptional = false,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy - EEEE').format(date)
                        : isOptional
                        ? 'Optional - Tap to select'
                        : 'Tap to select date',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: date != null ? Colors.black87 : Colors.grey[500],
                      fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentToggle(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.isUrgent.value
            ? Colors.red[50]
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: controller.isUrgent.value
              ? Colors.red[300]!
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on,
            color: controller.isUrgent.value
                ? Colors.red[600]
                : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgent Delivery',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Mark as urgent for faster bidding',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.isUrgent.value,
            onChanged: (value) => controller.isUrgent.value = value,
            activeColor: Colors.red[600],
          ),
        ],
      ),
    ));
  }

  Widget _buildEstimatedCost(BuildContext context) {
    final estimatedCost = controller.calculateEstimatedCost();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            'Estimated Cost: ₹${estimatedCost.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Approximate',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Requirements',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.commonRequirements.map((requirement) {
            final isSelected = controller.requirements.contains(requirement);
            return FilterChip(
              label: Text(
                requirement,
                style: TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              onSelected: (_) => controller.toggleRequirement(requirement),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildImageSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Add photos of your load to get better bids',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: controller.addImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Photo'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => controller.selectedImages.isEmpty
            ? Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, color: Colors.grey[400], size: 32),
                const SizedBox(height: 8),
                Text(
                  'No images added',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        )
            : GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.selectedImages.length,
          itemBuilder: (context, index) {
            final imageUrl = controller.selectedImages[index];
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeImage(imageUrl),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )),
      ],
    );
  }
}