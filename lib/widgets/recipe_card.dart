import 'package:flutter/material.dart';

import '../models/recipe.dart';

/// Readable name for a category, used on the card and the search chips.
String categoryLabel(RecipeCategory category) {
  switch (category) {
    case RecipeCategory.mainDish:
      return 'Main dish';
    case RecipeCategory.appetiser:
      return 'Appetiser';
    case RecipeCategory.dessert:
      return 'Dessert';
    case RecipeCategory.drink:
      return 'Drink';
  }
}

/// Readable name for a difficulty level.
String difficultyLabel(Difficulty difficulty) {
  switch (difficulty) {
    case Difficulty.easy:
      return 'Easy';
    case Difficulty.medium:
      return 'Medium';
    case Difficulty.hard:
      return 'Hard';
  }
}

/// One recipe in a list. Used by the Discover feed (S2) and Search (S3).
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.restaurant_menu),
        title: Text(recipe.title),
        subtitle: Text(
          'By ${recipe.authorName}\n'
          '${categoryLabel(recipe.category)} · '
          '${recipe.prepTimeMinutes} min · '
          '${difficultyLabel(recipe.difficulty)}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
