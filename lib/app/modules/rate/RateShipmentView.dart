// lib/app/modules/Shipments/RateShipmentView.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/RateShipmentController.dart';
import '../../data/models/LoadModel.dart';
import '../../widgets/loading_widget.dart';

class RateShipmentView extends GetView<RateShipmentController> {
  const RateShipmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.skipRating,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: LoadingWidget(message: 'Loading shipment details...'),
          );
        }

        final shipment = controller.shipment.value;
        if (shipment == null) {
          return _buildErrorState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipment info card
              _buildShipmentInfoCard(context, shipment),
              const SizedBox(height: 24),

              // Overall rating
              _buildOverallRating(context),
              const SizedBox(height: 24),

              // Detailed ratings
              _buildDetailedRatings(context),
              const SizedBox(height: 24),

              // Feedback options
              _buildFeedbackOptions(context),
              const SizedBox(height: 24),

              // Comments section
              _buildCommentsSection(context),
              const SizedBox(height: 24),

              // Photo upload
              _buildPhotoUpload(context),
              const SizedBox(height: 32),

              // Submit button
              _buildSubmitButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShipmentInfoCard(BuildContext context, ShipmentModel shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: shipment.driverPhotoUrl != null
                      ? NetworkImage(shipment.driverPhotoUrl!)
                      : null,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: shipment.driverPhotoUrl == null
                      ? Icon(Icons.person, color: Theme.of(context).primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.driverName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${shipment.vehicleType} - ${shipment.vehicleNumber}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Shipment #${shipment.id.substring(0, 8)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.route, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From: ${shipment.pickupLocation}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'To: ${shipment.deliveryLocation}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRating(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Experience *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How would you rate your overall experience?',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () => controller.setOverallRating(rating),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      controller.overallRating.value >= rating
                          ? Icons.star
                          : Icons.star_border,
                      size: 40,
                      color: controller.overallRating.value >= rating
                          ? Colors.amber
                          : Colors.grey[400],
                    ),
                  ),
                );
              }),
            )),
            const SizedBox(height: 8),
            Obx(() => Center(
              child: Text(
                controller.ratingCategory,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: controller.hasHighRating
                      ? Colors.green[600]
                      : controller.hasLowRating
                      ? Colors.red[600]
                      : Colors.orange[600],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedRatings(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Ratings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildRatingRow('Driver Behavior *', controller.driverRating, controller.setDriverRating),
            const SizedBox(height: 16),
            _buildRatingRow('Timeliness', controller.timelinessRating, controller.setTimelinessRating),
            const SizedBox(height: 16),
            _buildRatingRow('Communication', controller.communicationRating, controller.setCommunicationRating),
            const SizedBox(height: 16),
            _buildRatingRow('Cargo Handling', controller.handlingRating, controller.setHandlingRating),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String title, RxInt rating, Function(int) onRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: List.generate(5, (index) {
            final ratingValue = index + 1;
            return GestureDetector(
              onTap: () => onRate(ratingValue),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  rating.value >= ratingValue ? Icons.star : Icons.star_border,
                  size: 24,
                  color: rating.value >= ratingValue ? Colors.amber : Colors.grey[400],
                ),
              ),
            );
          }),
        )),
      ],
    );
  }

  Widget _buildFeedbackOptions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What went well?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.feedbackOptions.map((option) {
                final isSelected = controller.selectedFeedback.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => controller.toggleFeedback(option),
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Comments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your detailed feedback (optional)',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.commentsController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            Obx(() => Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.charactersCount.value}/500',
                style: TextStyle(
                  fontSize: 12,
                  color: controller.charactersCount.value > 450
                      ? Colors.red[600]
                      : Colors.grey[600],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos of the delivery (optional, max 5)',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (controller.isUploadingPhoto.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Column(
                children: [
                  // Photo grid
                  if (controller.localPhotos.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: controller.localPhotos.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(controller.localPhotos[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => controller.removePhoto(index),
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
                    ),

                  if (controller.localPhotos.isNotEmpty)
                    const SizedBox(height: 16),

                  // Upload buttons
                  if (controller.localPhotos.length < 5)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.capturePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.uploadPhoto,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.canSubmit.value && !controller.isSubmitting.value
            ? controller.submitRating
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isSubmitting.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Submit Review',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ));
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Shipment Not Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load shipment details for rating',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}