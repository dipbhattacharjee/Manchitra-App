import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/pandal_provider.dart';
import '../../core/services/route_service.dart';
import '../pandals/pandal_detail_screen.dart';
import '../route/hop_route_screen.dart';
import '../../core/services/panjika_service.dart';
import '../../core/services/calendar_sync_service.dart';
import '../../shared/widgets/notification_bell_badge.dart';
import '../profile/profile_data.dart';

/// ============================================================
/// MANCHITRA — Real Portable Trip Planning Calendar Screen
/// ============================================================

class TripCalendarScreen extends StatefulWidget {
  const TripCalendarScreen({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<TripCalendarScreen> createState() => _TripCalendarScreenState();
}

class _TripCalendarScreenState extends State<TripCalendarScreen> {
  // Calendar state
  DateTime _currentMonth = DateTime(2026, 10, 1);
  DateTime _selectedDate = DateTime(2026, 10, 18); // Maha Ashtami default
  String _selectedDayTab = 'Ashtami';
  bool _isCalendarMinimized = false;
  List<PujaDay> _pujaDays = [];

  // In-app notification state
  bool _showNotificationBanner = false;
  String? _activeNotificationTitle;
  String? _activeNotificationBody;
  Timer? _notificationTimer;
  Timer? _dismissTimer;

  // Custom added entries per date string (yyyy-MM-dd)
  final Map<String, List<_CalendarEntry>> _customEntries = {};

  @override
  void initState() {
    super.initState();
    _loadPanjikaData();
    _syncTabWithDate(_selectedDate);
  }

  Future<void> _loadPanjikaData() async {
    final days = await PanjikaService.instance.getPujaDays();
    if (mounted) {
      setState(() {
        _pujaDays = days;
      });
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _syncTabWithDate(DateTime date) {
    if (date.month == 10) {
      if (date.day == 10) {
        _selectedDayTab = 'Mahalaya';
      } else if (date.day == 15) {
        _selectedDayTab = 'Panchami';
      } else if (date.day == 16) {
        _selectedDayTab = 'Sasthi';
      } else if (date.day == 17) {
        _selectedDayTab = 'Saptami';
      } else if (date.day == 18) {
        _selectedDayTab = 'Ashtami';
      } else if (date.day == 19) {
        _selectedDayTab = 'Navami';
      } else if (date.day == 20) {
        _selectedDayTab = 'Dashami';
      } else {
        _selectedDayTab = 'Oct ${date.day}';
      }
    } else {
      _selectedDayTab = '${_monthName(date.month).substring(0, 3)} ${date.day}';
    }
  }

  void _scheduleInAppNotification(String name, String time) {
    _notificationTimer?.cancel();
    _dismissTimer?.cancel();

    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _activeNotificationTitle = 'Puja Reminder: $name';
          _activeNotificationBody = 'Your visit scheduled for $time is coming up! Live crowd status is available.';
          _showNotificationBanner = true;
        });

        _dismissTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showNotificationBanner = false;
            });
          }
        });
      }
    });
  }

  String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final pandalProvider = Provider.of<PandalProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                onPressed: widget.onBack,
              )
            : (Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
                    onPressed: () => Navigator.pop(context),
                  )
                : null),
        title: Text(
          'Puja Trip Planner',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route_rounded, color: AppColors.primary, size: 24),
            tooltip: 'View Hop Route',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HopRouteScreen(plannedDate: _selectedDate)),
              );
            },
          ),
          const NotificationBellBadge(),
        ],
      ),
      body: Stack(
        children: [
          // Single Unified ScrollView for full page (Calendar moves naturally up & down with itinerary content)
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header title with Flexible column to fix right overflow
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Festive Calendar',
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Organize real pandal visits and cultural experiences.',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Portable Calendar Toggle Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isCalendarMinimized = !_isCalendarMinimized;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isCalendarMinimized ? Icons.calendar_month : Icons.unfold_less,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isCalendarMinimized ? 'Big View' : 'Minimize',
                                style: GoogleFonts.manrope(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Interactive Real Portable Calendar View
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _isCalendarMinimized
                      ? _buildMinimizedCalendarBar()
                      : _buildFullCalendarGrid(),
                ),

                // Day selection quick tabs
                _buildPujaDayTabs(),
                const SizedBox(height: 6),

                // Panjika Highlight & Rituals Card
                _buildPanjikaCard(),
                const SizedBox(height: 6),

                // Real Itinerary timeline section
                _buildRealItinerarySection(pandalProvider),
              ],
            ),
          ),

          // Sliding notification banner overlay
          if (_showNotificationBanner)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppColors.secondary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _activeNotificationTitle ?? 'Puja Notification',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _activeNotificationBody ?? '',
                                style: GoogleFonts.manrope(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                          onPressed: () {
                            setState(() {
                              _showNotificationBanner = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Compact Minimized Calendar View
  Widget _buildMinimizedCalendarBar() {
    final dateString = '${_monthName(_selectedDate.month)} ${_selectedDate.day}, ${_selectedDate.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateString,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Selected Day: $_selectedDayTab',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => setState(() => _isCalendarMinimized = false),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
            label: Text(
              'Expand',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Full Big Calendar Grid View (Fixed Header Row to prevent right overflow)
  Widget _buildFullCalendarGrid() {
    final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonthCount = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final leadingPadding = (firstDayOfMonth.weekday - 1) % 7;

    final List<int?> gridDays = [];
    for (int i = 0; i < leadingPadding; i++) {
      gridDays.add(null);
    }
    for (int d = 1; d <= daysInMonthCount; d++) {
      gridDays.add(d);
    }

    String? getPujaTitle(int day) {
      if (_currentMonth.month == 10 && _currentMonth.year == 2026) {
        if (day == 10) return 'Mahalaya';
        if (day == 15) return 'Panchami';
        if (day == 16) return 'Sasthi';
        if (day == 17) return 'Saptami';
        if (day == 18) return 'Ashtami';
        if (day == 19) return 'Navami';
        if (day == 20) return 'Dashami';
      }
      return null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Header & Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.black87),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.black54, size: 22),
                onPressed: () => setState(() => _isCalendarMinimized = true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Weekdays Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => SizedBox(
              width: 28,
              height: 20,
              child: Center(
                child: Text(
                  w,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),

          // Calendar Days Grid (Compact row height & cell margin)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final dayVal = gridDays[index];
              if (dayVal == null) {
                return const SizedBox.shrink();
              }

              final dateOfCell = DateTime(_currentMonth.year, _currentMonth.month, dayVal);
              final bool isSelected = _selectedDate.year == dateOfCell.year &&
                  _selectedDate.month == dateOfCell.month &&
                  _selectedDate.day == dateOfCell.day;
              final pujaTitle = getPujaTitle(dayVal);
              final bool isPujaDay = pujaTitle != null;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = dateOfCell;
                    _syncTabWithDate(_selectedDate);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isPujaDay ? const Color(0xFFFFF2F0) : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: (isPujaDay && !isSelected)
                        ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayVal.toString(),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : (isPujaDay ? AppColors.primary : Colors.black87),
                        ),
                      ),
                      if (pujaTitle != null)
                        Text(
                          pujaTitle,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white70 : AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Puja Days Horizontal Selection Tabs
  Widget _buildPujaDayTabs() {
    final List<Map<String, dynamic>> tabs = [
      {'key': 'Mahalaya', 'date': DateTime(2026, 10, 10), 'label': 'OCT 10'},
      {'key': 'Panchami', 'date': DateTime(2026, 10, 15), 'label': 'OCT 15'},
      {'key': 'Sasthi', 'date': DateTime(2026, 10, 16), 'label': 'OCT 16'},
      {'key': 'Saptami', 'date': DateTime(2026, 10, 17), 'label': 'OCT 17'},
      {'key': 'Ashtami', 'date': DateTime(2026, 10, 18), 'label': 'OCT 18'},
      {'key': 'Navami', 'date': DateTime(2026, 10, 19), 'label': 'OCT 19'},
      {'key': 'Dashami', 'date': DateTime(2026, 10, 20), 'label': 'OCT 20'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: tabs.map((t) {
          final DateTime tabDate = t['date'] as DateTime;
          final bool isSelected = _selectedDate.year == tabDate.year &&
              _selectedDate.month == tabDate.month &&
              _selectedDate.day == tabDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = tabDate;
                _currentMonth = DateTime(tabDate.year, tabDate.month, 1);
                _syncTabWithDate(tabDate);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t['label'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  Text(
                    t['key'] as String,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Panjika Rituals & Highlights Card for Active Selected Day
  Widget _buildPanjikaCard() {
    PujaDay? activeDay;
    final dateStr = _dateKey(_selectedDate);
    try {
      activeDay = _pujaDays.firstWhere((d) => d.dateString == dateStr);
    } catch (_) {
      activeDay = null;
    }

    if (activeDay == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A080C), Color(0xFF500F17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${activeDay.name} 2026',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final success =
                      await CalendarSyncService.instance.addPujaDayToCalendar(activeDay!);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${activeDay.name} added to your device calendar!'),
                        backgroundColor: const Color(0xFF2A8A4A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.event_available_rounded, size: 14, color: Colors.black87),
                label: const Text(
                  'Add to Calendar',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activeDay.description,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          if (activeDay.rituals.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: activeDay.rituals.map((r) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.brightness_7_rounded, size: 10, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        r,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Real Itinerary Section using Provider & HopListManager
  Widget _buildRealItinerarySection(PandalProvider provider) {
    final dKey = _dateKey(_selectedDate);
    final customList = _customEntries[dKey] ?? [];

    // Real selected pandals from user's Hop List or provider
    final List<Pandal> hopPandals = HopListManager.selectedPandals;

    // Filter pandals for this day
    final List<Pandal> displayPandals = [];
    if (hopPandals.isNotEmpty) {
      displayPandals.addAll(hopPandals);
    } else if (provider.pandals.isNotEmpty) {
      // Show featured top 3 pandals from real database if user hop list is empty
      displayPandals.addAll(provider.pandals.take(3));
    }

    final int totalItems = displayPandals.length + customList.length;

    if (totalItems == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.temple_hindu_outlined, size: 54, color: AppColors.secondary),
              const SizedBox(height: 12),
              Text(
                'No visits scheduled for $_selectedDayTab yet.',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Add pandals from the database or your Hop List to build your trip!',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddPandalFromDatabaseSheet(provider),
                icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
                label: Text(
                  'Add Pandal from Database',
                  style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // View Route on Map Banner Card for current selected date
        if (displayPandals.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF8B1A1A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.map_rounded, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Route on Map ($_selectedDayTab)',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Access map route for ${displayPandals.length} scheduled pandals',
                        style: GoogleFonts.manrope(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.setRouteStops(displayPandals);
                    for (final p in displayPandals) {
                      HopListManager.add(p);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HopRouteScreen(plannedDate: _selectedDate)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.alt_route_rounded, size: 14, color: Colors.black87),
                  label: Text(
                    'Open Map',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Action Bar for the Day with Save Plan button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scheduled Stops (${displayPandals.length + customList.length})',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  if (displayPandals.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final success = await ProfileData.saveRoutePlanToProfile(
                          pujaDay: _selectedDayTab,
                          date: _selectedDate,
                          pandals: displayPandals,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved $_selectedDayTab route plan to your Profile!'),
                              backgroundColor: const Color(0xFF2A8A4A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF2F0),
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primary, width: 1),
                        ),
                      ),
                      icon: const Icon(Icons.bookmark_add_outlined, size: 14, color: AppColors.primary),
                      label: Text(
                        'Save Plan',
                        style: GoogleFonts.manrope(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () => _showAddPandalFromDatabaseSheet(provider),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    label: Text(
                      'Add Stop',
                      style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Non-scrollable list view so parent SingleChildScrollView scrolls smoothly
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: displayPandals.length + customList.length,
          itemBuilder: (context, index) {
            if (index < displayPandals.length) {
              final pandal = displayPandals[index];
              final String timeSlot = '${(9 + (index * 2)).toString().padLeft(2, '0')}:00 PM';
              return _buildRealPandalEntry(pandal, timeSlot, index, displayPandals.length + customList.length);
            } else {
              final customIdx = index - displayPandals.length;
              final entry = customList[customIdx];
              return _buildCustomEntryItem(entry, index, displayPandals.length + customList.length, dKey, customIdx);
            }
          },
        ),
      ],
    );
  }

  /// Real Pandal Entry Card
  Widget _buildRealPandalEntry(Pandal pandal, String time, int index, int total) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.temple_hindu_rounded, color: AppColors.primary, size: 16),
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          // Content Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PandalDetailScreen(pandal: pandal)),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: pandal.crowdLevel.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.people_alt, size: 10, color: pandal.crowdLevel.color),
                              const SizedBox(width: 4),
                              Text(
                                '${pandal.crowdLevel.label} Crowd',
                                style: TextStyle(
                                  color: pandal.crowdLevel.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pandal.name,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          pandal.area,
                          style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    if (pandal.coverPhotoUrl != null && pandal.coverPhotoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          pandal.coverPhotoUrl!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 18),
                              tooltip: 'In-App Reminder',
                              onPressed: () {
                                _scheduleInAppNotification(pandal.name, time);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reminder set for ${pandal.name}'),
                                    backgroundColor: AppColors.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 14),
                            IconButton(
                              icon: const Icon(Icons.event_available_rounded, color: Color(0xFF2A8A4A), size: 18),
                              tooltip: 'Add Stop to Device Calendar',
                              onPressed: () async {
                                final scheduledTime = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  _selectedDate.day,
                                  10 + (index * 2), // Staggered visit time
                                  0,
                                );
                                final success = await CalendarSyncService.instance.addPandalStopToCalendar(
                                  pandal: pandal,
                                  scheduledDate: scheduledTime,
                                );
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${pandal.name} synced to your device calendar!'),
                                      backgroundColor: const Color(0xFF2A8A4A),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PandalDetailScreen(pandal: pandal)),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 14, color: AppColors.secondary),
                          label: Text(
                            'View Details',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom User Entry Item
  Widget _buildCustomEntryItem(_CalendarEntry entry, int index, int total, String dKey, int customIdx) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  child: const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 16),
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.time,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _customEntries[dKey]?.removeAt(customIdx);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.name,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.description,
                    style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Sheet to Pick and Add Real Pandals from Database
  void _showAddPandalFromDatabaseSheet(PandalProvider provider) {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = provider.pandals.where((p) {
            if (query.trim().isEmpty) return true;
            return p.name.toLowerCase().contains(query.trim().toLowerCase()) ||
                p.area.toLowerCase().contains(query.trim().toLowerCase());
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Pandal to $_selectedDayTab',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (val) => setModalState(() => query = val),
                  decoration: InputDecoration(
                    hintText: 'Search pandals in Kolkata...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No pandals found matching query.'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final item = filtered[idx];
                            final isInHop = HopListManager.selectedPandals.any((p) => p.id == item.id);

                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.coverPhotoUrl != null && item.coverPhotoUrl!.isNotEmpty
                                    ? Image.network(
                                        item.coverPhotoUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 50,
                                          height: 50,
                                          color: AppColors.primaryContainer,
                                          child: const Icon(Icons.temple_hindu, color: AppColors.primary),
                                        ),
                                      )
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        color: AppColors.primaryContainer,
                                        child: const Icon(Icons.temple_hindu, color: AppColors.primary),
                                      ),
                              ),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item.area),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInHop ? AppColors.secondary : AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  if (!isInHop) {
                                    HopListManager.add(item);
                                    provider.addToRoute(item);
                                  }
                                  setState(() {});
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Added ${item.name} to $_selectedDayTab trip!'),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                },
                                child: Text(
                                  isInHop ? 'Added' : 'Add',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CalendarEntry {
  _CalendarEntry(
    this.time,
    this.name,
    this.location, {
    required this.description,
  });

  final String time;
  final String name;
  final String location;
  final String description;
}
