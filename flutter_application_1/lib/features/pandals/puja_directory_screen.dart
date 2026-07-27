import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/services/supabase_service.dart';
import 'pandal_detail_screen.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/loading/loading.dart';
import '../../shared/widgets/states/skeleton_loaders.dart';

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
  }

  Future<void> _fetchPandals() async {
    setState(() => _isLoading = true);
    try {
      var data = await SupabaseService.instance.getPandals();
      if (data.isEmpty) {
        data = SampleData.featuredPandals;
      }
      setState(() {
        _allPandals = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching directory pandals: $e');
      setState(() {
        _allPandals = SampleData.featuredPandals;
        _isLoading = false;
      });
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
        final themeMatch = p.theme?.toLowerCase().contains(query) ?? false;
        return nameMatch || areaMatch || themeMatch;
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredPandals();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kolkata Puja Directory',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: Icon(Icons.search, color: Colors.grey, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, area, or theme...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_isLoading && _searchQuery.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: AppSpinner(size: 16, strokeWidth: 2.0),
                    ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                      onPressed: () => _searchController.clear(),
                    ),
                ],
              ),
            ),
          ),

          // 2. Custom Tabs Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'Community'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeTab == 'Community' ? const Color(0xFFAF101A) : Colors.transparent,
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: _activeTab == 'BonediBari' ? const Color(0xFFAF101A) : Colors.transparent,
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

          const SizedBox(height: 10),

          // 3. Main Directory List Content
          Expanded(
            child: _isLoading
                ? const PandalListSkeletonLoader(itemCount: 6)
                : RefreshIndicator(
                    onRefresh: _fetchPandals,
                    color: const Color(0xFFAF101A),
                    child: filteredList.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No pujas matched your search.',
                                      style: GoogleFonts.manrope(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
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
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 80x80 Pandal Thumbnail
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
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
                    pandal.theme ?? 'Traditional Celebration',
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
                          color: pandal.crowdLevel.color.withOpacity(0.08),
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
