import 'package:flutter/foundation.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';

enum LoadStatus { loading, loaded, empty, error }

/// Shared recipe list used by S2, S3, S4 and S5.
class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();

  List<Recipe> recipes = [];
  LoadStatus status = LoadStatus.loading;
  String? error;

  Future<void> loadRecipes() async {
    status = LoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      recipes = await _service.fetchRecipes();
      status = recipes.isEmpty ? LoadStatus.empty : LoadStatus.loaded;
    } catch (e) {
      error = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Throws if saving fails, so the S5 form can show the error.
  Future<void> addRecipe(Recipe recipe) async {
    final saved = await _service.addRecipe(recipe);
    recipes.insert(0, saved);
    status = LoadStatus.loaded;
    notifyListeners();
  }

  Recipe? findById(String id) {
    for (final r in recipes) {
      if (r.id == id) return r;
    }
    return null;
  }
}
