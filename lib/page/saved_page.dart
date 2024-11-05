import 'package:faap/Helpers/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favorites = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Items"),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text("No items saved"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 50,
                    height: 50,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 30),
                  ),
                  title: Text(item.name),
                  subtitle: Text("Price: ${item.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      favoritesProvider.removeFavorite(item.name);
                    },
                  ),
                );
              },
            ),
    );
  }
}
