import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class DiscoverFeedScreen extends StatelessWidget {
  const DiscoverFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: rebuild this screen every time the provider calls notifyListeners.
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: RefreshIndicator(
        onRefresh: () => context.read<RecipeProvider>().loadRecipes(),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RecipeProvider provider) {
    switch (provider.status) {
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LoadStatus.empty:
        // A ListView so pull-to-refresh still works when there is nothing to show.
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 200),
            const Center(child: Text('No recipes yet')),
            const SizedBox(height: 16),
            // As in the design, an empty feed points the user to S5.
            Center(
              child: FilledButton(
                onPressed: () => context.go('/create'),
                child: const Text('Create recipe'),
              ),
            ),
          ],
        );

      case LoadStatus.error:
        final message = (provider.error ?? 'Something went wrong').replaceFirst(
          'Exception: ',
          '',
        );
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 150),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                onPressed: () => context.read<RecipeProvider>().loadRecipes(),
                child: const Text('Try again'),
              ),
            ),
          ],
        );

      case LoadStatus.loaded:
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: provider.recipes.length,
          itemBuilder: (context, index) {
            final recipe = provider.recipes[index];
            return RecipeCard(
              recipe: recipe,
              onTap: () => context.push('/recipe/${recipe.id}'),
            );
          },
        );
    }
  }
}
