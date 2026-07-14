import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// ============================================================
/// MANCHITRA — Shared / Common Widgets (Premium Light Theme)
/// ============================================================

// ─── PREMIUM APP BAR ─────────────────────────────────────────
class ManchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ManchAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.isGradient = false,
    this.showLogo = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool isGradient;
  final bool showLogo;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading ??
          (Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
            ),
        ],
      ),
      actions: actions,
    );
  }
}

// ─── SAFFRON GLOW CHIP ───────────────────────────────────────
class GlowChip extends StatelessWidget {
  const GlowChip({
    super.key,
    required this.label,
    this.icon,
    this.isActive = false,
    this.onTap,
    this.activeColor,
    this.textColor,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final primaryColor = activeColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? primaryColor 
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor ?? (isActive ? primaryColor : AppColors.border.withOpacity(0.5)),
            width: 1,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : (textColor ?? AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? Colors.white : (textColor ?? AppColors.textSecondary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CROWD LEVEL BADGE ───────────────────────────────────────
class CrowdBadge extends StatelessWidget {
  const CrowdBadge({super.key, required this.level});
  final dynamic level; // CrowdLevel

  @override
  Widget build(BuildContext context) {
    final color = level.color as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            level.label as String,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DISTANCE BADGE ──────────────────────────────────────────
class DistanceBadge extends StatelessWidget {
  const DistanceBadge({super.key, required this.distanceText});
  final String distanceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF7E7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 12, color: AppColors.secondary),
          const SizedBox(width: 2),
          Text(
            distanceText,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PANDAL CARD (Image 1 Nearby Puja style) ───────────────────
class PandalCard extends StatelessWidget {
  const PandalCard({
    super.key,
    required this.pandal,
    this.onTap,
    this.onAddToHop,
    this.isInHopList = false,
    this.showSaffronBorder = false,
  });

  final dynamic pandal;
  final VoidCallback? onTap;
  final VoidCallback? onAddToHop;
  final bool isInHopList;
  final bool showSaffronBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: showSaffronBorder ? AppColors.primary.withOpacity(0.3) : AppColors.border.withOpacity(0.3),
            width: showSaffronBorder ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon/thumbnail placeholder
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.temple_hindu_rounded, 
                        color: AppColors.primary, 
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pandal.name as String? ?? '',
                            style: AppTextStyles.pandalName.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: AppColors.secondary),
                              const SizedBox(width: 2),
                              Text(
                                pandal.rating != null ? '${pandal.rating}' : '4.5',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '· ${pandal.theme ?? "Heritage Art"}',
                                style: AppTextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer row (Distance badge + Add to hop action)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withOpacity(0.5),
                  border: const Border(
                    top: BorderSide(color: AppColors.divider, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DistanceBadge(distanceText: pandal.distanceText as String? ?? '800m away'),
                    GestureDetector(
                      onTap: onAddToHop,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isInHopList ? AppColors.primary : const Color(0xFFFFF2F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isInHopList ? '✓ In Hop' : '+ Add Hop',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isInHopList ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}

// ─── FEATURED PANDAL CARD (Image 1 Hero top pandals style) ────────
class FeaturedPandalCard extends StatelessWidget {
  const FeaturedPandalCard({
    super.key,
    required this.pandal,
    this.onTap,
    this.onAddToHop,
  });

  final dynamic pandal;
  final VoidCallback? onTap;
  final VoidCallback? onAddToHop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
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
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background patterns
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.temple_hindu_rounded,
                  size: 150,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Trending tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Trending #1',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Pandal Name
                  Text(
                    pandal.name as String? ?? 'Suruchi Sangha',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        pandal.area as String? ?? 'New Alipore',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bottom stats row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Theme: ${pandal.theme ?? "Eco-balance"}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Wait: ~15 mins',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
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
      ),
    );
  }
}

// ─── TRANSPORT LEG CONNECTOR ─────────────────────────────────
class TransportLegChip extends StatelessWidget {
  const TransportLegChip({
    super.key,
    required this.mode,
    required this.durationText,
  });

  final dynamic mode;
  final String durationText;

  Color get _modeColor {
    switch (mode.label) {
      case 'Walk':
        return AppColors.transportWalk;
      case 'Metro':
        return AppColors.transportMetro;
      case 'Train':
        return AppColors.transportTrain;
      case 'Cab':
        return AppColors.transportCab;
      default:
        return AppColors.transportAuto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Container(
            width: 2,
            height: 24,
            color: AppColors.border,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _modeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _modeColor.withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(mode.icon as IconData, size: 14, color: _modeColor),
                const SizedBox(width: 6),
                Text(
                  '${mode.label} · $durationText',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _modeColor,
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
}

// ─── SECTION HEADER ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            child: Row(
              children: [
                Text(actionLabel!),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios, size: 10),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── PUJA DAY BADGE ──────────────────────────────────────────
class PujaDayBadge extends StatelessWidget {
  const PujaDayBadge({
    super.key,
    required this.dayName,
    required this.date,
  });

  final String dayName;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪷', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '$dayName • $date',
            style: AppTextStyles.pujaDayChip.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STAR RATING ROW ─────────────────────────────────────────
class StarRatingRow extends StatelessWidget {
  const StarRatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star, size: 16, color: AppColors.secondary);
          } else if (i < rating) {
            return const Icon(Icons.star_half, size: 16, color: AppColors.secondary);
          }
          return const Icon(Icons.star_outline, size: 16, color: AppColors.border);
        }),
        const SizedBox(width: 6),
        Text(
          '$rating',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${reviewCount}k reviews)',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

// ─── PREMIUM FLOATING BOTTOM DOCK ────────────────────────────
class ManchBottomNav extends StatelessWidget {
  const ManchBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.explore_outlined, Icons.explore, 'Explore', 0),
            _navItem(Icons.map_outlined, Icons.map, 'Discover', 1),
            _navItem(Icons.route_outlined, Icons.route, 'Routes', 2),
            _navItem(Icons.temple_hindu_outlined, Icons.temple_hindu, 'Favorites', 3),
            _navItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData normalIcon, IconData selectedIcon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? selectedIcon : normalIcon,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

