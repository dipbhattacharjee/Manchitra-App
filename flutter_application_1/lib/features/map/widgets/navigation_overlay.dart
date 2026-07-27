import 'package:flutter/material.dart';
import 'package:manchitra/core/providers/navigation_controller.dart';
import 'package:manchitra/core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Navigation Overlay (Turn-by-Turn Banners)
/// ============================================================

class NavigationOverlay extends StatelessWidget {
  final NavigationController nav;
  final VoidCallback onEndNavigation;

  const NavigationOverlay({
    super.key,
    required this.nav,
    required this.onEndNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final step = nav.currentStep;
    final destPandal = nav.destinationPandal;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // 1. Top Maneuver & Next Turn Instruction Banner (Full Width, Solid Background)
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E0A10), Color(0xFF380813)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Destination & Waypoint Context Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.navigation_rounded, color: AppColors.tertiary, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              nav.isMultiStopMode
                                  ? 'Stop ${nav.currentWaypointIndex + 1} of ${nav.totalWaypoints} · ${destPandal?.name ?? "Pandal"}'
                                  : 'Navigating to ${destPandal?.name ?? "Pandal"}',
                              style: const TextStyle(
                                color: AppColors.tertiary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (nav.isMultiStopMode)
                      GestureDetector(
                        onTap: () => nav.advanceToNextStop(),
                        child: Row(
                          children: const [
                            Text(
                              'Next Stop',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (nav.isRerouting) ...[
                  Row(
                    children: const [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.tertiary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recalculating route...',
                        style: TextStyle(
                          color: AppColors.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  children: [
                    // Turn Maneuver Icon Circle
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getManeuverIcon(step?.maneuverType, step?.maneuverModifier),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Instruction Text & Distance Banner ("In 108 m")
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step?.instruction ?? 'Proceed along route',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'In ${_formatManeuverDistance(nav.distanceToNextStepMeters)}',
                            style: const TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 2. Bottom Navigation ETA Summary Bar (Positioned safely above Bottom Nav Bar)
        Positioned(
          bottom: 88 + bottomPadding,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Destination details + ETA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            nav.formattedDurationRemaining,
                            style: const TextStyle(
                              color: Color(0xFF2A8A4A),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${nav.formattedDistanceRemaining})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ETA: ${nav.etaFormatted} • ${destPandal?.name ?? "Pandal"}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // End Navigation (Red Cross) Button EMBEDDED SAFELY INSIDE ETA BAR
                GestureDetector(
                  onTap: onEndNavigation,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFC8363C),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getManeuverIcon(String? type, String? modifier) {
    if (type == 'arrive') return Icons.flag_rounded;
    if (modifier == null) return Icons.straight_rounded;

    if (modifier.contains('left')) {
      if (modifier.contains('slight')) return Icons.turn_slight_left_rounded;
      if (modifier.contains('sharp')) return Icons.turn_sharp_left_rounded;
      return Icons.turn_left_rounded;
    }

    if (modifier.contains('right')) {
      if (modifier.contains('slight')) return Icons.turn_slight_right_rounded;
      if (modifier.contains('sharp')) return Icons.turn_sharp_right_rounded;
      return Icons.turn_right_rounded;
    }

    if (modifier.contains('uturn')) return Icons.u_turn_left_rounded;

    return Icons.straight_rounded;
  }

  String _formatManeuverDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }
}
