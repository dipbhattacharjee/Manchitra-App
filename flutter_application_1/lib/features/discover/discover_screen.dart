import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../pandals/pandal_detail_screen.dart';

/// ============================================================
/// MANCHITRA — Discover / Map Screen (Image 2 Redesign)
/// ============================================================

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showPandalSheet = true;
  String _selectedPandalName = 'Sreebhumi Sporting Club';
  String _selectedPandalArea = 'Lake Town, Kolkata';
  String _selectedPandalTheme = 'Vatican City';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
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
          _buildMapMarker(top: 220, left: 100, label: 'Sreebhumi Sporting Club', isActive: true),
          _buildMapMarker(top: 360, left: 220, label: 'College Square', isActive: false),
          _buildMapMarker(top: 150, left: 240, label: 'Ahiritola Sarbojanin', isActive: false),

          // 3. Search Bar Overlay at Top
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
                        hintText: 'Search pandals, locations...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
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

          // 4. Horizontal Filters Row
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Filters button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.tune, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Filters',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Theme Puja'),
                const SizedBox(width: 8),
                _buildFilterChip('Traditional'),
                const SizedBox(width: 8),
                _buildFilterChip('Popular'),
              ],
            ),
          ),

          // 5. Floating Action Controls (GPS + Layers)
          Positioned(
            right: 20,
            top: 180,
            child: Column(
              children: [
                _buildFloatingControl(Icons.my_location),
                const SizedBox(height: 12),
                _buildFloatingControl(Icons.layers_outlined),
              ],
            ),
          ),

          // 6. Bottom Pandal Detail Card (Sreebhumi Sporting Club)
          if (_showPandalSheet)
            Positioned(
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
                                  _selectedPandalName,
                                  style: const TextStyle(
                                    fontSize: 20,
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
                                      _selectedPandalArea,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.keyboard_arrow_up, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Two Badges row
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
                                    child: const Icon(Icons.people, color: AppColors.primary, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Live Crowd', style: TextStyle(color: Colors.black54, fontSize: 10)),
                                        Text('Very High', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
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
                                        Text(_selectedPandalTheme, style: const TextStyle(color: Color(0xFF785900), fontWeight: FontWeight.bold, fontSize: 12)),
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

                      // Navigation Button
                      GestureDetector(
                        onTap: () {
                          // Jump to detail screen
                          final pandal = SampleData.featuredPandals.firstWhere(
                            (p) => p.name.contains('Sreebhumi') || p.name.contains('Kumartuli'),
                            orElse: () => SampleData.featuredPandals.first,
                          );
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
                              Icon(Icons.navigation, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Navigate (15 mins)',
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
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 12),
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

  Widget _buildMapMarker({
    required double top,
    required double left,
    required String label,
    required bool isActive,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPandalName = label;
            _selectedPandalArea = label.contains('Sporting') ? 'Lake Town, Kolkata' : 'Kolkata, WB';
            _selectedPandalTheme = label.contains('Sporting') ? 'Vatican City' : 'Heritage Revival';
            _showPandalSheet = true;
          });
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label.length > 15 ? '${label.substring(0, 15)}...' : label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.blueGrey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.temple_hindu, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paints a beautiful soft-colored map vector structure
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

    // Draw some water
    final waterPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(size.width * 0.3, size.height * 0.75, size.width * 0.7, size.height * 0.9, size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
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
