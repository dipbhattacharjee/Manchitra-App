import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/theme.dart';
import '../../core/models/notification_model.dart';
import '../../core/services/notification_service.dart';

/// ============================================================
/// MANCHITRA — Notification Settings Screen
/// ============================================================

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _service = NotificationService.instance;

  UserNotificationPreferences _prefs = const UserNotificationPreferences();
  bool _isLoading = true;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await _service.fetchPreferences();
    final perm = await Permission.notification.status;

    if (mounted) {
      setState(() {
        _prefs = prefs;
        _permissionStatus = perm;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences(UserNotificationPreferences newPrefs) async {
    setState(() => _prefs = newPrefs);
    final success = await _service.updatePreferences(newPrefs);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update notification settings.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      if (mounted) {
        setState(() => _permissionStatus = status);
      }
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final currentStr = isStart ? _prefs.quietHoursStart : _prefs.quietHoursEnd;
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? (isStart ? 23 : 7),
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        _updatePreferences(_prefs.copyWith(quietHoursStart: formatted));
      } else {
        _updatePreferences(_prefs.copyWith(quietHoursEnd: formatted));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // 1. System Permission Card Banner
                _buildPermissionStatusCard(),
                const SizedBox(height: 24),

                // 2. Notification Category Toggles
                const Text(
                  'ALERT CATEGORIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                _buildSwitchTile(
                  title: 'Crowd Alerts',
                  subtitle: 'Real-time high crowd notifications for saved & nearby pandals',
                  icon: Icons.people_rounded,
                  iconColor: const Color(0xFFE53935),
                  value: _prefs.crowdAlertsEnabled,
                  onChanged: (val) => _updatePreferences(_prefs.copyWith(crowdAlertsEnabled: val)),
                ),
                _buildSwitchTile(
                  title: 'Festival Updates',
                  subtitle: 'Special Aarti timings, inauguration news & cultural schedules',
                  icon: Icons.stars_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  value: _prefs.festivalUpdatesEnabled,
                  onChanged: (val) => _updatePreferences(_prefs.copyWith(festivalUpdatesEnabled: val)),
                ),
                _buildSwitchTile(
                  title: 'Nearby Food & Special Offers',
                  subtitle: 'Exclusive dining discounts & food stall offers near your route',
                  icon: Icons.local_offer_rounded,
                  iconColor: const Color(0xFFF57C00),
                  value: _prefs.nearbyOffersEnabled,
                  onChanged: (val) => _updatePreferences(_prefs.copyWith(nearbyOffersEnabled: val)),
                ),
                _buildSwitchTile(
                  title: 'System & AI Route Alerts',
                  subtitle: 'Route generation updates, weather warnings & app notifications',
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  value: _prefs.systemEnabled,
                  onChanged: (val) => _updatePreferences(_prefs.copyWith(systemEnabled: val)),
                ),

                const SizedBox(height: 32),

                // 3. Quiet Hours Section
                const Text(
                  'QUIET HOURS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.bedtime_rounded, color: Color(0xFF3F51B5), size: 22),
                              SizedBox(width: 12),
                              Text(
                                'Enable Quiet Hours',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          Switch(
                            value: _prefs.quietHoursEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (val) => _updatePreferences(_prefs.copyWith(quietHoursEnabled: val)),
                          ),
                        ],
                      ),
                      if (_prefs.quietHoursEnabled) ...[
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTimeSelectorTile(
                              label: 'Start Time',
                              timeStr: _prefs.quietHoursStart,
                              onTap: () => _pickTime(isStart: true),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey[200]),
                            _buildTimeSelectorTile(
                              label: 'End Time',
                              timeStr: _prefs.quietHoursEnd,
                              onTap: () => _pickTime(isStart: false),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionStatusCard() {
    final isGranted = _permissionStatus.isGranted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isGranted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGranted ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isGranted ? Colors.green.shade700 : Colors.orange.shade800,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGranted ? 'Notifications Allowed' : 'Notifications Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isGranted ? Colors.green.shade900 : Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGranted
                      ? 'You are ready to receive live Puja updates & crowd alerts.'
                      : 'Grant permission to get instant crowd warnings & route updates.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isGranted ? Colors.green.shade800 : Colors.orange.shade900,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            ElevatedButton(
              onPressed: _requestNotificationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Enable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelectorTile({
    required String label,
    required String timeStr,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
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
