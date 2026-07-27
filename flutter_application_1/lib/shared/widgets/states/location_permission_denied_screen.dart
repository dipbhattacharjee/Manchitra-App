import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — Location Permission Denied Screen
/// ============================================================

class LocationPermissionDeniedScreen extends StatelessWidget {
  final VoidCallback? onRetryPermission;

  const LocationPermissionDeniedScreen({
    super.key,
    this.onRetryPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StateBaseLayout(
          iconWidget: const Icon(
            Icons.location_off_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          title: 'Location Access Required',
          message: 'Manchitra needs your GPS location to calculate live turn-by-turn routes, measure distances to Durga Puja pandals, and render your location puck on the map.',
          primaryButtonText: 'Grant Location Access',
          onPrimaryAction: () async {
            final status = await Permission.location.request();
            if (status.isPermanentlyDenied) {
              await openAppSettings();
            }
            if (onRetryPermission != null) onRetryPermission!();
          },
          secondaryButtonText: 'Open App Settings',
          onSecondaryAction: () => openAppSettings(),
        ),
      ),
    );
  }
}
