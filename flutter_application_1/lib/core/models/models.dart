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
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg',
      photoUrls: const [
        'https://res.cloudinary.com/mizoda0v/image/upload/v1784038553/579c3d50-c14f-49f4-accd-1a6d29de66e1_u8k0dq.jpg',
        'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
      ],
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
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784038970/114045851_baf6ub.png',
      photoUrls: const ['https://res.cloudinary.com/mizoda0v/image/upload/v1784038970/114045851_baf6ub.png'],
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
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039236/ekdalia-evergreen_fbvbsr.jpg',
      photoUrls: const ['https://res.cloudinary.com/mizoda0v/image/upload/v1784039236/ekdalia-evergreen_fbvbsr.jpg'],
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
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039272/inauguration-ceremony-of-the-57th-year-of-youth-association-of-mohammad-ali-park-durga-puja-6_culxki.jpg',
      photoUrls: const ['https://res.cloudinary.com/mizoda0v/image/upload/v1784039277/Inauguration-ceremony-of-the-57th-Year-of-Youth-Association-of-Mohammad-Ali-Park-Durga-Puja_2_libo56.jpg'],
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
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784036075/tallest-goddess-durga-idol_kfdgox.webp',
      photoUrls: const ['https://res.cloudinary.com/mizoda0v/image/upload/v1784036075/tallest-goddess-durga-idol_kfdgox.webp'],
    ),
    Pandal(
      id: 'p007',
      name: 'Sreebhumi Sporting Club',
      area: 'Lake Town',
      latitude: 22.5997,
      longitude: 88.4026,
      committeeName: 'Sreebhumi Sporting Club Committee',
      theme: 'Vatican City replica',
      description: 'Known for creating spectacular, lavish replicas of world-famous heritage monuments and decorating the Durga idol with pure gold ornaments.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '08:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.veryHigh,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784043552/sreebhumi_sporting_club_pnyf33.jpg',
      photoUrls: const ['https://res.cloudinary.com/mizoda0v/image/upload/v1784043558/sreebhumi_sporting_clube_durga_puja_jg4vst.jpg'],

    ),
    Pandal(
      id: 'p008',
      name: 'College Square Sarbojanin',
      area: 'Central Kolkata',
      latitude: 22.5747,
      longitude: 88.3640,
      committeeName: 'College Square Sarbojanin Durgotsav Committee',
      theme: 'Illumination & Waterfront',
      description: 'Renowned for its massive, dazzling light installations. The primary structure is built on a massive lake inside the park, casting a flawless reflection of the illuminated design over the water at night.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '12:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.high,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
      coverPhotoUrl: '',
      photoUrls: const [''],

    ),
    Pandal(
      id: 'p009',
      name: 'Suruchi Sangha',
      area: 'South Kolkata',
      latitude: 22.5191,
      longitude: 88.3378,
      committeeName: 'New Alipore Suruchi Sangha Committee',
      theme: 'State-Themes & Cultural Diversity',
      description: 'Famous for depicting a unique Indian state\'s art, handicraft, and lifestyle traditions every year. The idol\'s features and attire are meticulously styled to mirror the chosen state\'s heritage.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '09:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.high,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
      coverPhotoUrl: '',
      photoUrls: const [''],

    ),
    Pandal(
      id: 'p010',
      name: 'Tridhara Sammilani',
      area: 'Ballygunge',
      latitude: 22.5204,
      longitude: 88.3650,
      committeeName: 'Tridhara Sammilani Committee',
      theme: 'Traditional tribal art',
      description: 'An artistic powerhouse in Ballygunge that blends modern creative theme design with ancient Indian arts and crafts.',
      isFeatured2026: false,
      category: PandalCategory.themeBased,
      visitStartTime: '10:00',
      visitEndTime: '23:00',
      crowdLevel: CrowdLevel.medium,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
      coverPhotoUrl: '',
      photoUrls: const [''],

    ),
    Pandal(
      id: 'p011',
      name: 'Bosepukur Sitalamandir',
      area: 'Kasba',
      latitude: 22.5221,
      longitude: 88.3846,
      committeeName: 'Bosepukur Sitalamandir Committee',
      theme: 'Rural earthen pottery',
      description: 'Famous for its innovative use of everyday elements (like clay cups, hand-fans, or bicycle parts) to create intricate pandal structures.',
      isFeatured2026: false,
      category: PandalCategory.themeBased,
      visitStartTime: '09:00',
      visitEndTime: '23:00',
      crowdLevel: CrowdLevel.medium,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
      coverPhotoUrl: '',
      photoUrls: const [''],

    ),
    Pandal(
      id: 'p012',
      name: 'Nalin Sarkar Street',
      area: 'Shyambazar',
      latitude: 22.5935,
      longitude: 88.3689,
      committeeName: 'Nalin Sarkar Street Durgotsab Committee',
      theme: 'Wood carvings',
      description: 'A critically acclaimed north Kolkata puja that transforms a narrow alley into a museum of detailed folk art.',
      isFeatured2026: false,
      category: PandalCategory.themeBased,
      visitStartTime: '11:00',
      visitEndTime: '22:30',
      crowdLevel: CrowdLevel.medium,
      distanceKm: 3.1,
      rating: 4.5,
      reviewCount: 980,
      coverPhotoUrl: '',
      photoUrls: const [''],

    ),
    Pandal(
      id: 'p013',
      name: 'Mudiali Club',
      area: 'Tollygunge',
      latitude: 22.5103,
      longitude: 88.3499,
      committeeName: 'Mudiali Club Durgotsab Committee',
      theme: 'Classical temple architecture',
      description: 'Known for elegant and tasteful setups that remain true to traditional aesthetic structures with elegant color harmony.',
      isFeatured2026: false,
      category: PandalCategory.themeBased,
      visitStartTime: '09:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.medium,
    ),
    Pandal(
      id: 'p014',
      name: 'Badamtala Ashar Sangha',
      area: 'Kalighat',
      latitude: 22.5189,
      longitude: 88.3479,
      committeeName: 'Badamtala Ashar Sangha Committee',
      theme: 'Experimental Theme & Compact Pandal',
      description: 'Celebrated as one of the definitive pioneers of modern "theme-based" pujas in Kolkata. Though set within narrow lanes, it showcases highly creative, intimate design motifs that pull heavy crowds yearly.',
      isFeatured2026: false,
      category: PandalCategory.themeBased,
      visitStartTime: '10:00',
      visitEndTime: '23:00',
      crowdLevel: CrowdLevel.medium,
    ),
    Pandal(
      id: 'p015',
      name: 'Ahiritola Sarbojanin Durgotsab',
      area: 'Ahiritola',
      latitude: 22.5960,
      longitude: 88.3588,
      committeeName: 'Ahiritola Sarbojanin Durgotsab Committee',
      theme: 'Street artists tribute',
      description: 'Running since 1940, it is famous for its large-scale creative theme work depicting rural livelihood and traditional folk arts.',
      isFeatured2026: false,
      category: PandalCategory.themeBased,
      visitStartTime: '08:00',
      visitEndTime: '23:00',
      crowdLevel: CrowdLevel.high,
    ),
    Pandal(
      id: 'p016',
      name: 'Shovabazar Rajbari (Deb Family)',
      area: 'Shovabazar',
      latitude: 22.5947,
      longitude: 88.3649,
      committeeName: 'Shovabazar Rajbari Estate',
      theme: 'Traditional Deb Family idol',
      description: 'Started in 1757 by Raja Nabakrishna Deb in the presence of Lord Clive. This is one of the most famous ancestral household pujas in Bengal.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '10:00',
      visitEndTime: '22:00',
      crowdLevel: CrowdLevel.medium,
    ),
    Pandal(
      id: 'p017',
      name: 'Sabarna Roy Choudhury Bari (Barisha)',
      area: 'Barisha',
      latitude: 22.4834,
      longitude: 88.3249,
      committeeName: 'Sabarna Roy Choudhury Paribar',
      theme: 'Aatchala traditional idol',
      description: 'The oldest recorded Durga Puja in Kolkata, dating back to 1610. The family landlord Sabarna Roy Choudhury sold Kolkata to the British East India Company.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '08:00',
      visitEndTime: '22:00',
      crowdLevel: CrowdLevel.low,
    ),
    Pandal(
      id: 'p018',
      name: 'Jorasanko Dawn Bari',
      area: 'Jorasanko',
      latitude: 22.5834,
      longitude: 88.3610,
      committeeName: 'Dawn Mansion Estate',
      theme: 'Gold/silver decorations (Daker Saaj)',
      description: 'The ancestral household puja of Shibkrishna Dawn. Known for the grand mansion courtyard (Thakur Dalan) and gold/silver decorations of the deities.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '09:00',
      visitEndTime: '22:00',
      crowdLevel: CrowdLevel.low,
      coverPhotoUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg',
      photoUrls: const [
        'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg',
        'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
      ],
    ),
    Pandal(
      id: 'p019',
      name: 'Pathuriaghata Khelat Ghosh Bari',
      area: 'Pathuriaghata',
      latitude: 22.5913,
      longitude: 88.3579,
      committeeName: 'Khelat Ghosh Mansion Estate',
      theme: 'Traditional Durga in marble courtyard',
      description: 'Celebrated in the historic Khelat Bhavan mansion, featuring a stunning 85-foot long marble corridor (Thakur Dalan) and traditional rituals.',
      isFeatured2026: true,
      category: PandalCategory.famousHeritage,
      visitStartTime: '10:00',
      visitEndTime: '21:00',
      crowdLevel: CrowdLevel.low,
    ),
    Pandal(
      id: 'p020',
      name: 'Jorasanko Shib Krishna Deb Bari',
      area: 'Jorasanko',
      latitude: 22.5847,
      longitude: 88.3619,
      committeeName: 'Deb Mansion Estate',
      theme: 'Hara-Gouri style traditional idol',
      description: 'Famous ancestral house puja known for its heritage architecture and maintaining the strict, centuries-old Bengali puja rituals.',
      isFeatured2026: false,
      category: PandalCategory.famousHeritage,
      visitStartTime: '09:00',
      visitEndTime: '21:00',
      crowdLevel: CrowdLevel.low,
    ),
    Pandal(
      id: 'p021',
      name: 'Thanthania Dutta Bari',
      area: 'College Street',
      latitude: 22.5789,
      longitude: 88.3659,
      committeeName: 'Dutta Mansion Estate',
      theme: 'Hara-Gouri theme idol',
      description: 'Dating back to 1855, this ancestral puja is unique because the Durga idol is styled as Hara-Gouri (sitting on Shiva\'s lap) rather than killing the demon.',
      isFeatured2026: false,
      category: PandalCategory.famousHeritage,
      visitStartTime: '08:00',
      visitEndTime: '22:00',
      crowdLevel: CrowdLevel.low,
    ),
    Pandal(
      id: 'p022',
      name: 'Santosh Mitra Square (Bowbazar)',
      area: 'Central Kolkata',
      latitude: 22.5684,
      longitude: 88.3644,
      committeeName: 'Santosh Mitra Square Committee',
      theme: 'Big Budget & Grand Opulence',
      description: 'One of the most visited big-budget spectacles in central Kolkata. Famous for extravagant setups, ranging from gold/silver clad structures to jaw-dropping replicas of monuments. Expect heavy foot traffic.',
      isFeatured2026: true,
      category: PandalCategory.themeBased,
      visitStartTime: '09:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.veryHigh,
    ),
    Pandal(
      id: 'p023',
      name: 'Chetla Agrani Club',
      area: 'South Kolkata (Chetla)',
      latitude: 22.5181,
      longitude: 88.3444,
      committeeName: 'Chetla Agrani Club Committee',
      theme: 'Eco-Friendly Conceptual Art',
      description: 'A legendary powerhouse for installation art. It relies heavily on eco-friendly, natural elements (like millions of rudraksha seeds or specialized wood crafts) to tell a profound sociological or spiritual story.',
      isFeatured2026: true,
      category: PandalCategory.ecoFriendly,
      visitStartTime: '09:00',
      visitEndTime: '23:59',
      crowdLevel: CrowdLevel.high,
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
