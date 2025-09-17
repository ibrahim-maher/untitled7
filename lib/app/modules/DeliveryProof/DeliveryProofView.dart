import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryProofView extends GetView<DeliveryProofController> {
  const DeliveryProofView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Proof'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: controller.downloadProof,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareProof,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return _buildErrorState(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipment info
              _buildShipmentInfo(context),
              const SizedBox(height: 20),

              // Delivery proof content
              _buildProofContent(context),
              const SizedBox(height: 20),

              // Delivery details
              _buildDeliveryDetails(context),
              const SizedBox(height: 20),

              // Actions
              _buildActions(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShipmentInfo(BuildContext context) {
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
                Icon(Icons.verified, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Delivery Confirmed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                _buildInfoRow('Shipment ID', controller.shipmentId.value),
                _buildInfoRow('Delivered To', controller.deliveredTo.value),
                _buildInfoRow('Delivery Date', controller.deliveryDate.value),
                _buildInfoRow('Delivery Time', controller.deliveryTime.value),
                _buildInfoRow('Received By', controller.receivedBy.value),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofContent(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.proofImages.isEmpty) {
                return _buildNoPhotosState();
              }
              return _buildPhotoGrid(context);
            }),
            const SizedBox(height: 16),
            if (controller.hasSignature.value) ...[
              Text(
                'Digital Signature',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSignatureSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoPhotosState() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No delivery photos available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: controller.proofImages.length,
      itemBuilder: (context, index) {
        final imageUrl = controller.proofImages[index];
        return GestureDetector(
          onTap: () => controller.viewFullImage(imageUrl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text(
                          'Failed to load',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignatureSection(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Obx(() => controller.signatureUrl.value.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          controller.signatureUrl.value,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.draw, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Signature not available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.draw, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No signature captured',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildDeliveryDetails(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
              controller.deliveryNotes.value.isNotEmpty
                  ? controller.deliveryNotes.value
                  : 'No additional notes provided',
              style: TextStyle(
                color: controller.deliveryNotes.value.isNotEmpty
                    ? Colors.black87
                    : Colors.grey[600],
              ),
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                    'Delivered at: ${controller.deliveryLocation.value}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.downloadProof,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.shareProof,
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Proof',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The delivery proof could not be loaded',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.retryLoading,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Delivery Proof Controller
class DeliveryProofController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var shipmentId = ''.obs;
  var deliveredTo = ''.obs;
  var deliveryDate = ''.obs;
  var deliveryTime = ''.obs;
  var receivedBy = ''.obs;
  var deliveryNotes = ''.obs;
  var deliveryLocation = ''.obs;
  var proofImages = <String>[].obs;
  var hasSignature = false.obs;
  var signatureUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProofData();
  }

  void _loadProofData() {
    isLoading.value = true;
    hasError.value = false;

    try {
      // Get data from arguments
      final args = Get.arguments ?? {};
      final proofUrl = args['proofUrl'] ?? '';
      shipmentId.value = args['shipmentId'] ?? 'Unknown';

      // In production, load actual proof data from Firestore
      _mockLoadProofData();
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _mockLoadProofData() {
    // Mock data - replace with actual Firestore loading
    deliveredTo.value = '123 Business Center, Downtown';
    deliveryDate.value = 'March 15, 2024';
    deliveryTime.value = '2:30 PM';
    receivedBy.value = 'John Smith';
    deliveryNotes.value = 'Package delivered to reception desk. Signed by facility manager.';
    deliveryLocation.value = '40.7128° N, 74.0060° W';

    proofImages.addAll([
      'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Package+Delivered',
      'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Delivery+Location',
    ]);

    hasSignature.value = true;
    signatureUrl.value = 'https://via.placeholder.com/400x150/FF9800/FFFFFF?text=Digital+Signature';
  }

  void viewFullImage(String imageUrl) {
    Get.dialog(
      Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
            maxWidth: Get.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Delivery Photo'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadImage(imageUrl),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void downloadProof() {
    Get.snackbar(
      'Download Started',
      'Delivery proof is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.download, color: Colors.green),
    );
  }

  void shareProof() {
    Get.snackbar(
      'Sharing Proof',
      'Delivery proof details copied to share',
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.share, color: Colors.blue),
    );
  }

  void _downloadImage(String imageUrl) {
    Get.snackbar(
      'Download Started',
      'Image is being downloaded...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void retryLoading() {
    _loadProofData();
  }
}

// Delivery Proof Binding
class DeliveryProofBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryProofController>(() => DeliveryProofController());
  }
}