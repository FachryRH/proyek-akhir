import 'package:flutter/foundation.dart';
import 'package:restaurant_app/helpers/database_helper.dart';
import 'package:restaurant_app/models/restaurant.dart';

class FavoriteProvider extends ChangeNotifier {
  final DatabaseHelper databaseHelper;
  List<Restaurant> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  FavoriteProvider({required this.databaseHelper}) {
    loadFavorites();
  }

  List<Restaurant> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await databaseHelper.getFavorites();
    } catch (e) {
      _errorMessage =
          'Maaf, terjadi kesalahan saat memuat daftar restoran favorit Anda. Silakan coba lagi.';
      debugPrint('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isFavorite(String id) async {
    try {
      return await databaseHelper.isFavorite(id);
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  Future<String?> toggleFavorite(Restaurant restaurant) async {
    try {
      final isFav = await databaseHelper.isFavorite(restaurant.id);
      if (isFav) {
        await databaseHelper.removeFavorite(restaurant.id);
        _favorites.removeWhere((resto) => resto.id == restaurant.id);
        notifyListeners();
        return 'Restoran dihapus dari favorit';
      } else {
        await databaseHelper.insertFavorite(restaurant);
        _favorites.add(restaurant);
        notifyListeners();
        return 'Restoran ditambahkan ke favorit';
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return 'Gagal mengubah status favorit. Silakan coba lagi nanti.';
    }
  }
}
