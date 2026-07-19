import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Trip Planning Calendar Screen
/// ============================================================

class TripCalendarScreen extends StatefulWidget {
  const TripCalendarScreen({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<TripCalendarScreen> createState() => _TripCalendarScreenState();
}

class _TripCalendarScreenState extends State<TripCalendarScreen> {
  String _selectedDay = 'Saptami';
  bool _reminderSet = false;

  final Map<String, List<_CalendarEntry>> _dayPlans = {
    'Saptami': [
      const _CalendarEntry(
        '09:00 AM',
        'Suruchi Sangha',
        'New Alipore',
        description: 'Thematic Pandal known for its intricate sustainable craftwork. Expect 45 min queue.',
        imageUrl: 'https://images.unsplash.com/photo-1620608581699-23c21a48c6a2?w=500',
        distanceText: '2.4 km from stay',
        priorityTag: 'High Priority',
      ),
      const _CalendarEntry(
        '12:30 PM',
        '6 Ballygunge Place',
        'Ballygunge',
        description: 'Traditional Bengali Lunch. Recommended: Kosha Mangsho and Basanti Pulao.',
        isFood: true,
        rating: '4.8',
        reviews: '2.1k',
        isPremium: true,
      ),
      const _CalendarEntry(
        '03:00 PM',
        'Ballygunge Cultural',
        'Ballygunge',
        description: "Exquisite traditional idol. Known for classical aesthetics and 'Shabeki' style.",
        waitTime: '15 mins',
        crowdLevel: 'Moderate',
      ),
      const _CalendarEntry(
        '06:00 PM',
        'Evening Arati & Cultural Program',
        'Local Area',
        description: 'Join the Dhunuchi Naach and traditional Arati rituals followed by local folk music.',
        isEvent: true,
        hasReminderButton: true,
      ),
    ],
    'Ashtami': [
      const _CalendarEntry(
        '10:00 AM',
        'Bagbazar Sarbojanin',
        'North Kolkata',
        description: 'One of the oldest and most revered Durga Puja committees in Kolkata. Expect massive crowds for Ashtami Anjali.',
        imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg',
        distanceText: '1.2 km from stay',
        priorityTag: 'High Priority',
      ),
      const _CalendarEntry(
        '01:00 PM',
        'Traditional Ashtami Bhog',
        'North Kolkata',
        description: 'Enjoy delicious Khichuri Bhog, Labra, and Payesh served at the pandal community hall.',
        isFood: true,
        rating: '4.9',
        reviews: '5k',
      ),
      const _CalendarEntry(
        '04:00 PM',
        'Kumartuli Park Durgotsav',
        'North Kolkata',
        description: 'Located in the artisan district, showcasing beautiful traditional art.',
        waitTime: '20 mins',
        crowdLevel: 'High',
      ),
    ],
    'Navami': [
      const _CalendarEntry(
        '11:00 AM',
        'Ekdalia Evergreen',
        'South Kolkata',
        description: 'Famous for its light decorations and massive temple replica. Expect high crowds.',
        imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039236/ekdalia-evergreen_fbvbsr.jpg',
        distanceText: '3.8 km from stay',
      ),
      const _CalendarEntry(
        '02:00 PM',
        'Kolkata Street Food Crawl',
        'South Kolkata',
        description: 'Taste the iconic egg rolls, phuchka, and cutlets near Gariahat crossing.',
        isFood: true,
        rating: '4.7',
        reviews: '1.2k',
      ),
      const _CalendarEntry(
        '07:00 PM',
        'Dhunuchi Naach Competition',
        'South Kolkata',
        description: 'Watch the energetic traditional dance with clay incense burners.',
        isEvent: true,
        hasReminderButton: true,
      ),
    ],
    'Dashami': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF5),
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                onPressed: widget.onBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header title & description
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Puja Calendar',
                    style: GoogleFonts.manrope(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your divine journey through the heart of Bengal.',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Monthly Calendar Grid
          _buildMonthCalendarGrid(),

          // Day selection tabs
          _buildDayTabs(),
          const SizedBox(height: 8),

          // Timeline list
          Expanded(
            child: _buildItinerary(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarGrid() {
    final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    // October 2026 starts on Thursday
    final List<int?> daysInMonth = [
      null, null, null,
      1, 2, 3, 4,
      5, 6, 7, 8, 9, 10, 11,
      12, 13, 14, 15, 16, 17, 18,
      19, 20, 21, 22, 23, 24, 25,
      26, 27, 28, 29, 30, 31
    ];

    String? getDayKeyForDate(int date) {
      if (date == 21) return 'Saptami';
      if (date == 22) return 'Ashtami';
      if (date == 23) return 'Navami';
      if (date == 24) return 'Dashami';
      return null;
    }

    int? getSelectedDate() {
      if (_selectedDay == 'Saptami') return 21;
      if (_selectedDay == 'Ashtami') return 22;
      if (_selectedDay == 'Navami') return 23;
      if (_selectedDay == 'Dashami') return 24;
      return null;
    }

    final selectedDate = getSelectedDate();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EAE1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'October 2026',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Durga Puja Month',
                  style: TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) => SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  w,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final dayVal = daysInMonth[index];
              if (dayVal == null) {
                return const SizedBox.shrink();
              }

              final String? dayKey = getDayKeyForDate(dayVal);
              final bool isPujaDay = dayKey != null;
              final bool isSelected = selectedDate == dayVal;

              return GestureDetector(
                onTap: () {
                  if (isPujaDay) {
                    setState(() {
                      _selectedDay = dayKey;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No custom puja schedule created for October $dayVal.'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFAF101A) 
                        : (isPujaDay ? const Color(0xFFFFF2F0) : Colors.transparent),
                    shape: BoxShape.circle,
                    border: (isPujaDay && !isSelected)
                        ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      dayVal.toString(),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isSelected 
                            ? Colors.white 
                            : (isPujaDay ? AppColors.primary : Colors.black87),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayTabs() {
    final List<Map<String, String>> days = [
      {'key': 'Saptami', 'date': 'OCT 21'},
      {'key': 'Ashtami', 'date': 'OCT 22'},
      {'key': 'Navami', 'date': 'OCT 23'},
      {'key': 'Dashami', 'date': 'OCT 24'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: days.map((day) {
          final isSelected = _selectedDay == day['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day['key']!),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFAF101A) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    day['date']!,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day['key']!,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
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

  Widget _buildItinerary() {
    final entries = _dayPlans[_selectedDay] ?? [];

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hops planned for $_selectedDay yet.',
              style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120, left: 24, right: 24),
      itemCount: entries.length + 1,
      itemBuilder: (context, i) {
        if (i < entries.length) {
          return _buildCalendarEntry(entries[i], i, entries.length);
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 60),
            child: _buildAiOptimizerCard(),
          );
        }
      },
    );
  }

  Widget _buildCalendarEntry(_CalendarEntry entry, int index, int total) {
    IconData icon;
    Color iconColor;
    Color timeColor;

    if (entry.isFood) {
      icon = Icons.restaurant;
      iconColor = const Color(0xFFAF101A);
      timeColor = const Color(0xFFAF101A);
    } else if (entry.isEvent) {
      icon = Icons.theater_comedy;
      iconColor = const Color(0xFF8A1E65);
      timeColor = const Color(0xFF8A1E65);
    } else {
      icon = Icons.temple_hindu;
      iconColor = const Color(0xFFDFB610);
      timeColor = const Color(0xFFDFB610);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left Timeline Line & Icon
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE6DCBC),
                    ),
                  ),
              ],
            ),
          ),

          // 2. Right Content Card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.time,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: timeColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header title & potential badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.name,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (entry.priorityTag != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFAF101A),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                entry.priorityTag!,
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        entry.description,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Optional image with inline overlay
                      if (entry.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                entry.imageUrl!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (entry.distanceText != null)
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        entry.distanceText!,
                                        style: GoogleFonts.manrope(
                                          color: Colors.white,
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
                      ],

                      // Optional food badges
                      if (entry.isFood && (entry.rating != null || entry.isPremium)) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (entry.rating != null)
                              _buildBadge(
                                '★ ${entry.rating} (${entry.reviews ?? ""})',
                                icon: Icons.star_rounded,
                              ),
                            if (entry.isPremium)
                              _buildBadge(
                                'Premium',
                                icon: Icons.attach_money_rounded,
                              ),
                          ],
                        ),
                      ],

                      // Optional wait time & crowd level badges
                      if (entry.waitTime != null || entry.crowdLevel != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (entry.waitTime != null)
                              _buildBadge(
                                'Wait Time: ${entry.waitTime}',
                                icon: Icons.access_time_rounded,
                              ),
                            if (entry.crowdLevel != null)
                              _buildBadge(
                                'Crowd Level: ${entry.crowdLevel}',
                                icon: Icons.people_outline_rounded,
                              ),
                          ],
                        ),
                      ],

                      // Optional reminder button
                      if (entry.hasReminderButton) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _reminderSet = !_reminderSet;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_reminderSet
                                    ? 'Reminder set for "${entry.name}"!'
                                    : 'Reminder cancelled!'),
                                backgroundColor: const Color(0xFFAF101A),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _reminderSet ? '✓ Reminder Set' : 'Set Reminder',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFFAF101A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFFAF101A),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.grey[700]),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiOptimizerCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFDCBCB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFAF101A), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'AI Optimizer',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  '"Crowd density at Suruchi is expected to spike after 10 AM. If you leave 15 mins earlier, you can bypass the morning rush. Also, 6 Ballygunge Place has a table available at 12:15 PM!"',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: GestureDetector(
            onTap: _handleAddPlanItem,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFAF101A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3FAF101A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAddPlanItem() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan Your Puja Day',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create a customized itinerary for $_selectedDay.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            // Option 1: Auto-Fill Curated Day Plan
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _autoFillDailyPlan();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDCBCB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFAF101A), size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-Fill Full Day Plan',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fills the entire day (Early morning to Night) with curated pandals, food stops, and arati events.',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFAF101A)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Option 2: Add Custom Plan
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showCustomAddSheet();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Custom Event',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manually add a specific Pandal visit or Restaurant dining time to your schedule.',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoFillDailyPlan() {
    setState(() {
      _dayPlans[_selectedDay] = [
        const _CalendarEntry(
          '06:00 AM',
          'Bagbazar Ghat & Morning Arati',
          'Bagbazar',
          description: 'Start your day with a holy dip/view at Bagbazar Ghat followed by the serene Morning Arati at Bagbazar Sarbojanin.',
          isEvent: true,
        ),
        const _CalendarEntry(
          '09:00 AM',
          'Suruchi Sangha',
          'New Alipore',
          description: 'Thematic Pandal known for its intricate sustainable craftwork. Expect 45 min queue.',
          imageUrl: 'https://images.unsplash.com/photo-1620608581699-23c21a48c6a2?w=500',
          distanceText: '2.4 km from stay',
          priorityTag: 'High Priority',
        ),
        const _CalendarEntry(
          '12:30 PM',
          '6 Ballygunge Place',
          'Ballygunge',
          description: 'Traditional Bengali Lunch. Recommended: Kosha Mangsho and Basanti Pulao.',
          isFood: true,
          rating: '4.8',
          reviews: '2.1k',
          isPremium: true,
        ),
        const _CalendarEntry(
          '03:30 PM',
          'Jorasanko Dawn Bari',
          'Jorasanko',
          description: 'Ancestral household family puja of Shibkrishna Dawn. Known for the grand mansion courtyard and gold/silver decorations.',
          imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg',
          distanceText: '5.1 km from lunch',
        ),
        const _CalendarEntry(
          '06:00 PM',
          'Sandhya Arati & Dhunuchi Naach',
          'Mohammad Ali Park',
          description: 'Experience the magical Sandhya Arati and traditional Dhunuchi Naach over the iconic waterfront.',
          isEvent: true,
          hasReminderButton: true,
        ),
        const _CalendarEntry(
          '09:00 PM',
          'College Square Illumination',
          'Central Kolkata',
          description: 'Famous for the stunning waterfront illumination reflecting beautifully over the lake.',
          waitTime: '20 mins',
          crowdLevel: 'Very High',
        ),
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Curated Daily Plan (Morning to Night) generated for $_selectedDay!'),
        backgroundColor: const Color(0xFFAF101A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCustomAddSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final timeController = TextEditingController(text: '12:00 PM');
    bool isFood = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Plan to $_selectedDay',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (Pandal or Food place)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description / Recommended items',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time (e.g., 01:00 PM)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Is this a food stop?',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                    value: isFood,
                    onChanged: (val) {
                      setModalState(() {
                        isFood = val;
                      });
                    },
                    activeColor: const Color(0xFFAF101A),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAF101A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    setState(() {
                      final newEntry = _CalendarEntry(
                        timeController.text.trim(),
                        nameController.text.trim(),
                        isFood ? 'Restaurant / Dining' : 'Durga Puja Pandal',
                        description: descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : 'Planned visit during Puja.',
                        isFood: isFood,
                      );
                      if (_dayPlans[_selectedDay] == null) {
                        _dayPlans[_selectedDay] = [];
                      }
                      _dayPlans[_selectedDay]!.add(newEntry);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${nameController.text.trim()}" to $_selectedDay!'),
                        backgroundColor: const Color(0xFFAF101A),
                      ),
                    );
                  },
                  child: Text(
                    'Add Plan',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarEntry {
  const _CalendarEntry(
    this.time,
    this.name,
    this.location, {
    required this.description,
    this.isFood = false,
    this.isEvent = false,
    this.imageUrl,
    this.distanceText,
    this.priorityTag,
    this.rating,
    this.reviews,
    this.isPremium = false,
    this.waitTime,
    this.crowdLevel,
    this.hasReminderButton = false,
  });

  final String time;
  final String name;
  final String location;
  final String description;
  final bool isFood;
  final bool isEvent;
  final String? imageUrl;
  final String? distanceText;
  final String? priorityTag;
  final String? rating;
  final String? reviews;
  final bool isPremium;
  final String? waitTime;
  final String? crowdLevel;
  final bool hasReminderButton;
}
