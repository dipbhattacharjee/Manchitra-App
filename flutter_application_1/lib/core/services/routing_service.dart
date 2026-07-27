import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/map_config.dart';
import '../utils/navigation_utils.dart';

/// ============================================================
/// MANCHITRA — Routing Models & OSRM Service
/// ============================================================

/// Represents a single turn-by-turn navigation maneuver step.
class NavigationStep {
  final String instruction;
  final String maneuverType;
  final String maneuverModifier;
  final double distanceMeters;
  final double durationSeconds;
  final LatLng location;

  const NavigationStep({
    required this.instruction,
    required this.maneuverType,
    required this.maneuverModifier,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final type = maneuver['type'] as String? ?? 'straight';
    final modifier = maneuver['modifier'] as String? ?? '';
    final locationList = (maneuver['location'] as List<dynamic>?)?.cast<num>();

    final LatLng loc = (locationList != null && locationList.length >= 2)
        ? LatLng(locationList[1].toDouble(), locationList[0].toDouble())
        : const LatLng(0, 0);

    final distance = (json['distance'] as num?)?.toDouble() ?? 0.0;
    final duration = (json['duration'] as num?)?.toDouble() ?? 0.0;
    final name = json['name'] as String? ?? '';

    final instructionText = _generateInstruction(type, modifier, name);

    return NavigationStep(
      instruction: instructionText,
      maneuverType: type,
      maneuverModifier: modifier,
      distanceMeters: distance,
      durationSeconds: duration,
      location: loc,
    );
  }

  static String _generateInstruction(String type, String modifier, String streetName) {
    final street = streetName.isNotEmpty ? ' onto $streetName' : '';
    switch (type) {
      case 'depart':
        return 'Head towards your destination';
      case 'arrive':
        return 'Arrive at Durga Puja pandal!';
      case 'turn':
        if (modifier.contains('left')) return 'Turn left$street';
        if (modifier.contains('right')) return 'Turn right$street';
        if (modifier.contains('slight left')) return 'Slight left$street';
        if (modifier.contains('slight right')) return 'Slight right$street';
        if (modifier.contains('sharp left')) return 'Sharp left$street';
        if (modifier.contains('sharp right')) return 'Sharp right$street';
        return 'Turn$street';
      case 'end of road':
        return 'At the end of the road, turn ${modifier.replaceAll('_', ' ')}$street';
      case 'fork':
        return 'Take the fork ${modifier.replaceAll('_', ' ')}$street';
      case 'roundabout':
      case 'rotary':
        return 'Enter roundabout and exit$street';
      case 'continue':
      case 'new name':
      case 'straight':
      default:
        return 'Continue straight$street';
    }
  }
}

/// Represents the complete route calculated from OSRM.
class NavigationRoute {
  final List<LatLng> points;
  final double totalDistanceMeters;
  final double totalDurationSeconds;
  final List<NavigationStep> steps;

  const NavigationRoute({
    required this.points,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.steps,
  });

  String get formattedDistance {
    if (totalDistanceMeters >= 1000) {
      return '${(totalDistanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${totalDistanceMeters.round()} m';
  }

  String get formattedDuration {
    final minutes = (totalDurationSeconds / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remMin = minutes % 60;
      return '${hours}h ${remMin}m';
    }
    return '$minutes min';
  }
}

/// Abstract interface to isolate routing provider implementation.
abstract class RoutingService {
  Future<NavigationRoute?> getRoute({
    required LatLng start,
    required LatLng destination,
  });

  Future<NavigationRoute?> getMultiStopRoute(List<LatLng> waypoints);
}

/// Concrete OSRM routing service implementation using the OSRM REST API.
class OsrmRoutingService implements RoutingService {
  final String baseUrl;
  final http.Client _httpClient;

  OsrmRoutingService({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? MapConfig.osrmBaseUrl,
        _httpClient = httpClient ?? http.Client();

  @override
  Future<NavigationRoute?> getRoute({
    required LatLng start,
    required LatLng destination,
  }) async {
    final String url =
        '$baseUrl/route/v1/driving/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?steps=true&geometries=geojson&overview=full';

    try {
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {'User-Agent': MapConfig.userAgentPackageName},
      );

      if (response.statusCode != 200) {
        debugPrint('OSRM routing request failed with status: ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
        debugPrint('OSRM routing response returned no valid route: ${data['code']}');
        return null;
      }

      final routeData = data['routes'][0] as Map<String, dynamic>;
      List<LatLng> points = [];
      final geom = routeData['geometry'];
      if (geom is Map<String, dynamic> && geom['coordinates'] != null) {
        final coordsList = geom['coordinates'] as List<dynamic>;
        points = coordsList.map((c) {
          final list = c as List<dynamic>;
          return LatLng(list[1].toDouble(), list[0].toDouble());
        }).toList();
      } else if (geom is String) {
        points = NavigationUtils.decodePolyline(geom);
      }

      final totalDistance = (routeData['distance'] as num).toDouble();
      final totalDuration = (routeData['duration'] as num).toDouble();

      final List<NavigationStep> steps = [];
      final legs = routeData['legs'] as List<dynamic>?;

      if (legs != null && legs.isNotEmpty) {
        final legSteps = legs[0]['steps'] as List<dynamic>?;
        if (legSteps != null) {
          for (final stepJson in legSteps) {
            steps.add(NavigationStep.fromJson(stepJson as Map<String, dynamic>));
          }
        }
      }

      return NavigationRoute(
        points: points,
        totalDistanceMeters: totalDistance,
        totalDurationSeconds: totalDuration,
        steps: steps,
      );
    } catch (e) {
      debugPrint('Error fetching OSRM route: $e');
      return null;
    }
  }

  @override
  Future<NavigationRoute?> getMultiStopRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    final coords = waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
    final String url =
        '$baseUrl/route/v1/driving/$coords?steps=true&geometries=geojson&overview=full';

    try {
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {'User-Agent': MapConfig.userAgentPackageName},
      );

      if (response.statusCode != 200) {
        debugPrint('OSRM multi-stop routing failed: ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
        return null;
      }

      final routeData = data['routes'][0] as Map<String, dynamic>;
      List<LatLng> points = [];
      final geom = routeData['geometry'];
      if (geom is Map<String, dynamic> && geom['coordinates'] != null) {
        final coordsList = geom['coordinates'] as List<dynamic>;
        points = coordsList.map((c) {
          final list = c as List<dynamic>;
          return LatLng(list[1].toDouble(), list[0].toDouble());
        }).toList();
      } else if (geom is String) {
        points = NavigationUtils.decodePolyline(geom);
      }

      final totalDistance = (routeData['distance'] as num).toDouble();
      final totalDuration = (routeData['duration'] as num).toDouble();

      final List<NavigationStep> steps = [];
      final legs = routeData['legs'] as List<dynamic>?;
      if (legs != null) {
        for (final leg in legs) {
          final legSteps = leg['steps'] as List<dynamic>?;
          if (legSteps != null) {
            for (final stepJson in legSteps) {
              steps.add(NavigationStep.fromJson(stepJson as Map<String, dynamic>));
            }
          }
        }
      }

      return NavigationRoute(
        points: points,
        totalDistanceMeters: totalDistance,
        totalDurationSeconds: totalDuration,
        steps: steps,
      );
    } catch (e) {
      debugPrint('Error fetching OSRM multi-stop route: $e');
      return null;
    }
  }
}
