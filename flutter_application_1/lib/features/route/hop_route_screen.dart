import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/services/route_service.dart';
import '../../core/providers/pandal_provider.dart';
import '../../core/providers/navigation_controller.dart';
import '../../shared/widgets/states/location_permission_denied_screen.dart';
import '../pandals/pandal_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../shared/widgets/loading/loading.dart';
import '../../core/services/calendar_sync_service.dart';

/// ============================================================
/// MANCHITRA — Hop Route Planner Screen (OpenStreetMap & Provider Routing)
/// ============================================================

class HopRouteScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMap;
  final VoidCallback? onBack;
  final DateTime? plannedDate;

  const HopRouteScreen({
    super.key,
    this.onNavigateToMap,
    this.onBack,
    this.plannedDate,
  });

  @override
  State<HopRouteScreen> createState() => _HopRouteScreenState();
}

class _HopRouteScreenState extends State<HopRouteScreen> {
  final RouteService _routeService = RouteService.instance;

  int _activeVariantIndex = 0; // 0: Fastest, 1: Shortest, 2: Walking
  bool _isSaving = false;
  bool _isOptimizing = false;
  bool _hasInitializedFromHopList = false;
  bool _isCustomOrdered = false;

  Future<void> _runOptimization(PandalProvider provider) async {
    if (_isOptimizing) return;
    setState(() => _isOptimizing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    provider.optimizeRoute();
    if (mounted) {
      setState(() {
        _isCustomOrdered = false;
        _isOptimizing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route reordered for shortest travel time.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Mock User Location (College Square, Kolkata) fallback
  final double _startLat = 22.574697;
  final double _startLng = 88.363989;

  // Local tracking of visited stops by pandal ID
  final Set<String> _visitedPandalIds = {};

  Future<void> _beginMultiStopNavigation(HopRoute activeRoute) async {
    final pandalProvider = context.read<PandalProvider>();
    final nav = context.read<NavigationController>();
    var pos = pandalProvider.userPosition;

    if (pos == null) {
      final status = await Permission.location.status;
      if (!status.isGranted) {
        final reqStatus = await Permission.location.request();
        if (!reqStatus.isGranted) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LocationPermissionDeniedScreen(),
              ),
            );
          }
          return;
        }
      }
      await pandalProvider.determinePosition();
      pos = pandalProvider.userPosition;
    }

    if (pos == null || activeRoute.stops.isEmpty) return;

    await nav.startMultiStopNavigation(activeRoute.stops, pos);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Started Multi-Stop Navigation across ${activeRoute.stops.length} Pandals!',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
        duration: const Duration(seconds: 2),
      ),
    );

    if (widget.onNavigateToMap != null) {
      widget.onNavigateToMap!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _saveActiveRoute(HopRoute activeRoute) async {
    setState(() => _isSaving = true);
    try {
      await _routeService.saveRoute(activeRoute);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route saved successfully!'),
          backgroundColor: Color(0xFF2A8A4A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Couldn\'t save your route — check connection and try again.',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _swapStops(int index1, int index2) {
    context.read<PandalProvider>().swapStops(index1, index2);
    setState(() {
      _isCustomOrdered = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stops reordered!'),
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: 24,
              ),
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else if (widget.onNavigateToMap != null) {
                  widget.onNavigateToMap!();
                }
              },
              tooltip: 'Back',
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                'Route Planner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black87,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              tooltip: 'Notifications',
            ),
            const SizedBox(width: 4),
            // Sticky Add Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAF101A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                elevation: 2,
              ),
              onPressed: _showAddPandalsSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final pandalProvider = context.watch<PandalProvider>();

    if (!_hasInitializedFromHopList &&
        pandalProvider.routeStops.isEmpty &&
        HopListManager.selectedPandals.isNotEmpty) {
      _hasInitializedFromHopList = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final deduped = {
          for (final p in HopListManager.selectedPandals) p.id: p,
        }.values.toList();
        pandalProvider.setRouteStops(deduped);
      });
    }

    final activeStops = pandalProvider.routeStops;
    final startLat = pandalProvider.userPosition?.latitude ?? _startLat;
    final startLng = pandalProvider.userPosition?.longitude ?? _startLng;

    // Reactively generate route variants based on provider stops
    final routeVariants = activeStops.isNotEmpty
        ? _routeService.generateRouteVariants(
            activeStops,
            startLat,
            startLng,
            preserveOrder: _isCustomOrdered,
          )
        : <HopRoute>[];

    final activeRoute = routeVariants.isNotEmpty
        ? routeVariants[_activeVariantIndex]
        : null;
    final bool isEmpty = activeStops.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: isEmpty
          ? _buildEmptyPlaceholder(context)
          : Column(
              children: [
                _buildHeaderRow(context),
                const Divider(color: Color(0xFFF0EAE1), height: 1),

                // Scrollable Body
                Expanded(
                  child: _buildRoutePlanner(
                    pandalProvider,
                    activeRoute,
                    startLat,
                    startLng,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Column(
      children: [
        _buildHeaderRow(context),
        const Divider(color: Color(0xFFF0EAE1), height: 1),
        Expanded(
          child: Center(
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
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.alt_route_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Hop List is Empty',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Go to the Discover screen or tap "+ Add Pandals" below to construct your customized route.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAF101A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _showAddPandalsSheet,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Pandals',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoutePlanner(
    PandalProvider provider,
    HopRoute? activeRoute,
    double startLat,
    double startLng,
  ) {
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

          // Feature Card: Proceed with Route to App Map (Road Navigation Feature)
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8C0D15), Color(0xFFAF101A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_road_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Proceed Route to Map',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'View your route & ${activeRoute.stops.length} pandals live on the road map',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _beginMultiStopNavigation(activeRoute),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.navigation_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      label: const Text(
                        'Proceed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.dipbhattacharjee.manchitra',
                              ),
                              RichAttributionWidget(
                                alignment: AttributionAlignment.bottomRight,
                                showFlutterMapAttribution: false,
                                attributions: [
                                  TextSourceAttribution(
                                    '© OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                              // Draw Polyline path (Real OSRM Road Polyline)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [
                                      LatLng(startLat, startLng),
                                      ...activeRoute.stops.map(
                                        (p) => LatLng(p.latitude, p.longitude),
                                      ),
                                    ],
                                    strokeWidth: 5.0,
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
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  // Stops markers numbered
                                  ...List.generate(activeRoute.stops.length, (
                                    idx,
                                  ) {
                                    final stop = activeRoute.stops[idx];
                                    return Marker(
                                      point: LatLng(
                                        stop.latitude,
                                        stop.longitude,
                                      ),
                                      width: 32,
                                      height: 32,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
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
                              onPressed: _isOptimizing
                                  ? null
                                  : () => _runOptimization(provider),
                              child: _isOptimizing
                                  ? const AppSpinner(size: 14, strokeWidth: 2.0)
                                  : const Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 5. Named Route Headline & Optimize Action
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _showAddStopDialog(context, provider),
                            icon: const Icon(
                              Icons.add_location_alt_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Add Stop',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Clear Hop Route?'),
                                  content: const Text(
                                    'Are you sure you want to remove all pandals from your current route sequence?',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        provider.clearRoute();
                                        HopListManager.selectedPandals.clear();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                      ),
                                      child: const Text(
                                        'Clear All',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            label: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: _isOptimizing
                                ? null
                                : () => _runOptimization(provider),
                            icon: _isOptimizing
                                ? const AppSpinner(size: 14, strokeWidth: 2.0)
                                : const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                            label: Text(
                              _isOptimizing ? 'Optimizing...' : 'Optimize',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed:
                                activeRoute == null || activeRoute.stops.isEmpty
                                ? null
                                : () async {
                                    final tripDate =
                                        widget.plannedDate ??
                                        DateTime(2026, 10, 18);
                                    final success = await CalendarSyncService
                                        .instance
                                        .addRouteScheduleToCalendar(
                                          stops: activeRoute.stops,
                                          tripDate: tripDate,
                                        );
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Hop Route synced to native device calendar!',
                                          ),
                                          backgroundColor: Color(0xFF2A8A4A),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(
                              Icons.event_available_rounded,
                              size: 16,
                              color: Color(0xFF2A8A4A),
                            ),
                            label: const Text(
                              'Sync Cal',
                              style: TextStyle(
                                color: Color(0xFF2A8A4A),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isOptimizing) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      AppSpinner(size: 12, strokeWidth: 1.8),
                      SizedBox(width: 8),
                      Text(
                        'Calculating best route sequence...',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    sub: provider.userPosition != null
                        ? 'Live GPS Location'
                        : 'College Square area, Kolkata',
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
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    isStart: true,
                  ),

                  // Legs and Stops
                  ...List.generate(activeRoute.stops.length, (index) {
                    final stop = activeRoute.stops[index];
                    final leg = (index < activeRoute.legs.length)
                        ? activeRoute.legs[index]
                        : null;
                    final bool isVisited = _visitedPandalIds.contains(stop.id);

                    return Column(
                      children: [
                        // Timeline connector representing transit leg
                        if (leg != null)
                          _buildTimelineConnector(
                            text:
                                '${leg.durationMin} min via ${leg.suggestedMode.name.toUpperCase()} (${leg.distanceKm.toStringAsFixed(1)} km)',
                            icon: leg.suggestedMode.icon,
                          ),

                        // Timeline Stop representing Pandal
                        _buildTimelineStop(
                          title: stop.name,
                          sub: stop.theme ?? 'Traditional barowari design',
                          crowd: stop.crowdLevel.label,
                          duration: '30 min view time',
                          badgeText: 'Stop ${index + 1}',
                          badgeBg: isVisited
                              ? const Color(0xFFE2F0D9)
                              : const Color(0xFFFFF2F0),
                          badgeTextColor: isVisited
                              ? const Color(0xFF2A8A4A)
                              : AppColors.primary,
                          pandal: stop,
                          isVisited: isVisited,
                          onToggleVisited: () {
                            setState(() {
                              if (isVisited) {
                                _visitedPandalIds.remove(stop.id);
                              } else {
                                _visitedPandalIds.add(stop.id);
                              }
                            });
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PandalDetailScreen(pandal: stop),
                              ),
                            );
                          },
                          // Reordering options
                          showReorder: true,
                          onMoveUp: index > 0
                              ? () => _swapStops(index, index - 1)
                              : null,
                          onMoveDown: index < activeRoute.stops.length - 1
                              ? () => _swapStops(index, index + 1)
                              : null,
                          onRemove: () {
                            provider.removeFromRoute(stop.id);
                            HopListManager.remove(stop.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Removed ${stop.name} from route.',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          // 7. Action Buttons (Start Multi-Stop Navigation & Save Route)
          if (activeRoute != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _beginMultiStopNavigation(activeRoute),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A8A4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.navigation_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Start Multi-Stop Navigation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (activeRoute.stops.isNotEmpty) {
                              if (widget.onNavigateToMap != null) {
                                widget.onNavigateToMap!();
                              } else {
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.map_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text(
                            'View Route on Map',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving
                              ? null
                              : () => _saveActiveRoute(activeRoute),
                          icon: _isSaving
                              ? const AppSpinner(size: 14, strokeWidth: 2.0)
                              : const Icon(
                                  Icons.save_alt_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save This Hop',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
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
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: hasCrowdRing
                ? Border.all(color: Colors.green, width: 2)
                : null,
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
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (unit.isNotEmpty) const SizedBox(width: 2),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            color: Colors.grey[500],
          ),
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
    Widget? markerWidget,
    Pandal? pandal,
    bool isVisited = false,
    VoidCallback? onToggleVisited,
    bool isStart = false,
    bool showReorder = false,
    VoidCallback? onMoveUp,
    VoidCallback? onMoveDown,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  }) {
    Widget avatarWidget;
    if (isStart || pandal == null) {
      avatarWidget = markerWidget ??
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 20),
          );
    } else {
      final String? imageUrl = (pandal.coverPhotoUrl != null &&
              pandal.coverPhotoUrl!.trim().isNotEmpty)
          ? pandal.coverPhotoUrl
          : (pandal.photoUrls.isNotEmpty &&
                  pandal.photoUrls.first.trim().isNotEmpty)
              ? pandal.photoUrls.first
              : null;

      Widget imgContent;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imgContent = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isVisited
                    ? const Color(0xFF2A8A4A)
                    : pandal.placeType.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVisited ? Icons.check : pandal.placeType.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      } else {
        imgContent = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isVisited
                ? const Color(0xFF2A8A4A)
                : pandal.placeType.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isVisited ? Icons.check : pandal.placeType.icon,
            color: Colors.white,
            size: 20,
          ),
        );
      }

      avatarWidget = GestureDetector(
        onTap: onToggleVisited,
        child: Stack(
          children: [
            imgContent,
            if (isVisited)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A8A4A).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0EAE1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            avatarWidget,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
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
                      if (crowd != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Crowd: $crowd',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (showReorder) ...[
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onMoveUp != null)
                    InkWell(
                      onTap: onMoveUp,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Color(0xFFB71C1C),
                          size: 22,
                        ),
                      ),
                    ),
                  if (onMoveDown != null)
                    InkWell(
                      onTap: onMoveDown,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFFB71C1C),
                          size: 22,
                        ),
                      ),
                    ),
                  if (onRemove != null)
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ],
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
        border: Border(left: BorderSide(color: Color(0xFFE2DCD0), width: 2)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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
                    color: AppColors.primary.withValues(alpha: 0.9),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                            final isAdded = provider.routeStops.any(
                              (p) => p.id == pandal.id,
                            );
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image:
                                      pandal.coverPhotoUrl != null &&
                                          pandal.coverPhotoUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            pandal.coverPhotoUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: const Color(0xFFF5F5F5),
                                ),
                                child:
                                    pandal.coverPhotoUrl != null &&
                                        pandal.coverPhotoUrl!.isNotEmpty
                                    ? null
                                    : const Icon(
                                        Icons.temple_hindu,
                                        color: Color(0xFFAF101A),
                                      ),
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
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isAdded
                                      ? Icons.check_circle_rounded
                                      : Icons.add_circle_outline_rounded,
                                  color: isAdded
                                      ? Colors.green
                                      : const Color(0xFFAF101A),
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

  void _showAddStopDialog(BuildContext context, PandalProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DefaultTabController(
          length: 3,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Stop to Route',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.temple_hindu, size: 18),
                      text: 'Pandals',
                    ),
                    Tab(
                      icon: Icon(Icons.restaurant_rounded, size: 18),
                      text: 'Dining',
                    ),
                    Tab(
                      icon: Icon(Icons.place_rounded, size: 18),
                      text: 'Other Places',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPlaceList(
                        ctx,
                        provider,
                        provider.pandals
                            .where((p) => p.placeType == PlaceType.pandal)
                            .toList(),
                      ),
                      _buildPlaceList(
                        ctx,
                        provider,
                        SampleData.sampleNonPandalPlaces
                            .where((p) => p.placeType == PlaceType.restaurant)
                            .toList(),
                      ),
                      _buildPlaceList(
                        ctx,
                        provider,
                        SampleData.sampleNonPandalPlaces
                            .where((p) => p.placeType == PlaceType.other)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceList(
    BuildContext ctx,
    PandalProvider provider,
    List<Pandal> places,
  ) {
    return ListView.separated(
      itemCount: places.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = places[index];
        final isAlreadyAdded = provider.routeStops.any((s) => s.id == place.id);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: place.placeType.color.withValues(alpha: 0.12),
            child: Icon(
              place.placeType.icon,
              color: place.placeType.color,
              size: 20,
            ),
          ),
          title: Text(
            place.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${place.area} • ${place.theme ?? place.category.label}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: IconButton(
            icon: Icon(
              isAlreadyAdded ? Icons.check_circle : Icons.add_circle_outline,
              color: isAlreadyAdded ? Colors.green : AppColors.primary,
            ),
            onPressed: () {
              if (!isAlreadyAdded) {
                provider.addToRoute(place);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${place.name} to route sequence!'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
