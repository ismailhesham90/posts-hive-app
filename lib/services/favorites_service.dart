import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';

class FavoritesService {
  static const String _boxName = 'favoritesBox';

  Box<Post> get _box => Hive.box<Post>(_boxName);

  Future<void> toggleFavorite(Post post) async {
    // CRITICAL LAB RULE: A HiveObject can only live in one box at a time.
    // The post instance comes from postsBox, so putting it directly into
    // favoritesBox throws HiveError. ALWAYS save a copy.
    final Post copy = Post(
      id: post.id,
      title: post.title,
      body: post.body,
      userId: post.userId,
    );

    if (_box.containsKey(post.id)) {
      await _box.delete(post.id);
    } else {
      await _box.put(post.id, copy);
    }
  }

  bool isFavorite(int id) => _box.containsKey(id);

  List<Post> getFavorites() => _box.values.toList();

  ValueListenable<Box<Post>> get listenable =>
      Hive.box<Post>(_boxName).listenable();
}