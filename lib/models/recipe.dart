import 'package:cloud_firestore/cloud_firestore.dart';

import 'ingredient.dart';
import 'recipe_step.dart';

enum RecipeCategory { mainDish, appetiser, dessert, drink }

enum Difficulty { easy, medium, hard }

/// A published recipe, stored in the `recipes` collection.
/// Ingredients and steps live inside the same document so the
/// details screen only needs one read.
class Recipe {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final RecipeCategory category;
  final int prepTimeMinutes;
  final int servings;
  final Difficulty difficulty;
  final String? coverImageUrl;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final int likeCount;
  final int saveCount;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.category,
    required this.prepTimeMinutes,
    required this.servings,
    required this.difficulty,
    this.coverImageUrl,
    required this.ingredients,
    required this.steps,
    this.likeCount = 0,
    this.saveCount = 0,
    required this.createdAt,
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String? ?? '',
      title: map['title'] as String,
      category: RecipeCategory.values.byName(map['category'] as String),
      prepTimeMinutes: map['prepTimeMinutes'] as int,
      servings: map['servings'] as int,
      difficulty: Difficulty.values.byName(map['difficulty'] as String),
      coverImageUrl: map['coverImageUrl'] as String?,
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Ingredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      steps: (map['steps'] as List<dynamic>? ?? [])
          .map((e) => RecipeStep.fromMap(e as Map<String, dynamic>))
          .toList(),
      likeCount: map['likeCount'] as int? ?? 0,
      saveCount: map['saveCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'category': category.name,
      'prepTimeMinutes': prepTimeMinutes,
      'servings': servings,
      'difficulty': difficulty.name,
      'coverImageUrl': coverImageUrl,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'steps': steps.map((s) => s.toMap()).toList(),
      'likeCount': likeCount,
      'saveCount': saveCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Recipe copyWith({String? id, int? likeCount, int? saveCount}) {
    return Recipe(
      id: id ?? this.id,
      authorId: authorId,
      authorName: authorName,
      title: title,
      category: category,
      prepTimeMinutes: prepTimeMinutes,
      servings: servings,
      difficulty: difficulty,
      coverImageUrl: coverImageUrl,
      ingredients: ingredients,
      steps: steps,
      likeCount: likeCount ?? this.likeCount,
      saveCount: saveCount ?? this.saveCount,
      createdAt: createdAt,
    );
  }
}
