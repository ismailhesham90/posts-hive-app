import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/post_model.dart';
import 'screens/posts_screen.dart';
import 'screens/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PostAdapter());

  // Open boxes early
  await Hive.openBox<Post>('postsBox');
  await Hive.openBox<Post>('favoritesBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts Hive App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (BuildContext context, Widget? child) {
        final double screenWidth = MediaQuery.of(context).size.width;
        // If running directly on a mobile screen or in Chrome Device Mode (width <= 500):
        if (screenWidth <= 500) {
          return child ?? const SizedBox.shrink();
        }

        // On wide desktop/web displays: frame inside a centered iPhone-like viewport:
        return Container(
          color: const Color(0xFF1E1E2E), // Modern sleek backdrop
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 860),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 36,
                        spreadRadius: 4,
                        offset: Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF313244),
                      width: 4,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      home: const PostsScreen(),
      routes: <String, WidgetBuilder>{
        '/favorites': (BuildContext context) => FavoritesScreen(),
      },
    );
  }
}
