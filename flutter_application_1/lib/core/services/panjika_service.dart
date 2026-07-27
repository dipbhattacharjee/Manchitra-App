import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// ============================================================
/// MANCHITRA — Panjika Service (Local Durga Puja 2026 Dataset)
/// 100% Offline, Zero API Key, Zero Cost Panjika Loader
/// ============================================================

class PanjikaService {
  PanjikaService._();
  static final PanjikaService instance = PanjikaService._();

  List<PujaDay>? _cachedDays;

  /// Load Durga Puja 2026 dataset from local asset bundle
  Future<List<PujaDay>> getPujaDays() async {
    if (_cachedDays != null && _cachedDays!.isNotEmpty) {
      return _cachedDays!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/durga_puja_2026.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> daysJson = data['days'] as List<dynamic>? ?? [];

      _cachedDays = daysJson.map((e) => PujaDay.fromJson(e)).toList();
      return _cachedDays!;
    } catch (e) {
      debugPrint('Error loading local Panjika JSON: $e');
      _cachedDays = _fallbackPujaDays;
      return _cachedDays!;
    }
  }

  /// Get specific PujaDay for a given DateTime
  Future<PujaDay?> getPujaDayByDate(DateTime date) async {
    final days = await getPujaDays();
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return days.firstWhere((d) => d.dateString == dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Hardcoded fallback in case asset bundle loading is ever delayed
  static final List<PujaDay> _fallbackPujaDays = [
    const PujaDay(
      name: 'Mahalaya',
      dateString: '2026-10-10',
      rituals: ['Tarpan', 'Devi Paksha Invocation', 'Chakshu Dan'],
      description:
          'Marks the auspicious beginning of Devi Paksha and Goddess Durga\'s arrival journey to Earth.',
    ),
    const PujaDay(
      name: 'Maha Shashthi',
      dateString: '2026-10-16',
      rituals: ['Bilva Nimantran', 'Kalparambha', 'Bodhon', 'Adhivas'],
      description:
          'The Goddess\'s idol is unveiled to the public for the first time amidst Dhak beats and Bodhon rituals.',
    ),
    const PujaDay(
      name: 'Maha Saptami',
      dateString: '2026-10-17',
      rituals: ['Navapatrika Puja', 'Kola Bou Snan', 'Prana Pratishtha'],
      description:
          'Nine sacred plants symbolizing Durga\'s nine forms are bathed at dawn in the Hooghly river and installed.',
    ),
    const PujaDay(
      name: 'Maha Ashtami',
      dateString: '2026-10-18',
      rituals: ['Pushpanjali', 'Kumari Puja', 'Sandhi Puja (108 Lamps & Lotus)'],
      description:
          'The most sacred day of Durga Puja; Sandhi Puja marks the precise junction between Ashtami and Navami when Mahishasuramardini slays Chanda and Munda.',
    ),
    const PujaDay(
      name: 'Maha Navami',
      dateString: '2026-10-19',
      rituals: ['Navami Havan', 'Maha Arati', 'Bhog Prasad Distribution'],
      description:
          'Final day of grand battle between Durga and Mahishasura, celebrated with holy Havans and evening Dhunuchi Naach.',
    ),
    const PujaDay(
      name: 'Vijaya Dashami',
      dateString: '2026-10-20',
      rituals: ['Dashami Puja', 'Sindoor Khela', 'Durga Visarjan', 'Subho Bijoya Greetings'],
      description:
          'Durga Visarjan — ceremonial immersion of idols in the Hooghly river, marking Goddess Durga\'s return to Kailash.',
    ),
  ];
}
