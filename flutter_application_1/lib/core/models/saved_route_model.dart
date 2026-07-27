import 'package:flutter/foundation.dart';

/// Model representing a user's saved route plan for a specific Puja day
class SavedRoutePlan {
  final String id;
  final String userId;
  final String pujaDay; // e.g. "Ashtami", "Panchami", "Saptami"
  final DateTime date;
  final List<PlannedStopItem> stops;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedRoutePlan({
    required this.id,
    required this.userId,
    required this.pujaDay,
    required this.date,
    required this.stops,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'puja_day': pujaDay,
        'date': date.toIso8601String(),
        'stops': stops.map((s) => s.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory SavedRoutePlan.fromJson(Map<String, dynamic> json) {
    return SavedRoutePlan(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      pujaDay: json['puja_day'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map((e) => PlannedStopItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PlannedStopItem {
  final String pandalId;
  final String name;
  final int order;
  final String plannedTime;
  final String type; // 'pandal' | 'restaurant'

  PlannedStopItem({
    required this.pandalId,
    required this.name,
    required this.order,
    required this.plannedTime,
    this.type = 'pandal',
  });

  Map<String, dynamic> toJson() => {
        'pandal_id': pandalId,
        'name': name,
        'order': order,
        'planned_time': plannedTime,
        'type': type,
      };

  factory PlannedStopItem.fromJson(Map<String, dynamic> json) {
    return PlannedStopItem(
      pandalId: json['pandal_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      plannedTime: json['planned_time'] as String? ?? '',
      type: json['type'] as String? ?? 'pandal',
    );
  }
}
