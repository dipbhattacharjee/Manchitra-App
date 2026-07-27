import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — Slow Network / Degraded Connection Screen
/// ============================================================

class SlowNetworkScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const SlowNetworkScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StateBaseLayout(
      iconWidget: const Icon(
        Icons.network_check_rounded,
        size: 48,
        color: AppColors.secondary,
      ),
      title: 'Slow Connection Detected',
      message: 'Having trouble connecting — this request is taking longer than usual. Map tiles and pandal images may take extra time to load.',
      extraContent: Column(
        children: const [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Retrying in background...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      primaryButtonText: 'Try Again Now',
      onPrimaryAction: onRetry,
    );
  }
}
