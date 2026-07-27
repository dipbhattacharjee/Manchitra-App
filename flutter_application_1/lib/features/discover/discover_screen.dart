import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/pandal_provider.dart';
import '../../core/providers/navigation_controller.dart';
import '../pandals/pandal_detail_screen.dart';
import '../map/map_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/widgets/states/skeleton_loaders.dart';
import '../../shared/widgets/loading/loading.dart';

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

  // Live Debounced Search & Voice Input State
  Timer? _debounceTimer;
  List<Pandal> _liveSearchResults = [];
  bool _showSearchResultsDropdown = false;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListeningVoice = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<PandalProvider>();

    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _searchController.text = widget.initialSearchQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.updateSearchQuery(widget.initialSearchQuery!);
      });
    }

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.determinePosition();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim().toLowerCase();
      context.read<PandalProvider>().updateSearchQuery(_searchController.text);

      if (query.isEmpty) {
        if (mounted) {
          setState(() {
            _liveSearchResults = [];
            _showSearchResultsDropdown = false;
          });
        }
      } else {
        final allPandals = context.read<PandalProvider>().pandals;
        final matches = allPandals.where((p) {
          final nameMatch = p.name.toLowerCase().contains(query);
          final areaMatch = p.area.toLowerCase().contains(query);
          final themeMatch = p.theme != null && p.theme!.toLowerCase().contains(query);
          final categoryMatch = p.category.label.toLowerCase().contains(query);
          return nameMatch || areaMatch || themeMatch || categoryMatch;
        }).toList();

        if (mounted) {
          setState(() {
            _liveSearchResults = matches;
            _showSearchResultsDropdown = true;
          });
        }
      }
    });
  }

  void _listenVoiceInput() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission required for voice search.'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      bool available = await _speechToText.initialize(
        onError: (err) {
          if (mounted) {
            setState(() => _isListeningVoice = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Voice recognition error: ${err.errorMsg}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );

      if (available) {
        setState(() => _isListeningVoice = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listening... Speak pandal name or area (e.g. "Sree Bhumi")'),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _speechToText.listen(
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 8),
          onResult: (result) {
            if (mounted) {
              setState(() {
                _searchController.text = result.recognizedWords;
                _isListeningVoice = false;
              });
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition unavailable on this device.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Speech to text error: $e');
      if (mounted) {
        setState(() => _isListeningVoice = false);
      }
    }
  }

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pandalProvider = context.watch<PandalProvider>();
    final navController = context.watch<NavigationController>();
    final isNavigating = navController.isNavigating;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Map View Widget
          if (_isMapView)
            const MapScreen()
          else
            _buildListView(pandalProvider, size),

          // Top Protective Shield Backdrop (Ensures map markers never bleed underneath search bar + filters)
          if (!isNavigating)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 175,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.92),
                        Colors.white.withOpacity(0.70),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 2. Search Bar Overlay at Top (Hidden during turn-by-turn navigation)
          if (!isNavigating)
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
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
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
                    if (pandalProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: AppSpinner(size: 16, strokeWidth: 2.0),
                      ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _showSearchResultsDropdown = false;
                          });
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: GestureDetector(
                        onTap: _listenVoiceInput,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isListeningVoice ? AppColors.secondary : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListeningVoice ? Icons.graphic_eq_rounded : Icons.mic,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Live Debounced Search Results Dropdown List
          if (!isNavigating && _showSearchResultsDropdown)
            Positioned(
              top: 112,
              left: 20,
              right: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: _liveSearchResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "No pandals found for '${_searchController.text}'",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: _liveSearchResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _liveSearchResults[index];
                            final photo = p.coverPhotoUrl ??
                                (p.photoUrls.isNotEmpty ? p.photoUrls.first : null);
                            return ListTile(
                              dense: true,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: photo != null
                                      ? Image.network(photo, fit: BoxFit.cover)
                                      : const Icon(Icons.temple_hindu, color: AppColors.primary, size: 20),
                                ),
                              ),
                              title: Text(
                                p.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              subtitle: Text(
                                '${p.area} • ${p.category}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                              ),
                              onTap: () {
                                setState(() {
                                  _showSearchResultsDropdown = false;
                                  _selectedPandal = p;
                                  _showPandalSheet = true;
                                });
                                _mapController.move(
                                  LatLng(p.latitude, p.longitude),
                                  16.0,
                                );
                              },
                            );
                          },
                        ),
                ),
              ),
            ),

          // 4. Horizontal Filters Row (Hidden during turn-by-turn navigation)
          if (!isNavigating && !_showSearchResultsDropdown)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              height: 44,
              child: _buildFiltersRow(pandalProvider),
            ),

          // 5. Live Location Permission Banner (Hidden during turn-by-turn navigation)
          if (pandalProvider.permissionDenied && !isNavigating && !_showSearchResultsDropdown)
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

          // 6. Floating Action Controls (GPS reset + Map Layer toggle) (Hidden during navigation)
          if (_isMapView && !isNavigating && !_showSearchResultsDropdown)
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

          // 7. Bottom Pandal Detail Card (Only in Map View & when not navigating)
          if (_isMapView && _showPandalSheet && !isNavigating)
            _buildBottomCard(pandalProvider),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(PandalProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 32),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                mainAxisSize: MainAxisSize.min,
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

          _buildFilterChip(
            label: 'Featured 2026',
            isSelected: provider.featuredOnly,
            onTap: () => provider.toggleFeaturedOnly(),
          ),
          const SizedBox(width: 8),

          _buildCategoryDropdownChip(provider),
          const SizedBox(width: 8),

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
        hasDropdown: true,
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
        hasDropdown: true,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    bool hasDropdown = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ],
          ],
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
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }

  Widget _buildBottomCard(PandalProvider provider) {
    if (_selectedPandal == null) return const SizedBox.shrink();
    final p = _selectedPandal!;

    return Positioned(
      bottom: 90,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: AppColors.primary.withOpacity(0.1),
                child: p.coverPhotoUrl != null
                    ? Image.network(p.coverPhotoUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.temple_hindu, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p.area} • ${p.category}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _showPandalSheet = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(PandalProvider provider, Size size) {
    final pandals = provider.pandals;
    if (provider.isLoading && pandals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 170),
        child: PandalListSkeletonLoader(itemCount: 6),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 170, bottom: 100, left: 16, right: 16),
      itemCount: pandals.length,
      itemBuilder: (context, index) {
        final pandal = pandals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 54,
                height: 54,
                color: AppColors.primary.withOpacity(0.1),
                child: pandal.coverPhotoUrl != null
                    ? Image.network(pandal.coverPhotoUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.temple_hindu, color: AppColors.primary),
              ),
            ),
            title: Text(pandal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${pandal.area} • ${pandal.category.label}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PandalDetailScreen(pandal: pandal)),
              );
            },
          ),
        );
      },
    );
  }
}
