import 'package:flutter/material.dart';
import 'app_shimmer.dart';

/// ============================================================
/// MANCHITRA — Reusable SkeletonBox Primitive Widget
/// Parameterized rounded rectangle box primitive wrapped in AppShimmer.
/// ============================================================

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxShape shape;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.margin,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.color,
  });

  const SkeletonBox.circle({
    super.key,
    required double size,
    this.margin,
    this.padding,
    this.color,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: color ?? const Color(0xFFECE8E0),
      shape: shape,
      borderRadius: shape == BoxShape.circle
          ? null
          : BorderRadius.circular(borderRadius),
    );

    final boxChild = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: boxDecoration,
    );

    return AppShimmer(child: boxChild);
  }
}
