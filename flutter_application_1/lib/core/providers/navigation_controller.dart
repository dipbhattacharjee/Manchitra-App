import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import '../config/map_config.dart';
import '../models/models.dart';
import '../services/routing_service.dart';
import '../utils/navigation_utils.dart';

/// ============================================================
/// MANCHITRA — Navigation Controller & Turn-by-Turn Engine
/// ============================================================

class NavigationController extends ChangeNotifier {
  final RoutingService _routingService;

  NavigationController({RoutingService? routingService})
      : _routingService = routingService ?? OsrmRoutingService() {
    _initCompassListener();
  }

  // Active Single Destination State
  bool _isNavigating = false;
  bool _isRerouting = false;
  Pandal? _destinationPandal;
  NavigationRoute? _currentRoute;
  int _currentStepIndex = 0;

  // Multi-Stop Route State
  bool _isMultiStopMode = false;
  List<Pandal> _waypoints = [];
  int _currentWaypointIndex = 0;
  bool _isHopCompleted = false;

  // Location & Heading State
  Position? _rawUserPosition;
  LatLng? _snappedUserPosition;
  double _compassHeading = 0.0;
  DateTime? _lastRerouteTime;

  // Streams
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Getters
  bool get isNavigating => _isNavigating;
  bool get isRerouting => _isRerouting;
  Pandal? get destinationPandal => _destinationPandal;
  NavigationRoute? get currentRoute => _currentRoute;
  int get currentStepIndex => _currentStepIndex;

  bool get isMultiStopMode => _isMultiStopMode;
  bool get isHopCompleted => _isHopCompleted;
  int get currentWaypointIndex => _currentWaypointIndex;
  int get totalWaypoints => _waypoints.length;
  List<Pandal> get waypoints => _waypoints;

  Position? get rawUserPosition => _rawUserPosition;
  LatLng? get userLocation =>
      _snappedUserPosition ??
      (_rawUserPosition != null
          ? LatLng(_rawUserPosition!.latitude, _rawUserPosition!.longitude)
          : null);
  double get compassHeading => _compassHeading;

  NavigationStep? get currentStep {
    if (_currentRoute == null || _currentRoute!.steps.isEmpty) return null;
    if (_currentStepIndex < _currentRoute!.steps.length) {
      return _currentRoute!.steps[_currentStepIndex];
    }
    return _currentRoute!.steps.last;
  }

  NavigationStep? get nextStep {
    if (_currentRoute == null || _currentRoute!.steps.isEmpty) return null;
    if (_currentStepIndex + 1 < _currentRoute!.steps.length) {
      return _currentRoute!.steps[_currentStepIndex + 1];
    }
    return null;
  }

  double get distanceToNextStepMeters {
    final loc = userLocation;
    final step = currentStep;
    if (loc == null || step == null) return 0.0;
    return NavigationUtils.distanceMeters(loc, step.location);
  }

  double get totalRemainingDistanceMeters {
    final loc = userLocation;
    if (loc == null || _currentRoute == null || _currentRoute!.points.isEmpty) {
      return 0.0;
    }
    return NavigationUtils.distanceToPolyline(loc, _currentRoute!.points);
  }

  double get totalRemainingDurationSeconds {
    final distanceMeters = totalRemainingDistanceMeters;
    const avgSpeedMetersPerSec = (15.0 * 1000.0) / 3600.0;
    return distanceMeters / avgSpeedMetersPerSec;
  }

  String get etaFormatted {
    final remainingSec = totalRemainingDurationSeconds;
    final arrivalTime = DateTime.now().add(Duration(seconds: remainingSec.round()));
    final hour = arrivalTime.hour > 12 ? arrivalTime.hour - 12 : (arrivalTime.hour == 0 ? 12 : arrivalTime.hour);
    final minute = arrivalTime.minute.toString().padLeft(2, '0');
    final period = arrivalTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get formattedDistanceRemaining {
    final dist = totalRemainingDistanceMeters;
    if (dist >= 1000) {
      return '${(dist / 1000).toStringAsFixed(1)} km';
    }
    return '${dist.round()} m';
  }

  String get formattedDurationRemaining {
    final min = (totalRemainingDurationSeconds / 60).round();
    if (min >= 60) {
      return '${min ~/ 60}h ${min % 60}m';
    }
    return '$min min';
  }

  void _initCompassListener() {
    try {
      _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
        if (event.heading != null) {
          _compassHeading = event.heading!;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Compass listener init error: $e');
    }
  }

  /// Start single-destination navigation
  Future<bool> startNavigation(Pandal pandal, Position startPos) async {
    _isMultiStopMode = false;
    _waypoints = [];
    _isHopCompleted = false;
    _destinationPandal = pandal;
    _rawUserPosition = startPos;
    _isRerouting = true;
    notifyListeners();

    final startLatLng = LatLng(startPos.latitude, startPos.longitude);
    final destLatLng = LatLng(pandal.latitude, pandal.longitude);

    final route = await _routingService.getRoute(
      start: startLatLng,
      destination: destLatLng,
    );

    _isRerouting = false;

    if (route == null || route.points.isEmpty) {
      debugPrint('Failed to calculate route to ${pandal.name}');
      notifyListeners();
      return false;
    }

    _currentRoute = route;
    _currentStepIndex = 0;
    _isNavigating = true;
    _snappedUserPosition = NavigationUtils.snapToPolyline(startLatLng, route.points);

    _startPositionStream();
    notifyListeners();
    return true;
  }

  /// Start multi-stop sequential navigation across waypoints
  Future<bool> startMultiStopNavigation(List<Pandal> waypoints, Position startPos) async {
    if (waypoints.isEmpty) return false;

    _isMultiStopMode = true;
    _waypoints = waypoints;
    _currentWaypointIndex = 0;
    _isHopCompleted = false;

    return await _navigateToCurrentWaypoint(startPos);
  }

  /// Advance to next stop in multi-stop route
  Future<bool> advanceToNextStop() async {
    if (!_isMultiStopMode || _waypoints.isEmpty) return false;

    if (_currentWaypointIndex + 1 < _waypoints.length) {
      _currentWaypointIndex++;
      final currentPos = _rawUserPosition ??
          Position(
            latitude: MapConfig.defaultLat,
            longitude: MapConfig.defaultLng,
            timestamp: DateTime.now(),
            accuracy: 10,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
      return await _navigateToCurrentWaypoint(currentPos);
    } else {
      // Completed all stops!
      _isHopCompleted = true;
      stopNavigation();
      notifyListeners();
      return true;
    }
  }

  Future<bool> _navigateToCurrentWaypoint(Position startPos) async {
    final currentTarget = _waypoints[_currentWaypointIndex];
    return await startNavigation(currentTarget, startPos);
  }

  /// Stop active turn-by-turn navigation session
  void stopNavigation() {
    _isNavigating = false;
    _isRerouting = false;
    _currentRoute = null;
    _destinationPandal = null;
    _currentStepIndex = 0;
    _snappedUserPosition = null;
    _lastRerouteTime = null;

    _isMultiStopMode = false;
    _waypoints = [];
    _currentWaypointIndex = 0;
    _isHopCompleted = false;

    _positionSubscription?.cancel();
    _positionSubscription = null;
    notifyListeners();
  }

  /// Manual route query without entering active turn-by-turn navigation mode
  Future<NavigationRoute?> fetchRouteOnly(LatLng start, LatLng destination) async {
    return await _routingService.getRoute(start: start, destination: destination);
  }

  /// Fetch road-snapped multi-stop route polyline for previews
  Future<NavigationRoute?> fetchMultiStopRoute(List<LatLng> points) async {
    return await _routingService.getMultiStopRoute(points);
  }

  void _startPositionStream() {
    _positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_onPositionUpdated);
  }

  void _onPositionUpdated(Position position) {
    _rawUserPosition = position;

    if (position.heading != 0.0 && position.headingAccuracy > 0) {
      _compassHeading = position.heading;
    }

    if (!_isNavigating || _currentRoute == null || _destinationPandal == null) {
      notifyListeners();
      return;
    }

    final userCoord = LatLng(position.latitude, position.longitude);
    _snappedUserPosition = NavigationUtils.snapToPolyline(userCoord, _currentRoute!.points);

    _updateStepProgress(userCoord);
    _checkOnPathAndReroute(userCoord);

    // Arrival detection at destination (within 35m)
    final destLatLng = LatLng(_destinationPandal!.latitude, _destinationPandal!.longitude);
    final distToDest = NavigationUtils.distanceMeters(userCoord, destLatLng);
    if (distToDest <= 35.0 && _isMultiStopMode && _currentWaypointIndex < _waypoints.length) {
      advanceToNextStop();
    }

    notifyListeners();
  }

  void _updateStepProgress(LatLng userCoord) {
    if (_currentRoute == null || _currentRoute!.steps.isEmpty) return;

    final currentManeuver = currentStep;
    if (currentManeuver != null) {
      final distToStep = NavigationUtils.distanceMeters(userCoord, currentManeuver.location);
      if (distToStep <= 20.0 && _currentStepIndex < _currentRoute!.steps.length - 1) {
        _currentStepIndex++;
      }
    }
  }

  void _checkOnPathAndReroute(LatLng userCoord) async {
    if (_isRerouting || _currentRoute == null || _destinationPandal == null) return;

    if (_lastRerouteTime != null &&
        DateTime.now().difference(_lastRerouteTime!).inSeconds < MapConfig.rerouteCooldownSeconds) {
      return;
    }

    final offPathDistance = NavigationUtils.distanceToPolyline(userCoord, _currentRoute!.points);

    if (offPathDistance > MapConfig.onPathToleranceMeters) {
      debugPrint('User off-path by ${offPathDistance.toStringAsFixed(1)}m. Triggering live OSRM reroute...');
      _isRerouting = true;
      _lastRerouteTime = DateTime.now();
      notifyListeners();

      final destLatLng = LatLng(_destinationPandal!.latitude, _destinationPandal!.longitude);
      final newRoute = await _routingService.getRoute(start: userCoord, destination: destLatLng);

      _isRerouting = false;

      if (newRoute != null && newRoute.points.isNotEmpty) {
        _currentRoute = newRoute;
        _currentStepIndex = 0;
        _snappedUserPosition = NavigationUtils.snapToPolyline(userCoord, newRoute.points);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }
}
