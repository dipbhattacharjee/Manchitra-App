import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final _client = Supabase.instance.client;

  /// Helper to convert DB category string to PandalCategory enum
  PandalCategory _parseCategory(String? val) {
    if (val == null) return PandalCategory.themeBased;
    switch (val) {
      case 'TRADITIONAL_BAROWARI':
        return PandalCategory.traditionalBarowari;
      case 'THEME_BASED':
        return PandalCategory.themeBased;
      case 'ECO_FRIENDLY':
        return PandalCategory.ecoFriendly;
      case 'COMMUNITY':
        return PandalCategory.community;
      case 'FAMOUS_HERITAGE':
        return PandalCategory.famousHeritage;
      default:
        return PandalCategory.themeBased;
    }
  }

  /// Helper to convert DB crowdLevel string to CrowdLevel enum
  CrowdLevel _parseCrowdLevel(String? val) {
    if (val == null) return CrowdLevel.medium;
    switch (val) {
      case 'LOW':
        return CrowdLevel.low;
      case 'MEDIUM':
        return CrowdLevel.medium;
      case 'HIGH':
        return CrowdLevel.high;
      case 'VERY_HIGH':
        return CrowdLevel.veryHigh;
      default:
        return CrowdLevel.medium;
    }
  }

  /// Map raw DB row to Pandal object
  Pandal _mapRowToPandal(Map<String, dynamic> row, {double? calculatedDistanceKm}) {
    double? distanceKm = calculatedDistanceKm;
    if (row.containsKey('distance_meters') && row['distance_meters'] != null) {
      distanceKm = (row['distance_meters'] as num).toDouble() / 1000.0;
    }

    return Pandal(
      id: row['id'] as String,
      name: row['name'] as String,
      area: row['area'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      ward: row['ward'] as String?,
      committeeName: row['committeeName'] as String?,
      theme: row['theme'] as String?,
      description: row['description'] as String?,
      isFeatured2026: row['isFeatured2026'] as bool? ?? false,
      category: _parseCategory(row['category'] as String?),
      visitStartTime: row['visitStartTime'] as String?,
      visitEndTime: row['visitEndTime'] as String?,
      crowdLevel: _parseCrowdLevel(row['crowdLevel'] as String?),
      rating: 4.5,
      reviewCount: 150,
      photoUrls: const [],
      distanceKm: distanceKm,
    );
  }

  /// Fetch all pandals with optional filter and search criteria
  Future<List<Pandal>> getPandals({
    String? searchQuery,
    String? categoryFilter,
    String? areaFilter,
    bool? featuredOnly,
    double? userLat,
    double? userLng,
  }) async {
    try {
      List<dynamic> rows;

      if (userLat != null && userLng != null) {
        // Use PostGIS RPC to calculate distance and sort
        final response = await _client.rpc(
          'get_nearby_pandals',
          params: {
            'user_lat': userLat,
            'user_lng': userLng,
            'max_dist_meters': 100000.0, // 100km max range
          },
        );
        rows = response as List<dynamic>;
      } else {
        // Regular fetch
        final response = await _client.from('Pandal').select();
        rows = response as List<dynamic>;
      }

      // Convert rows to Pandals
      List<Pandal> pandals = rows.map((r) => _mapRowToPandal(r as Map<String, dynamic>)).toList();

      // Apply client-side filters for search query & custom filters
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        pandals = pandals.where((p) {
          final nameMatch = p.name.toLowerCase().contains(query);
          final areaMatch = p.area.toLowerCase().contains(query);
          final themeMatch = p.theme?.toLowerCase().contains(query) ?? false;
          return nameMatch || areaMatch || themeMatch;
        }).toList();
      }

      if (categoryFilter != null && categoryFilter != 'All') {
        pandals = pandals.where((p) {
          // Compare category label or internal label
          return p.category.label == categoryFilter;
        }).toList();
      }

      if (areaFilter != null && areaFilter != 'All') {
        pandals = pandals.where((p) => p.area.toLowerCase().contains(areaFilter.toLowerCase())).toList();
      }

      if (featuredOnly == true) {
        pandals = pandals.where((p) => p.isFeatured2026).toList();
      }

      return pandals;
    } catch (e) {
      print('Supabase getPandals error: $e');
      return [];
    }
  }
}
