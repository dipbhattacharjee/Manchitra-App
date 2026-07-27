import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/map_config.dart';
import '../../core/models/models.dart';
import '../../core/providers/navigation_controller.dart';
import '../../core/providers/pandal_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/navigation_utils.dart';
import 'widgets/location_puck.dart';
import 'widgets/navigation_overlay.dart';
import 'widgets/pandal_detail_sheet.dart';
import 'widgets/pandal_marker_layer.dart';
import 'widgets/route_renderer.dart';
import '../../shared/widgets/loading/loading.dart';
import '../../shared/widgets/states/skeleton_loaders.dart';

/// ============================================================
/// MANCHITRA — Full Interactive Map & Navigation Screen
/// ============================================================

class MapScreen extends StatefulWidget {
  final Pandal? initialPandal;
  final bool embedInDiscover;

  const MapScreen({
    super.key,
    this.initialPandal,
    this.embedInDiscover = true,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  Pandal? _selectedPandal;
  bool _isEveningTheme = MapConfig.isEveningTime();
  bool _isFollowUserMode = true;

  @override
  void initState() {
    super.initState();
    _selectedPandal = widget.initialPandal;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pandalProvider = context.read<PandalProvider>();
      pandalProvider.determinePosition();

      if (widget.initialPandal != null) {
        _animatedMapMove(
          LatLng(widget.initialPandal!.latitude, widget.initialPandal!.longitude),
          16.0,
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Perform smooth animated camera movement (ease-in-out)
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _onPandalSelected(Pandal pandal) {
    setState(() {
      _selectedPandal = pandal;
      _isFollowUserMode = false;
    });

    _animatedMapMove(
      LatLng(pandal.latitude, pandal.longitude),
      16.0,
    );
  }

  void _recenterOnUser(NavigationController nav, PandalProvider provider) {
    final pos = nav.userLocation ??
        (provider.userPosition != null
            ? LatLng(provider.userPosition!.latitude, provider.userPosition!.longitude)
            : const LatLng(MapConfig.defaultLat, MapConfig.defaultLng));

    setState(() {
      _isFollowUserMode = true;
    });

    _animatedMapMove(pos, nav.isNavigating ? MapConfig.navigationZoom : MapConfig.defaultZoom);
  }

  @override
  Widget build(BuildContext context) {
    final pandalProvider = context.watch<PandalProvider>();
    final nav = context.watch<NavigationController>();

    final userCoord = nav.userLocation ??
        (pandalProvider.userPosition != null
            ? LatLng(
                pandalProvider.userPosition!.latitude,
                pandalProvider.userPosition!.longitude,
              )
            : const LatLng(MapConfig.defaultLat, MapConfig.defaultLng));

    // Calculate distance & ETA strings for bottom detail sheet
    String distanceText = '1.2 km';
    String etaText = '8 min';
    if (_selectedPandal != null) {
      final dist = NavigationUtils.distanceMeters(
        userCoord,
        LatLng(_selectedPandal!.latitude, _selectedPandal!.longitude),
      );
      if (dist >= 1000) {
        distanceText = '${(dist / 1000).toStringAsFixed(1)} km';
        etaText = '${(dist / 1000 * 12).round()} min';
      } else {
        distanceText = '${dist.round()} m';
        etaText = '${(dist / 1000 * 12).round().clamp(1, 60)} min';
      }
    }

    // Display pandals: Highlight waypoints during active multi-stop navigation; otherwise show all pandals
    final List<Pandal> displayedPandals = (nav.isNavigating && nav.isMultiStopMode && nav.waypoints.isNotEmpty)
        ? nav.waypoints
        : pandalProvider.pandals;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Core Interactive Map View (Raster tiles at 100% natural saturation, no dark tint overlay)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userCoord,
              initialZoom: MapConfig.defaultZoom,
              minZoom: 10.0,
              maxZoom: 18.5,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isFollowUserMode) {
                  setState(() => _isFollowUserMode = false);
                }
              },
            ),
            children: [
              // Tile Layer: OpenStreetMap Raster Tiles (Full Natural Color Saturation)
              TileLayer(
                urlTemplate: MapConfig.osmTileUrlPattern,
                userAgentPackageName: MapConfig.userAgentPackageName,
                tileProvider: NetworkTileProvider(),
              ),

              // Polyline Layer: Rendered ONLY when active turn-by-turn navigation is running
              if (nav.isNavigating && nav.currentRoute != null && nav.currentRoute!.points.isNotEmpty)
                RouteRenderer(
                  points: nav.currentRoute!.points,
                  isRerouting: nav.isRerouting,
                ),

              // Marker Cluster Layer: Sourced from user planning route (if active) or all pandals
              PandalMarkerLayer(
                pandals: displayedPandals,
                selectedPandal: _selectedPandal,
                onPandalTapped: _onPandalSelected,
              ),

              // User Location Puck Layer (Animated pulse + heading arrow)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userCoord,
                    width: 70,
                    height: 70,
                    child: LocationPuck(
                      headingDegrees: nav.compassHeading,
                    ),
                  ),
                ],
              ),

              // Collapsed Legal OpenStreetMap Attribution Widget ("Watermark Fix")
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomRight,
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Pandal Data Loading Map Overlay
          if (pandalProvider.isLoading && pandalProvider.pandals.isEmpty)
            const Positioned.fill(child: MapSkeletonLoader()),

          // Route Calculation Loading Banner
          if (nav.isRerouting || (nav.isNavigating && (nav.currentRoute == null || nav.currentRoute!.points.isEmpty)))
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppSpinner(size: 16, strokeWidth: 2.0),
                    SizedBox(width: 10),
                    Text(
                      'Finding your route...',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 2. Standalone Top Bar Controls (Only shown when NOT embedded in DiscoverScreen)
          if (!widget.embedInDiscover && !nav.isNavigating)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Floating Back Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Search Bar Chip
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Explore Puja Pandals...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Day/Night Puja Theme Toggle Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isEveningTheme
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_rounded,
                        color: _isEveningTheme ? const Color(0xFFFDC003) : Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEveningTheme = !_isEveningTheme;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          // 3. Standalone Recenter GPS Button (Only shown when NOT embedded in DiscoverScreen)
          if (!widget.embedInDiscover && !nav.isNavigating)
            Positioned(
              bottom: _selectedPandal != null ? 360 : 110,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'recenter_gps',
                backgroundColor: Colors.white,
                foregroundColor: _isFollowUserMode ? AppColors.primary : Colors.black87,
                elevation: 6,
                onPressed: () => _recenterOnUser(nav, pandalProvider),
                child: Icon(
                  _isFollowUserMode
                      ? Icons.my_location_rounded
                      : Icons.location_searching_rounded,
                ),
              ),
            ),

          // 4. Turn-by-Turn Navigation Active Overlay Mode
          if (nav.isNavigating)
            NavigationOverlay(
              nav: nav,
              onEndNavigation: () {
                nav.stopNavigation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigation ended.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

          // 5. Pandal Detail Draggable Bottom Sheet (on marker tap)
          if (_selectedPandal != null && !nav.isNavigating)
            PandalDetailSheet(
              pandal: _selectedPandal!,
              distanceText: distanceText,
              etaText: etaText,
              onStartNavigation: () async {
                final pos = pandalProvider.userPosition;
                if (pos == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Acquiring user GPS location for navigation...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  await pandalProvider.determinePosition();
                }

                final currentPos = pandalProvider.userPosition;
                if (currentPos != null) {
                  final success = await nav.startNavigation(_selectedPandal!, currentPos);
                  if (success) {
                    _animatedMapMove(
                      LatLng(currentPos.latitude, currentPos.longitude),
                      MapConfig.navigationZoom,
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enable GPS permissions to navigate.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onAddToHop: () {
                pandalProvider.addToRoute(_selectedPandal!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${_selectedPandal!.name} to your Hop List!'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onClose: () {
                setState(() => _selectedPandal = null);
              },
            ),
        ],
      ),
    );
  }
}
