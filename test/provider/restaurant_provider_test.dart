import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/services/api_service.dart';

@GenerateMocks([ApiService])
import 'restaurant_provider_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late RestaurantProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantProvider(apiService: mockApiService);
  });

  test('Initial state should be Loading', () {
    expect(provider.restaurantsState, isA<Loading<List<Restaurant>>>());
  });

  test('fetchRestaurants should return list of restaurants when successful',
      () async {
    final testRestaurants = [
      Restaurant(
        id: "1",
        name: "Test Restaurant",
        description: "Test Description",
        pictureId: "1",
        city: "Test City",
        rating: 4.5,
      ),
    ];

    when(mockApiService.getRestaurants())
        .thenAnswer((_) async => testRestaurants);

    await provider.fetchRestaurants();

    expect(provider.restaurantsState, isA<Success<List<Restaurant>>>());
    final state = provider.restaurantsState as Success<List<Restaurant>>;
    expect(state.data, testRestaurants);
    verify(mockApiService.getRestaurants()).called(1);
  });

  test('fetchRestaurants should return error when API call fails', () async {
    when(mockApiService.getRestaurants())
        .thenThrow(Exception('Failed to load restaurants'));

    await provider.fetchRestaurants();

    expect(provider.restaurantsState, isA<Error<List<Restaurant>>>());
    final state = provider.restaurantsState as Error<List<Restaurant>>;
    expect(state.message,
        'Maaf, terjadi kesalahan saat memuat daftar restoran. Silakan periksa koneksi internet Anda dan coba lagi.');
    verify(mockApiService.getRestaurants()).called(1);
  });

  test('searchRestaurants should return list of restaurants when successful',
      () async {
    final testRestaurants = [
      Restaurant(
        id: "1",
        name: "Test Restaurant",
        description: "Test Description",
        pictureId: "1",
        city: "Test City",
        rating: 4.5,
      ),
    ];

    when(mockApiService.searchRestaurants('test'))
        .thenAnswer((_) async => testRestaurants);

    await provider.searchRestaurants('test');

    expect(provider.searchState, isA<Success<List<Restaurant>>>());
    final state = provider.searchState as Success<List<Restaurant>>;
    expect(state.data, testRestaurants);
    verify(mockApiService.searchRestaurants('test')).called(1);
  });

  test('searchRestaurants should return error when API call fails', () async {
    when(mockApiService.searchRestaurants('test'))
        .thenThrow(Exception('Failed to search restaurants'));

    await provider.searchRestaurants('test');

    expect(provider.searchState, isA<Error<List<Restaurant>>>());
    final state = provider.searchState as Error<List<Restaurant>>;
    expect(state.message,
        'Maaf, terjadi kesalahan saat mencari restoran. Silakan periksa koneksi internet Anda dan coba lagi.');
    verify(mockApiService.searchRestaurants('test')).called(1);
  });
}
