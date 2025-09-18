import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../controllers/home_controller.dart';
import '../utils/location_picker_helper.dart';

class SearchSection extends StatelessWidget {
  final HomeController controller;
  final AppLocalizations l10n;

  const SearchSection({
    Key? key,
    required this.controller,
    required this.l10n,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main search bar
            CustomTextField(
              hint: l10n.searchLoadsTrucksLocations,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: controller.showFilterDialog,
              ),
              onChanged: controller.onSearchChanged,
            ),
            const SizedBox(height: 12),

            // Location selection card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.routeSelection,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      // Clear all button
                      Obx(() => (controller.isPickupLocationSelected.value ||
                          controller.isDeliveryLocationSelected.value)
                          ? TextButton(
                        onPressed: _clearAllLocations,
                        child: Text(
                          l10n.clearAll,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      )
                          : const SizedBox.shrink()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location selection row
                  Row(
                    children: [
                      // From location
                      Expanded(
                        flex: 5,
                        child: _buildLocationField(
                          context,
                          isPickup: true,
                          icon: Icons.location_on_outlined,
                          hint: l10n.fromLocation,
                          selectedLocation: controller.pickupLocation,
                          isSelected: controller.isPickupLocationSelected,
                          onTap: () => _handleLocationSelection(context, true),
                          onClear: controller.clearPickupLocation,
                        ),
                      ),

                      // Swap button
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Obx(() => IconButton(
                          onPressed: (controller.isPickupLocationSelected.value &&
                              controller.isDeliveryLocationSelected.value)
                              ? controller.swapLocations
                              : null,
                          icon: Icon(
                            Icons.swap_horiz,
                            color: (controller.isPickupLocationSelected.value &&
                                controller.isDeliveryLocationSelected.value)
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[400],
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: (controller.isPickupLocationSelected.value &&
                                controller.isDeliveryLocationSelected.value)
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )),
                      ),

                      // To location
                      Expanded(
                        flex: 5,
                        child: _buildLocationField(
                          context,
                          isPickup: false,
                          icon: Icons.location_on,
                          hint: l10n.toLocation,
                          selectedLocation: controller.deliveryLocation,
                          isSelected: controller.isDeliveryLocationSelected,
                          onTap: () => _handleLocationSelection(context, false),
                          onClear: controller.clearDeliveryLocation,
                        ),
                      ),
                    ],
                  ),

                  // Route info (if both locations selected)
                  Obx(() => (controller.isPickupLocationSelected.value &&
                      controller.isDeliveryLocationSelected.value)
                      ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.routeReady,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.navigateToSearchTrucks(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                          ),
                          child: Text(
                            l10n.findTrucks,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField(
      BuildContext context, {
        required bool isPickup,
        required IconData icon,
        required String hint,
        required RxString selectedLocation,
        required RxBool isSelected,
        required VoidCallback onTap,
        required VoidCallback onClear,
      }) {
    return Obx(() => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected.value
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected.value
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected.value
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isSelected.value ? selectedLocation.value : hint,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected.value
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: isSelected.value
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected.value)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                  ),
              ],
            ),
            if (!isSelected.value) ...[
              const SizedBox(height: 4),
              Text(
                l10n.tapToSelect,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }

  Future<void> _handleLocationSelection(BuildContext context, bool isPickup) async {
    final result = await LocationPickerHelper.showLocationPicker(context, isPickup);

    if (result != null) {
      final address = result['address'] as String;
      final coordinates = result['coordinates'] as Map<String, double>?;

      // Update controller with selected location
      if (isPickup) {
        controller.onPickupLocationSelected(address, coordinates);
      } else {
        controller.onDeliveryLocationSelected(address, coordinates);
      }
    }
  }

  void _clearAllLocations() {
    controller.clearPickupLocation();
    controller.clearDeliveryLocation();
  }
}