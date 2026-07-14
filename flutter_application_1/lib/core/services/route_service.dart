import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'route_optimizer.dart';

class HopListManager {
  static final List<Pandal> selectedPandals = [];

  static void add(Pandal pandal) {
    if (!selectedPandals.any((p) => p.id == pandal.id)) {
      selectedPandals.add(pandal);
    }
  }

  static void remove(String id) {
    selectedPandals.removeWhere((p) => p.id == id);
  }

  static void clear() {
    selectedPandals.clear();
  }
}

class RouteService {
  RouteService._();
  static final RouteService instance = RouteService._();

  final _client = Supabase.instance.client;

  /// Generate 3 route variants: Fastest, Shortest, and Walking Friendly
  List<HopRoute> generateRouteVariants(List<Pandal> stops, double startLat, double startLng) {
    if (stops.isEmpty) return [];

    // 1. Optimize stop sequence using TSP Nearest Neighbor + 2-opt
    final List<Pandal> optimizedStops = RouteOptimizer.optimizeRoute(stops, startLat, startLng);

    // 2. Build 3 variants
    return [
      _buildVariant(optimizedStops, RouteType.fastest, startLat, startLng),
      _buildVariant(optimizedStops, RouteType.shortest, startLat, startLng),
      _buildVariant(optimizedStops, RouteType.walkingFriendly, startLat, startLng),
    ];
  }

  HopRoute _buildVariant(List<Pandal> stops, RouteType type, double startLat, double startLng) {
    final List<RouteLeg> legs = [];
    double totalDistance = 0.0;
    int totalTime = 0;

    double currentLat = startLat;
    double currentLng = startLng;
    String currentId = 'start'; // Start location label

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final distance = RouteOptimizer.calculateDistance(currentLat, currentLng, stop.latitude, stop.longitude);
      
      final mode = _suggestTransportMode(distance, type);
      final duration = _calculateDuration(distance, mode);

      legs.add(RouteLeg(
        id: 'leg_${i}_${type.name}',
        fromPandalId: currentId,
        toPandalId: stop.id,
        distanceKm: distance,
        durationMin: duration,
        suggestedMode: mode,
        sequenceOrder: i,
      ));

      totalDistance += distance;
      totalTime += duration;

      // Add 30 minutes viewing time for each pandal stop
      totalTime += 30;

      currentLat = stop.latitude;
      currentLng = stop.longitude;
      currentId = stop.id;
    }

    return HopRoute(
      id: 'route_${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      routeType: type,
      stops: stops,
      legs: legs,
      totalDistanceKm: totalDistance,
      totalTimeMin: totalTime,
    );
  }

  TransportMode _suggestTransportMode(double distanceKm, RouteType type) {
    if (type == RouteType.walkingFriendly) {
      if (distanceKm <= 1.5) {
        return TransportMode.walk;
      }
      // If it is long distance but walking friendly route, suggest Metro as it is traffic-free in Kolkata
      return TransportMode.metro;
    }

    if (type == RouteType.shortest) {
      if (distanceKm <= 0.8) return TransportMode.walk;
      return TransportMode.auto;
    }

    // Fastest (Driving)
    if (distanceKm <= 0.6) return TransportMode.walk;
    if (distanceKm <= 3.0) return TransportMode.auto;
    return TransportMode.cab;
  }

  int _calculateDuration(double distanceKm, TransportMode mode) {
    switch (mode) {
      case TransportMode.walk:
        // Assumes walking speed 4 km/h (15 min/km)
        return (distanceKm * 15).round();
      case TransportMode.metro:
        // Metro speed is fast, but add 10 min platform/boarding overhead
        return 10 + (distanceKm * 2.0).round();
      case TransportMode.auto:
        // Auto speed in traffic (avg 15 km/h, 4 min/km)
        return (distanceKm * 4).round();
      case TransportMode.cab:
        // Cab speed (avg 20 km/h, 3 min/km)
        return (distanceKm * 3).round();
      case TransportMode.train:
        return 15 + (distanceKm * 1.5).round();
    }
  }

  /// Save optimized route to Supabase Route and RouteLeg tables
  Future<void> saveRoute(HopRoute route, {String? userId}) async {
    try {
      final activeUser = _client.auth.currentUser;
      final effectiveUserId = userId ?? activeUser?.id;

      if (effectiveUserId == null) {
        print('RouteService: Cannot save route. No user is logged in.');
        return;
      }

      // 1. Write Route row
      final routeResponse = await _client.from('Route').insert({
        'userId': effectiveUserId,
        'routeType': route.routeType.name.toUpperCase(),
        'totalDistanceKm': route.totalDistanceKm,
        'totalTimeMin': route.totalTimeMin,
      }).select().single();

      final routeId = routeResponse['id'] as String;

      // 2. Write RouteLeg rows
      final List<Map<String, dynamic>> legsToInsert = [];
      for (int i = 0; i < route.legs.length; i++) {
        final leg = route.legs[i];
        legsToInsert.add({
          'routeId': routeId,
          'sequenceOrder': i,
          'fromPandalId': leg.fromPandalId == 'start' ? null : leg.fromPandalId, // Map start to null or first stop
          'toPandalId': leg.toPandalId,
          'distanceKm': leg.distanceKm,
          'durationMin': leg.durationMin,
          'suggestedMode': leg.suggestedMode.name.toUpperCase(),
        });
      }

      await _client.from('RouteLeg').insert(legsToInsert);
      print('RouteService: Route saved to Supabase successfully.');
    } catch (e) {
      print('RouteService saveRoute error: $e');
    }
  }
}
