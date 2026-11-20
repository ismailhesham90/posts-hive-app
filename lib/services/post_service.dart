import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../models/post_model.dart';

class PostService {
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  static const String _boxName = 'postsBox';

  static const List<String> _englishTitles = <String>[
    'Getting Started with Flutter and Hive NoSQL Storage',
    'Understanding Offline-First Mobile Architecture',
    'State Management Best Practices in Modern Dart',
    'How to Cache REST API Data Locally with Hive',
    'Building Responsive and Adaptive Mobile Layouts',
    'Optimizing Network Requests and Error Handling',
    'Securing Mobile Applications and Stored Data',
    'Flutter Widget Lifecycle and State Synchronization',
    'Clean Architecture Principles in Mobile Development',
    'Deep Dive into Asynchronous Programming with Streams',
    'Creating Custom TypeAdapters for Hive Persistence',
    'Managing User Authentication and Session Tokens',
    'Designing Intuitive Dark and Light Theme Modes',
    'Automated Testing: Unit, Widget, and Integration',
    'Performance Tuning and Memory Management in Flutter',
    'Implementing Smooth Animations and Micro-Interactions',
    'Handling Background Tasks and Push Notifications',
    'Working with Local Databases: Hive vs SQLite',
    'Cross-Platform Deployment on iOS, Android, and Web',
    'Continuous Integration and Delivery for Mobile Apps',
  ];

  static const List<String> _englishBodies = <String>[
    'Learn how to build resilient mobile applications that continue to function seamlessly even when there is no active internet connection.',
    'Discover the power of lightweight key-value NoSQL databases in pure Dart for fast data serialization and instant read access.',
    'Explore practical patterns for managing state across complex widget trees while keeping code clean, testable, and maintainable.',
    'A comprehensive step-by-step guide on caching remote JSON responses into local storage and syncing data efficiently upon reconnection.',
    'Ensure your user interface scales beautifully across phones, tablets, and desktop displays with flexible layout widgets.',
    'Implement robust error boundaries, retries, and informative feedback to keep users informed during unexpected network drops.',
    'Protect sensitive user data on device storage using advanced encryption standards and secure credential management.',
    'Master the Flutter build cycle, rebuild optimizations, and ValueNotifier patterns for 60fps high-performance apps.',
    'Organize your codebase into independent presentation, domain, and data layers for long-term scalability and team collaboration.',
    'Harness Dart Futures and Streams to process real-time data feeds, user inputs, and asynchronous background events.',
  ];

  static Post _toEnglish(Post post) {
    final int index = post.id - 1;
    final String title = _englishTitles[index % _englishTitles.length];
    final String body = _englishBodies[index % _englishBodies.length];
    return Post(
      id: post.id,
      title: title,
      body: body,
      userId: post.userId,
    );
  }

  Box<Post> get _box => Hive.box<Post>(_boxName);

  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
        final List<Post> onlinePosts = decoded
            .map((dynamic e) => _toEnglish(Post.fromJson(e as Map<String, dynamic>)))
            .toList();

        final Box<Post> box = _box;
        await box.clear();
        await box.addAll(onlinePosts);

        debugPrint('Loaded from API and cached to Hive: ${onlinePosts.length}');
        return onlinePosts;
      }

      // Non-200 response: fall through to offline cache.
      throw Exception('API responded with status ${response.statusCode}');
    } catch (_) {
      final Box<Post> box = _box;
      if (box.isNotEmpty) {
        debugPrint('Loaded from Hive offline: ${box.length}');
        return box.values.toList();
      }
      throw Exception('No Internet and No Cached Data');
    }
  }
}
