import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:manchitra/core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Route Renderer Widget (Double-Stroke Polyline)
/// ============================================================

class RouteRenderer extends StatelessWidget {
  final List<LatLng> points;
  final bool isRerouting;

  const RouteRenderer({
    super.key,
    required this.points,
    this.isRerouting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    return PolylineLayer(
      polylines: [
        // 1. Base Casing Line (Dark Maroon/Navy underneath)
        Polyline(
          points: points,
          strokeWidth: 9.0,
          color: const Color(0xFF1E0A10),
          borderColor: Colors.transparent,
        ),

        // 2. Main Route Line (Durga Puja Deep Red accent on top)
        Polyline(
          points: points,
          strokeWidth: 5.0,
          color: isRerouting
              ? AppColors.tertiary
              : AppColors.primary,
          borderColor: Colors.transparent,
        ),
      ],
    );
  }
}
