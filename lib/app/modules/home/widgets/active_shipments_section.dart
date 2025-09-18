// lib/app/modules/home/widgets/active_shipments_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../controllers/home_controller.dart';
import '../../../data/models/LoadModel.dart';
import '../../../routes/app_pages.dart';

class ActiveShipmentsSection extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const ActiveShipmentsSection({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.activeShipments.isEmpty) {
          return const SizedBox.shrink(); // Don't show section if no active shipments
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Shipments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View All'),
                    onPressed: () => Get.toNamed(Routes.SHIPMENTS),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show up to 3 active shipments
              ...controller.activeShipments.take(3).map((shipment) =>
                  _buildShipmentCard(context, shipment)),

              // Show count if more than 3
              if (controller.activeShipments.length > 3)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.local_shipping),
                    label: Text(
                      '${controller.activeShipments.length - 3} More Active Shipments',
                    ),
                    onPressed: () => Get.toNamed(Routes.SHIPMENTS),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildShipmentCard(BuildContext context, ShipmentModel shipment) {
    final statusColor = _getStatusColor(shipment.status);
    final progress = _calculateProgress(shipment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed(
          Routes.TRACK_SHIPMENT,
          parameters: {'id': shipment.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipment #${shipment.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          shipment.driverName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      shipment.status.displayName,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Route info
              Row(
                children: [
                  Icon(Icons.trip_origin, color: Colors.green[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment.pickupLocation,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey[300],
                ),
              ),

              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment.deliveryLocation,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(
                        Routes.TRACK_SHIPMENT,
                        parameters: {'id': shipment.id},
                      ),
                      icon: const Icon(Icons.track_changes, size: 16),
                      label: const Text('Track', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _callDriver(shipment.driverPhone),
                    icon: Icon(Icons.phone, color: Colors.green[600]),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _callDriver(String phoneNumber) {
    // Use url_launcher to make phone call
    Get.snackbar(
      'Calling',
      'Calling driver at $phoneNumber',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.orange[600]!;
      case ShipmentStatus.confirmed:
        return Colors.blue[700]!;
      case ShipmentStatus.accepted:
        return Colors.blue[600]!;
      case ShipmentStatus.pickup:
        return Colors.purple[600]!;
      case ShipmentStatus.pickedUp:
        return Colors.purple[700]!;
      case ShipmentStatus.loaded:
        return Colors.indigo[600]!;
      case ShipmentStatus.inTransit:
        return Colors.teal[600]!;
      case ShipmentStatus.delivered:
        return Colors.green[600]!;
      case ShipmentStatus.completed:
        return Colors.green[700]!;
      case ShipmentStatus.cancelled:
        return Colors.red[600]!;
    }
  }

  double _calculateProgress(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 0.1;
      case ShipmentStatus.confirmed:
        return 0.15;
      case ShipmentStatus.accepted:
        return 0.2;
      case ShipmentStatus.pickup:
        return 0.4;
      case ShipmentStatus.pickedUp:
        return 0.5;
      case ShipmentStatus.loaded:
        return 0.6;
      case ShipmentStatus.inTransit:
        return 0.8;
      case ShipmentStatus.delivered:
        return 1.0;
      case ShipmentStatus.completed:
        return 1.0;
      case ShipmentStatus.cancelled:
        return 0.0;
    }
  }
}