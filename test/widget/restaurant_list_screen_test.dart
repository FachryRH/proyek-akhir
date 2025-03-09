import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_app/services/api_service.dart';

@GenerateMocks([ApiService])
import 'restaurant_list_screen_test.mocks.dart';

class TestRestaurantItem extends StatelessWidget {
  final Restaurant restaurant;
  const TestRestaurantItem({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(restaurant.name),
      subtitle: Text('${restaurant.city} • Rating: ${restaurant.rating}'),
    );
  }
}

class TestRestaurantList extends StatefulWidget {
  const TestRestaurantList({super.key});

  @override
  TestRestaurantListState createState() => TestRestaurantListState();
}

class TestRestaurantListState extends State<TestRestaurantList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.restaurantsState is Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.restaurantsState is Success<List<Restaurant>>) {
            final restaurants =
                (provider.restaurantsState as Success<List<Restaurant>>).data;
            return ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return TestRestaurantItem(restaurant: restaurant);
              },
            );
          } else if (provider.restaurantsState is Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text((provider.restaurantsState as Error).message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchRestaurants();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}

void main() {
  group('RestaurantProvider Test', () {
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
      final testRestaurant = Restaurant(
        id: "1",
        name: "Test Restaurant",
        description: "Test Description",
        pictureId: "test.jpg",
        city: "Test City",
        rating: 4.5,
      );

      when(mockApiService.getRestaurants())
          .thenAnswer((_) async => [testRestaurant]);

      await provider.fetchRestaurants();

      expect(provider.restaurantsState, isA<Success<List<Restaurant>>>());
      final state = provider.restaurantsState as Success<List<Restaurant>>;
      expect(state.data.first.name, equals("Test Restaurant"));
      expect(state.data.first.city, equals("Test City"));
      verify(mockApiService.getRestaurants()).called(1);
    });

    test('fetchRestaurants should return error when API call fails', () async {
      when(mockApiService.getRestaurants())
          .thenThrow(Exception('Failed to load restaurants'));

      await provider.fetchRestaurants();

      expect(provider.restaurantsState, isA<Error<List<Restaurant>>>());
      final state = provider.restaurantsState as Error<List<Restaurant>>;
      expect(
          state.message,
          equals(
              'Maaf, terjadi kesalahan saat memuat daftar restoran. Silakan periksa koneksi internet Anda dan coba lagi.'));
      verify(mockApiService.getRestaurants()).called(1);
    });
  });
}
