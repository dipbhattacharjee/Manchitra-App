import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — Empty State Widget
/// ============================================================

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Pandals Found',
    this.message = 'Try searching with a different name, area, or theme keyword.',
    this.icon = Icons.search_off_rounded,
    this.buttonText = 'Explore Pandals',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return StateBaseLayout(
      iconWidget: Icon(icon, size: 48, color: AppColors.primary),
      title: title,
      message: message,
      primaryButtonText: buttonText,
      onPrimaryAction: onAction,
    );
  }
}
