import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  // Servings picked with the stepper. Null means the user has not changed it
  // yet, so we use the recipe's own servings.
  int? _selectedServings;

  // Shows 3.0 as "3" and 1.875 as "1.9".
  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final recipe = provider.findById(widget.recipeId);

    if (provider.status == LoadStatus.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe details')),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    final servings = _selectedServings ?? recipe.servings;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            recipe.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text('By ${recipe.authorName}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(categoryLabel(recipe.category))),
              Chip(label: Text('${recipe.prepTimeMinutes} min')),
              Chip(label: Text(difficultyLabel(recipe.difficulty))),
            ],
          ),
          const SizedBox(height: 16),

          // Servings stepper
          Row(
            children: [
              const Text('Servings'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                // Disabled at 1 so servings never go below the minimum.
                onPressed: servings > 1
                    ? () => setState(() => _selectedServings = servings - 1)
                    : null,
              ),
              Text('$servings'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () =>
                    setState(() => _selectedServings = servings + 1),
              ),
            ],
          ),
          const Divider(),

          Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final ingredient in recipe.ingredients)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• ${_formatQuantity(ingredient.scaledQuantity(recipe.servings, servings))} '
                '${ingredient.unit} ${ingredient.name}',
              ),
            ),
          const Divider(),

          Text('Steps', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < recipe.steps.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(recipe.steps[i].text),
            ),
        ],
      ),
    );
  }
}
