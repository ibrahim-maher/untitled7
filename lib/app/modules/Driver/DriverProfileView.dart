import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/DriverProfileController.dart';
import '../../theme/app_theme.dart';

class DriverProfileView extends GetView<DriverProfileController> {
  const DriverProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: controller.callDriver,
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: controller.messageDriver,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver info card
              _buildDriverInfoCard(context),
              const SizedBox(height: 16),

              // Rating and reviews
              _buildRatingCard(context),
              const SizedBox(height: 16),

              // Vehicle information
              _buildVehicleCard(context),
              const SizedBox(height: 16),

              // Documents and certifications
              _buildDocumentsCard(context),
              const SizedBox(height: 16),

              // Trip history
              _buildTripHistoryCard(context),
              const SizedBox(height: 16),

              // Contact actions
              _buildContactActionsCard(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDriverInfoCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Obx(() => CircleAvatar(
                  radius: 40,
                  backgroundImage: controller.driverPhotoUrl.value.isNotEmpty
                      ? NetworkImage(controller.driverPhotoUrl.value)
                      : null,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: controller.driverPhotoUrl.value.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  )
                      : null,
                )),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        controller.driverName.value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        controller.driverPhone.value,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: controller.isOnline.value
                                  ? Colors.green[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: controller.isOnline.value
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  controller.isOnline.value ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: controller.isOnline.value
                                        ? Colors.green[700]
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (controller.isVerified.value)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, size: 12, color: Colors.blue[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Trips',
                    controller.totalTrips.value.toString(),
                    Icons.local_shipping,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Years Experience',
                    controller.yearsExperience.value.toString(),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Success Rate',
                    '${controller.successRate.value.toStringAsFixed(0)}%',
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor   , size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRatingCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating & Reviews',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Obx(() => Text(
                      controller.averageRating.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    Obx(() => Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < controller.averageRating.value.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      '${controller.totalReviews.value} reviews',
                      style: TextStyle(color: Colors.grey[600]),
                    )),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar('5 ⭐', controller.rating5Count.value, controller.totalReviews.value),
                      _buildRatingBar('4 ⭐', controller.rating4Count.value, controller.totalReviews.value),
                      _buildRatingBar('3 ⭐', controller.rating3Count.value, controller.totalReviews.value),
                      _buildRatingBar('2 ⭐', controller.rating2Count.value, controller.totalReviews.value),
                      _buildRatingBar('1 ⭐', controller.rating1Count.value, controller.totalReviews.value),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: controller.viewAllReviews,
              child: const Text('View All Reviews'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        controller.vehicleType.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )),
                      Obx(() => Text(
                        controller.vehicleNumber.value,
                        style: TextStyle(color: Colors.grey[600]),
                      )),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        'Capacity: ${controller.vehicleCapacity.value}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVehicleDetail(
                    'Model Year',
                    controller.vehicleYear.value.toString(),
                  ),
                ),
                Expanded(
                  child: _buildVehicleDetail(
                    'Insurance',
                    controller.hasInsurance.value ? 'Valid' : 'Expired',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents & Certifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDocumentItem('Driving License', true),
            _buildDocumentItem('Vehicle Registration', true),
            _buildDocumentItem('Insurance Certificate', controller.hasInsurance.value),
            _buildDocumentItem('PAN Card', true),
            _buildDocumentItem('Transport License', controller.hasTransportLicense.value),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            isValid ? 'Valid' : 'Invalid',
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripHistoryCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Trips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.viewAllTrips,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.recentTrips.isEmpty) {
                return const Text('No recent trips available');
              }
              return Column(
                children: controller.recentTrips.map((trip) =>
                    _buildTripItem(trip)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTripItem(Map<String, dynamic> trip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check, color: Colors.green[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip['from']} → ${trip['to']}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  trip['date'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < trip['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 12,
                  );
                }),
              ),
              Text(
                '₹${trip['amount']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactActionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.callDriver,
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.messageDriver,
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.reportDriver,
                icon: const Icon(Icons.report, color: Colors.red),
                label: const Text('Report Driver', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}