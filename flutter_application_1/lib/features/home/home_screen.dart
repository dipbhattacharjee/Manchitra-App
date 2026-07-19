import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/pandal_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../pandals/pandal_detail_screen.dart';
import '../pandals/puja_directory_screen.dart';
import '../discover/discover_screen.dart';
import '../route/hop_route_screen.dart';
import '../profile/profile_screen.dart';
import '../calendar/trip_calendar_screen.dart';
import '../../shared/widgets/skeleton_loader.dart';

/// ============================================================
/// MANCHITRA — Home Screen (Stitch Redesign)
/// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String? _searchQueryForDiscover;

  void _addToHop(BuildContext context, String id) {
    final provider = context.read<PandalProvider>();
    final pandal = provider.pandals.firstWhere(
      (p) => p.id == id,
      orElse: () => SampleData.featuredPandals.firstWhere(
        (p) => p.id == id,
        orElse: () => SampleData.featuredPandals.first,
      ),
    );
    provider.addToRoute(pandal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${pandal.name} to your Hop List!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPage(List<String> hopList) {
    switch (_currentNavIndex) {
      case 1:
        return DiscoverScreen(initialSearchQuery: _searchQueryForDiscover);
      case 2:
        return const HopRouteScreen();
      case 3:
        return TripCalendarScreen(
          onBack: () {
            setState(() => _currentNavIndex = 0);
          },
        );
      case 4:
        return ProfileScreen(
          onLogout: () {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          },
          onBackToHome: () {
            setState(() => _currentNavIndex = 0);
          },
        );
      default:
        return _HomeContent(
          hopList: hopList,
          onAddToHop: (id) => _addToHop(context, id),
          onNavigateToExplore: () {
            setState(() => _currentNavIndex = 1);
          },
          onSearch: (q) {
            setState(() {
              _searchQueryForDiscover = q;
              _currentNavIndex = 1;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeStops = context.watch<PandalProvider>().routeStops;
    final hopList = routeStops.map((p) => p.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: _buildPage(hopList)),
        ],
      ),
      bottomNavigationBar: _currentNavIndex == 4
          ? null
          : ManchBottomNav(
              currentIndex: _currentNavIndex,
              onTap: (i) => setState(() {
                if (i != 1) {
                  _searchQueryForDiscover = null;
                }
                _currentNavIndex = i;
              }),
            ),
    );
  }
}

// ─── HOME CONTENT ─────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.hopList,
    required this.onAddToHop,
    required this.onNavigateToExplore,
    required this.onSearch,
  });

  final List<String> hopList;
  final Function(String) onAddToHop;
  final VoidCallback onNavigateToExplore;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PandalProvider>();
    final isDataLoading = provider.isLoading;

    final displayTopPandals = provider.pandals.where((p) => p.isFeatured2026).toList();
    final topList = displayTopPandals.isEmpty ? SampleData.featuredPandals : displayTopPandals;

    final displayNearby = provider.pandals;
    final nearbyList = displayNearby.isEmpty ? SampleData.featuredPandals : displayNearby;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. App Bar Header (Brand name + notification)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manchitra',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: Icon(Icons.search, color: Colors.grey, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          onSearch(val.trim());
                        }
                      },
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Search pandals or areas...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Voice search feature coming soon!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Quick Chips Row (Location, Weather, Crowd)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Location Chip
                  _buildQuickChip(
                    icon: Icons.location_on,
                    label: 'Kolkata, WB',
                    bgColor: const Color(0xFFFFF2F0),
                    textColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  // Weather Chip
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/weather');
                    },
                    child: _buildQuickChip(
                      icon: Icons.wb_sunny_rounded,
                      label: '28°C Partly Cloudy',
                      bgColor: const Color(0xFFFFF9E6),
                      textColor: const Color(0xFF785900),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Crowd Chip
                  _buildQuickChip(
                    icon: Icons.people,
                    label: 'Moderate Crowd',
                    bgColor: const Color(0xFFFDF0F5),
                    textColor: AppColors.tertiary,
                  ),
                ],
              ),
            ),
          ),

          // 4. Today's Top Pandals Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: SectionHeader(
              title: 'Today\'s Top Pandals',
              actionLabel: 'See All',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PujaDirectoryScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: isDataLoading ? 3 : topList.length,
              itemBuilder: (context, i) {
                if (isDataLoading) {
                  return const FeaturedPandalCardSkeleton();
                }
                final pandal = topList[i];
                return FeaturedPandalCard(
                  pandal: pandal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PandalDetailScreen(pandal: pandal),
                    ),
                  ),
                  onAddToHop: () => onAddToHop(pandal.id),
                );
              },
            ),
          ),

          // 5. Nearby Puja Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: SectionHeader(
              title: 'Nearby Puja',
              actionLabel: 'View Map',
              onAction: onNavigateToExplore,
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: isDataLoading ? 3 : nearbyList.length,
              itemBuilder: (context, i) {
                if (isDataLoading) {
                  return const NearbyPandalCardSkeleton();
                }
                final pandal = nearbyList[i];
                final isInHop = hopList.contains(pandal.id);
                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pandal.name,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 10, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            pandal.category.label,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pandal.distanceText,
                              style: const TextStyle(
                                color: Color(0xFF785900),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onAddToHop(pandal.id),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF2F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isInHop ? Icons.check : Icons.near_me_outlined,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 6. AI Suggestion Section (Image 1 custom block)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC8363C),
                    Color(0xFF8B1A4A),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'AI Suggestion',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Based on your love for traditional art and preference for low crowds, we crafted a unique 3-pandal route in North Kolkata.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ai');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('View Custom Route', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. Popular Routes Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionHeader(
              title: 'Popular Routes',
              actionLabel: 'Explore All',
              onAction: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                _buildRouteCard(
                  title: 'South Heritage Trail',
                  stops: '4 Stops',
                  duration: '2.5 Hrs',
                  iconBg: const Color(0xFFFDF0F5),
                  iconColor: AppColors.tertiary,
                  icon: Icons.route,
                ),
                _buildRouteCard(
                  title: 'Midnight Illumination',
                  stops: '5 Stops',
                  duration: '4.0 Hrs',
                  iconBg: const Color(0xFFFFF9E6),
                  iconColor: const Color(0xFF785900),
                  icon: Icons.wb_twighlight,
                ),
              ],
            ),
          ),

          // 8. Festival Highlights Grid (2x2)
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              'Festival Highlights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildHighlightCard(
                  icon: Icons.theater_comedy_rounded,
                  iconColor: AppColors.primary,
                  title: 'Cultural Events',
                  sub: 'Live performances near you',
                ),
                _buildHighlightCard(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFDC003),
                  title: 'Pandal Awards',
                  sub: 'Top rated by experts',
                ),
                _buildHighlightCard(
                  icon: Icons.restaurant_menu_rounded,
                  iconColor: AppColors.tertiary,
                  title: 'Bhog Timings',
                  sub: 'Prasad distribution schedules',
                ),
                _buildHighlightCard(
                  icon: Icons.directions_car_rounded,
                  iconColor: Colors.blueGrey,
                  title: 'Traffic Updates',
                  sub: 'Live road closures',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuickChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard({
    required String title,
    required String stops,
    required String duration,
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[150] ?? Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(stops, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(duration, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

