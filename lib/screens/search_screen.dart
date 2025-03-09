import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/models/restaurant.dart';
import 'package:restaurant_app/providers/restaurant_provider.dart';
import 'package:restaurant_app/widgets/loading_indicator.dart';
import 'package:restaurant_app/screens/restaurant_list_screen.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<RestaurantProvider>().searchRestaurants(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari restoran...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          return switch (provider.searchState) {
            Initial<List<Restaurant>>() => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Masukkan kata kunci pencarian',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Loading<List<Restaurant>>() => Center(child: loadingLottie()),
            Error<List<Restaurant>>() => const Center(
                child: Text('Error loading search results'),
              ),
            Success<List<Restaurant>>(data: final restaurants) => restaurants
                    .isEmpty
                ? const Center(child: Text('Tidak ada restoran yang ditemukan'))
                : ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return RestaurantItem(restaurant: restaurants[index]);
                    },
                  ),
          };
        },
      ),
    );
  }
}
