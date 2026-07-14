// ============================================================
// MANCHITRA — Data Models
// ============================================================

import 'package:flutter/material.dart';

// ─── ENUMS ────────────────────────────────────────────────────

enum PandalCategory {
  traditionalBarowari('Traditional Barowari'),
  themeBased('Theme-Based'),
  ecoFriendly('Eco-Friendly'),
  community('Community'),
  famousHeritage('Famous Heritage');

  const PandalCategory(this.label);
  final String label;
}

enum CrowdLevel {
  low('Low', Color(0xFF2A8A4A)),
  medium('Medium', Color(0xFFC8961A)),
  high('High', Color(0xFFE8531A)),
  veryHigh('Very High', Color(0xFF8B1A4A));

  const CrowdLevel(this.label, this.color);
  final String label;
  final Color color;
}

enum TransportMode {
  walk('Walk', Icons.directions_walk),
  metro('Metro', Icons.subway),
  train('Train', Icons.train),
  cab('Cab', Icons.local_taxi),
  auto('Auto', Icons.electric_rickshaw);

  const TransportMode(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum RouteType {
  fastest('Fastest', Icons.bolt),
  shortest('Shortest', Icons.straighten),
  walkingFriendly('Walking Friendly', Icons.directions_walk);

  const RouteType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum GroupType {
  solo('Solo', Icons.person),
  couple('Couple', Icons.favorite),
  family('Family', Icons.family_restroom),
  group('Group', Icons.group);

  const GroupType(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum AppExperienceTheme {
  traditional('Traditional / Heritage', Icons.temple_hindu),
  couple('Couple Special', Icons.favorite),
  family('Family Friendly', Icons.family_restroom);

  const AppExperienceTheme(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─── MODELS ───────────────────────────────────────────────────

class Pandal {
  const Pandal({
    required this.id,
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
    this.ward,
    this.committeeName,
    this.theme,
    this.description,
    this.isFeatured2026 = false,
    this.category = PandalCategory.themeBased,
    this.visitStartTime,
    this.visitEndTime,
    this.crowdLevel = CrowdLevel.medium,
    this.photoUrls = const [],
    this.coverPhotoUrl,
    this.rating,
    this.reviewCount = 0,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String area;
  final double latitude;
  final double longitude;
  final String? ward;
  final String? committeeName;
  final String? theme;
  final String? description;
  final bool isFeatured2026;
  final PandalCategory category;
  final String? visitStartTime;
  final String? visitEndTime;
  final CrowdLevel crowdLevel;
  final List<String> photoUrls;
  final String? coverPhotoUrl;
  final double? rating;
  final int reviewCount;
  final double? distanceKm;

  String get distanceText {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }
}

class RouteLeg {
  const RouteLeg({
    required this.id,
    required this.fromPandalId,
    required this.toPandalId,
    required this.distanceKm,
    required this.durationMin,
    required this.suggestedMode,
    this.sequenceOrder = 0,
  });

  final String id;
  final String fromPandalId;
  final String toPandalId;
  final double distanceKm;
  final int durationMin;
  final TransportMode suggestedMode;
  final int sequenceOrder;

  String get durationText {
    if (durationMin < 60) return '$durationMin min';
    final h = durationMin ~/ 60;
    final m = durationMin % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class HopRoute {
  const HopRoute({
    required this.id,
    required this.routeType,
    required this.stops,
    required this.legs,
    required this.totalDistanceKm,
    required this.totalTimeMin,
  });

  final String id;
  final RouteType routeType;
  final List<Pandal> stops;
  final List<RouteLeg> legs;
  final double totalDistanceKm;
  final int totalTimeMin;

  String get totalTimeText {
    final h = totalTimeMin ~/ 60;
    final m = totalTimeMin % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class TripStop {
  const TripStop({
    required this.id,
    required this.pandal,
    required this.visitOrder,
    this.plannedTime,
    this.visited = false,
  });

  final String id;
  final Pandal pandal;
  final int visitOrder;
  final String? plannedTime;
  final bool visited;
}

class Trip {
  const Trip({
    required this.id,
    required this.tripDate,
    this.title,
    this.stops = const [],
    this.route,
  });

  final String id;
  final DateTime tripDate;
  final String? title;
  final List<TripStop> stops;
  final HopRoute? route;
}

class FoodPlace {
  const FoodPlace({
    required this.id,
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
    this.cuisine,
    this.priceRange,
    this.isVeg,
    this.rating,
    this.distanceKm,
    this.isPujaSpecial = false,
  });

  final String id;
  final String name;
  final String area;
  final double latitude;
  final double longitude;
  final String? cuisine;
  final String? priceRange; // '₹', '₹₹', '₹₹₹'
  final bool? isVeg;
  final double? rating;
  final double? distanceKm;
  final bool isPujaSpecial;
}

class Hotel {
  const Hotel({
    required this.id,
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
    this.priceRange,
    this.rating,
    this.distanceKm,
    this.pricePerNight,
  });

  final String id;
  final String name;
  final String area;
  final double latitude;
  final double longitude;
  final String? priceRange;
  final double? rating;
  final double? distanceKm;
  final int? pricePerNight;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.pandalSuggestions = const [],
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Pandal> pandalSuggestions;
}

// ─── SAMPLE SEED DATA ─────────────────────────────────────────

class SampleData {
  SampleData._();

  static const List<Pandal> featuredPandals = [
    Pandal(
      id: 'p001',
      name: 'Bagbazar Sarbojanin',
      area: 'North Kolkata',
      latitude: 22.5960,
      longitude: 88.3697,
      committeeName: 'Bagbazar Sarbojanin Durgotsab Committee',
      theme: 'Heritage Revival',
      description:
          'One of the oldest and most revered Durga Puja committees in Kolkata, known for its traditional decor and spiritual ambiance. A landmark celebration since 1919.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '09:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.veryHigh,
      distanceKm: 2.3,
      rating: 4.8,
      reviewCount: 2100,
    ),
    Pandal(
      id: 'p002',
      name: 'Kumartuli Park Durgotsav',
      area: 'North Kolkata',
      latitude: 22.5951,
      longitude: 88.3614,
      committeeName: 'Kumartuli Park Sporting Club',
      theme: "Artisan's Legacy",
      description:
          'Located at the heart of the idol-maker\'s district, this pandal celebrates the craft of Kumartuli\'s artisans with a spectacular theme.',
      isFeatured2026: true,
      category: PandalCategory.themeBased,
      visitStartTime: '10:00',
      visitEndTime: '23:30',
      crowdLevel: CrowdLevel.high,
      distanceKm: 1.8,
      rating: 4.6,
      reviewCount: 1450,
    ),
    Pandal(
      id: 'p003',
      name: 'Ekdalia Evergreen',
      area: 'South Kolkata',
      latitude: 22.5178,
      longitude: 88.3578,
      committeeName: 'Ekdalia Evergreen Club',
      theme: 'Forest of Light',
      description:
          'Known for its breathtaking pandal architecture and innovative themes, Ekdalia Evergreen is a perennial favorite of south Kolkata.',
      isFeatured2026: true,
      category: PandalCategory.themeBased,
      visitStartTime: '08:00',
      visitEndTime: '00:00',
      crowdLevel: CrowdLevel.high,
      distanceKm: 4.5,
      rating: 4.7,
      reviewCount: 1800,
    ),
    Pandal(
      id: 'p004',
      name: 'Mohammad Ali Park',
      area: 'Central Kolkata',
      latitude: 22.5751,
      longitude: 88.3674,
      committeeName: 'Mohammad Ali Park Durga Puja Committee',
      theme: 'Eco-Future',
      description:
          'A central Kolkata institution known for massive pandal structures and eco-friendly innovation. The 2026 theme explores sustainability.',
      isFeatured2026: true,
      category: PandalCategory.ecoFriendly,
      visitStartTime: '09:00',
      visitEndTime: '23:00',
      crowdLevel: CrowdLevel.veryHigh,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
    ),
    Pandal(
      id: 'p005',
      name: 'Lake Kalibari Sarbojanin',
      area: 'South Kolkata',
      latitude: 22.5261,
      longitude: 88.3493,
      theme: 'Benkipur Village',
      description:
          'A popular South Kolkata puja that recreates a traditional Bengal village pandal experience.',
      isFeatured2026: false,
      category: PandalCategory.traditionalBarowari,
      crowdLevel: CrowdLevel.medium,
      distanceKm: 5.2,
      rating: 4.3,
      reviewCount: 620,
    ),
    Pandal(
      id: 'p006',
      name: 'Deshapriya Park',
      area: 'South Kolkata',
      latitude: 22.5272,
      longitude: 88.3629,
      committeeName: 'Deshapriya Park Durga Puja',
      theme: 'Ganges Revived',
      description:
          'Deshapriya Park 2026 focuses on a water conservation theme, with a stunning pandal built around the concept of a revived Ganges.',
      isFeatured2026: true,
      category: PandalCategory.ecoFriendly,
      crowdLevel: CrowdLevel.high,
      distanceKm: 5.8,
      rating: 4.6,
      reviewCount: 1200,
    ),
  ];

  static const List<FoodPlace> nearbyFood = [
    FoodPlace(
      id: 'f001',
      name: 'Arsalan',
      area: 'Park Circus',
      latitude: 22.5330,
      longitude: 88.3830,
      cuisine: 'Mughlai',
      priceRange: '₹₹',
      isVeg: false,
      rating: 4.5,
      distanceKm: 1.2,
      isPujaSpecial: true,
    ),
    FoodPlace(
      id: 'f002',
      name: "Nizams",
      area: 'New Market',
      latitude: 22.5600,
      longitude: 88.3521,
      cuisine: 'Rolls & Kebabs',
      priceRange: '₹',
      isVeg: false,
      rating: 4.4,
      distanceKm: 0.8,
      isPujaSpecial: true,
    ),
    FoodPlace(
      id: 'f003',
      name: 'Bhojohori Manna',
      area: 'Adi Ballygunge',
      latitude: 22.5295,
      longitude: 88.3750,
      cuisine: 'Bengali',
      priceRange: '₹₹',
      isVeg: false,
      rating: 4.6,
      distanceKm: 2.1,
    ),
  ];

  static const List<Hotel> nearbyHotels = [
    Hotel(
      id: 'h001',
      name: 'Kenilworth Hotel',
      area: 'Little Russell St',
      latitude: 22.5528,
      longitude: 88.3511,
      priceRange: '₹₹₹',
      rating: 4.3,
      distanceKm: 2.5,
      pricePerNight: 4500,
    ),
    Hotel(
      id: 'h002',
      name: 'Hotel Hindustan International',
      area: 'AJC Bose Road',
      latitude: 22.5364,
      longitude: 88.3561,
      priceRange: '₹₹₹',
      rating: 4.1,
      distanceKm: 3.0,
      pricePerNight: 3800,
    ),
  ];

  static const List<String> pujaQuickPrompts = [
    'Plan my Ashtami evening',
    'Best pandals in South Kolkata',
    'Theme pandals under 5km',
    'Sandhi Puja timing',
    'Best street food near my route',
    'Family-friendly pandals',
  ];

  static const List<String> areaFilters = [
    'All',
    'North Kolkata',
    'South Kolkata',
    'Central Kolkata',
    'Salt Lake',
    'Howrah',
    'Dum Dum',
    'Behala',
  ];

  static const Map<String, String> pujaDays = {
    'Shashti': 'Oct 5',
    'Saptami': 'Oct 6',
    'Ashtami': 'Oct 7',
    'Navami': 'Oct 8',
    'Dashami': 'Oct 9',
  };
}
