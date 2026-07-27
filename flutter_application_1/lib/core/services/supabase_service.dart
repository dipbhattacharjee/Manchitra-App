import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'route_optimizer.dart';

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
  Pandal _mapRowToPandal(
    Map<String, dynamic> row, {
    double? calculatedDistanceKm,
    List<String> photoUrls = const [],
    String? coverPhotoUrl,
  }) {
    double? distanceKm = calculatedDistanceKm;
    if (row.containsKey('distance_meters') && row['distance_meters'] != null) {
      distanceKm = (row['distance_meters'] as num).toDouble() / 1000.0;
    }

    String? resolvedCoverUrl = coverPhotoUrl;
    if (resolvedCoverUrl == null || resolvedCoverUrl.trim().isEmpty) {
      if (photoUrls.isNotEmpty && photoUrls.first.trim().isNotEmpty) {
        resolvedCoverUrl = photoUrls.first;
      } else {
        final cat = _parseCategory(row['category'] as String?);
        if (cat == PandalCategory.famousHeritage || (row['name'] as String).toLowerCase().contains('bari')) {
          resolvedCoverUrl = 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg';
        } else {
          resolvedCoverUrl = 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg';
        }
      }
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
      photoUrls: photoUrls,
      coverPhotoUrl: resolvedCoverUrl,
      distanceKm: distanceKm,
    );
  }

  /// Add a new photo for a Pandal in the Supabase database
  Future<bool> addPandalPhoto(String pandalId, String url, {bool isCover = false}) async {
    try {
      final id = _generateUuid();
      await _client.from('PandalPhoto').insert({
        'id': id,
        'pandalId': pandalId,
        'url': url,
        'isCover': isCover,
      });
      return true;
    } catch (e) {
      debugPrint('Supabase addPandalPhoto error: $e');
      return false;
    }
  }

  /// Upload user photo to pandal_user_photos table with status='pending'
  Future<bool> addUserPhoto({
    required String pandalId,
    required String imageUrl,
    String? caption,
  }) async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id ?? _generateUuid();
      await _client.from('pandal_user_photos').insert({
        'pandal_id': pandalId,
        'user_id': userId,
        'image_url': imageUrl,
        'caption': caption,
        'status': 'pending',
      });
      return true;
    } catch (e) {
      debugPrint('Supabase addUserPhoto error: $e');
      return addPandalPhoto(pandalId, imageUrl);
    }
  }

  /// Fetch approved user photos for a given pandal
  Future<List<String>> getApprovedUserPhotos(String pandalId) async {
    try {
      final List<dynamic> response = await _client
          .from('pandal_user_photos')
          .select('image_url')
          .eq('pandal_id', pandalId)
          .eq('status', 'approved');

      return response.map((row) => row['image_url'] as String).toList();
    } catch (e) {
      debugPrint('Supabase getApprovedUserPhotos error: $e');
      return [];
    }
  }

  /// Generates a RFC4122 v4 compliant UUID in pure Dart
  String _generateUuid() {
    final random = math.Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // set version 4
    values[8] = (values[8] & 0x3f) | 0x80; // set variant 10
    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
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
        try {
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
        } catch (rpcError) {
          debugPrint('Supabase RPC get_nearby_pandals failed, falling back to regular fetch: $rpcError');
          final response = await _client.from('Pandal').select();
          rows = response as List<dynamic>;
        }
      } else {
        // Regular fetch
        final response = await _client.from('Pandal').select();
        rows = response as List<dynamic>;
      }

      // Fetch all photos from PandalPhoto table
      List<dynamic> photosList = [];
      try {
        final photoResponse = await _client.from('PandalPhoto').select();
        photosList = photoResponse as List<dynamic>;
      } catch (e) {
        debugPrint('Supabase fetch PandalPhoto error: $e');
      }

      // Group photos by pandalId
      final Map<String, List<String>> photosMap = {};
      final Map<String, String> coverMap = {};
      for (var photo in photosList) {
        final pId = photo['pandalId'] as String;
        final url = photo['url'] as String;
        final isCover = photo['isCover'] as bool? ?? false;
        photosMap.putIfAbsent(pId, () => []).add(url);
        if (isCover) {
          coverMap[pId] = url;
        }
      }

      // Convert rows to Pandals
      List<Pandal> pandals = rows.map((r) {
        final pId = r['id'] as String;
        double? clientDistance;
        if (userLat != null && userLng != null && !r.containsKey('distance_meters')) {
          clientDistance = RouteOptimizer.calculateDistance(
            userLat,
            userLng,
            (r['latitude'] as num).toDouble(),
            (r['longitude'] as num).toDouble(),
          );
        }
        return _mapRowToPandal(
          r as Map<String, dynamic>,
          calculatedDistanceKm: clientDistance,
          photoUrls: photosMap[pId] ?? const [],
          coverPhotoUrl: coverMap[pId],
        );
      }).toList();

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
      debugPrint('Supabase getPandals error: $e');
      return [];
    }
  }
}
