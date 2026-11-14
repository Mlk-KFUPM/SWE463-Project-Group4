import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Local UI state: only this screen needs it, so it stays here.
  String _query = '';
  RecipeCategory? _selectedCategory; // null means all categories

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    // Spaces typed before or after the text are ignored.
    final query = _query.trim().toLowerCase();

    // Keep recipes whose title contains the text AND match the chip (if any).
    final results = provider.recipes.where((recipe) {
      final matchesText = recipe.title.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null || recipe.category == _selectedCategory;
      return matchesText && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search recipes',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final category in RecipeCategory.values)
                  ChoiceChip(
                    label: Text(categoryLabel(category)),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        // Tapping the selected chip again clears the filter.
                        if (_selectedCategory == category) {
                          _selectedCategory = null;
                        } else {
                          _selectedCategory = category;
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults(provider, results)),
        ],
      ),
    );
  }

  Widget _buildResults(RecipeProvider provider, List<Recipe> results) {
    if (provider.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return const Center(child: Text('No results'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final recipe = results[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () => context.push('/recipe/${recipe.id}'),
        );
      },
    );
  }
}
