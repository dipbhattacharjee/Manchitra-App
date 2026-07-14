import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/common_widgets.dart';

/// ============================================================
/// MANCHITRA — Trip Planning Calendar Screen
/// ============================================================

class TripCalendarScreen extends StatefulWidget {
  const TripCalendarScreen({super.key});

  @override
  State<TripCalendarScreen> createState() => _TripCalendarScreenState();
}

class _TripCalendarScreenState extends State<TripCalendarScreen> {
  String _selectedDay = 'Ashtami';

  final Map<String, List<_CalendarEntry>> _dayPlans = {
    'Ashtami': [
      _CalendarEntry('10:00 AM', 'Bagbazar Sarbojanin', 'North Kolkata',
          isStop: true, transportNext: TransportMode.walk, nextDuration: 15),
      _CalendarEntry('11:30 AM', 'Kumartuli Park', 'North Kolkata',
          isStop: true, transportNext: TransportMode.metro, nextDuration: 12),
      _CalendarEntry('1:00 PM', 'Arsalan Restaurant', 'Park Circus',
          isFood: true),
      _CalendarEntry('2:30 PM', 'Ekdalia Evergreen', 'South Kolkata',
          isStop: true, transportNext: TransportMode.cab, nextDuration: 8),
    ],
    'Navami': [],
    'Dashami': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Puja Calendar', style: AppTextStyles.titleLarge),
            Text(
              'Durga Puja 2026',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Day tab bar
          _buildDayTabs(),
          const SizedBox(height: 8),

          // Day summary
          if (_dayPlans[_selectedDay]?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: PujaDayBadge(
                dayName: _selectedDay,
                date: SampleData.pujaDays[_selectedDay] ?? '',
              ),
            ),

          // Itinerary
          Expanded(
            child: _buildItinerary(),
          ),

          // Add button
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildDayTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: SampleData.pujaDays.entries.map((entry) {
            final isSelected = _selectedDay == entry.key;
            final hasPlans = _dayPlans[entry.key]?.isNotEmpty ?? false;
            return GestureDetector(
              onTap: () => setState(() => _selectedDay = entry.key),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Text(
                            entry.key,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.value,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.textDisabled,
                            ),
                          ),
                          if (hasPlans)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Active underline
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: 60,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded,
                  size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'No hops planned for $_selectedDay yet',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to plan your hop!',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, i) => _buildCalendarEntry(entries[i], i, entries.length),
    );
  }

  Widget _buildCalendarEntry(_CalendarEntry entry, int index, int total) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: entry.isFood ? AppColors.secondaryContainer : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: entry.isFood ? AppColors.secondary : AppColors.border,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: entry.isFood
                    ? AppColors.secondaryContainer
                    : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.time,
                style: AppTextStyles.labelSmall.copyWith(
                  color: entry.isFood ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ),
            title: Text(entry.name, style: AppTextStyles.titleSmall),
            subtitle: Text(entry.location, style: AppTextStyles.bodySmall),
            trailing: entry.isFood
                ? const Icon(Icons.restaurant, color: AppColors.secondary, size: 20)
                : const Icon(Icons.temple_hindu, color: AppColors.primary, size: 20),
          ),
        ),

        // Transport connector
        if (index < total - 1 && entry.transportNext != null)
          TransportLegChip(
            mode: entry.transportNext!,
            durationText: '${entry.nextDuration} min',
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: GradientButton(
        onPressed: () {},
        text: '+ Add to $_selectedDay',
        hasGlow: true,
        height: 52,
      ),
    );
  }
}

class _CalendarEntry {
  const _CalendarEntry(
    this.time,
    this.name,
    this.location, {
    this.isStop = false,
    this.isFood = false,
    this.transportNext,
    this.nextDuration,
  });

  final String time;
  final String name;
  final String location;
  final bool isStop;
  final bool isFood;
  final TransportMode? transportNext;
  final int? nextDuration;
}
