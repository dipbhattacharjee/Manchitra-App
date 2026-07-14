import 'dart:math';
import '../models/models.dart';

class RouteOptimizer {
  /// Calculate distance in km between two lat/lng points using Haversine formula
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Earth's radius in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// TSP Heuristic: Nearest Neighbor + 2-opt refinement
  static List<Pandal> optimizeRoute(List<Pandal> stops, double startLat, double startLng) {
    if (stops.isEmpty) return [];

    final List<Pandal> unvisited = List.from(stops);
    final List<Pandal> optimized = [];

    double currentLat = startLat;
    double currentLng = startLng;

    // Nearest-Neighbor
    while (unvisited.isNotEmpty) {
      Pandal closest = unvisited.first;
      double minDist = calculateDistance(currentLat, currentLng, closest.latitude, closest.longitude);

      for (final p in unvisited) {
        final dist = calculateDistance(currentLat, currentLng, p.latitude, p.longitude);
        if (dist < minDist) {
          minDist = dist;
          closest = p;
        }
      }

      optimized.add(closest);
      unvisited.remove(closest);
      currentLat = closest.latitude;
      currentLng = closest.longitude;
    }

    // Simple 2-opt optimization
    bool improved = true;
    while (improved) {
      improved = false;
      for (int i = 1; i < optimized.length - 1; i++) {
        for (int j = i + 1; j < optimized.length; j++) {
          final double currentDist = _routeSegmentDistance(optimized, i - 1, i) +
              _routeSegmentDistance(optimized, j, j + 1, endIsLast: j == optimized.length - 1);
          final double swapDist = _routeSegmentDistance(optimized, i - 1, j) +
              _routeSegmentDistance(optimized, i, j + 1, endIsLast: j == optimized.length - 1);

          if (swapDist < currentDist) {
            // Reverse the segment between i and j
            _reverseSegment(optimized, i, j);
            improved = true;
          }
        }
      }
    }

    return optimized;
  }

  static double _routeSegmentDistance(List<Pandal> route, int idx1, int idx2, {bool endIsLast = false}) {
    if (idx1 < 0 || idx2 >= route.length) return 0.0;
    return calculateDistance(route[idx1].latitude, route[idx1].longitude, route[idx2].latitude, route[idx2].longitude);
  }

  static void _reverseSegment(List<Pandal> list, int start, int end) {
    while (start < end) {
      final temp = list[start];
      list[start] = list[end];
      list[end] = temp;
      start++;
      end--;
    }
  }
}
