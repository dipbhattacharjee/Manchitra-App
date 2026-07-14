import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/common_widgets.dart';

/// ============================================================
/// MANCHITRA — Pandal Detail Screen
/// ============================================================

class PandalDetailScreen extends StatefulWidget {
  const PandalDetailScreen({super.key, required this.pandal});
  final Pandal pandal;

  @override
  State<PandalDetailScreen> createState() => _PandalDetailScreenState();
}

class _PandalDetailScreenState extends State<PandalDetailScreen> {
  bool _isFavorited = false;
  bool _isInHop = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero image sliver
          _buildSliverHero(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPandalInfo(),
                _buildDividerLine(),
                _buildAboutSection(),
                _buildDividerLine(),
                _buildTimingsGrid(),
                _buildDividerLine(),
                _buildLocationSection(),
                const SizedBox(height: 100), // space for sticky bottom bar
              ],
            ),
          ),
        ],
      ),

      // Sticky action bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverHero() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.modalOverlay,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => setState(() => _isFavorited = !_isFavorited),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.modalOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? AppColors.tertiary : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.modalOverlay,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient hero image placeholder
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.temple_hindu, size: 80, color: AppColors.secondary),
              ),
            ),
            // Overlay
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.featuredCardOverlay),
            ),
            // Featured badge
            if (widget.pandal.isFeatured2026)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '★ FEATURED 2026',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPandalInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(widget.pandal.name, style: AppTextStyles.headlineSmall),

          if (widget.pandal.committeeName != null) ...[
            const SizedBox(height: 4),
            Text(widget.pandal.committeeName!, style: AppTextStyles.bodySmall),
          ],

          const SizedBox(height: 12),

          // Tags row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              GlowChip(label: widget.pandal.area, icon: Icons.location_on_outlined),
              GlowChip(
                  label: widget.pandal.category.label,
                  activeColor: AppColors.tertiary),
              if (widget.pandal.theme != null)
                GlowChip(label: widget.pandal.theme!, activeColor: AppColors.secondary),
            ],
          ),

          const SizedBox(height: 12),

          // Rating
          if (widget.pandal.rating != null)
            StarRatingRow(
              rating: widget.pandal.rating!,
              reviewCount: widget.pandal.reviewCount ~/ 1000,
            ),
        ],
      ),
    );
  }

  Widget _buildTimingsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Info', icon: Icons.info_outline),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _infoCard(
                Icons.access_time,
                'Opens',
                widget.pandal.visitStartTime ?? 'All day',
              ),
              _infoCard(
                Icons.people_outline,
                'Crowd',
                widget.pandal.crowdLevel.label,
                valueColor: widget.pandal.crowdLevel.color,
              ),
              _infoCard(
                Icons.wb_sunny_outlined,
                'Best Time',
                'Morning / Evening',
              ),
              _infoCard(
                Icons.directions_walk,
                'Distance',
                widget.pandal.distanceText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'About This Pandal', icon: Icons.article_outlined),
          const SizedBox(height: 8),
          Text(
            widget.pandal.description ??
                'This is one of the celebrated Durga Puja pandals in Kolkata, known for its spectacular theme and community spirit.',
            style: AppTextStyles.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Read More'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Location', icon: Icons.map_outlined),
          const SizedBox(height: 12),

          // Map placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                // Dark map placeholder
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const RadialGradient(
                      colors: [Color(0xFF1A2030), Color(0xFF0D1218)],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.glowSaffron, blurRadius: 12),
                          ],
                        ),
                        child: const Icon(Icons.location_pin, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.pandal.area}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          OutlinedGoldButton(
            onPressed: () {},
            text: 'Get Directions',
            icon: const Icon(Icons.directions, color: AppColors.secondary, size: 18),
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildDividerLine() {
    return Container(
      height: 6,
      color: AppColors.background,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              onPressed: () => setState(() => _isInHop = !_isInHop),
              text: _isInHop ? '✓ In Hop List' : '+ Add to Hop List',
              height: 52,
              hasGlow: true,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedGoldButton(
            onPressed: () {},
            text: 'Navigate',
            icon: const Icon(Icons.navigation, color: AppColors.secondary, size: 18),
            height: 52,
            width: null,
          ),
        ],
      ),
    );
  }
}
