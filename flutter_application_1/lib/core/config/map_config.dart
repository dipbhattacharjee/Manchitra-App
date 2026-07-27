/// ============================================================
/// MANCHITRA — Map & Navigation Configuration
/// ============================================================

class MapConfig {
  MapConfig._();

  /// OSRM Base URL for turn-by-turn routing & road network geometry.
  /// Uses public demo server by default, easily swapped to self-hosted URL via env flag or property.
  static const String osrmBaseUrl = String.fromEnvironment(
    'OSRM_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  /// OpenStreetMap raster tile URL pattern
  static const String osmTileUrlPattern =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Package name passed to OpenStreetMap tile server (required for OSM tile policy)
  static const String userAgentPackageName = 'com.manchitra.app';

  /// Off-path distance tolerance in meters.
  /// If the user moves further than this distance from the current route polyline,
  /// automatic live rerouting is triggered.
  static const double onPathToleranceMeters = 35.0;

  /// Minimum time interval in seconds between automatic reroute attempts
  static const int rerouteCooldownSeconds = 5;

  /// Default center coordinates (Kolkata Center - Esplanade / Maidan)
  static const double defaultLat = 22.5726;
  static const double defaultLng = 88.3639;
  static const double defaultZoom = 14.5;
  static const double navigationZoom = 17.0;

  /// Time of day boundary: Evening mode starts at 6 PM (18:00) and ends at 5 AM (05:00)
  static bool isEveningTime([DateTime? time]) {
    final now = time ?? DateTime.now();
    return now.hour >= 18 || now.hour < 5;
  }
}
