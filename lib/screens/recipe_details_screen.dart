import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe details')),
      body: const Center(child: Text('Recipe details')),
    );
  }
}
