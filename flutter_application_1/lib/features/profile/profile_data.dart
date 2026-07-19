import '../../core/models/models.dart';

class ProfileData {
  static String name = 'Shubho Sharodiya';
  static String email = 'shubho@pandalhop.ai';
  static String phone = '+91 98765 43210';
  static String bio = 'Urban traveler and cultural enthusiast. Exploring the vibrant heart of Kolkata one pandal at a time.';
  static String location = 'Kolkata, WB';
  static String photoUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';

  static final List<Pandal> favoritePandals = [];

  static void addFavorite(Pandal pandal) {
    if (!favoritePandals.any((p) => p.id == pandal.id)) {
      favoritePandals.add(pandal);
    }
  }

  static void removeFavorite(String id) {
    favoritePandals.removeWhere((p) => p.id == id);
  }

  static bool isFavorite(String id) {
    return favoritePandals.any((p) => p.id == id);
  }
}
