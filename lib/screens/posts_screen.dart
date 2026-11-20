import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';
import '../services/favorites_service.dart' as fav;

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService _service = PostService();
  final fav.FavoritesService _fav =
      fav.FavoritesService();
  late Future<List<Post>> _postsFuture;

  _PostsScreenState() {
    _postsFuture = _service.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed<void>(
                context,
                '/favorites',
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          final List<Post> posts = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _postsFuture = _service.getPosts();
              });
            },
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                final Post post = posts[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(post.id.toString())),
                    title: Text(
                      post.title,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(post.body, maxLines: 2),
                    trailing: ValueListenableBuilder<Box<Post>>(
                      valueListenable:
                          Hive.box<Post>('favoritesBox').listenable(),
                      builder: (BuildContext context, Box<Post> box, Widget? child) {
                        final bool isFavorite = _fav.isFavorite(post.id);
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.amber : null,
                          ),
                          onPressed: () => _fav.toggleFavorite(post),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}