import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Production State Base Layout
/// Reusable base container matching Durga Puja red/gold aesthetics.
/// ============================================================

class StateBaseLayout extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final String message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryAction;
  final Widget? extraContent;

  const StateBaseLayout({
    super.key,
    required this.iconWidget,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.onPrimaryAction,
    this.secondaryButtonText,
    this.onSecondaryAction,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon / Illustration Badge
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F0),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Description / Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            if (extraContent != null) ...[
              extraContent!,
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (primaryButtonText != null && onPrimaryAction != null) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    primaryButtonText!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            if (secondaryButtonText != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(
                  secondaryButtonText!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
