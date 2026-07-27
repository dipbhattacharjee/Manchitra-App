import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/github_pandal_service.dart';
import 'pandal_detail_screen.dart';
import '../../shared/widgets/loading/loading.dart';
import '../../shared/widgets/states/skeleton_loaders.dart';
import '../../shared/widgets/notification_bell_badge.dart';

/// ============================================================
/// MANCHITRA — Kolkata Puja Directory Screen (See All Pujas)
/// ============================================================

class PujaDirectoryScreen extends StatefulWidget {
  const PujaDirectoryScreen({super.key});

  @override
  State<PujaDirectoryScreen> createState() => _PujaDirectoryScreenState();
}

class _PujaDirectoryScreenState extends State<PujaDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Pandal> _allPandals = [];
  bool _isLoading = true;
  String _activeTab = 'Community'; // 'Community' or 'BonediBari'
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPandals();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  Future<void> _fetchPandals() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // 1. Fetch from Supabase DB
      var data = await SupabaseService.instance.getPandals();

      // 2. If DB returns fewer items than full map_server repo (~182), fetch & merge GitHub data
      if (data.length < 50) {
        final githubPandals = await GithubPandalService.fetchPandalsFromGitHub();
        if (githubPandals.isNotEmpty) {
          final Map<String, Pandal> pandalMap = {};
          for (final p in data) {
            pandalMap[p.name.trim().toLowerCase()] = p;
          }
          for (final p in githubPandals) {
            pandalMap.putIfAbsent(p.name.trim().toLowerCase(), () => p);
          }
          data = pandalMap.values.toList();
        }
      }

      if (data.isEmpty) {
        data = SampleData.featuredPandals;
      }

      if (mounted) {
        setState(() {
          _allPandals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching directory pandals: $e');
      try {
        final ghData = await GithubPandalService.fetchPandalsFromGitHub();
        if (mounted) {
          setState(() {
            _allPandals = ghData.isNotEmpty ? ghData : SampleData.featuredPandals;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _allPandals = SampleData.featuredPandals;
            _isLoading = false;
          });
        }
      }
    }
  }

  bool _isBonediBari(Pandal p) {
    final name = p.name.toLowerCase();
    final committee = p.committeeName?.toLowerCase() ?? '';
    final desc = p.description?.toLowerCase() ?? '';
    return name.contains('bari') ||
        name.contains('rajbari') ||
        committee.contains('estate') ||
        committee.contains('paribar') ||
        desc.contains('ancestral') ||
        desc.contains('family landlord');
  }

  List<Pandal> _getFilteredPandals() {
    List<Pandal> list = [];
    if (_activeTab == 'BonediBari') {
      list = _allPandals.where((p) => _isBonediBari(p)).toList();
    } else {
      list = _allPandals.where((p) => !_isBonediBari(p)).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final areaMatch = p.area.toLowerCase().contains(query);
        final committeeMatch = p.committeeName?.toLowerCase().contains(query) ?? false;
        final descMatch = p.description?.toLowerCase().contains(query) ?? false;
        final themeMatch = p.theme?.toLowerCase().contains(query) ?? false;
        return nameMatch || areaMatch || committeeMatch || descMatch || themeMatch;
      }).toList();
    }

    return list;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFAF6F0),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Kolkata Puja Directory',
        style: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFB71C1C), // deep puja red
          letterSpacing: 0.2,
        ),
      ),
      actions: const [
        NotificationBellBadge(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredPandals();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 1. Search Bar Input Fix
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFEADCD5)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: GoogleFonts.manrope(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search by name, area, or theme...',
                  hintStyle: GoogleFonts.manrope(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
          ),

          // 2. Custom Tabs Selector (Barowari vs Bonedi Bari)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEADCD5)),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'Community'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _activeTab == 'Community' ? const Color(0xFFB71C1C) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Community (Barowari)',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 'Community' ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'BonediBari'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _activeTab == 'BonediBari' ? const Color(0xFFB71C1C) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Bonedi Bari (Household)',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 'BonediBari' ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Count summary indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Found ${filteredList.length} matching pujas'
                      : 'Showing ${filteredList.length} pujas',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                if (_allPandals.isNotEmpty)
                  Text(
                    'Total Synced: ${_allPandals.length}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // 3. Main Directory List Content
          Expanded(
            child: _isLoading
                ? const PandalListSkeletonLoader(itemCount: 6)
                : RefreshIndicator(
                    onRefresh: _fetchPandals,
                    color: const Color(0xFFB71C1C),
                    child: filteredList.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB71C1C).withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.search_off_rounded, size: 56, color: Color(0xFFB71C1C)),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No pandals found',
                                        style: GoogleFonts.manrope(
                                          color: const Color(0xFFB71C1C),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'No results matching "$_searchQuery" in ${_activeTab == "BonediBari" ? "Bonedi Bari" : "Community Pujas"}'
                                            : 'No pandals found in this section.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.manrope(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (_searchQuery.isNotEmpty) ...[
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFB71C1C),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            _onSearchChanged('');
                                          },
                                          icon: const Icon(Icons.clear, size: 16),
                                          label: Text(
                                            'Clear Search',
                                            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                            itemCount: filteredList.length,
                            itemBuilder: (context, i) {
                              final pandal = filteredList[i];
                              return _buildDirectoryCard(pandal);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryCard(Pandal pandal) {
    final bool isBonedi = _isBonediBari(pandal);
    final String displayImage = (pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.trim().isNotEmpty)
        ? pandal.coverPhotoUrl!
        : (pandal.photoUrls.isNotEmpty && pandal.photoUrls.first.trim().isNotEmpty)
            ? pandal.photoUrls.first
            : (isBonedi
                ? 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg'
                : 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg');

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
          border: Border.all(color: const Color(0xFFEADCD5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Pandal Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                displayImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppColors.primaryContainer,
                    child: const Center(
                      child: AppSpinner(size: 18, strokeWidth: 2.0),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.primaryContainer,
                  child: const Center(
                    child: Icon(Icons.temple_hindu, color: AppColors.secondary, size: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content details on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pandal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pandal.theme ?? 'Traditional Durga Puja',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats (Area tag & Crowd level badge)
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 11, color: Colors.grey),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  pandal.area,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(fontSize: 11, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: pandal.crowdLevel.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${pandal.crowdLevel.label} Crowd',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: pandal.crowdLevel.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
