import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/services/route_service.dart';
import '../pandals/pandal_detail_screen.dart';

/// ============================================================
/// MANCHITRA — Hop Route Planner Screen (Phase 3 Integration)
/// ============================================================

class HopRouteScreen extends StatefulWidget {
  const HopRouteScreen({super.key});

  @override
  State<HopRouteScreen> createState() => _HopRouteScreenState();
}

class _HopRouteScreenState extends State<HopRouteScreen> {
  final RouteService _routeService = RouteService.instance;
  
  int _activeVariantIndex = 0; // 0: Fastest, 1: Shortest, 2: Walking
  List<HopRoute> _routeVariants = [];
  bool _isSaving = false;

  // Mock User Location (College Square, Kolkata)
  final double _startLat = 22.574697;
  final double _startLng = 88.363989;

  // Local tracking of visited stops by pandal ID
  final Set<String> _visitedPandalIds = {};

  @override
  void initState() {
    super.initState();
    _recalculateRoutes();
  }

  void _recalculateRoutes() {
    if (HopListManager.selectedPandals.isNotEmpty) {
      setState(() {
        _routeVariants = _routeService.generateRouteVariants(
          HopListManager.selectedPandals,
          _startLat,
          _startLng,
        );
      });
    } else {
      setState(() {
        _routeVariants = [];
      });
    }
  }

  void _swapStops(int index1, int index2) {
    if (index1 < 0 || index1 >= HopListManager.selectedPandals.length) return;
    if (index2 < 0 || index2 >= HopListManager.selectedPandals.length) return;

    setState(() {
      final temp = HopListManager.selectedPandals[index1];
      HopListManager.selectedPandals[index1] = HopListManager.selectedPandals[index2];
      HopListManager.selectedPandals[index2] = temp;
    });
    _recalculateRoutes();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route recalculated instantly!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveActiveRoute() async {
    if (_routeVariants.isEmpty) return;
    final activeRoute = _routeVariants[_activeVariantIndex];

    setState(() => _isSaving = true);
    await _routeService.saveRoute(activeRoute);
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route saved successfully to Supabase!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = HopListManager.selectedPandals.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: isEmpty ? _buildEmptyPlaceholder() : _buildRoutePlanner(),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F0),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 4),
              ),
              child: const Icon(Icons.alt_route_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Hop List is Empty',
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              'Go to the Discover screen and tap "+ Add to Hop List" on pandals to construct your customized route.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePlanner() {
    final activeRoute = _routeVariants.isNotEmpty ? _routeVariants[_activeVariantIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Title + Tagline)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Your Pandal Hop',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI optimized routes to experience the best of the festival with minimal crowds.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Route Variant Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROUTE PREFERENCE',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2EA),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildVariantTab(0, 'Fastest', Icons.bolt),
                      _buildVariantTab(1, 'Shortest', Icons.straighten),
                      _buildVariantTab(2, 'Walking', Icons.directions_walk),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Statistics Indicators Row
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatIndicator(
                    icon: Icons.alt_route,
                    value: activeRoute.totalDistanceKm.toStringAsFixed(1),
                    unit: 'km',
                    label: 'Total Dist.',
                    circleColor: Colors.white,
                  ),
                  _buildStatIndicator(
                    icon: Icons.access_time_rounded,
                    value: activeRoute.totalTimeText,
                    unit: '',
                    label: 'Est. Time',
                    circleColor: Colors.white,
                  ),
                  _buildStatIndicator(
                    icon: Icons.people_outline,
                    value: 'Medium',
                    unit: '',
                    label: 'Crowd Factor',
                    circleColor: Colors.white,
                    hasCrowdRing: true,
                  ),
                ],
              ),
            ),

          // 4. Named Route Headline
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                const Text(
                  'Optimized Sequence',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      HopListManager.clear();
                      _recalculateRoutes();
                    });
                  },
                  child: const Text('(Clear)', style: TextStyle(color: Colors.grey, fontSize: 13, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),

          // 5. Dynamic Timeline List
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Start Location indicator
                  _buildTimelineStop(
                    title: 'Your Starting Point',
                    sub: 'College Square area, Kolkata',
                    crowd: null,
                    duration: null,
                    badgeText: 'Start',
                    badgeBg: const Color(0xFFFEF0D4),
                    badgeTextColor: const Color(0xFFB37400),
                    markerWidget: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.my_location, color: Colors.white, size: 14),
                    ),
                    isStart: true,
                  ),

                  // Legs and Stops
                  ...List.generate(activeRoute.stops.length, (index) {
                    final stop = activeRoute.stops[index];
                    final leg = activeRoute.legs[index];
                    final bool isVisited = _visitedPandalIds.contains(stop.id);

                    return Column(
                      children: [
                        // Timeline connector representing transit leg
                        _buildTimelineConnector(
                          text: '${leg.durationMin} min via ${leg.suggestedMode.name.toUpperCase()} (${leg.distanceKm.toStringAsFixed(1)} km)',
                          icon: leg.suggestedMode.icon,
                        ),

                        // Timeline Stop representing Pandal
                        _buildTimelineStop(
                          title: stop.name,
                          sub: stop.theme ?? 'Traditional barowari design',
                          crowd: stop.crowdLevel.label,
                          duration: '30 min view time',
                          badgeText: 'Stop ${index + 1}',
                          badgeBg: isVisited ? const Color(0xFFE2F0D9) : const Color(0xFFFFF2F0),
                          badgeTextColor: isVisited ? const Color(0xFF2A8A4A) : AppColors.primary,
                          markerWidget: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isVisited) {
                                  _visitedPandalIds.remove(stop.id);
                                } else {
                                  _visitedPandalIds.add(stop.id);
                                }
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isVisited ? const Color(0xFF2A8A4A) : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isVisited ? Icons.check : Icons.temple_hindu,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PandalDetailScreen(pandal: stop),
                              ),
                            );
                          },
                          // Reordering options
                          showReorder: true,
                          onMoveUp: index > 0 ? () => _swapStops(index, index - 1) : null,
                          onMoveDown: index < activeRoute.stops.length - 1 ? () => _swapStops(index, index + 1) : null,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          // 6. Action Button (Save Route to Supabase)
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveActiveRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save_alt_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Save Route to Supabase',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantTab(int index, String label, IconData icon) {
    final bool isSelected = _activeVariantIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeVariantIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.primary : Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIndicator({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color circleColor,
    bool hasCrowdRing = false,
  }) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: hasCrowdRing ? Border.all(color: Colors.green, width: 2) : null,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            if (unit.isNotEmpty) const SizedBox(width: 2),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontFamily: 'Manrope', fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildTimelineStop({
    required String title,
    required String sub,
    required String? crowd,
    required String? duration,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required Widget markerWidget,
    bool isStart = false,
    bool showReorder = false,
    VoidCallback? onMoveUp,
    VoidCallback? onMoveDown,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            markerWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                      if (crowd != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Crowd: $crowd',
                          style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showReorder)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                    onPressed: onMoveUp,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                    onPressed: onMoveDown,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineConnector({
    required String text,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            width: 2,
            height: 40,
            color: Colors.grey[300],
          ),
          const SizedBox(width: 20),
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
