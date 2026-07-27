import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// ============================================================
/// MANCHITRA — Button Styles
/// ============================================================
/// All reusable button styles in one place.
/// Import this file for consistent button theming.
/// ============================================================

class AppButtonStyles {
  AppButtonStyles._();

  // ─── ELEVATED BUTTON STYLES ───────────────────────────────────

  /// Primary full-width saffron gradient button (main CTAs)
  static ButtonStyle primaryGradientButton({
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: AppColors.onPrimary,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      textStyle: AppTextStyles.labelLarge,
    );
  }

  /// Secondary outlined gold button
  static ButtonStyle secondaryOutlinedButton({
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.secondary,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      side: const BorderSide(color: AppColors.secondary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      textStyle: AppTextStyles.labelLarge,
    );
  }

  /// Ghost / text button (muted, for less prominent actions)
  static ButtonStyle ghostButton() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.textMuted,
      textStyle: AppTextStyles.bodyMedium,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// Chip-style small button (e.g., 'Add to Hop', crowd filters)
  static ButtonStyle chipButton({
    bool isActive = false,
    Color? activeColor,
    BorderRadius? borderRadius,
  }) {
    final color = activeColor ?? AppColors.primary;
    return OutlinedButton.styleFrom(
      foregroundColor: isActive ? AppColors.onPrimary : color,
      backgroundColor: isActive ? color : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      side: BorderSide(color: color, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      textStyle: AppTextStyles.labelMedium,
    );
  }

  /// Icon + label button (e.g., transport mode chip)
  static ButtonStyle iconLabelChip({
    bool isActive = false,
    Color? backgroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? (isActive ? AppColors.primary : AppColors.surface),
      foregroundColor: isActive ? AppColors.onPrimary : AppColors.textSecondary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      textStyle: AppTextStyles.labelSmall,
    );
  }

  /// Floating Action Button style (saffron glow)
  static FloatingActionButtonThemeData get fabTheme => FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 8,
    splashColor: AppColors.primaryLight,
    shape: const CircleBorder(),
  );

  /// Google sign-in button style
  static ButtonStyle googleSignInButton() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      backgroundColor: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      side: const BorderSide(color: AppColors.border, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: AppTextStyles.labelLarge,
    );
  }

  /// Danger / destructive button (e.g., Logout)
  static ButtonStyle dangerButton() {
    return TextButton.styleFrom(
      foregroundColor: AppColors.error,
      textStyle: AppTextStyles.bodyMedium,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // ─── GRADIENT BUTTON DECORATOR ────────────────────────────────
  /// Use this with a GradientButton wrapper widget to apply gradient
  static BoxDecoration primaryGradientDecoration({
    double borderRadius = 8,
    bool hasGlow = false,
  }) {
    return BoxDecoration(
      gradient: AppColors.primaryButtonGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: hasGlow
          ? [
              BoxShadow(
                color: AppColors.glowSaffron,
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration heroGradientDecoration({double borderRadius = 8}) {
    return BoxDecoration(
      gradient: AppColors.heroGradient,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // ─── BUTTON SIZE CONSTANTS ────────────────────────────────────
  static const double heightSmall = 36;
  static const double heightMedium = 48;
  static const double heightLarge = 56;
  static const double heightXLarge = 64;

  // ─── BORDER RADIUS CONSTANTS ─────────────────────────────────
  static const double radiusSmall = 6;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusPill = 100;
}

// ─── GRADIENT BUTTON WIDGET ──────────────────────────────────────
/// Use this widget anywhere you need a gradient button
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.gradient,
    this.height = AppButtonStyles.heightMedium,
    this.width = double.infinity,
    this.borderRadius = AppButtonStyles.radiusMedium,
    this.hasGlow = false,
    this.textStyle,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final LinearGradient? gradient;
  final double height;
  final double? width;
  final double borderRadius;
  final bool hasGlow;
  final TextStyle? textStyle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryButtonGradient;
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: onPressed != null ? effectiveGradient : null,
          color: onPressed == null ? AppColors.textDisabled : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: hasGlow && onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.glowSaffron,
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: textStyle ??
                          AppTextStyles.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── OUTLINED GRADIENT BORDER BUTTON ─────────────────────────────
class OutlinedGoldButton extends StatelessWidget {
  const OutlinedGoldButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.height = AppButtonStyles.heightMedium,
    this.width = double.infinity,
    this.padding,
    this.borderRadius = AppButtonStyles.radiusMedium,
  });

  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.secondary, width: 1.5),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
