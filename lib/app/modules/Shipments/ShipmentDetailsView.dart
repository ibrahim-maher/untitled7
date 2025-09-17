import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/ShipmentDetailsController.dart';
import '../../data/models/LoadModel.dart';

class ShipmentDetailsView extends GetView<ShipmentDetailsController> {
  const ShipmentDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareShipment,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'track',
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed),
                    SizedBox(width: 8),
                    Text('Track Shipment'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'documents',
                child: Row(
                  children: [
                    Icon(Icons.description),
                    SizedBox(width: 8),
                    Text('View Documents'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.support_agent),
                    SizedBox(width: 8),
                    Text('Contact Support'),
                  ],
                ),
              ),
            ],
            onSelected: controller.onMenuSelected,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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
              // Status card
              _buildStatusCard(context, shipment),
              const SizedBox(height: 16),

              // Route details
              _buildRouteCard(context, shipment),
              const SizedBox(height: 16),

              // Timeline
              _buildTimelineCard(context, shipment),
              const SizedBox(height: 16),

              // Transport details
              _buildTransportDetailsCard(context, shipment),
              const SizedBox(height: 16),

              // Payment details
              _buildPaymentCard(context, shipment),
              const SizedBox(height: 16),

              // Documents
              _buildDocumentsCard(context, shipment),
              const SizedBox(height: 16),

              // Actions
              _buildActionsCard(context, shipment),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(BuildContext context, ShipmentModel shipment) {
    final statusColor = _getStatusColor(shipment.status);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Load #${shipment.loadId.substring(0, 8)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    shipment.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
                    'Total Amount',
                    '₹${shipment.totalAmount.toStringAsFixed(0)}',
                    Icons.currency_rupee,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Payment Status',
                    shipment.paymentStatus.displayName,
                    Icons.payment,
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteCard(BuildContext context, ShipmentModel shipment) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 60,
                      color: Colors.grey[400],
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        shipment.pickupLocation,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (shipment.estimatedPickup != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Est. ${DateFormat('MMM dd, HH:mm').format(shipment.estimatedPickup!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Delivery Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        shipment.deliveryLocation,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (shipment.estimatedDelivery != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Est. ${DateFormat('MMM dd, HH:mm').format(shipment.estimatedDelivery!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
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

  Widget _buildTimelineCard(BuildContext context, ShipmentModel shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipment Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (shipment.trackingUpdates.isNotEmpty)
              ...shipment.trackingUpdates.reversed.map((update) =>
                  _buildTimelineItem(update)).toList()
            else
              _buildTimelineItem(TrackingUpdate(
                id: '1',
                status: shipment.status,
                location: 'System',
                description: 'Shipment created',
                timestamp: shipment.createdAt,
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TrackingUpdate update) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getStatusColor(update.status),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(update.status),
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (update.location.isNotEmpty)
                  Text(
                    update.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(update.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportDetailsCard(BuildContext context, ShipmentModel shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transport Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        shipment.driverPhone,
                        style: TextStyle(color: Colors.grey[600]),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.vehicleType,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          shipment.vehicleNumber,
                          style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildPaymentCard(BuildContext context, ShipmentModel shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '₹${shipment.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Status',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(shipment.paymentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shipment.paymentStatus.displayName,
                    style: TextStyle(
                      color: _getPaymentStatusColor(shipment.paymentStatus),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (shipment.paymentStatus != PaymentStatus.paid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.makePayment,
                  child: const Text('Make Payment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsCard(BuildContext context, ShipmentModel shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (shipment.documents.isEmpty)
              Text(
                'No documents available',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              ...shipment.documents.map((doc) => _buildDocumentItem(doc)).toList(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.viewAllDocuments,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('View All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.downloadDocuments,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String documentUrl) {
    final fileName = documentUrl.split('/').last;
    return ListTile(
      leading: const Icon(Icons.description),
      title: Text(fileName),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () => controller.downloadDocument(documentUrl),
      ),
      onTap: () => controller.viewDocument(documentUrl),
    );
  }

  Widget _buildActionsCard(BuildContext context, ShipmentModel shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.trackShipment,
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('Track Live'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.reportIssue,
                    icon: const Icon(Icons.report_problem),
                    label: const Text('Report Issue'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (shipment.status == ShipmentStatus.delivered ||
                shipment.status == ShipmentStatus.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.rateExperience,
                  icon: const Icon(Icons.star),
                  label: const Text('Rate Experience'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
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
            'Shipment Not Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load shipment details',
            style: TextStyle(color: Colors.grey[500]),
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

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.orange[600]!;
      case ShipmentStatus.confirmed:
        return Colors.blue[600]!;
      case ShipmentStatus.accepted:
        return Colors.green[600]!;
      case ShipmentStatus.pickup:
        return Colors.purple[600]!;
      case ShipmentStatus.pickedUp:
        return Colors.indigo[600]!;
      case ShipmentStatus.loaded:
        return Colors.indigo[600]!;
      case ShipmentStatus.inTransit:
        return Colors.teal[600]!;
      case ShipmentStatus.delivered:
        return Colors.green[700]!;
      case ShipmentStatus.completed:
        return Colors.green[800]!;
      case ShipmentStatus.cancelled:
        return Colors.red[600]!;
    }
  }

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
      case ShipmentStatus.pickedUp:
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

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange[600]!;
      case PaymentStatus.partial:
        return Colors.yellow[700]!;
      case PaymentStatus.paid:
        return Colors.green[600]!;
      case PaymentStatus.overdue:
        return Colors.red[600]!;
      case PaymentStatus.cancelled:
        return Colors.grey[600]!;
    }
  }
}