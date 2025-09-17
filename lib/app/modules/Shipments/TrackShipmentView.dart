import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../data/models/LoadModel.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import 'TrackShipmentController.dart';

class TrackShipmentView extends GetView<TrackShipmentController> {
  const TrackShipmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Track Shipment'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshTracking,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Tracking'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'call_driver',
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Text('Call Driver'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'emergency',
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Emergency Support', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'share':
                  controller.shareTracking();
                  break;
                case 'call_driver':
                  controller.callDriver();
                  break;
                case 'emergency':
                  controller.callEmergencySupport();
                  break;
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingWidget(message: 'Loading shipment details...'));
        }

        final shipment = controller.shipment.value;
        if (shipment == null) {
          return _buildErrorState(context, l10n);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTracking,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipment info card
                _buildShipmentInfoCard(context, shipment, l10n),
                const SizedBox(height: 16),

                // Current status card
                _buildCurrentStatusCard(context, shipment, l10n),
                const SizedBox(height: 16),

                // Progress timeline
                _buildProgressTimeline(context, shipment, l10n),
                const SizedBox(height: 16),

                // Route information
                _buildRouteInformation(context, shipment, l10n),
                const SizedBox(height: 16),

                // Driver & Vehicle info
                _buildDriverVehicleInfo(context, shipment, l10n),
                const SizedBox(height: 16),

                // Tracking updates
                _buildTrackingUpdates(context, shipment, l10n),
                const SizedBox(height: 16),

                // Action buttons
                _buildActionButtons(context, shipment, l10n),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShipmentInfoCard(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment #${shipment.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Load #${shipment.loadId.substring(0, 8)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(shipment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(shipment.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    shipment.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(shipment.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Started',
                    DateFormat('MMM dd, yyyy').format(shipment.createdAt),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Amount',
                    '₹${shipment.totalAmount.toStringAsFixed(0)}',
                    Icons.currency_rupee,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
    final progress = _calculateProgress(shipment.status);

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
                  'Current Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(shipment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(shipment.status),
                    color: _getStatusColor(shipment.status),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.status.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(shipment.status),
                          ),
                        ),
                        Text(
                          _getStatusDescription(shipment.status),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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

  Widget _buildProgressTimeline(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipment Progress',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Shipment Created',
              'Shipment was created and assigned to transporter',
              Icons.post_add,
              true,
              shipment.createdAt,
            ),
            _buildTimelineItem(
              'Accepted',
              'Transport partner accepted the shipment',
              Icons.handshake,
              _isStatusCompleted(ShipmentStatus.accepted, shipment.status),
              shipment.createdAt.add(const Duration(hours: 1)),
            ),
            _buildTimelineItem(
              'Pickup Scheduled',
              'Driver is on the way to pickup location',
              Icons.schedule,
              _isStatusCompleted(ShipmentStatus.pickup, shipment.status),
              shipment.estimatedPickup ?? shipment.createdAt.add(const Duration(hours: 4)),
            ),
            _buildTimelineItem(
              'Load Picked Up',
              'Load has been collected from pickup location',
              Icons.inventory,
              _isStatusCompleted(ShipmentStatus.pickedUp, shipment.status),
              shipment.actualPickup ?? shipment.createdAt.add(const Duration(hours: 6)),
            ),
            _buildTimelineItem(
              'In Transit',
              'Load is on the way to delivery location',
              Icons.local_shipping,
              _isStatusCompleted(ShipmentStatus.inTransit, shipment.status),
              shipment.createdAt.add(const Duration(hours: 8)),
            ),
            _buildTimelineItem(
              'Delivered',
              'Load has been successfully delivered',
              Icons.check_circle,
              _isStatusCompleted(ShipmentStatus.delivered, shipment.status),
              shipment.actualDelivery ?? shipment.estimatedDelivery ?? shipment.createdAt.add(const Duration(hours: 12)),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      String title,
      String description,
      IconData icon,
      bool isCompleted,
      DateTime dateTime, {
        bool isLast = false,
      }) {
    final color = isCompleted ? Colors.green[600]! : Colors.grey[400]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    if (isCompleted)
                      Text(
                        DateFormat('MMM dd, HH:mm').format(dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInformation(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Information',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.grey[400],
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        shipment.pickupLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'To',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        shipment.deliveryLocation,
                        style: const TextStyle(
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
    );
  }

  Widget _buildDriverVehicleInfo(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver & Vehicle Details',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: shipment.driverPhotoUrl != null
                      ? NetworkImage(shipment.driverPhotoUrl!)
                      : null,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: shipment.driverPhotoUrl == null
                      ? Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shipment.driverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${shipment.vehicleType} - ${shipment.vehicleNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '4.5 (120 reviews)', // In production, use actual rating
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: controller.callDriver,
                      icon: Icon(Icons.phone, color: Colors.green[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green[50],
                      ),
                    ),
                    IconButton(
                      onPressed: controller.messageDriver,
                      icon: Icon(Icons.message, color: Colors.blue[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingUpdates(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Updates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // FIXED: Use actual tracking updates from shipment
            if (shipment.trackingUpdates.isNotEmpty)
              ...shipment.trackingUpdates.reversed.take(3).map((update) =>
                  _buildUpdateItem(
                    update.description,
                    update.location,
                    update.timestamp,
                    _getStatusIcon(update.status),
                  ),
              ).toList()
            else
              _buildUpdateItem(
                'Shipment created',
                'Initial shipment creation',
                shipment.createdAt,
                Icons.post_add,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(
      String title,
      String description,
      DateTime dateTime,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor
              ,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(dateTime),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ShipmentModel shipment, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.callDriver,
                icon: const Icon(Icons.phone),
                label: const Text('Call Driver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.shareTracking,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.callEmergencySupport,
            icon: const Icon(Icons.emergency, color: Colors.red),
            label: const Text('Emergency Support', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
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
            'Unable to load shipment details. Please try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshTracking,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // FIXED: Handle all ShipmentStatus cases including pickedUp
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
      case ShipmentStatus.pickedUp: // FIXED: Added missing case
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

  // FIXED: Handle all ShipmentStatus cases including pickedUp
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
      case ShipmentStatus.pickedUp: // FIXED: Added missing case
        return Colors.indigo[600]!;
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

  // FIXED: Handle all ShipmentStatus cases including pickedUp
  IconData _getStatusIcon(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Icons.hourglass_empty;
      case ShipmentStatus.confirmed:
        return Icons.check;
      case ShipmentStatus.accepted:
        return Icons.handshake;
      case ShipmentStatus.pickup:
        return Icons.schedule;
      case ShipmentStatus.pickedUp: // FIXED: Added missing case
        return Icons.inventory_2;
      case ShipmentStatus.loaded:
        return Icons.inventory;
      case ShipmentStatus.inTransit:
        return Icons.local_shipping;
      case ShipmentStatus.delivered:
        return Icons.check_circle;
      case ShipmentStatus.completed:
        return Icons.done_all;
      case ShipmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  // FIXED: Handle all ShipmentStatus cases including pickedUp
  String _getStatusDescription(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Waiting for transporter acceptance';
      case ShipmentStatus.confirmed:
        return 'Shipment confirmed and scheduled';
      case ShipmentStatus.accepted:
        return 'Transporter assigned and confirmed';
      case ShipmentStatus.pickup:
        return 'Driver is heading to pickup location';
      case ShipmentStatus.pickedUp: // FIXED: Added missing case
        return 'Load has been picked up from origin';
      case ShipmentStatus.loaded:
        return 'Load has been loaded and secured';
      case ShipmentStatus.inTransit:
        return 'Load is on the way to destination';
      case ShipmentStatus.delivered:
        return 'Load has been delivered successfully';
      case ShipmentStatus.completed:
        return 'Shipment completed and payment processed';
      case ShipmentStatus.cancelled:
        return 'Shipment has been cancelled';
    }
  }

  bool _isStatusCompleted(ShipmentStatus targetStatus, ShipmentStatus currentStatus) {
    const statusOrder = [
      ShipmentStatus.pending,
      ShipmentStatus.confirmed,
      ShipmentStatus.accepted,
      ShipmentStatus.pickup,
      ShipmentStatus.pickedUp, // FIXED: Added missing status
      ShipmentStatus.loaded,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
      ShipmentStatus.completed,
    ];

    final targetIndex = statusOrder.indexOf(targetStatus);
    final currentIndex = statusOrder.indexOf(currentStatus);

    return currentIndex >= targetIndex;
  }
}