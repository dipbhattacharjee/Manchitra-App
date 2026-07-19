import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/services/route_service.dart';
import '../../core/providers/pandal_provider.dart';
import '../pandals/pandal_detail_screen.dart';

/// ============================================================
/// MANCHITRA — Hop Route Planner Screen (OpenStreetMap & Provider Routing)
/// ============================================================

class HopRouteScreen extends StatefulWidget {
  const HopRouteScreen({super.key});

  @override
  State<HopRouteScreen> createState() => _HopRouteScreenState();
}

class _HopRouteScreenState extends State<HopRouteScreen> {
  final RouteService _routeService = RouteService.instance;
  
  int _activeVariantIndex = 0; // 0: Fastest, 1: Shortest, 2: Walking
  bool _isSaving = false;

  // Mock User Location (College Square, Kolkata) fallback
  final double _startLat = 22.574697;
  final double _startLng = 88.363989;

  // Local tracking of visited stops by pandal ID
  final Set<String> _visitedPandalIds = {};

  Future<void> _saveActiveRoute(HopRoute activeRoute) async {
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

  void _swapStops(int index1, int index2) {
    context.read<PandalProvider>().swapStops(index1, index2);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stops reordered and route recalculated!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pandalProvider = context.watch<PandalProvider>();
    final activeStops = pandalProvider.routeStops;
    final startLat = pandalProvider.userPosition?.latitude ?? _startLat;
    final startLng = pandalProvider.userPosition?.longitude ?? _startLng;

    // Reactively generate route variants based on provider stops
    final routeVariants = activeStops.isNotEmpty
        ? _routeService.generateRouteVariants(activeStops, startLat, startLng)
        : <HopRoute>[];

    final activeRoute = routeVariants.isNotEmpty ? routeVariants[_activeVariantIndex] : null;
    final bool isEmpty = activeStops.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: isEmpty
          ? _buildEmptyPlaceholder()
          : Column(
              children: [
                // Sticky Header at top of screen
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Plan Your Pandal Hop',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Optimized routing to experience the best of the festival.',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sticky Add Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAF101A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            elevation: 2,
                          ),
                          onPressed: _showAddPandalsSheet,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Add Stop',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFFF0EAE1), height: 1),

                // Scrollable Body
                Expanded(
                  child: _buildRoutePlanner(pandalProvider, activeRoute, startLat, startLng),
                ),
              ],
            ),
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
              'Go to the Discover screen or tap "+ Add Pandals" below to construct your customized route.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAF101A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _showAddPandalsSheet,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Pandals',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutePlanner(PandalProvider provider, HopRoute? activeRoute, double startLat, double startLng) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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

          // 4. Map Preview with Polyline route
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUTE VISUALIZATION',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                activeRoute.stops.first.latitude,
                                activeRoute.stops.first.longitude,
                              ),
                              initialZoom: 13.0,
                              minZoom: 3.0,
                              maxZoom: 18.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.dipbhattacharjee.manchitra',
                              ),
                              SimpleAttributionWidget(
                                source: const Text('OpenStreetMap contributors'),
                              ),
                              // Draw Polyline path
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [
                                      LatLng(startLat, startLng),
                                      ...activeRoute.stops.map((p) => LatLng(p.latitude, p.longitude)),
                                    ],
                                    strokeWidth: 4.5,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                              // Start position + Stop markers
                              MarkerLayer(
                                markers: [
                                  // User start marker
                                  Marker(
                                    point: LatLng(startLat, startLng),
                                    width: 32,
                                    height: 32,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blueGrey,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Colors.black26, blurRadius: 4),
                                        ],
                                      ),
                                      child: const Icon(Icons.my_location, color: Colors.white, size: 14),
                                    ),
                                  ),
                                  // Stops markers numbered
                                  ...List.generate(activeRoute.stops.length, (idx) {
                                    final stop = activeRoute.stops[idx];
                                    return Marker(
                                      point: LatLng(stop.latitude, stop.longitude),
                                      width: 32,
                                      height: 32,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: Colors.black26, blurRadius: 4),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${idx + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                          // Optimize floating button overlay
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: FloatingActionButton.small(
                              heroTag: 'optimize_route_btn',
                              backgroundColor: Colors.white,
                              onPressed: () {
                                provider.optimizeRoute();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Route optimized using Nearest-Neighbor!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 5. Named Route Headline
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Optimized Sequence',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        provider.clearRoute();
                      },
                      child: const Text('(Clear)', style: TextStyle(color: Colors.grey, fontSize: 13, decoration: TextDecoration.underline)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        provider.optimizeRoute();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Route optimized using Nearest-Neighbor!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('(Optimize)', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 6. Dynamic Timeline List
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Start Location indicator
                  _buildTimelineStop(
                    title: 'Your Starting Point',
                    sub: provider.userPosition != null ? 'Live GPS Location' : 'College Square area, Kolkata',
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

          // 7. Action Button (Save Route to Supabase)
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveActiveRoute(activeRoute),
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
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: isSelected ? AppColors.primary : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          border: Border.all(color: const Color(0xFFF0EAE1)),
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
            const SizedBox(width: 14),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Crowd: $crowd',
                            style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onMoveUp != null)
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.primary, size: 24),
                      onPressed: onMoveUp,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onMoveDown != null)
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 24),
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
    return Container(
      margin: const EdgeInsets.only(left: 27),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Color(0xFFE2DCD0),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: AppColors.primary.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPandalsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<PandalProvider>(
          builder: (context, provider, child) {
            final List<Pandal> availablePandals = provider.pandals.isNotEmpty
                ? provider.pandals
                : SampleData.featuredPandals;
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'Add Pandals to Hop List',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: availablePandals.length,
                          itemBuilder: (context, index) {
                            final pandal = availablePandals[index];
                            final isAdded = provider.routeStops.any((p) => p.id == pandal.id);
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(pandal.coverPhotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: const Color(0xFFF5F5F5),
                                ),
                                child: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                                    ? null
                                    : const Icon(Icons.temple_hindu, color: Color(0xFFAF101A)),
                              ),
                              title: Text(
                                pandal.name,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                pandal.area,
                                style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                  color: isAdded ? Colors.green : const Color(0xFFAF101A),
                                  size: 28,
                                ),
                                onPressed: () {
                                  if (isAdded) {
                                    provider.removeFromRoute(pandal.id);
                                  } else {
                                    provider.addToRoute(pandal);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
