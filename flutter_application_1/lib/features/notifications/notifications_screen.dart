import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/models/notification_model.dart';
import '../../core/providers/pandal_provider.dart';
import '../../core/services/notification_service.dart';
import '../pandals/pandal_detail_screen.dart';
import 'notification_settings_screen.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/states/skeleton_loaders.dart';

/// ============================================================
/// MANCHITRA — Notifications Screen (Real Supabase Wiring & Deep-linking)
/// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService.instance;
  String _selectedFilter = 'All';
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await _service.fetchNotifications(categoryFilter: _selectedFilter);
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadNotifications();
  }

  Future<void> _handleNotificationTap(AppNotification notif) async {
    await _service.markAsRead(notif.userNotificationId);
    setState(() {}); // Refresh read status dot

    if (!mounted) return;

    if (notif.relatedPandalId != null) {
      final pandalProvider = context.read<PandalProvider>();
      final matches = pandalProvider.pandals.where((p) => p.id == notif.relatedPandalId);
      final Pandal? pandal = matches.isNotEmpty
          ? matches.first
          : (pandalProvider.pandals.isNotEmpty ? pandalProvider.pandals.first : null);

      if (pandal != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PandalDetailScreen(pandal: pandal),
          ),
        );
      }
    } else if (notif.deepLink != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opened link: ${notif.deepLink}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: back button, logo text, settings gear
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ).then((_) => _loadNotifications());
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
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay updated with live crowd alerts & festival news',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Filter Tabs (All / Crowd Alerts / Festival Updates / Offers / System)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterTab('All'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Crowd Alerts'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Festival Updates'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Special Offers'),
                  const SizedBox(width: 8),
                  _buildFilterTab('System'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notifications List / Loading State / Empty State
            Expanded(
              child: _isLoading
                  ? const NotificationListSkeletonLoader()
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final item = _notifications[index];
                            return _buildNotificationCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => _onFilterSelected(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFAF101A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFAF101A) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFFFF9F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isRead ? Colors.grey[200]! : AppColors.primary.withOpacity(0.3),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.category.icon,
                color: item.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.category.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: item.category.color,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            item.timeAgoFormatted,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (!item.isRead) ...[
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We\'ll notify you about live crowd alerts & updates',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
