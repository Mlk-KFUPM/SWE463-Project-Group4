import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'router/app_router.dart';

void main() {
  // One AuthProvider shared by the widgets (through Provider) and the router.
  final auth = AuthProvider();
  final router = createRouter(auth);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => RecipeProvider()..loadRecipes()),
      ],
      child: SufrahApp(router: router),
    ),
  );
}

class SufrahApp extends StatelessWidget {
  const SufrahApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sufrah',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      routerConfig: router,
    );
  }
}
