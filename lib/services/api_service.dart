import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/models/restaurant.dart';

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev/';

  Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}list'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['restaurants'] as List)
            .map((json) => Restaurant.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Maaf, tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda dan coba lagi.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<RestaurantDetail> getRestaurantDetail(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}detail/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RestaurantDetail.fromJson(data['restaurant']);
      } else {
        throw Exception(
            'Maaf, tidak dapat menampilkan detail restoran. Silakan coba lagi nanti.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<List<CustomerReview>> addReview(
      String id, String name, String review) async {
    try {
      final response = await http
          .post(
            Uri.parse('${_baseUrl}review'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"id": id, "name": name, "review": review}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['customerReviews'] as List)
            .map((json) => CustomerReview.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Maaf, tidak dapat mengirim ulasan. Silakan coba lagi nanti.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menambahkan review: $e');
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return (jsonData['restaurants'] as List)
          .map((data) => Restaurant.fromJson(data))
          .toList();
    } else {
      throw Exception(
          'Maaf, tidak dapat menemukan restoran yang Anda cari. Silakan coba kata kunci lain.');
    }
  }
}
