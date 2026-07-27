import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// ============================================================
/// MANCHITRA — Navigation & Polyline Geometry Utilities
/// ============================================================

class NavigationUtils {
  NavigationUtils._();

  static const double earthRadiusMeters = 6371000.0;

  /// Decodes an OSRM/Google encoded polyline string (5 decimal precision)
  /// into a list of LatLng coordinates.
  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Calculates Haversine distance in meters between two LatLng points.
  static double distanceMeters(LatLng p1, LatLng p2) {
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLng = _toRadians(p2.longitude - p1.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(p1.latitude)) *
            math.cos(_toRadians(p2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Calculates initial bearing in degrees (0..360) from point [p1] to [p2].
  static double calculateBearing(LatLng p1, LatLng p2) {
    final lat1 = _toRadians(p1.latitude);
    final lat2 = _toRadians(p2.latitude);
    final dLng = _toRadians(p2.longitude - p1.longitude);

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final radians = math.atan2(y, x);
    final degrees = (radians * 180 / math.pi + 360) % 360;
    return degrees;
  }

  /// Calculates the shortest distance in meters from a point [point] to a polyline [polyline].
  /// Used for on-path tolerance checks in turn-by-turn navigation.
  static double distanceToPolyline(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) return distanceMeters(point, polyline.first);

    double minDistance = double.infinity;

    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];
      final dist = _distanceToSegment(point, p1, p2);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }

    return minDistance;
  }

  /// Finds the closest snapped point on the [polyline] from current user location [point].
  static LatLng snapToPolyline(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return point;
    if (polyline.length == 1) return polyline.first;

    double minDistance = double.infinity;
    LatLng closestPoint = polyline.first;

    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];
      final candidate = _closestPointOnSegment(point, p1, p2);
      final dist = distanceMeters(point, candidate);

      if (dist < minDistance) {
        minDistance = dist;
        closestPoint = candidate;
      }
    }

    return closestPoint;
  }

  /// Calculates distance from point [p] to segment between [a] and [b]
  static double _distanceToSegment(LatLng p, LatLng a, LatLng b) {
    final closest = _closestPointOnSegment(p, a, b);
    return distanceMeters(p, closest);
  }

  /// Projects point [p] onto segment [a]-[b]
  static LatLng _closestPointOnSegment(LatLng p, LatLng a, LatLng b) {
    final l2 = math.pow(a.latitude - b.latitude, 2) + math.pow(a.longitude - b.longitude, 2);
    if (l2 == 0) return a;

    double t = ((p.latitude - a.latitude) * (b.latitude - a.latitude) +
            (p.longitude - a.longitude) * (b.longitude - a.longitude)) /
        l2;

    t = t.clamp(0.0, 1.0);

    return LatLng(
      a.latitude + t * (b.latitude - a.latitude),
      a.longitude + t * (b.longitude - a.longitude),
    );
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;
}
