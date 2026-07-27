import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/pandal_provider.dart';
import '../../shared/widgets/notification_bell_badge.dart';
import '../pandals/pandal_detail_screen.dart';
import '../route/hop_route_screen.dart';
import 'profile_data.dart';
import '../../shared/widgets/states/skeleton_loaders.dart';
import 'package:provider/provider.dart';

/// ============================================================
/// MANCHITRA — Profile Screen
/// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onLogout, this.onBackToHome});
  final VoidCallback? onLogout;
  final VoidCallback? onBackToHome;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: _isLoading
            ? const ProfileSkeletonLoader()
            : SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // Header row: Home, Profile Title, Gear settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        if (widget.onBackToHome != null) {
                          widget.onBackToHome!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Text(
                      'Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const NotificationBellBadge(),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Color(0xFFAF101A)),
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/settings');
                            if (mounted) setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile avatar with concentric golden circles
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFF2F0), width: 2),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFDF9E), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(ProfileData.photoUrl),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                ProfileData.name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    ProfileData.location,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Edit Profile Button
              OutlinedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/edit-profile');
                  if (mounted) setState(() {});
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFAF101A),
                  side: const BorderSide(color: Color(0xFFAF101A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Liked/Favorite Pandals Section
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'FAVORITE PANDALS (${ProfileData.favoritePandals.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[500],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (ProfileData.favoritePandals.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Center(
                    child: Text(
                      'No favorite pandals added yet.',
                      style: GoogleFonts.manrope(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ProfileData.favoritePandals.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
                    itemBuilder: (context, index) {
                      final pandal = ProfileData.favoritePandals[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty
                              ? Image.network(pandal.coverPhotoUrl!, width: 48, height: 48, fit: BoxFit.cover)
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: AppColors.primaryContainer,
                                  child: const Icon(Icons.temple_hindu, color: AppColors.secondary, size: 20),
                                ),
                        ),
                        title: Text(
                          pandal.name,
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${pandal.area} • ${pandal.category.label}',
                          style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PandalDetailScreen(pandal: pandal),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 28),

              // Saved Routes Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'MY SAVED ROUTES',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[500],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Saved Routes List / Card
              if (ProfileData.savedRoutes.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_border_rounded, color: AppColors.secondary, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No saved routes yet',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Create a day plan in Puja Trip Planner and tap "Save Plan"',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ProfileData.savedRoutes.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
                    itemBuilder: (context, index) {
                      final plan = ProfileData.savedRoutes[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 22),
                        ),
                        title: Text(
                          'Maha ${plan.pujaDay} Plan',
                          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        subtitle: Text(
                          '${plan.stops.length} scheduled stops • Oct ${plan.date.day}, 2026',
                          style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            final provider = context.read<PandalProvider>();
                            final matchedPandals = <Pandal>[];
                            for (final s in plan.stops) {
                              final match = provider.pandals.where((p) => p.id == s.pandalId);
                              if (match.isNotEmpty) {
                                matchedPandals.add(match.first);
                              }
                            }
                            if (matchedPandals.isNotEmpty) {
                              provider.setRouteStops(matchedPandals);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HopRouteScreen(plannedDate: plan.date),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Open Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 32),

              // Preferences Section Title
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'PREFERENCES',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[500],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Preferences Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.015),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      Icons.person_search_outlined,
                      'Account Settings',
                      isFirst: true,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F1F1)),
                    _buildSettingsItem(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F1F1)),
                    _buildSettingsItem(
                      Icons.info_outline,
                      'About Manchitra',
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F1F1)),
                    _buildSettingsItem(
                      Icons.star_outline_rounded,
                      'Rate the App',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Sign Out Button in red
              TextButton.icon(
                onPressed: () {
                  if (widget.onLogout != null) {
                    widget.onLogout!();
                  }
                },
                icon: const Icon(Icons.logout, color: Color(0xFFAF101A), size: 20),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFAF101A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title,
      {bool isFirst = false, bool isLast = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(28) : Radius.zero,
          topRight: isFirst ? const Radius.circular(28) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(28) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(28) : Radius.zero,
        ),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () async {
        if (title == 'Account Settings') {
          await Navigator.pushNamed(context, '/settings');
          if (mounted) setState(() {});
        } else if (title == 'Privacy Policy') {
          await Navigator.pushNamed(context, '/privacy-policy');
        } else if (title == 'About Manchitra') {
          await Navigator.pushNamed(context, '/about-manchitra');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title tapped')),
          );
        }
      },
    );
  }
}
