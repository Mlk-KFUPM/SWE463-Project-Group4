import 'package:flutter/material.dart';

import 'router/app_router.dart';

void main() {
  runApp(const SufrahApp());
}

class SufrahApp extends StatelessWidget {
  const SufrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sufrah',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      routerConfig: appRouter,
    );
  }
}
