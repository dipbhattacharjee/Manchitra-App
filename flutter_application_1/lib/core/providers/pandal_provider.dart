import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import '../services/route_optimizer.dart';

import '../services/github_pandal_service.dart';

class PandalProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Pandals lists & state
  List<Pandal> _pandals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pandal> get pandals => _pandals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Search & Filter state
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedArea = 'All';
  bool _featuredOnly = false;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedArea => _selectedArea;
  bool get featuredOnly => _featuredOnly;

  // Active City/Location Context
  String _selectedLocation = 'Kolkata, West Bengal';
  String get selectedLocation => _selectedLocation;

  void setSelectedLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  // Selected Hop Route state
  List<Pandal> _routeStops = [];
  List<Pandal> get routeStops => _routeStops;

  // User live location state
  Position? _userPosition;
  bool _permissionDenied = false;

  Position? get userPosition => _userPosition;
  bool get permissionDenied => _permissionDenied;

  // Kolkata Center coordinates as a fallback/default
  static const double kolkataLat = 22.5726;
  static const double kolkataLng = 88.3639;

  PandalProvider() {
    // Initial fetch of pandals
    fetchPandals();
  }

  // Setters for search and filters that trigger fetch
  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchPandals();
  }

  void updateCategory(String category) {
    _selectedCategory = category;
    fetchPandals();
  }

  void updateArea(String area) {
    _selectedArea = area;
    fetchPandals();
  }

  void toggleFeaturedOnly() {
    _featuredOnly = !_featuredOnly;
    fetchPandals();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedArea = 'All';
    _featuredOnly = false;
    fetchPandals();
  }

  // Fetch pandals from Supabase / GitHub CDN API
  Future<void> fetchPandals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _supabaseService.getPandals(
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryFilter: _selectedCategory != 'All' ? _selectedCategory : null,
        areaFilter: _selectedArea != 'All' ? _selectedArea : null,
        featuredOnly: _featuredOnly ? true : null,
        userLat: _userPosition?.latitude,
        userLng: _userPosition?.longitude,
      );

      _pandals = results;

      // If DB has fewer items than full map_server repo (~182), fetch & merge GitHub data
      if (_pandals.length < 50 &&
          _searchQuery.isEmpty &&
          _selectedCategory == 'All' &&
          _selectedArea == 'All' &&
          !_featuredOnly) {
        final githubPandals = await GithubPandalService.fetchPandalsFromGitHub();
        if (githubPandals.isNotEmpty) {
          final Map<String, Pandal> map = {};
          for (final p in _pandals) {
            map[p.name.trim().toLowerCase()] = p;
          }
          for (final p in githubPandals) {
            map.putIfAbsent(p.name.trim().toLowerCase(), () => p);
          }
          _pandals = map.values.toList();
        } else if (_pandals.isEmpty) {
          _pandals = SampleData.featuredPandals;
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch pandals: $e';
      // Fallback to GitHub API if DB fails
      try {
        final githubPandals = await GithubPandalService.fetchPandalsFromGitHub();
        if (githubPandals.isNotEmpty) {
          _pandals = githubPandals;
        } else {
          _pandals = SampleData.featuredPandals;
        }
      } catch (_) {
        _pandals = SampleData.featuredPandals;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Explicitly fetch pandals directly from GitHub API
  Future<void> fetchFromGitHubDirectly() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final githubPandals = await GithubPandalService.fetchPandalsFromGitHub();
      if (githubPandals.isNotEmpty) {
        _pandals = githubPandals;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch from GitHub CDN API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Route actions
  void addToRoute(Pandal pandal) {
    if (!_routeStops.any((p) => p.id == pandal.id)) {
      _routeStops.add(pandal);
      notifyListeners();
    }
  }

  void removeFromRoute(String id) {
    _routeStops.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clearRoute() {
    _routeStops.clear();
    notifyListeners();
  }

  void swapStops(int index1, int index2) {
    if (index1 < 0 || index1 >= _routeStops.length) return;
    if (index2 < 0 || index2 >= _routeStops.length) return;
    final temp = _routeStops[index1];
    _routeStops[index1] = _routeStops[index2];
    _routeStops[index2] = temp;
    notifyListeners();
  }

  void reorderRoute(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _routeStops.removeAt(oldIndex);
    _routeStops.insert(newIndex, item);
    notifyListeners();
  }

  void optimizeRoute() {
    if (_routeStops.isEmpty) return;

    final startLat = _userPosition?.latitude ?? kolkataLat;
    final startLng = _userPosition?.longitude ?? kolkataLng;

    _routeStops = RouteOptimizer.optimizeRoute(_routeStops, startLat, startLng);
    notifyListeners();
  }

  void setRouteStops(List<Pandal> stops) {
    _routeStops = List.from(stops);
    notifyListeners();
  }

  // Calculate route total distance using Haversine formula
  double calculateTotalRouteDistance() {
    if (_routeStops.isEmpty) return 0.0;

    double totalDist = 0.0;
    double currentLat = _userPosition?.latitude ?? kolkataLat;
    double currentLng = _userPosition?.longitude ?? kolkataLng;

    for (final stop in _routeStops) {
      totalDist += RouteOptimizer.calculateDistance(
        currentLat,
        currentLng,
        stop.latitude,
        stop.longitude,
      );
      currentLat = stop.latitude;
      currentLng = stop.longitude;
    }
    return totalDist;
  }

  // Location functions
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _permissionDenied = true;
      _errorMessage = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _permissionDenied = true;
        _errorMessage = 'Location permissions are denied';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _permissionDenied = true;
      _errorMessage = 'Location permissions are permanently denied.';
      notifyListeners();
      return;
    }

    _permissionDenied = false;
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Security Check: Verify GPS is not spoofed (mock location detection)
      if (position.isMocked) {
        _userPosition = null;
        _errorMessage = 'Security Alert: Spoofed/Mock location detected!';
        notifyListeners();
        return;
      }

      _userPosition = position;
      _errorMessage = null;
      notifyListeners();

      // Refetch pandals sorting by current location
      await fetchPandals();
    } catch (e) {
      _errorMessage = 'Failed to get current location: $e';
      notifyListeners();
    }
  }
}
