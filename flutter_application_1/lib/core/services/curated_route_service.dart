import '../models/models.dart';

/// ============================================================
/// MANCHITRA — Curated Popular Routes Service
/// Predefined heritage, illumination & themed routes.
/// ============================================================

class CuratedRoute {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String imageUrl;
  final int stopCount;
  final int estimatedMinutes;
  final List<Pandal> stops;

  const CuratedRoute({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.stopCount,
    required this.estimatedMinutes,
    required this.stops,
  });
}

class CuratedRouteService {
  static List<CuratedRoute> getCuratedRoutes(List<Pandal> allPandals) {
    final pandalMap = {for (var p in allPandals) p.id: p};
    final fallbackList = SampleData.featuredPandals;

    Pandal getPandal(String id, Pandal fallback) {
      return pandalMap[id] ?? fallback;
    }

    return [
      CuratedRoute(
        id: 'cr001',
        title: 'Heritage Pandal Trail',
        subtitle: 'North Kolkata historic barowari pujas with traditional idols & rajbari heritage',
        category: 'Heritage',
        imageUrl: 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?auto=format&fit=crop&w=600',
        stopCount: 4,
        estimatedMinutes: 90,
        stops: [
          getPandal('p002', fallbackList[0]), // College Square
          getPandal('p003', fallbackList[1]), // Kumartuli Park
          getPandal('p006', fallbackList[2]), // Ahiritola
          getPandal('p007', fallbackList[3]), // Sovabazar
        ],
      ),
      CuratedRoute(
        id: 'cr002',
        title: 'Illumination Special Trail',
        subtitle: 'Spectacular Chandannagar light art & glowing street installations',
        category: 'Lighting & Art',
        imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=600',
        stopCount: 4,
        estimatedMinutes: 110,
        stops: [
          getPandal('p001', fallbackList[0]), // Sree Bhumi
          getPandal('p004', fallbackList[1]), // FD Block
          getPandal('p002', fallbackList[2]), // College Square
          getPandal('p005', fallbackList[3]), // Ekdalia
        ],
      ),
      CuratedRoute(
        id: 'cr003',
        title: "First-Timer's Kolkata Tour",
        subtitle: 'Beginner friendly central Kolkata route covering essential iconic pandals',
        category: 'Beginner Friendly',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=600',
        stopCount: 3,
        estimatedMinutes: 60,
        stops: [
          getPandal('p002', fallbackList[0]), // College Square
          getPandal('p001', fallbackList[1]), // Sree Bhumi
          getPandal('p005', fallbackList[2]), // Ekdalia
        ],
      ),
      CuratedRoute(
        id: 'cr004',
        title: 'South Kolkata Big-Budget Spectacle',
        subtitle: 'Grand multi-crore themed pandals with immersive artistic architecture',
        category: 'Big Budget Themes',
        imageUrl: 'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?auto=format&fit=crop&w=600',
        stopCount: 4,
        estimatedMinutes: 120,
        stops: [
          getPandal('p005', fallbackList[0]), // Ekdalia Evergreen
          getPandal('p004', fallbackList[1]), // FD Block
          getPandal('p001', fallbackList[2]), // Sree Bhumi
          getPandal('p002', fallbackList[3]), // College Square
        ],
      ),
    ];
  }
}
