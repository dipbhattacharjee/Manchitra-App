import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class GithubPandalService {
  static const String jsonUrl =
      'https://raw.githubusercontent.com/dbaidya811/map_server/refs/heads/main/Must-visit.json';
  static const String imageBaseUrl =
      'https://raw.githubusercontent.com/dbaidya811/map_server/refs/heads/main/';

  /// Fetches Pandals directly from GitHub Raw CDN endpoint
  static Future<List<Pandal>> fetchPandalsFromGitHub() async {
    try {
      final response = await http.get(Uri.parse(jsonUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('Fetched ${data.length} locations from GitHub API.');

        return data.map((jsonItem) {
          final List<String> localImages =
              (jsonItem['local_images'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];

          // Combine imageBaseUrl + local_images path
          final List<String> liveImageUrls = localImages
              .map((path) => imageBaseUrl + path)
              .toList();

          final String name = jsonItem['name'] as String? ?? 'Pandal';

          return Pandal(
            id: jsonItem['id'] as String? ?? UniqueKey().toString(),
            name: name,
            area: _deriveArea(name),
            latitude: (jsonItem['latitude'] as num).toDouble(),
            longitude: (jsonItem['longitude'] as num).toDouble(),
            description: jsonItem['description'] as String?,
            committeeName: name,
            isFeatured2026: true,
            category: PandalCategory.themeBased,
            visitStartTime: '09:00',
            visitEndTime: '23:59',
            crowdLevel: CrowdLevel.medium,
            rating: 4.6,
            reviewCount: 120,
            photoUrls: liveImageUrls,
            coverPhotoUrl: liveImageUrls.isNotEmpty ? liveImageUrls.first : null,
          );
        }).toList();
      } else {
        debugPrint('Failed to fetch GitHub JSON: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error loading data from GitHub API: $e');
      return [];
    }
  }

  static String _deriveArea(String name) {
    if (name.contains('Dum Dum')) return 'Dum Dum Park';
    if (name.contains('Hatibagan')) return 'Hatibagan';
    if (name.contains('Kumartuli')) return 'Kumartuli';
    if (name.contains('Kashi Bose')) return 'Shyambazar';
    if (name.contains('College Square')) return 'Central Kolkata';
    if (name.contains('Santosh Mitra')) return 'Bowbazar';
    if (name.contains('Ultadanga')) return 'Ultadanga';
    if (name.contains('Beliaghata') || name.contains('Beleghata')) return 'Beliaghata';
    if (name.contains('Sandhani')) return 'Beliaghata';
    if (name.contains('Ekdalia')) return 'Gariahat';
    if (name.contains('Singhi Park')) return 'Ballygunge';
    if (name.contains('Hindusthan Park')) return 'Gariahat';
    if (name.contains('Tridhara')) return 'Ballygunge';
    if (name.contains('Deshapriya')) return 'South Kolkata';
    if (name.contains('Maddox')) return 'Ballygunge';
    if (name.contains('Bhowanipur')) return 'Bhowanipur';
    if (name.contains('Chetla')) return 'Chetla';
    if (name.contains('Suruchi')) return 'New Alipore';
    if (name.contains('Mudiali')) return 'Tollygunge';
    if (name.contains('95 Pally')) return 'Jodhpur Park';
    if (name.contains('21 Pally')) return 'Ballygunge';
    if (name.contains('Rajdanga')) return 'Kasba';
    if (name.contains('Behala Nutan')) return 'Behala';
    if (name.contains('Buroshibtala')) return 'Behala';
    if (name.contains('Barisha')) return 'Barisha';
    if (name.contains('Ajeya')) return 'Haridevpur';
    if (name.contains('Naktala')) return 'Naktala';
    if (name.contains('Labony') || name.contains('EC Block')) return 'Salt Lake';
    return 'Kolkata';
  }
}
