import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_step.dart';

/// TEMPORARY in-memory recipe service for Phase 3.
/// Phase 4 replaces the method bodies with Cloud Firestore calls;
/// the method signatures stay the same so the providers do not change.
class RecipeService {
  bool simulateError = false; // set to true to demo the error state on S2

  final List<Recipe> _recipes = [
    Recipe(
      id: 'r1',
      authorId: 'u1',
      authorName: 'Test User',
      title: 'Chicken Kabsa',
      category: RecipeCategory.mainDish,
      prepTimeMinutes: 90,
      servings: 4,
      difficulty: Difficulty.medium,
      ingredients: const [
        Ingredient(quantity: 1.5, unit: 'kg', name: 'Chicken'),
        Ingredient(quantity: 3, unit: 'cups', name: 'Basmati rice'),
        Ingredient(quantity: 2, unit: 'tbsp', name: 'Kabsa spices'),
      ],
      steps: const [
        RecipeStep(text: 'Brown the chicken with onion and spices.'),
        RecipeStep(text: 'Add water and cook the chicken until tender.'),
        RecipeStep(text: 'Add the rice and cook on low heat for 30 minutes.'),
      ],
      createdAt: DateTime(2026, 11, 2),
    ),
    Recipe(
      id: 'r2',
      authorId: 'u1',
      authorName: 'Test User',
      title: 'Luqaimat',
      category: RecipeCategory.dessert,
      prepTimeMinutes: 45,
      servings: 6,
      difficulty: Difficulty.easy,
      ingredients: const [
        Ingredient(quantity: 2, unit: 'cups', name: 'Flour'),
        Ingredient(quantity: 1, unit: 'tbsp', name: 'Yeast'),
        Ingredient(quantity: 0.5, unit: 'cup', name: 'Date syrup'),
      ],
      steps: const [
        RecipeStep(text: 'Mix flour, yeast and warm water, then let it rise.'),
        RecipeStep(text: 'Fry small balls of dough until golden.'),
        RecipeStep(text: 'Pour date syrup on top and serve.'),
      ],
      createdAt: DateTime(2026, 11, 3),
    ),
  ];

  Future<List<Recipe>> fetchRecipes() async {
    await Future.delayed(const Duration(seconds: 1));
    if (simulateError) {
      throw Exception('Could not load recipes. Check your connection.');
    }
    return List.of(_recipes);
  }

  /// Saves the recipe and returns it with its new id.
  Future<Recipe> addRecipe(Recipe recipe) async {
    await Future.delayed(const Duration(seconds: 1));
    final saved = recipe.copyWith(id: 'r${_recipes.length + 1}');
    _recipes.insert(0, saved);
    return saved;
  }
}
