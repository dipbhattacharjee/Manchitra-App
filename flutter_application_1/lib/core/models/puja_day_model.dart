import 'package:flutter/foundation.dart';

/// ============================================================
/// MANCHITRA — Puja Day Panjika Model
/// Represents a Durga Puja ritual day (Mahalaya to Vijaya Dashami).
/// ============================================================

@immutable
class PujaDay {
  final String name;
  final String dateString; // "yyyy-MM-dd"
  final List<String> rituals;
  final String description;

  const PujaDay({
    required this.name,
    required this.dateString,
    required this.rituals,
    required this.description,
  });

  DateTime get date => DateTime.parse(dateString);

  factory PujaDay.fromJson(Map<String, dynamic> json) {
    return PujaDay(
      name: json['name'] as String? ?? '',
      dateString: json['date'] as String? ?? '',
      rituals: (json['rituals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': dateString,
      'rituals': rituals,
      'description': description,
    };
  }
}
