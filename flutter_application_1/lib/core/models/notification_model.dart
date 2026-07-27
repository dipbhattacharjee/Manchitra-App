import 'package:flutter/material.dart';

/// Supported Notification Categories
enum NotificationCategory {
  crowdAlert('crowd_alert', 'Crowd Alert', Icons.people_rounded, Color(0xFFE53935)),
  festivalUpdate('festival_update', 'Festival Update', Icons.stars_rounded, Color(0xFF8E24AA)),
  nearbyOffer('nearby_offer', 'Special Offer', Icons.local_offer_rounded, Color(0xFFF57C00)),
  system('system', 'System', Icons.notifications_active_rounded, Color(0xFF1E88E5));

  final String dbValue;
  final String label;
  final IconData icon;
  final Color color;

  const NotificationCategory(this.dbValue, this.label, this.icon, this.color);

  static NotificationCategory fromString(String categoryStr) {
    return NotificationCategory.values.firstWhere(
      (c) => c.dbValue == categoryStr,
      orElse: () => NotificationCategory.system,
    );
  }
}

/// Represents a single notification instance delivered to a user
class AppNotification {
  final String id;
  final String userNotificationId;
  final NotificationCategory category;
  final String title;
  final String body;
  final String? relatedPandalId;
  final String? deepLink;
  final bool isRead;
  final DateTime deliveredAt;

  const AppNotification({
    required this.id,
    required this.userNotificationId,
    required this.category,
    required this.title,
    required this.body,
    this.relatedPandalId,
    this.deepLink,
    required this.isRead,
    required this.deliveredAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final notif = json['notifications'] as Map<String, dynamic>? ?? json;
    final userNotifId = json['id'] as String? ?? notif['id'] as String? ?? '';
    final notifId = notif['id'] as String? ?? userNotifId;

    return AppNotification(
      id: notifId,
      userNotificationId: userNotifId,
      category: NotificationCategory.fromString(notif['category'] as String? ?? 'system'),
      title: notif['title'] as String? ?? 'Notice',
      body: notif['body'] as String? ?? '',
      relatedPandalId: notif['related_pandal_id'] as String?,
      deepLink: notif['deep_link'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : DateTime.now(),
    );
  }

  String get timeAgoFormatted {
    final diff = DateTime.now().difference(deliveredAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${deliveredAt.day}/${deliveredAt.month}';
  }
}

/// Represents user-configured notification preferences
class UserNotificationPreferences {
  final bool crowdAlertsEnabled;
  final bool festivalUpdatesEnabled;
  final bool nearbyOffersEnabled;
  final bool systemEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart; // e.g. "23:00"
  final String quietHoursEnd;   // e.g. "07:00"

  const UserNotificationPreferences({
    this.crowdAlertsEnabled = true,
    this.festivalUpdatesEnabled = true,
    this.nearbyOffersEnabled = true,
    this.systemEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '23:00',
    this.quietHoursEnd = '07:00',
  });

  factory UserNotificationPreferences.fromJson(Map<String, dynamic> json) {
    return UserNotificationPreferences(
      crowdAlertsEnabled: json['crowd_alerts_enabled'] as bool? ?? true,
      festivalUpdatesEnabled: json['festival_updates_enabled'] as bool? ?? true,
      nearbyOffersEnabled: json['nearby_offers_enabled'] as bool? ?? true,
      systemEnabled: json['system_enabled'] as bool? ?? true,
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] as String? ?? '23:00',
      quietHoursEnd: json['quiet_hours_end'] as String? ?? '07:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crowd_alerts_enabled': crowdAlertsEnabled,
      'festival_updates_enabled': festivalUpdatesEnabled,
      'nearby_offers_enabled': nearbyOffersEnabled,
      'system_enabled': systemEnabled,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserNotificationPreferences copyWith({
    bool? crowdAlertsEnabled,
    bool? festivalUpdatesEnabled,
    bool? nearbyOffersEnabled,
    bool? systemEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return UserNotificationPreferences(
      crowdAlertsEnabled: crowdAlertsEnabled ?? this.crowdAlertsEnabled,
      festivalUpdatesEnabled: festivalUpdatesEnabled ?? this.festivalUpdatesEnabled,
      nearbyOffersEnabled: nearbyOffersEnabled ?? this.nearbyOffersEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
