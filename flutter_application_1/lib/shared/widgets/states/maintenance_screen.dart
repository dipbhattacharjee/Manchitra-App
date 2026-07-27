import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — Maintenance / Backend Service Down Screen
/// ============================================================

class MaintenanceScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const MaintenanceScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StateBaseLayout(
          iconWidget: const Icon(
            Icons.build_circle_rounded,
            size: 48,
            color: AppColors.secondary,
          ),
          title: 'Server Under Maintenance',
          message: 'Our Durga Puja server infrastructure is undergoing brief scheduled updates to prepare 150+ pandal updates. Please check back shortly.',
          primaryButtonText: 'Check Service Status',
          onPrimaryAction: onRetry,
        ),
      ),
    );
  }
}
