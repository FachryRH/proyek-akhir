import 'package:flutter/foundation.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/services/api_service.dart';

sealed class ResultState<T> {}

class Initial<T> extends ResultState<T> {}

class Loading<T> extends ResultState<T> {}

class Success<T> extends ResultState<T> {
  final T data;
  Success(this.data);
}

class Error<T> extends ResultState<T> {
  final String message;
  Error(this.message);
}

class RestaurantProvider extends ChangeNotifier {
  final ApiService apiService;

  RestaurantProvider({required this.apiService});

  ResultState<List<Restaurant>> _restaurantsState = Loading();
  ResultState<List<Restaurant>> get restaurantsState => _restaurantsState;

  ResultState<RestaurantDetail> _restaurantDetailState = Loading();
  ResultState<RestaurantDetail> get restaurantDetailState =>
      _restaurantDetailState;

  ResultState<List<Restaurant>> _searchState = Initial();
  ResultState<List<Restaurant>> get searchState => _searchState;

  Future<void> fetchRestaurants() async {
    _restaurantsState = Loading();
    notifyListeners();

    try {
      final restaurants = await apiService.getRestaurants();
      _restaurantsState = Success(restaurants);
    } catch (e) {
      _restaurantsState = Error(
          'Maaf, terjadi kesalahan saat memuat daftar restoran. Silakan periksa koneksi internet Anda dan coba lagi.');
    }
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    _restaurantDetailState = Loading();
    notifyListeners();

    try {
      final restaurantDetail = await apiService.getRestaurantDetail(id);
      _restaurantDetailState = Success(restaurantDetail);
    } catch (e) {
      _restaurantDetailState = Error(
          'Maaf, terjadi kesalahan saat memuat detail restoran. Silakan periksa koneksi internet Anda dan coba lagi.');
    }
    notifyListeners();
  }

  Future<void> searchRestaurants(String query) async {
    _searchState = Loading();
    notifyListeners();

    try {
      final results = await apiService.searchRestaurants(query);
      _searchState = Success(results);
    } catch (e) {
      _searchState = Error(
          'Maaf, terjadi kesalahan saat mencari restoran. Silakan periksa koneksi internet Anda dan coba lagi.');
    }
    notifyListeners();
  }

  Future<void> addReview(String id, String name, String review) async {
    try {
      final updatedReviews = await apiService.addReview(id, name, review);
      if (_restaurantDetailState is Success<RestaurantDetail>) {
        final currentDetail =
            (_restaurantDetailState as Success<RestaurantDetail>).data;
        final updatedDetail = RestaurantDetail(
          id: currentDetail.id,
          name: currentDetail.name,
          description: currentDetail.description,
          city: currentDetail.city,
          address: currentDetail.address,
          pictureId: currentDetail.pictureId,
          rating: currentDetail.rating,
          categories: currentDetail.categories,
          menus: currentDetail.menus,
          customerReviews: updatedReviews,
        );
        _restaurantDetailState = Success(updatedDetail);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error addReview: $e');
    }
  }
}
