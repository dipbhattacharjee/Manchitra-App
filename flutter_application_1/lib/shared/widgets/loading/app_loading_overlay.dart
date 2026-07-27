import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'app_spinner.dart';

/// ============================================================
/// MANCHITRA — Reusable AppLoadingOverlay Widget
/// Full-screen modal overlay for blocking actions (uploading, route saving).
/// ============================================================

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final double? progressPercentage;
  final Color barrierColor;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.progressPercentage,
    this.barrierColor = const Color(0x99000000),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          PopScope(
            canPop: false,
            child: Container(
              color: barrierColor,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppSpinner(size: 36, strokeWidth: 3.0),
                      if (progressPercentage != null) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            value: progressPercentage! / 100.0,
                            backgroundColor: const Color(0xFFF0EAE1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${progressPercentage!.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      if (message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          message!,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
