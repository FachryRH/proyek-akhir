import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/providers/favorite_provider.dart';
import 'package:restaurant_app/widgets/loading_indicator.dart';
import 'package:restaurant_app/widgets/error_message.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  RestaurantDetailPageState createState() => RestaurantDetailPageState();
}

class RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchRestaurantDetail(widget.restaurant.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<RestaurantProvider>(context, listen: false);
      await provider.addReview(
        widget.restaurant.id,
        _nameController.text,
        _reviewController.text,
      );

      await provider.fetchRestaurantDetail(widget.restaurant.id);

      _nameController.clear();
      _reviewController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    }
  }

  Widget _buildReviewSection(List<CustomerReview> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...reviews.map((review) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(review.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.review),
                    const SizedBox(height: 4),
                    Text(
                      review.date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reviewController,
            decoration: const InputDecoration(
              labelText: 'Review',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your review';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Restoran'),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return FutureBuilder<bool>(
                future: favoriteProvider.isFavorite(widget.restaurant.id),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () async {
                      final message = await favoriteProvider
                          .toggleFavorite(widget.restaurant);
                      if (message != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.restaurantDetailState is Loading) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Hero(
                    tag: 'restaurant_image_${widget.restaurant.id}',
                    child: Image.network(
                      'https://restaurant-api.dicoding.dev/images/large/${widget.restaurant.pictureId}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 64,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: loadingLottie()),
                ],
              ),
            );
          } else if (provider.restaurantDetailState
              is Success<RestaurantDetail>) {
            final restaurant =
                (provider.restaurantDetailState as Success<RestaurantDetail>)
                    .data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'restaurant_image_${widget.restaurant.id}',
                    child: Image.network(
                      'https://restaurant-api.dicoding.dev/images/large/${widget.restaurant.pictureId}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 64,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'restaurant_title_${widget.restaurant.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              restaurant.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text('${restaurant.city} • ${restaurant.address}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.rating.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (restaurant.rating).floor()
                                      ? Icons.star
                                      : index < restaurant.rating
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: restaurant.categories.map((category) {
                            return Chip(
                              label: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(restaurant.description),
                        const SizedBox(height: 16),
                        ExpansionTile(
                          title: const Text('Menu Makanan'),
                          children: restaurant.menus.foods
                              .map((food) => ListTile(title: Text(food.name)))
                              .toList(),
                        ),
                        ExpansionTile(
                          title: const Text('Menu Minuman'),
                          children: restaurant.menus.drinks
                              .map((drink) => ListTile(title: Text(drink.name)))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildReviewSection(restaurant.customerReviews),
                        const Divider(),
                        _buildReviewForm(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (provider.restaurantDetailState is Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    (provider.restaurantDetailState as Error).message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<RestaurantProvider>(context, listen: false)
                          .fetchRestaurantDetail(widget.restaurant.id);
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
