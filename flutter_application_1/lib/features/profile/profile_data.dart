import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/models.dart';
import '../../core/models/saved_route_model.dart';

class ProfileData {
  static String name = 'Shubho Sharodiya';
  static String email = 'shubho@pandalhop.ai';
  static String phone = '+91 98765 43210';
  static String bio = 'Urban traveler and cultural enthusiast. Exploring the vibrant heart of Kolkata one pandal at a time.';
  static String location = 'Kolkata, WB';
  static String photoUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';

  static final List<Pandal> favoritePandals = [];
  static final List<SavedRoutePlan> savedRoutes = [];

  static void addFavorite(Pandal pandal) {
    if (!favoritePandals.any((p) => p.id == pandal.id)) {
      favoritePandals.add(pandal);
    }
  }

  static void removeFavorite(String id) {
    favoritePandals.removeWhere((p) => p.id == id);
  }

  static bool isFavorite(String id) {
    return favoritePandals.any((p) => p.id == id);
  }

  static void addOrUpdateSavedRoute(SavedRoutePlan plan) {
    final idx = savedRoutes.indexWhere((r) => r.pujaDay.toLowerCase() == plan.pujaDay.toLowerCase());
    if (idx != -1) {
      savedRoutes[idx] = plan;
    } else {
      savedRoutes.add(plan);
    }
  }

  static Future<bool> saveRoutePlanToProfile({
    required String pujaDay,
    required DateTime date,
    required List<Pandal> pandals,
  }) async {
    final now = DateTime.now();
    String userId = 'guest_user';
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) userId = user.id;
    } catch (_) {}

    final routeId = 'route_${pujaDay.toLowerCase()}_${date.year}';
    final stops = List.generate(pandals.length, (i) {
      return PlannedStopItem(
        pandalId: pandals[i].id,
        name: pandals[i].name,
        order: i + 1,
        plannedTime: '${9 + i}:00 AM',
        type: 'pandal',
      );
    });

    final plan = SavedRoutePlan(
      id: routeId,
      userId: userId,
      pujaDay: pujaDay,
      date: date,
      stops: stops,
      createdAt: now,
      updatedAt: now,
    );

    addOrUpdateSavedRoute(plan);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('saved_routes').upsert({
          'user_id': user.id,
          'puja_day': pujaDay,
          'date': date.toIso8601String(),
          'stops': stops.map((s) => s.toJson()).toList(),
          'updated_at': now.toIso8601String(),
        }, onConflict: 'user_id,puja_day');
      }
    } catch (e) {
      debugPrint('Supabase saved_routes note: $e');
    }

    return true;
  }
}
