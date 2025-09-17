import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../data/models/LoadModel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../controllers/ShipmentsController.dart';

class ShipmentsView extends GetView<ShipmentsController> {
  const ShipmentsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Shipments'),
        elevation: 0,
        actions: [
          // FIXED: Proper widget return type instead of nullable IconButton
          Obx(() => controller.isFilterApplied.value
              ? IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '•',
                      style: TextStyle(color: Colors.white, fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: controller.showFilterDialog,
          )
              : IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: controller.showFilterDialog,
          ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomTextField(
                  hint: 'Search shipments...',
                  prefixIcon: const Icon(Icons.search),
                  // FIXED: Proper widget handling for suffixIcon
                  suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearSearch,
                  )
                      : const SizedBox.shrink()),
                  onChanged: controller.onSearchChanged,
                ),
              ),

              // Tab bar
              TabBar(
                controller: controller.tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Theme.of(context).primaryColor,
                isScrollable: true, // Allow horizontal scrolling if needed
                tabs: [
                  Tab(
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'All',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.totalShipments}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                  Tab(
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Active',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.activeShipmentsCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                  Tab(
                    child: Obx(() => Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Completed',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${controller.completedShipmentsCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
              ),            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Statistics card
          _buildStatisticsCard(context),

          // Shipments list
          Expanded(
            child: Obx(
                  () => controller.isLoading.value
                  ? const Center(child: LoadingWidget(message: 'Loading shipments...'))
                  : TabBarView(
                controller: controller.tabController,
                children: [
                  _buildShipmentsList(context, controller.filteredShipments),
                  _buildShipmentsList(context, controller.activeShipments.where((s) =>
                      controller.filteredShipments.contains(s)).toList()),
                  _buildShipmentsList(context, controller.completedShipments.where((s) =>
                      controller.filteredShipments.contains(s)).toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildStatItem(
              context,
              'Total',
              '${controller.totalShipments}',
              Icons.local_shipping,
              Colors.white,
            )),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Obx(() => _buildStatItem(
              context,
              'Active',
              '${controller.activeShipmentsCount}',
              Icons.pending_actions,
              Colors.white,
            )),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Obx(() => _buildStatItem(
              context,
              'Success Rate',
              '${controller.completionRate.toStringAsFixed(0)}%',
              Icons.check_circle,
              Colors.white,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildShipmentsList(BuildContext context, List<ShipmentModel> shipments) {
    if (shipments.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshShipments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          return _buildShipmentCard(context, shipment);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Shipments Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your shipments will appear here once you have loads assigned to transporters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, ShipmentModel shipment) {
    final statusColor = _getStatusColor(shipment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.navigateToShipmentDetails(shipment),
        onLongPress: () => controller.showShipmentActions(shipment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipment #${shipment.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Load: ${shipment.loadId.substring(0, 8)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shipment.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Route information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
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
                          height: 30,
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
                            shipment.pickupLocation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            shipment.deliveryLocation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Driver and vehicle info
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shipment.driverName,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shipment.vehicleNumber,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Time and amount info
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(shipment.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${shipment.totalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              // Progress indicator for active shipments
              if (_isActiveShipment(shipment)) ...[
                const SizedBox(height: 12),
                _buildProgressIndicator(context, shipment),
              ],

              // Action buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.navigateToShipmentDetails(shipment),
                      icon: const Icon(Icons.track_changes, size: 18),
                      label: const Text('Track'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.showShipmentActions(shipment),
                      icon: const Icon(Icons.more_horiz, size: 18),
                      label: const Text('Actions'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
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

  Widget _buildProgressIndicator(BuildContext context, ShipmentModel shipment) {
    double progress = _calculateProgress(shipment.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  bool _isActiveShipment(ShipmentModel shipment) {
    return [
      ShipmentStatus.pending,
      ShipmentStatus.confirmed, // FIXED: Added missing status
      ShipmentStatus.accepted,
      ShipmentStatus.pickup,
      ShipmentStatus.loaded,
      ShipmentStatus.inTransit,
    ].contains(shipment.status);
  }

  // FIXED: Added missing ShipmentStatus.confirmed case
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
      case ShipmentStatus.pickedUp:  // Added missing case
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
  // FIXED: Added missing ShipmentStatus.confirmed case
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}