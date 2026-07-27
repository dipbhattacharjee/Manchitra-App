import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _supabase = Supabase.instance.client;

  // Local state cache
  List<AppNotification> _cachedNotifications = [];
  UserNotificationPreferences _preferences = const UserNotificationPreferences();

  List<AppNotification> get notifications => List.unmodifiable(_cachedNotifications);
  UserNotificationPreferences get preferences => _preferences;

  int get unreadCount => _cachedNotifications.where((n) => !n.isRead).length;

  /// Fetch live notifications for current authenticated user
  Future<List<AppNotification>> fetchNotifications({String? categoryFilter}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('user_notifications')
            .select('id, is_read, delivered_at, notifications!inner(*)')
            .eq('user_id', user.id)
            .order('delivered_at', ascending: false);

        final items = (response as List<dynamic>)
            .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
            .toList();

        _cachedNotifications = items;
      }
    } catch (e) {
      debugPrint('Supabase notifications fetch note: $e');
    }

    if (_cachedNotifications.isEmpty) {
      _cachedNotifications = _getSampleNotifications();
    }

    if (categoryFilter != null && categoryFilter != 'All') {
      final cat = _parseCategoryFilter(categoryFilter);
      return _cachedNotifications.where((n) => n.category == cat).toList();
    }

    return _cachedNotifications;
  }

  /// Mark single notification as read
  Future<void> markAsRead(String userNotifId) async {
    final idx = _cachedNotifications.indexWhere((n) => n.userNotificationId == userNotifId);
    if (idx != -1) {
      final old = _cachedNotifications[idx];
      _cachedNotifications[idx] = AppNotification(
        id: old.id,
        userNotificationId: old.userNotificationId,
        category: old.category,
        title: old.title,
        body: old.body,
        relatedPandalId: old.relatedPandalId,
        deepLink: old.deepLink,
        isRead: true,
        deliveredAt: old.deliveredAt,
      );
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('user_notifications')
            .update({'is_read': true})
            .eq('id', userNotifId)
            .eq('user_id', user.id);
      }
    } catch (e) {
      debugPrint('Error marking notification as read in Supabase: $e');
    }
  }

  /// Fetch user preferences
  Future<UserNotificationPreferences> fetchPreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('user_notification_preferences')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (response != null) {
          _preferences = UserNotificationPreferences.fromJson(response);
        }
      }
    } catch (e) {
      debugPrint('Error fetching notification preferences: $e');
    }
    return _preferences;
  }

  /// Update user notification preferences
  Future<bool> updatePreferences(UserNotificationPreferences newPrefs) async {
    _preferences = newPrefs;
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = newPrefs.toJson()..['user_id'] = user.id;
        await _supabase.from('user_notification_preferences').upsert(data);
      }
      return true;
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
      return false;
    }
  }

  /// Trigger a live crowd alert notification for high/very_high crowd reports
  Future<void> triggerCrowdAlert({
    required String pandalId,
    required String pandalName,
    required String crowdLevel,
  }) async {
    final title = 'Crowd Alert: $pandalName';
    final body = '$crowdLevel reported at $pandalName. Plan your visit accordingly!';
    final deepLink = 'manchitra://pandal/$pandalId';

    final notif = AppNotification(
      id: 'notif_crowd_${DateTime.now().millisecondsSinceEpoch}',
      userNotificationId: 'unotif_${DateTime.now().millisecondsSinceEpoch}',
      category: NotificationCategory.crowdAlert,
      title: title,
      body: body,
      relatedPandalId: pandalId,
      deepLink: deepLink,
      isRead: false,
      deliveredAt: DateTime.now(),
    );

    _cachedNotifications.insert(0, notif);
  }

  NotificationCategory _parseCategoryFilter(String label) {
    switch (label) {
      case 'Crowd Alerts':
        return NotificationCategory.crowdAlert;
      case 'Festival Updates':
        return NotificationCategory.festivalUpdate;
      case 'Special Offers':
      case 'Offers':
        return NotificationCategory.nearbyOffer;
      case 'System':
        return NotificationCategory.system;
      default:
        return NotificationCategory.system;
    }
  }

  List<AppNotification> _getSampleNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'sample_1',
        userNotificationId: 'usample_1',
        category: NotificationCategory.crowdAlert,
        title: 'Suruchi Sangha Peak Crowd',
        body: 'Very High crowd reported at Suruchi Sangha (60+ min wait time). Best to visit after 10 PM.',
        relatedPandalId: 'suruchi_sangha',
        deepLink: 'manchitra://pandal/suruchi_sangha',
        isRead: false,
        deliveredAt: now.subtract(const Duration(minutes: 12)),
      ),
      AppNotification(
        id: 'sample_2',
        userNotificationId: 'usample_2',
        category: NotificationCategory.festivalUpdate,
        title: 'Special Aarti Timing Change',
        body: 'Ekdalia Evergreen Maha Ashtami Sandhi Aarti rescheduled to 7:45 PM tonight.',
        relatedPandalId: 'ekdalia_evergreen',
        deepLink: 'manchitra://pandal/ekdalia_evergreen',
        isRead: false,
        deliveredAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'sample_3',
        userNotificationId: 'usample_3',
        category: NotificationCategory.nearbyOffer,
        title: '20% Off Durga Puja Special Thali',
        body: '6 Ballygunge Place is offering 20% off for Manchitra users within 2 km.',
        relatedPandalId: null,
        deepLink: 'manchitra://route/sample_route_1',
        isRead: true,
        deliveredAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'sample_4',
        userNotificationId: 'usample_4',
        category: NotificationCategory.system,
        title: 'Heritage Trail AI Route Created',
        body: 'Your custom 6-pandal North Kolkata Heritage Hop Route is ready for review.',
        relatedPandalId: null,
        deepLink: 'manchitra://route/heritage_trail',
        isRead: true,
        deliveredAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
