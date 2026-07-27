import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — Generic Error Screen
/// ============================================================

class GenericErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onTryAgain;

  const GenericErrorScreen({
    super.key,
    this.errorMessage,
    this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return StateBaseLayout(
      iconWidget: const Icon(
        Icons.error_outline_rounded,
        size: 48,
        color: AppColors.primary,
      ),
      title: 'Something Went Wrong',
      message: errorMessage ?? 'An unexpected error occurred while loading Durga Puja data. Please try again.',
      primaryButtonText: 'Try Again',
      onPrimaryAction: onTryAgain,
      secondaryButtonText: 'Report Issue',
      onSecondaryAction: () async {
        final Uri mailUri = Uri.parse('mailto:support@learntechsolutions.com?subject=Manchitra%20App%20Issue%20Report');
        if (await canLaunchUrl(mailUri)) {
          await launchUrl(mailUri);
        }
      },
    );
  }
}
