import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Notifications Screen (Screenshot 2 Redesign)
/// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<_NotificationItem> _allNotifications = [
    const _NotificationItem(
      category: 'CROWD ALERT',
      title: 'Suruchi Sangha Peak Traffic',
      description: 'Heavy crowd detected. Expected wait time is now 45 minutes.',
      time: 'Just now',
      isUnread: true,
      categoryType: _NotificationCategory.crowd,
    ),
    const _NotificationItem(
      category: 'FESTIVAL UPDATES',
      title: 'Special Aarti Timing Change',
      description: 'The evening Aarti at Ekdalia Evergreen will begin 30 minutes earlier today.',
      time: '2 hrs ago',
      isUnread: false,
      categoryType: _NotificationCategory.festival,
    ),
    const _NotificationItem(
      category: 'NEARBY OFFERS',
      title: 'Food Stall Discount',
      description: 'Exclusive 15% off at the traditional Bengali sweets stall near College Square.',
      time: 'Yesterday',
      isUnread: false,
      categoryType: _NotificationCategory.offer,
    ),
    const _NotificationItem(
      category: 'SYSTEM',
      title: 'New AI Route Generated',
      description: 'Your personalized \'Heritage Walk\' route for North Kolkata is ready to view.',
      time: 'Oct 18',
      isUnread: false,
      categoryType: _NotificationCategory.system,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter list
    final filteredList = _allNotifications.where((n) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Festival Updates' && n.categoryType == _NotificationCategory.festival) return true;
      if (_selectedFilter == 'Crowd Alerts' && n.categoryType == _NotificationCategory.crowd) return true;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: back button, logo text, settings button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFAF101A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Color(0xFFAF101A)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings tapped')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Screen title + subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stay updated with the latest festival happenings.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Festival Updates'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Crowd Alerts'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notifications List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications in this category',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(filteredList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFF2F0) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFFAF101A) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem item) {
    // Get colors & icon based on category
    Color badgeBg;
    Color badgeTextColor;
    IconData icon;

    switch (item.categoryType) {
      case _NotificationCategory.crowd:
        badgeBg = const Color(0xFFFEE8E8);
        badgeTextColor = const Color(0xFFC8363C);
        icon = Icons.people_outline;
        break;
      case _NotificationCategory.festival:
        badgeBg = const Color(0xFFFEF7E0);
        badgeTextColor = const Color(0xFFB88E00);
        icon = Icons.temple_hindu_outlined;
        break;
      case _NotificationCategory.offer:
        badgeBg = const Color(0xFFFDF0F5);
        badgeTextColor = const Color(0xFFC03C70);
        icon = Icons.local_offer_outlined;
        break;
      case _NotificationCategory.system:
        badgeBg = const Color(0xFFEEF2F6);
        badgeTextColor = const Color(0xFF4A5568);
        icon = Icons.alt_route;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle Icon Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: badgeTextColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with category, unread dot, time
                Row(
                  children: [
                    Text(
                      item.category,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.time,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.isUnread) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFAF101A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Title
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  item.description,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationCategory { crowd, festival, offer, system }

class _NotificationItem {
  const _NotificationItem({
    required this.category,
    required this.title,
    required this.description,
    required this.time,
    required this.isUnread,
    required this.categoryType,
  });

  final String category;
  final String title;
  final String description;
  final String time;
  final bool isUnread;
  final _NotificationCategory categoryType;
}
