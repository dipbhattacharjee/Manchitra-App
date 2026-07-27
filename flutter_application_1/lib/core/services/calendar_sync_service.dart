import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// ============================================================
/// MANCHITRA — Native Device Calendar Sync Service
/// Integrates pre-filled events into iOS Apple Calendar & Android Google Calendar
/// Zero API Key, Zero Cost, Works 100% Offline
/// ============================================================

class CalendarSyncService {
  CalendarSyncService._();
  static final CalendarSyncService instance = CalendarSyncService._();

  /// Export a key Panjika Puja Day (e.g. Maha Ashtami, Sandhi Puja) to native calendar
  Future<bool> addPujaDayToCalendar(PujaDay day) async {
    try {
      final startDate = day.date.add(const Duration(hours: 8)); // 8:00 AM
      final endDate = day.date.add(const Duration(hours: 22)); // 10:00 PM

      final ritualsList =
          day.rituals.isNotEmpty ? '\nRituals: ${day.rituals.join(", ")}' : '';

      final event = Event(
        title: '${day.name} 2026 — Manchitra Durga Puja',
        description:
            '${day.description}$ritualsList\n\nPlanned via Manchitra Durga Puja Guide & Map.',
        location: 'Kolkata, West Bengal',
        startDate: startDate,
        endDate: endDate,
        allDay: true,
      );

      return await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint('Error syncing PujaDay to native calendar: $e');
      return false;
    }
  }

  /// Export a single planned Pandal visit stop to native device calendar
  Future<bool> addPandalStopToCalendar({
    required Pandal pandal,
    required DateTime scheduledDate,
    Duration duration = const Duration(hours: 1),
  }) async {
    try {
      final event = Event(
        title: '${pandal.name} — Pandal Visit',
        description:
            'Area: ${pandal.area}\nTheme: ${pandal.theme ?? "Traditional"}\nCategory: ${pandal.category.label}\n\nPlanned via Manchitra App',
        location: '${pandal.name}, ${pandal.area}, Kolkata',
        startDate: scheduledDate,
        endDate: scheduledDate.add(duration),
      );

      return await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint('Error syncing Pandal stop to native calendar: $e');
      return false;
    }
  }

  /// Export a multi-stop Pandal Hop Route schedule to native calendar
  Future<bool> addRouteScheduleToCalendar({
    required List<Pandal> stops,
    required DateTime tripDate,
  }) async {
    if (stops.isEmpty) return false;

    try {
      final stopNames = stops.map((p) => p.name).join(' ➔ ');
      final startTime = DateTime(
          tripDate.year, tripDate.month, tripDate.day, 10, 0); // 10:00 AM start
      final endTime = startTime.add(Duration(hours: (stops.length * 1.2).ceil()));

      final event = Event(
        title: 'Manchitra Pandal Hop Route (${stops.length} Pandals)',
        description:
            'Pandal Sequence:\n$stopNames\n\nTotal Stops: ${stops.length}\nPlanned with Manchitra Durga Puja Guide & Map',
        location: '${stops.first.name}, ${stops.first.area}, Kolkata',
        startDate: startTime,
        endDate: endTime,
      );

      return await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint('Error syncing Hop Route to native calendar: $e');
      return false;
    }
  }
}
