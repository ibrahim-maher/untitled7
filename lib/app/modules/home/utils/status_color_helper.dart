// lib/app/modules/home/utils/status_color_helper.dart
import 'package:flutter/material.dart';
import '../../../data/models/LoadModel.dart'; // Import from LoadModel.dart where enums are defined
import '../../../theme/app_theme.dart';

class StatusColorHelper {
  static Color getStatusColor(ShipmentStatus status, BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>();

    switch (status) {
      case ShipmentStatus.pending:
        return appColors?.warning ?? AppTheme.warningColor;
      case ShipmentStatus.confirmed:
        return appColors?.info ?? AppTheme.infoColor;
      case ShipmentStatus.accepted:
        return Theme.of(context).colorScheme.tertiary;
      case ShipmentStatus.pickup:
        return Theme.of(context).colorScheme.secondary;
      case ShipmentStatus.pickedUp:
        return Theme.of(context).colorScheme.secondary;
      case ShipmentStatus.loaded:
        return Theme.of(context).colorScheme.primary;
      case ShipmentStatus.inTransit:
        return Theme.of(context).colorScheme.primary;
      case ShipmentStatus.delivered:
        return appColors?.success ?? AppTheme.successColor;
      case ShipmentStatus.completed:
        return appColors?.success ?? AppTheme.successColor;
      case ShipmentStatus.cancelled:
        return appColors?.error ?? AppTheme.errorColor;
    }
  }

  static IconData getStatusIcon(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Icons.schedule;
      case ShipmentStatus.confirmed:
        return Icons.check_circle_outline;
      case ShipmentStatus.accepted:
        return Icons.handshake;
      case ShipmentStatus.pickup:
        return Icons.schedule_send;
      case ShipmentStatus.pickedUp:
        return Icons.local_shipping;
      case ShipmentStatus.loaded:
        return Icons.inventory;
      case ShipmentStatus.inTransit:
        return Icons.directions_car;
      case ShipmentStatus.delivered:
        return Icons.check_circle;
      case ShipmentStatus.completed:
        return Icons.task_alt;
      case ShipmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  static Color getPaymentStatusColor(PaymentStatus status, BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>();

    switch (status) {
      case PaymentStatus.pending:
        return appColors?.warning ?? AppTheme.warningColor;
      case PaymentStatus.partial:
        return appColors?.info ?? AppTheme.infoColor;
      case PaymentStatus.paid:
        return appColors?.success ?? AppTheme.successColor;
      case PaymentStatus.overdue:
        return appColors?.error ?? AppTheme.errorColor;
      case PaymentStatus.cancelled:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  static IconData getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.partial:
        return Icons.pending;
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.overdue:
        return Icons.warning;
      case PaymentStatus.cancelled:
        return Icons.cancel;
    }
  }

  // Helper methods for Load status
  static Color getLoadStatusColor(LoadStatus status, BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>();

    switch (status) {
      case LoadStatus.posted:
        return appColors?.info ?? AppTheme.infoColor;
      case LoadStatus.bidding:
        return appColors?.warning ?? AppTheme.warningColor;
      case LoadStatus.assigned:
        return Theme.of(context).colorScheme.secondary;
      case LoadStatus.inProgress:
        return Theme.of(context).colorScheme.primary;
      case LoadStatus.completed:
        return appColors?.success ?? AppTheme.successColor;
      case LoadStatus.cancelled:
        return appColors?.error ?? AppTheme.errorColor;
      case LoadStatus.expired:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case LoadStatus.draft:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LoadStatus.active:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static IconData getLoadStatusIcon(LoadStatus status) {
    switch (status) {
      case LoadStatus.posted:
        return Icons.post_add;
      case LoadStatus.bidding:
        return Icons.gavel;
      case LoadStatus.assigned:
        return Icons.assignment;
      case LoadStatus.inProgress:
        return Icons.local_shipping;
      case LoadStatus.completed:
        return Icons.check_circle;
      case LoadStatus.cancelled:
        return Icons.cancel;
      case LoadStatus.expired:
        return Icons.access_time;
      case LoadStatus.draft:
        // TODO: Handle this case.
        throw UnimplementedError();
      case LoadStatus.active:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // Helper methods for Bid status
  static Color getBidStatusColor(BidStatus status, BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>();

    switch (status) {
      case BidStatus.pending:
        return appColors?.warning ?? AppTheme.warningColor;
      case BidStatus.accepted:
        return appColors?.success ?? AppTheme.successColor;
      case BidStatus.rejected:
        return appColors?.error ?? AppTheme.errorColor;
      case BidStatus.cancelled:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case BidStatus.expired:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case BidStatus.negotiating:
        return appColors?.info ?? AppTheme.infoColor;
    }
  }

  static IconData getBidStatusIcon(BidStatus status) {
    switch (status) {
      case BidStatus.pending:
        return Icons.schedule;
      case BidStatus.accepted:
        return Icons.check_circle;
      case BidStatus.rejected:
        return Icons.cancel;
      case BidStatus.cancelled:
        return Icons.cancel_outlined;
      case BidStatus.expired:
        return Icons.access_time;
      case BidStatus.negotiating:
        return Icons.handshake;
    }
  }
}