import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:manchitra/core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Animated Location Puck Widget
/// ============================================================

class LocationPuck extends StatefulWidget {
  final double headingDegrees;
  final double accuracyRadiusMeters;

  const LocationPuck({
    super.key,
    required this.headingDegrees,
    this.accuracyRadiusMeters = 18.0,
  });

  @override
  State<LocationPuck> createState() => _LocationPuckState();
}

class _LocationPuckState extends State<LocationPuck>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headingRadians = (widget.headingDegrees * math.pi) / 180.0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(
                    (1.5 - _pulseAnimation.value).clamp(0.0, 0.35),
                  ),
                ),
              ),
            ),

            Transform.rotate(
              angle: headingRadians,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: _HeadingConePainter(),
                  ),
                  Positioned(
                    top: 2,
                    child: Icon(
                      Icons.navigation_rounded,
                      size: 22,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeadingConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.4),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 - math.pi / 6,
        math.pi / 3,
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
