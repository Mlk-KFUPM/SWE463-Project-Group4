import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscoverFeedScreen extends StatelessWidget {
  const DiscoverFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.push('/recipe'),
          child: const Text('Open recipe details'),
        ),
      ),
    );
  }
}
