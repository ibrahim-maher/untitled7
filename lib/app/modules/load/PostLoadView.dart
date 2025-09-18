import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../../../generated/l10n/app_localizations.dart';
import '../../controllers/post_load_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../home/utils/location_picker_helper.dart';

class PostLoadView extends GetView<PostLoadController> {
  const PostLoadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _buildAppBar(context, l10n, theme),
      body: _buildBody(context, l10n, theme, appColors),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return AppBar(
      title: Text(l10n.postLoad),
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      actions: [
        Obx(() => IconButton(
          onPressed: controller.isFormValid.value ? controller.postLoad : null,
          icon: Icon(
            Icons.send,
            color: controller.isFormValid.value
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          tooltip: 'Post Load',
        )),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, ThemeData theme, AppColors? appColors) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: LoadingWidget(message: l10n.loading),
        );
      }

      return Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressIndicator(controller: controller, theme: theme),
              const SizedBox(height: 24),
              _BasicInformationSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _LoadDetailsSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _LocationSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _ScheduleSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _BudgetSection(controller: controller, l10n: l10n, theme: theme, appColors: appColors),
              const SizedBox(height: 16),
              _RequirementsSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _ContactInformationSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _ImagesSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _PreferencesSection(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 32),
              _SubmitButton(controller: controller, l10n: l10n, theme: theme),
              const SizedBox(height: 16),
              _ValidationSummary(controller: controller, l10n: l10n, theme: theme, appColors: appColors),
              const SizedBox(height: 16),
              _TermsAndConditions(l10n: l10n, theme: theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }
}

// Enhanced Widget Components with Theme Integration
class _ProgressIndicator extends StatelessWidget {
  final PostLoadController controller;
  final ThemeData theme;

  const _ProgressIndicator({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Your Load',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details below to receive competitive bids from verified transporters',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final ThemeData theme;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: theme.cardTheme.elevation ?? 2,
      shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
}

class _BasicInformationSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _BasicInformationSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l10n.createLoad,
      icon: Icons.info_outline,
      theme: theme,
      children: [
        CustomTextField(
          label: '${l10n.loadTitle} *',
          hint: 'e.g., Electronics Shipment, Furniture Move',
          controller: controller.titleController,
          validator: controller.validateTitle,
          prefixIcon: const Icon(Icons.title),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: l10n.description,
          hint: 'Describe your load in detail',
          controller: controller.descriptionController,
          maxLines: 3,
          prefixIcon: const Icon(Icons.description),
        ),
      ],
    );
  }
}

class _LoadDetailsSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _LoadDetailsSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Load Details',
      icon: Icons.inventory,
      theme: theme,
      children: [
        _LoadTypeSelector(controller: controller, l10n: l10n, theme: theme),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: '${l10n.weight} (${l10n.kilogram}) *',
                hint: '0',
                controller: controller.weightController,
                keyboardType: TextInputType.number,
                validator: (value) => controller.fieldErrors['weight'],
                prefixIcon: const Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: l10n.dimensions,
                hint: 'L x W x H (${l10n.meter})',
                controller: controller.dimensionsController,
                prefixIcon: const Icon(Icons.straighten),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _VehicleTypeSelector(controller: controller, l10n: l10n, theme: theme),
        Obx(() {
          if (controller.selectedVehicleType.value == null) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              const SizedBox(height: 12),
              _VehicleCapacityInfo(controller: controller, theme: theme),
            ],
          );
        }),
      ],
    );
  }
}

class _LoadTypeSelector extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _LoadTypeSelector({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.materialType} *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.5,
          ),
          itemCount: controller.loadTypes.length,
          itemBuilder: (context, index) {
            final loadType = controller.loadTypes[index];
            final isSelected = controller.selectedLoadType.value == loadType;

            return _SelectableCard(
              isSelected: isSelected,
              onTap: () => controller.selectLoadType(loadType),
              theme: theme,
              child:  Text(
                loadType.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        )),
      ],
    );
  }
}

class _VehicleTypeSelector extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _VehicleTypeSelector({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.vehicleType} *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
          ),
          itemCount: controller.vehicleTypes.length,
          itemBuilder: (context, index) {
            final vehicleType = controller.vehicleTypes[index];
            final isSelected = controller.selectedVehicleType.value == vehicleType;

            return _SelectableCard(
              isSelected: isSelected,
              onTap: () => controller.selectVehicleType(vehicleType),
              theme: theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicleType.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vehicleType.displayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicleType.capacity,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          },
        )),
      ],
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final ThemeData theme;

  const _SelectableCard({
    required this.isSelected,
    required this.onTap,
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _VehicleCapacityInfo extends StatelessWidget {
  final PostLoadController controller;
  final ThemeData theme;

  const _VehicleCapacityInfo({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vehicleType = controller.selectedVehicleType.value;
      if (vehicleType == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSecondaryContainer,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selected: ${vehicleType.displayName} - Max capacity: ${vehicleType.maxWeight.toStringAsFixed(0)} kg',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _LocationSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _LocationSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Pickup & Delivery',
      icon: Icons.location_on,
      theme: theme,
      children: [
        _LocationSelector(
          controller: controller,
          l10n: l10n,
          theme: theme,
          label: '${l10n.pickupLocation} *',
          isPickup: true,
        ),
        const SizedBox(height: 16),
        _LocationSelector(
          controller: controller,
          l10n: l10n,
          theme: theme,
          label: '${l10n.deliveryLocation} *',
          isPickup: false,
        ),
        const SizedBox(height: 16),
        _DistanceInfo(controller: controller, l10n: l10n, theme: theme),
      ],
    );
  }
}

class _LocationSelector extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;
  final String label;
  final bool isPickup;

  const _LocationSelector({
    required this.controller,
    required this.l10n,
    required this.theme,
    required this.label,
    required this.isPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = isPickup
          ? controller.pickupLocation.value
          : controller.deliveryLocation.value;
      final isSelected = isPickup
          ? controller.isPickupLocationSelected.value
          : controller.isDeliveryLocationSelected.value;
      final icon = isPickup
          ? Icons.location_on_outlined
          : Icons.location_on;

      return InkWell(
        onTap: () => _selectLocation(context, isPickup),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : theme.colorScheme.outline,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSelected ? value : 'Tap to select location',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                size: isSelected ? 20 : 16,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _selectLocation(BuildContext context, bool isPickupLocation) async {
    try {
      final result = await LocationPickerHelper.showLocationPicker(
        context,
        isPickupLocation,
      );

      if (result != null) {
        final address = result['address'] as String;
        final coordinates = result['coordinates'] as Map<String, dynamic>?;

        if (isPickupLocation) {
          controller.pickupLocation.value = address;
          controller.isPickupLocationSelected.value = true;
          if (coordinates != null) {
            controller.pickupCoordinates.value = coordinates;
          }
        } else {
          controller.deliveryLocation.value = address;
          controller.isDeliveryLocationSelected.value = true;
          if (coordinates != null) {
            controller.deliveryCoordinates.value = coordinates;
          }
        }

        controller.calculateDistance();

        HapticFeedback.lightImpact();
        Get.snackbar(
          'Location Selected',
          '${isPickupLocation ? 'Pickup' : 'Delivery'} location has been set',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Theme.of(context).extension<AppColors>()?.success?.withOpacity(0.1),
          colorText: Theme.of(context).extension<AppColors>()?.success,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: Icon(Icons.check_circle, color: Theme.of(context).extension<AppColors>()?.success),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).extension<AppColors>()?.error?.withOpacity(0.1),
        colorText: Theme.of(context).extension<AppColors>()?.error,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: Icon(Icons.error_outline, color: Theme.of(context).extension<AppColors>()?.error),
      );
    }
  }
}

class _DistanceInfo extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DistanceInfo({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final distance = controller.calculatedDistance.value;
      final travelTime = controller.estimatedTravelTime.value;

      if (distance <= 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${l10n.distance}: ${distance.toStringAsFixed(0)} ${l10n.kilometer}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (travelTime.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated travel time: $travelTime',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _ScheduleSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ScheduleSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Schedule',
      icon: Icons.schedule,
      theme: theme,
      children: [
        _DateSelector(
          controller: controller,
          l10n: l10n,
          theme: theme,
          label: '${l10n.pickupDate} *',
          dateObservable: controller.selectedPickupDate,
          onTap: controller.selectPickupDate,
        ),
        const SizedBox(height: 16),
        _DateSelector(
          controller: controller,
          l10n: l10n,
          theme: theme,
          label: l10n.deliveryDate,
          dateObservable: controller.selectedDeliveryDate,
          onTap: controller.selectDeliveryDate,
          isOptional: true,
        ),
        const SizedBox(height: 16),
        _ScheduleOptions(controller: controller, l10n: l10n, theme: theme),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;
  final String label;
  final Rx<DateTime?> dateObservable;
  final VoidCallback onTap;
  final bool isOptional;

  const _DateSelector({
    required this.controller,
    required this.l10n,
    required this.theme,
    required this.label,
    required this.dateObservable,
    required this.onTap,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = dateObservable.value;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceVariant,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date != null
                          ? DateFormat('MMM dd, yyyy - EEEE').format(date)
                          : isOptional
                          ? 'Optional - Tap to select'
                          : 'Tap to select date',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: date != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ScheduleOptions extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ScheduleOptions({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = theme.extension<AppColors>();

    return Column(
      children: [
        _ToggleOption(
          controller: controller,
          observable: controller.isUrgent,
          title: 'Urgent Delivery',
          subtitle: 'Mark as urgent for faster bidding (+40% premium)',
          icon: Icons.flash_on,
          activeColor: appColors?.error ?? Colors.red,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _ToggleOption(
          controller: controller,
          observable: controller.isFlexibleTiming,
          title: 'Flexible Timing',
          subtitle: 'Accept deliveries within ±2 days for better rates',
          icon: Icons.schedule_outlined,
          activeColor: appColors?.success ?? Colors.green,
          theme: theme,
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final PostLoadController controller;
  final RxBool observable;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color activeColor;
  final ThemeData theme;

  const _ToggleOption({
    required this.controller,
    required this.observable,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.activeColor,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: observable.value
            ? activeColor.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: observable.value
              ? activeColor.withOpacity(0.3)
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: observable.value ? activeColor : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: observable.value,
            onChanged: (value) => observable.value = value,
            activeColor: activeColor,
          ),
        ],
      ),
    ));
  }
}

class _BudgetSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColors? appColors;

  const _BudgetSection({
    required this.controller,
    required this.l10n,
    required this.theme,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l10n.budget,
      icon: Icons.currency_rupee,
      theme: theme,
      children: [
        CustomTextField(
          label: '${l10n.budget} (${l10n.rupees}) *',
          hint: '0',
          controller: controller.budgetController,
          keyboardType: TextInputType.number,
          validator: (value) => controller.fieldErrors['budget'],
          prefixIcon: const Icon(Icons.currency_rupee),
        ),
        const SizedBox(height: 12),
        _BudgetAnalysis(controller: controller, l10n: l10n, theme: theme, appColors: appColors),
        const SizedBox(height: 12),
        _EstimatedCost(controller: controller, l10n: l10n, theme: theme, appColors: appColors),
      ],
    );
  }
}

class _BudgetAnalysis extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColors? appColors;

  const _BudgetAnalysis({
    required this.controller,
    required this.l10n,
    required this.theme,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final budgetRange = controller.budgetRange.value;
      if (budgetRange == 'Enter your budget') return const SizedBox.shrink();

      Color textColor = theme.colorScheme.onSurface;
      Color backgroundColor = theme.colorScheme.surfaceVariant;
      IconData icon = Icons.info_outline;

      if (budgetRange.contains('Above market rate')) {
        textColor = appColors?.success ?? Colors.green;
        backgroundColor = (appColors?.success ?? Colors.green).withOpacity(0.1);
        icon = Icons.trending_up;
      } else if (budgetRange.contains('Good budget')) {
        textColor = appColors?.info ?? Colors.blue;
        backgroundColor = (appColors?.info ?? Colors.blue).withOpacity(0.1);
        icon = Icons.thumb_up;
      } else if (budgetRange.contains('Below market rate')) {
        textColor = appColors?.warning ?? Colors.orange;
        backgroundColor = (appColors?.warning ?? Colors.orange).withOpacity(0.1);
        icon = Icons.trending_down;
      } else if (budgetRange.contains('Very low budget')) {
        textColor = appColors?.error ?? Colors.red;
        backgroundColor = (appColors?.error ?? Colors.red).withOpacity(0.1);
        icon = Icons.warning;
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                budgetRange,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EstimatedCost extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColors? appColors;

  const _EstimatedCost({
    required this.controller,
    required this.l10n,
    required this.theme,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isCalculatingCost.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Calculating cost...',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      }

      final estimatedCost = controller.estimatedCost.value;
      if (estimatedCost <= 0) return const SizedBox.shrink();

      final minCost = controller.minEstimatedCost.value;
      final maxCost = controller.maxEstimatedCost.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estimated Cost: ₹${estimatedCost.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Expected range: ₹${minCost.toStringAsFixed(0)} - ₹${maxCost.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RequirementsSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _RequirementsSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Special Requirements',
      icon: Icons.checklist,
      theme: theme,
      children: [
        _RequirementsList(controller: controller, l10n: l10n, theme: theme),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Additional Instructions',
          hint: 'Any special handling instructions',
          controller: controller.specialInstructionsController,
          maxLines: 3,
          prefixIcon: const Icon(Icons.note),
        ),
      ],
    );
  }
}

class _RequirementsList extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _RequirementsList({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Requirements',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
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
                style: theme.textTheme.bodySmall,
              ),
              selected: isSelected,
              onSelected: (_) => controller.toggleRequirement(requirement),
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceVariant,
            );
          }).toList(),
        )),
      ],
    );
  }
}

class _ContactInformationSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ContactInformationSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      theme: theme,
      children: [
        CustomTextField(
          label: 'Contact Person *',
          hint: 'Full name',
          controller: controller.contactPersonController,
          validator: controller.validateContactPerson,
          prefixIcon: const Icon(Icons.person),
        ),
        const SizedBox(height: 16),
        _PhoneNumberField(controller: controller, l10n: l10n, theme: theme),
        const SizedBox(height: 16),
        _AlternateContactSection(controller: controller, l10n: l10n, theme: theme),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email (Optional)',
          hint: 'your.email@example.com',
          controller: controller.emailController,
          validator: controller.validateEmail,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email),
        ),
      ],
    );
  }
}

class _PhoneNumberField extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PhoneNumberField({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = theme.extension<AppColors>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.phone} *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: controller.isPhoneValid.value
                  ? (appColors?.success ?? Colors.green)
                  : (controller.contactPhoneController.text.isNotEmpty && !controller.isPhoneValid.value)
                  ? (appColors?.error ?? Colors.red)
                  : theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
                child: CountryCodePicker(
                  onChanged: controller.onCountryChanged,
                  initialSelection: controller.selectedCountryDialCode.value,
                  favorite: const ['+91', 'IN', '+1', 'US', '+44', 'GB'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller.contactPhoneController,
                  keyboardType: TextInputType.phone,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: theme.inputDecorationTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.isValidatingPhone.value) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      if (controller.contactPhoneController.text.isNotEmpty) {
                        return Icon(
                          controller.isPhoneValid.value ? Icons.check_circle : Icons.error,
                          color: controller.isPhoneValid.value
                              ? (appColors?.success ?? Colors.green)
                              : (appColors?.error ?? Colors.red),
                        );
                      }

                      return const SizedBox.shrink();
                    }),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),
        Obx(() {
          final message = controller.phoneValidationMessage.value;
          if (message.isEmpty) return const SizedBox.shrink();

          return Row(
            children: [
              Icon(
                controller.isPhoneValid.value
                    ? Icons.check_circle
                    : Icons.error_outline,
                size: 16,
                color: controller.isPhoneValid.value
                    ? (appColors?.success ?? Colors.green)
                    : (appColors?.error ?? Colors.red),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: controller.isPhoneValid.value
                        ? (appColors?.success ?? Colors.green)
                        : (appColors?.error ?? Colors.red),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _AlternateContactSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _AlternateContactSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Alternate Contact',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Switch(
              value: controller.hasAlternateContact.value,
              onChanged: (value) => controller.hasAlternateContact.value = value,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
        if (controller.hasAlternateContact.value) ...[
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Alternate Phone Number',
            hint: 'Backup contact number',
            controller: controller.alternatePhoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ],
      ],
    ));
  }
}

class _ImagesSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ImagesSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Load Images (Optional)',
      icon: Icons.image,
      theme: theme,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add photos of your load to get better bids',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.addImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(l10n.takePhoto),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ImageGrid(controller: controller, theme: theme),
          ],
        ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final PostLoadController controller;
  final ThemeData theme;

  const _ImageGrid({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'No images added',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return GridView.builder(
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
                  color: theme.colorScheme.surfaceVariant,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: theme.colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.image,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      );
                    },
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
                    decoration: BoxDecoration(
                      color: theme.extension<AppColors>()?.error ?? Colors.red,
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
      );
    });
  }
}

class _PreferencesSection extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PreferencesSection({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Preferences',
      icon: Icons.settings,
      theme: theme,
      children: [
        _PreferenceToggle(
          title: 'Enable Notifications',
          subtitle: 'Get updates about bids and messages',
          icon: Icons.notifications,
          observable: controller.enableNotifications,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _PreferenceToggle(
          title: 'Share Location',
          subtitle: 'Allow transporters to see your exact location',
          icon: Icons.location_on,
          observable: controller.shareLocationWithTransporter,
          theme: theme,
        ),
        const SizedBox(height: 16),
        _PreferenceToggle(
          title: 'Allow Bid Negotiation',
          subtitle: 'Let transporters negotiate rates with you',
          icon: Icons.handshake,
          observable: controller.allowBidNegotiation,
          theme: theme,
        ),
      ],
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final RxBool observable;
  final ThemeData theme;

  const _PreferenceToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.observable,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: observable.value
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: observable.value
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: observable.value
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: observable.value
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: observable.value
                        ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: observable.value,
            onChanged: (value) => observable.value = value,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    ));
  }
}

class _SubmitButton extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _SubmitButton({
    required this.controller,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomButton(
      text: l10n.postLoad,
      onPressed: controller.isFormValid.value ? controller.postLoad : null,
      isLoading: controller.isLoading.value,
      backgroundColor: controller.isFormValid.value
          ? theme.colorScheme.primary
          : theme.colorScheme.outline,
    ));
  }
}

class _ValidationSummary extends StatelessWidget {
  final PostLoadController controller;
  final AppLocalizations l10n;
  final ThemeData theme;
  final AppColors? appColors;

  const _ValidationSummary({
    required this.controller,
    required this.l10n,
    required this.theme,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isFormValid.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: appColors?.success ?? Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Form is complete and ready to submit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      // Show validation errors
      final errors = <String>[];
      if (controller.selectedLoadType.value == null) errors.add('Load type');
      if (controller.selectedVehicleType.value == null) errors.add('Vehicle type');
      if (!controller.isPickupLocationSelected.value) errors.add('Pickup location');
      if (!controller.isDeliveryLocationSelected.value) errors.add('Delivery location');
      if (controller.selectedPickupDate.value == null) errors.add('Pickup date');
      if (!controller.isPhoneValid.value) errors.add('Valid phone number');
      errors.addAll(controller.fieldErrors.keys);

      if (errors.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (appColors?.warning ?? Colors.orange).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: appColors?.warning ?? Colors.orange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: appColors?.warning ?? Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Please complete the following:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors?.warning ?? Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: errors.take(5).map((error) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (appColors?.warning ?? Colors.orange).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  error,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appColors?.warning ?? Colors.orange,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _TermsAndConditions extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _TermsAndConditions({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      'By posting this load, you agree to our ${l10n.termsOfService} and ${l10n.privacyPolicy}.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}