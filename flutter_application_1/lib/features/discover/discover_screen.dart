import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/pandal_provider.dart';
import '../pandals/pandal_detail_screen.dart';
import '../../shared/widgets/skeleton_loader.dart';

/// ============================================================
/// MANCHITRA — Discover / Map Screen (OpenStreetMap Integration)
/// ============================================================

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.initialSearchQuery});
  final String? initialSearchQuery;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  Pandal? _selectedPandal;
  bool _showPandalSheet = false;
  bool _isMapView = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PandalProvider>();

    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      // Update provider query silently or trigger fetch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.updateSearchQuery(widget.initialSearchQuery!);
      });
    }

    _searchController.addListener(_onSearchChanged);

    // Get initial position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.determinePosition();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<PandalProvider>().updateSearchQuery(_searchController.text);
  }

  // Recenter map on user location or Kolkata default
  void _recenterMap(PandalProvider provider) {
    if (provider.userPosition != null) {
      _mapController.move(
        LatLng(provider.userPosition!.latitude, provider.userPosition!.longitude),
        15.0,
      );
    } else {
      _mapController.move(
        const LatLng(PandalProvider.kolkataLat, PandalProvider.kolkataLng),
        13.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centered on Kolkata (GPS unavailable)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pandalProvider = context.watch<PandalProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Conditional View: Map or List Directory
          if (_isMapView)
            _buildMapView(pandalProvider)
          else
            _buildListView(pandalProvider, size),

          // 2. Search Bar Overlay at Top
          Positioned(
            top: 54,
            left: 20,
            right: 20,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.search, color: Colors.grey, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search pandals, locations, themes...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Horizontal Filters Row
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            height: 44,
            child: _buildFiltersRow(pandalProvider),
          ),

          // 4. Live Location Permission Banner
          if (pandalProvider.permissionDenied)
            Positioned(
              top: 172,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Location access denied. Map is centered on Kolkata default.',
                        style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => pandalProvider.determinePosition(),
                      child: const Text(
                        'Grant',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Floating Action Controls (GPS reset + Map Layer toggle)
          if (_isMapView)
            Positioned(
              right: 20,
              top: pandalProvider.permissionDenied ? 232 : 180,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _recenterMap(pandalProvider),
                    child: _buildFloatingControl(Icons.my_location),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OSM Standard tile layout active.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: _buildFloatingControl(Icons.layers_outlined),
                  ),
                ],
              ),
            ),

          // 6. Bottom Pandal Detail Card (Only in Map View)
          if (_isMapView && _showPandalSheet)
            _buildBottomCard(pandalProvider),
        ],
      ),
    );
  }

  Widget _buildMapView(PandalProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (provider.pandals.isEmpty) {
      return Container(
        color: const Color(0xFFFDFBF7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage ?? 'No markers match search filters.',
                style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => provider.fetchPandals(),
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    // Set up markers for Pandals
    final markers = provider.pandals.map((pandal) {
      final bool isActive = _selectedPandal?.id == pandal.id;
      return Marker(
        point: LatLng(pandal.latitude, pandal.longitude),
        width: 90.0,
        height: 70.0,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPandal = pandal;
              _showPandalSheet = true;
            });
            _mapController.move(LatLng(pandal.latitude, pandal.longitude), 15.0);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  pandal.name.length > 10 ? '${pandal.name.substring(0, 10)}...' : pandal.name,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.primary : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.temple_hindu, color: Colors.white, size: 12),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(PandalProvider.kolkataLat, PandalProvider.kolkataLng),
        initialZoom: 13.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) {
          setState(() {
            _showPandalSheet = false;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.dipbhattacharjee.manchitra',
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint('OSM Tile load failure: $error');
          },
        ),
        SimpleAttributionWidget(
          source: const Text('OpenStreetMap contributors'),
        ),
        // Live Location Layer (Draw separately so it is never clustered)
        MarkerLayer(
          markers: [
            if (provider.userPosition != null)
              Marker(
                point: LatLng(provider.userPosition!.latitude, provider.userPosition!.longitude),
                width: 40.0,
                height: 40.0,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Pandal Cluster Layer
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(6),
            markers: markers,
            builder: (context, clusterMarkers) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    clusterMarkers.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView(PandalProvider provider, Size size) {
    if (provider.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 180, bottom: 90, left: 16, right: 16),
        itemCount: 5,
        itemBuilder: (context, index) => const PandalDirectoryCardSkeleton(),
      );
    }

    if (provider.pandals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage ?? 'No pandals match filters.',
              style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => provider.fetchPandals(),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 180, bottom: 90, left: 16, right: 16),
      itemCount: provider.pandals.length,
      itemBuilder: (context, i) {
        final pandal = provider.pandals[i];
        return _buildPandalCard(pandal);
      },
    );
  }

  Widget _buildPandalCard(Pandal pandal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PandalDetailScreen(pandal: pandal),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(pandal.coverPhotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                    ? null
                    : const Center(
                        child: Icon(Icons.temple_hindu, color: AppColors.secondary, size: 36),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pandal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                        ),
                        if (pandal.isFeatured2026)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('★ 2026', style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pandal.theme ?? 'Traditional decor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(pandal.area, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(width: 12),
                        const Icon(Icons.directions_walk, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(pandal.distanceText, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: pandal.crowdLevel.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pandal.crowdLevel.label,
                            style: TextStyle(color: pandal.crowdLevel.color, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          pandal.rating?.toStringAsFixed(1) ?? '4.5',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(PandalProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // View Mode Toggle (Map vs List)
          GestureDetector(
            onTap: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isMapView ? Icons.list_alt_rounded : Icons.map_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isMapView ? 'List View' : 'Map View',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Featured filter chip
          _buildFilterChip(
            label: 'Featured 2026',
            isSelected: provider.featuredOnly,
            onTap: () => provider.toggleFeaturedOnly(),
          ),
          const SizedBox(width: 8),

          // Category Dropdown
          _buildCategoryDropdownChip(provider),
          const SizedBox(width: 8),

          // Area Dropdown
          _buildAreaDropdownChip(provider),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdownChip(PandalProvider provider) {
    final categories = ['All', 'Traditional Barowari', 'Theme-Based', 'Eco-Friendly', 'Community', 'Famous Heritage'];
    return PopupMenuButton<String>(
      onSelected: (val) => provider.updateCategory(val),
      itemBuilder: (context) => categories
          .map((c) => PopupMenuItem<String>(
                value: c,
                child: Text(c),
              ))
          .toList(),
      child: _buildFilterChip(
        label: provider.selectedCategory == 'All' ? 'Category' : provider.selectedCategory,
        isSelected: provider.selectedCategory != 'All',
        onTap: null,
      ),
    );
  }

  Widget _buildAreaDropdownChip(PandalProvider provider) {
    final areas = ['All', 'North Kolkata', 'South Kolkata', 'Central Kolkata', 'Lake Town', 'Gariahat', 'Shyambazar', 'Kumartuli', 'College Street', 'New Alipore', 'Kasba', 'Kalighat', 'Ahiritola', 'Barisha', 'Jorasanko', 'Pathuriaghata'];
    return PopupMenuButton<String>(
      onSelected: (val) => provider.updateArea(val),
      itemBuilder: (context) => areas
          .map((a) => PopupMenuItem<String>(
                value: a,
                child: Text(a),
              ))
          .toList(),
      child: _buildFilterChip(
        label: provider.selectedArea == 'All' ? 'Area' : provider.selectedArea,
        isSelected: provider.selectedArea != 'All',
        onTap: null,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingControl(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  Widget _buildBottomCard(PandalProvider provider) {
    if (!_showPandalSheet || _selectedPandal == null) {
      return const SizedBox.shrink();
    }
    final pandal = _selectedPandal!;
    final bool isInRoute = provider.routeStops.any((p) => p.id == pandal.id);

    // Format hours label
    final String start = pandal.visitStartTime ?? '09:00';
    final String end = pandal.visitEndTime ?? '23:59';
    final String hoursLabel = (start == '09:00' && end == '23:59') ? 'Open 24 Hours' : 'Hours: $start - $end';

    return Positioned(
      left: 16,
      right: 16,
      bottom: 96,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pandal Header Row with Image on Left
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(pandal.coverPhotoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                          ? null
                          : const LinearGradient(
                              colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    ),
                    child: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                        ? null
                        : const Center(
                            child: Icon(Icons.temple_hindu, color: AppColors.secondary, size: 30),
                          ),
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pandal.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showPandalSheet = false;
                                });
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.black54, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pandal.area,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, size: 13, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              hoursLabel,
                              style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chips Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, color: pandal.crowdLevel.color, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Crowd: ${pandal.crowdLevel.label}',
                              style: TextStyle(color: pandal.crowdLevel.color, fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFF785900), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pandal.theme ?? 'Traditional decor',
                              style: const TextStyle(color: Color(0xFF785900), fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Button Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // View Details Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PandalDetailScreen(pandal: pandal),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                      label: const Text(
                        'Details',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add to Route Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (isInRoute) {
                            provider.removeFromRoute(pandal.id);
                          } else {
                            provider.addToRoute(pandal);
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInRoute
                                  ? 'Removed ${pandal.name} from Route!'
                                  : 'Added ${pandal.name} to Route!',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: isInRoute ? Colors.black87 : AppColors.primary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInRoute ? Colors.grey[800] : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                      ),
                      icon: Icon(
                        isInRoute ? Icons.remove_circle_outline : Icons.add_location_alt_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(
                        isInRoute ? 'Remove Route' : 'Add to Route',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
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
}
