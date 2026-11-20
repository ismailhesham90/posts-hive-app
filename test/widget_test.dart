import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:posts_hive_app/models/post_model.dart';
import 'package:posts_hive_app/services/favorites_service.dart';

void main() {
  // A fresh Hive box is opened in an in-memory location for every test so the
  // tests are fully isolated from one another and from any persisted data.
  const String testBoxName = 'favoritesBox';

  setUpAll(() async {
    Hive.init('/tmp/hive_posts_test');
    Hive.registerAdapter(PostAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Post serialization', () {
    test('fromJson maps id, title, body and userId', () {
      final Post post = Post.fromJson(<String, dynamic>{
        'id': 1,
        'title': 'Hello',
        'body': 'World',
        'userId': 42,
      });

      expect(post.id, 1);
      expect(post.title, 'Hello');
      expect(post.body, 'World');
      expect(post.userId, 42);
    });

    test('Post round-trips through Hive via TypeAdapter', () async {
      final Box<Post> box = await Hive.openBox<Post>(testBoxName);
      final Post post = Post(
        id: 7,
        title: 'Cached',
        body: 'Offline first',
        userId: 3,
      );

      await box.put(post.id, post);
      final Post? loaded = box.get(post.id);

      expect(loaded, isNotNull);
      expect(loaded!.id, 7);
      expect(loaded.title, 'Cached');
      expect(loaded.body, 'Offline first');
      expect(loaded.userId, 3);

      await box.deleteFromDisk();
    });
  });

  group('FavoritesService logic', () {
    late Box<Post> box;

    setUp(() async {
      box = await Hive.openBox<Post>(testBoxName);
      await box.clear();
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('isFavorite returns false for an unknown id', () {
      final FavoritesService service = FavoritesService();
      expect(service.isFavorite(999), isFalse);
    });

    test('toggleFavorite adds a post and isFavorite becomes true', () async {
      final FavoritesService service = FavoritesService();
      final Post post = Post(
        id: 1,
        title: 'Title',
        body: 'Body',
        userId: 5,
      );

      await service.toggleFavorite(post);
      expect(service.isFavorite(1), isTrue);
      expect(service.getFavorites(), hasLength(1));
    });

    test('toggleFavorite removes a post when toggled twice', () async {
      final FavoritesService service = FavoritesService();
      final Post post = Post(
        id: 2,
        title: 'Title',
        body: 'Body',
        userId: 5,
      );

      await service.toggleFavorite(post);
      expect(service.isFavorite(2), isTrue);

      await service.toggleFavorite(post);
      expect(service.isFavorite(2), isFalse);
      expect(service.getFavorites(), isEmpty);
    });

    test(
        'CRITICAL LAB RULE: a post copied into favoritesBox is independent '
        'from the source instance', () async {
      final FavoritesService service = FavoritesService();
      final Post source = Post(
        id: 3,
        title: 'Source',
        body: 'Source body',
        userId: 9,
      );

      await service.toggleFavorite(source);

      // Mutating the source must not affect the stored favorite.
      source.title = 'Mutated';
      source.body = 'Mutated body';

      final List<Post> favorites = service.getFavorites();
      expect(favorites, hasLength(1));
      expect(favorites.first.title, 'Source');
      expect(favorites.first.body, 'Source body');
    });
  });
}