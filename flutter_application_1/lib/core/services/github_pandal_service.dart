import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class GithubPandalService {
  static const String repoContentsApi =
      'https://api.github.com/repos/dbaidya811/map_server/contents';
  static const String imageBaseUrl =
      'https://raw.githubusercontent.com/dbaidya811/map_server/refs/heads/main/';

  static const List<String> defaultCategoryFiles = [
    'Alipore_Port_area.json',
    'Bidhannagar_s.json',
    'Central_Kolkata.json',
    'Must-visit.json',
    'North_Kolkata.json',
    'Northern_Suburb-Kolkata.json',
    'South_Kolkata.json',
    'Southern_Suburb_Kolkata.json',
  ];

  /// Fetches all Pandals across multiple categories from GitHub API / Raw CDN
  static Future<List<Pandal>> fetchPandalsFromGitHub() async {
    try {
      List<String> filesToFetch = defaultCategoryFiles;

      // Try discovering files dynamically via GitHub Repo API
      try {
        final apiRes = await http.get(
          Uri.parse(repoContentsApi),
          headers: {'User-Agent': 'FlutterMapApp'},
        );
        if (apiRes.statusCode == 200) {
          final List<dynamic> contents = json.decode(apiRes.body);
          final jsonFiles = contents
              .where((item) =>
                  item['type'] == 'file' &&
                  (item['name'] as String).endsWith('.json') &&
                  item['name'] != 'package.json' &&
                  item['name'] != 'package-lock.json')
              .map((item) => item['name'] as String)
              .toList();

          if (jsonFiles.isNotEmpty) {
            filesToFetch = jsonFiles;
          }
        }
      } catch (apiErr) {
        debugPrint('GitHub contents API fetch failed, using fallback list: $apiErr');
      }

      final Map<String, Map<String, dynamic>> uniquePandalsMap = {};
      final Map<String, List<String>> pandalImagesMap = {};
      final Map<String, bool> pandalFeaturedMap = {};
      final Map<String, String> pandalSourceFileMap = {};

      // Fetch all category JSON files concurrently
      final responses = await Future.wait(
        filesToFetch.map((fileName) async {
          try {
            final url = imageBaseUrl + fileName;
            final res = await http.get(Uri.parse(url));
            if (res.statusCode == 200) {
              final List<dynamic> data = json.decode(res.body);
              return {'file': fileName, 'data': data};
            }
          } catch (e) {
            debugPrint('Failed to fetch $fileName from GitHub: $e');
          }
          return null;
        }),
      );

      for (final item in responses) {
        if (item == null) continue;
        final fileName = item['file'] as String;
        final data = item['data'] as List<dynamic>;

        for (final jsonItem in data) {
          final String? rawName = jsonItem['name'] as String?;
          if (rawName == null || rawName.trim().isEmpty) continue;

          final normKey = rawName.trim().toLowerCase();

          final List<String> localImages =
              (jsonItem['local_images'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];

          final List<String> liveUrls =
              localImages.map((path) => imageBaseUrl + path).toList();

          final bool isMustVisit = fileName.contains('Must-visit');

          if (!uniquePandalsMap.containsKey(normKey)) {
            uniquePandalsMap[normKey] = jsonItem as Map<String, dynamic>;
            pandalImagesMap[normKey] = liveUrls;
            pandalFeaturedMap[normKey] = isMustVisit;
            pandalSourceFileMap[normKey] = fileName;
          } else {
            // Update featured status if listed in Must-visit
            if (isMustVisit) {
              pandalFeaturedMap[normKey] = true;
            }
            // Merge description if current item has a longer description
            final currentDesc = jsonItem['description'] as String? ?? '';
            final existingDesc = uniquePandalsMap[normKey]!['description'] as String? ?? '';
            if (currentDesc.length > existingDesc.length) {
              uniquePandalsMap[normKey]!['description'] = currentDesc;
            }
            // Combine photos
            final existingPhotos = pandalImagesMap[normKey] ?? [];
            final combinedPhotos = {...existingPhotos, ...liveUrls}.toList();
            pandalImagesMap[normKey] = combinedPhotos;
          }
        }
      }

      debugPrint('Fetched ${uniquePandalsMap.length} unique Pandals across ${filesToFetch.length} category files.');

      return uniquePandalsMap.entries.map((entry) {
        final normKey = entry.key;
        final jsonItem = entry.value;
        final name = jsonItem['name'] as String? ?? 'Pandal';
        final photoUrls = pandalImagesMap[normKey] ?? [];
        final isFeatured = pandalFeaturedMap[normKey] ?? false;
        final fileName = pandalSourceFileMap[normKey] ?? '';

        return Pandal(
          id: jsonItem['id'] as String? ?? UniqueKey().toString(),
          name: name,
          area: _deriveArea(name, fileName),
          latitude: (jsonItem['latitude'] as num).toDouble(),
          longitude: (jsonItem['longitude'] as num).toDouble(),
          description: jsonItem['description'] as String?,
          committeeName: name,
          isFeatured2026: isFeatured,
          category: PandalCategory.themeBased,
          visitStartTime: '09:00',
          visitEndTime: '23:59',
          crowdLevel: CrowdLevel.medium,
          rating: 4.6,
          reviewCount: 120,
          photoUrls: photoUrls,
          coverPhotoUrl: photoUrls.isNotEmpty ? photoUrls.first : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading data from GitHub API: $e');
      return [];
    }
  }

  static String _deriveArea(String name, String fileName) {
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
    if (name.contains('Labony') || name.contains('EC Block') || name.contains('FD Block') || name.contains('BJ Block')) return 'Salt Lake';

    // Fallback to filename region
    if (fileName.contains('Alipore')) return 'Alipore';
    if (fileName.contains('Bidhannagar')) return 'Salt Lake';
    if (fileName.contains('Central')) return 'Central Kolkata';
    if (fileName.contains('North_Kolkata')) return 'North Kolkata';
    if (fileName.contains('Northern_Suburb')) return 'Northern Suburbs';
    if (fileName.contains('South_Kolkata')) return 'South Kolkata';
    if (fileName.contains('Southern_Suburb')) return 'Southern Suburbs';

    return 'Kolkata';
  }
}
