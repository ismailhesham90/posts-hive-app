import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';
import '../services/favorites_service.dart' as fav;

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final fav.FavoritesService favoritesService = fav.FavoritesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: ValueListenableBuilder<Box<Post>>(
        valueListenable: Hive.box<Post>('favoritesBox').listenable(),
        builder: (BuildContext context, Box<Post> box, Widget? child) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.star_border, size: 64, color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final List<Post> favorites = box.values.toList();
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (BuildContext context, int index) {
              final Post post = favorites[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(post.id.toString())),
                  title: Text(
                    post.title,
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(post.body, maxLines: 2),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: Colors.amber),
                    onPressed: () => favoritesService.toggleFavorite(post),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}