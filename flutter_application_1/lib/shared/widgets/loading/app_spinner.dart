import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Reusable Branded AppSpinner Widget
/// Customized circular indicator with brand styling & optional label.
/// ============================================================

class AppSpinner extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? label;
  final TextStyle? labelStyle;

  const AppSpinner({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.5,
    this.color,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor = color ?? AppColors.primary;

    final spinnerWidget = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
      ),
    );

    if (label == null) return spinnerWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        spinnerWidget,
        const SizedBox(height: 10),
        Text(
          label!,
          style: labelStyle ??
              TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
