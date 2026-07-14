import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/services/supabase_service.dart';
import '../pandals/pandal_detail_screen.dart';

/// ============================================================
/// MANCHITRA — Discover / Map Screen (Phase 2 Integration)
/// ============================================================

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService.instance;

  List<Pandal> _pandals = [];
  bool _isLoading = true;

  // Filters state
  String _selectedCategory = 'All';
  String _selectedArea = 'All';
  bool _featuredOnly = false;
  
  // Active search query
  String _searchQuery = '';

  // Bottom sheet details
  Pandal? _selectedPandal;
  bool _showPandalSheet = false;

  // View mode: true = Map, false = List Directory
  bool _isMapView = true;

  // Mock User Location (College Square, Kolkata)
  final double _userLat = 22.574697;
  final double _userLng = 88.363989;

  @override
  void initState() {
    super.initState();
    _fetchPandals();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _fetchPandals();
  }

  Future<void> _fetchPandals() async {
    setState(() => _isLoading = true);
    final results = await _supabaseService.getPandals(
      searchQuery: _searchQuery,
      categoryFilter: _selectedCategory,
      areaFilter: _selectedArea,
      featuredOnly: _featuredOnly,
      userLat: _userLat,
      userLng: _userLng,
    );
    setState(() {
      _pandals = results;
      _isLoading = false;
      
      // Update selected pandal if it is no longer in results
      if (_selectedPandal != null && !_pandals.any((p) => p.id == _selectedPandal!.id)) {
        _selectedPandal = null;
        _showPandalSheet = false;
      }
      
      // Select the first pandal as default if none selected
      if (_selectedPandal == null && _pandals.isNotEmpty) {
        _selectedPandal = _pandals.first;
        _showPandalSheet = true;
      }
    });
  }

  Offset _mapLatLngToXY(double lat, double lng, Size size) {
    // Normalization bounds for Kolkata coordinates
    const double minLat = 22.47;
    const double maxLat = 22.61;
    const double minLng = 88.31;
    const double maxLng = 88.42;

    // y goes from top (0) to bottom (height)
    // We map North (higher lat) to top, South (lower lat) to bottom
    final double pctY = 1.0 - ((lat - minLat) / (maxLat - minLat)).clamp(0.0, 1.0);
    final double y = 200 + (pctY * (size.height - 350));

    // x goes from left (0) to right (width)
    final double pctX = ((lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
    final double x = 32 + (pctX * (size.width - 64));

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Conditional View: Map or List Directory
          if (_isMapView)
            _buildMapView(size)
          else
            _buildListView(size),

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
                  if (_searchQuery.isNotEmpty)
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
            child: _buildFiltersRow(),
          ),

          // 4. Floating Action Controls (GPS reset + Map Layer toggle)
          if (_isMapView)
            Positioned(
              right: 20,
              top: 180,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Center map sheet back to first pandal
                      if (_pandals.isNotEmpty) {
                        setState(() {
                          _selectedPandal = _pandals.first;
                          _showPandalSheet = true;
                        });
                      }
                    },
                    child: _buildFloatingControl(Icons.my_location),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Satellite View mode simulated.')),
                      );
                    },
                    child: _buildFloatingControl(Icons.layers_outlined),
                  ),
                ],
              ),
            ),

          // 5. Bottom Pandal Detail Card (Only in Map View)
          if (_isMapView && _showPandalSheet)
            _buildBottomCard(),
        ],
      ),
    );
  }

  Widget _buildMapView(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_pandals.isEmpty) {
      return Container(
        color: const Color(0xFFF6F0E5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No markers match search filters.',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // 1. Stylized Isometric Map Background (simulated using CustomPaint)
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF6F0E5),
            child: CustomPaint(
              painter: _MapPainter(),
            ),
          ),
        ),

        // 2. Map Markers
        ..._pandals.map((pandal) {
          final offset = _mapLatLngToXY(pandal.latitude, pandal.longitude, size);
          final bool isActive = _selectedPandal?.id == pandal.id;
          return Positioned(
            top: offset.dy,
            left: offset.dx - 45,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPandal = pandal;
                  _showPandalSheet = true;
                });
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      pandal.name.length > 12 ? '${pandal.name.substring(0, 12)}...' : pandal.name,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.blueGrey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.temple_hindu, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildListView(Size size) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_pandals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No pandals match filters.',
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 180, bottom: 90, left: 16, right: 16),
      itemCount: _pandals.length,
      itemBuilder: (context, i) {
        final pandal = _pandals[i];
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
              // Cover Icon/Gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.temple_hindu, color: AppColors.secondary, size: 36),
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
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
                        const Text('4.5', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildFiltersRow() {
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
            isSelected: _featuredOnly,
            onTap: () {
              setState(() {
                _featuredOnly = !_featuredOnly;
              });
              _fetchPandals();
            },
          ),
          const SizedBox(width: 8),

          // Category Dropdown
          _buildCategoryDropdownChip(),
          const SizedBox(width: 8),

          // Area Dropdown
          _buildAreaDropdownChip(),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdownChip() {
    final categories = ['All', 'Traditional Barowari', 'Theme-Based', 'Eco-Friendly', 'Community', 'Famous Heritage'];
    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedCategory = val;
        });
        _fetchPandals();
      },
      itemBuilder: (context) => categories
          .map((c) => PopupMenuItem<String>(
                value: c,
                child: Text(c),
              ))
          .toList(),
      child: _buildFilterChip(
        label: _selectedCategory == 'All' ? 'Category' : _selectedCategory,
        isSelected: _selectedCategory != 'All',
        onTap: null, // Let popup trigger handle tap
      ),
    );
  }

  Widget _buildAreaDropdownChip() {
    final areas = ['All', 'North Kolkata', 'South Kolkata', 'Central Kolkata', 'Lake Town', 'Gariahat', 'Shyambazar', 'Kumartuli', 'College Street', 'New Alipore', 'Kasba', 'Kalighat', 'Ahiritola', 'Barisha', 'Jorasanko', 'Pathuriaghata'];
    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() {
          _selectedArea = val;
        });
        _fetchPandals();
      },
      itemBuilder: (context) => areas
          .map((a) => PopupMenuItem<String>(
                value: a,
                child: Text(a),
              ))
          .toList(),
      child: _buildFilterChip(
        label: _selectedArea == 'All' ? 'Area' : _selectedArea,
        isSelected: _selectedArea != 'All',
        onTap: null, // Let popup trigger handle tap
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

  Widget _buildBottomCard() {
    if (!_showPandalSheet || _selectedPandal == null) {
      return const SizedBox.shrink();
    }
    final pandal = _selectedPandal!;

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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pandal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              pandal.area,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.directions_walk, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              pandal.distanceText,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPandalSheet = false;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.black54, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Badges
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDC4C8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.people, color: pandal.crowdLevel.color, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Crowd Level', style: TextStyle(color: Colors.black54, fontSize: 10)),
                                Text(pandal.crowdLevel.label, style: TextStyle(color: pandal.crowdLevel.color, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEEBA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star, color: Color(0xFF785900), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Theme', style: TextStyle(color: Colors.black54, fontSize: 10)),
                                Text(pandal.theme ?? 'Traditional decor', style: const TextStyle(color: Color(0xFF785900), fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // View Details Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PandalDetailScreen(pandal: pandal),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFC8363C),
                        Color(0xFF8B1A4A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'View Pandal Details',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final parkPaint = Paint()
      ..color = const Color(0xFFE2F0D9)
      ..style = PaintingStyle.fill;

    final waterPaint = Paint()
      ..color = const Color(0xFFD3E5F5)
      ..style = PaintingStyle.fill;

    // Draw some parks
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(20, 120, 120, 80), const Radius.circular(16)),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(180, 280, 150, 100), const Radius.circular(16)),
      parkPaint,
    );

    // Draw Hooghly River (stylized water body on left/bottom)
    final waterPath = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(size.width * 0.25, size.height * 0.5, size.width * 0.1, size.height * 0.8, 0, size.height * 0.95)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * 0.4)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Draw stylized roads
    canvas.drawLine(const Offset(-20, 100), Offset(size.width + 20, 300), roadPaint);
    canvas.drawLine(const Offset(100, -20), Offset(150, size.height + 20), roadPaint);
    canvas.drawLine(const Offset(-20, 450), Offset(size.width + 20, 400), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
