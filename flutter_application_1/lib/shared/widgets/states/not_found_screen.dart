import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — 404 / Resource Not Found Screen
/// ============================================================

class NotFoundScreen extends StatelessWidget {
  final String? resourceName;
  final VoidCallback? onBackToHome;

  const NotFoundScreen({
    super.key,
    this.resourceName,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StateBaseLayout(
          iconWidget: const Icon(
            Icons.find_in_page_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          title: 'Pandal or Route Not Found',
          message: resourceName != null
              ? 'The requested $resourceName could not be found or may have been updated.'
              : 'The Durga Puja pandal or saved route you are looking for does not exist or has been removed.',
          primaryButtonText: 'Back to Discover Map',
          onPrimaryAction: () {
            if (onBackToHome != null) {
              onBackToHome!();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
    );
  }
}
