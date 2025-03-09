import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/screens/restaurant_detail_screen.dart';
import 'package:restaurant_app/screens/search_screen.dart';
import 'package:restaurant_app/widgets/loading_indicator.dart';
import 'package:restaurant_app/widgets/error_message.dart';

class RestaurantList extends StatefulWidget {
  const RestaurantList({super.key});

  @override
  RestaurantListState createState() => RestaurantListState();
}

class RestaurantListState extends State<RestaurantList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchRestaurants();
    });
  }

  Future<void> _fetchRestaurants() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await provider.fetchRestaurants();
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ErrorMessage(message: message),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _fetchRestaurants();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.restaurantsState is Loading) {
            return Center(child: loadingLottie());
          } else if (provider.restaurantsState is Success<List<Restaurant>>) {
            final restaurants =
                (provider.restaurantsState as Success<List<Restaurant>>).data;
            return ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return RestaurantItem(restaurant: restaurant);
              },
            );
          } else if (provider.restaurantsState is Error) {
            return _buildError(
                context, (provider.restaurantsState as Error).message);
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}

class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantItem({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Hero(
          tag: 'restaurant_image_${restaurant.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.network(
                'https://restaurant-api.dicoding.dev/images/medium/${restaurant.pictureId}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        title: Hero(
          tag: 'restaurant_title_${restaurant.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              restaurant.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        subtitle: Text('${restaurant.city} • Rating: ${restaurant.rating}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailPage(restaurant: restaurant),
            ),
          );
        },
      ),
    );
  }
}
