import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/recipe_step.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

/// The three text fields of one ingredient row.
class _IngredientFields {
  final quantity = TextEditingController();
  final unit = TextEditingController();
  final name = TextEditingController();

  void dispose() {
    quantity.dispose();
    unit.dispose();
    name.dispose();
  }
}

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  var _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _prepTime = TextEditingController();
  final _servings = TextEditingController();
  RecipeCategory? _category;
  Difficulty? _difficulty;
  List<_IngredientFields> _ingredients = [_IngredientFields()];
  List<TextEditingController> _steps = [TextEditingController()];
  bool _saving = false;

  // Off at first. After a failed Publish, each field is checked again as
  // soon as it changes, so an error goes away once the field is fixed.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _title.dispose();
    _prepTime.dispose();
    _servings.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return 'Enter a number above 0';
    return null;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    if (_ingredients.isEmpty || _steps.isEmpty) {
      _showMessage('Add at least one ingredient and one step.');
      return;
    }

    final user = context.read<AuthProvider>().user;
    final recipe = Recipe(
      id: '',
      authorId: user?.id ?? 'guest',
      authorName: user?.name ?? 'Guest',
      title: _title.text.trim(),
      category: _category!,
      prepTimeMinutes: int.parse(_prepTime.text.trim()),
      servings: int.parse(_servings.text.trim()),
      difficulty: _difficulty!,
      ingredients: _ingredients
          .map(
            (i) => Ingredient(
              quantity: double.parse(i.quantity.text.trim()),
              unit: i.unit.text.trim(),
              name: i.name.text.trim(),
            ),
          )
          .toList(),
      steps: _steps.map((s) => RecipeStep(text: s.text.trim())).toList(),
      createdAt: DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      await context.read<RecipeProvider>().addRecipe(recipe);
      if (!mounted) return;
      _showMessage('Recipe published');
      _clearForm();
      context.go('/feed');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not publish the recipe: $e');
    }
    if (mounted) setState(() => _saving = false);
  }

  /// Frees a removed row's controllers after the row has left the screen.
  void _disposeLater(VoidCallback dispose) {
    WidgetsBinding.instance.addPostFrameCallback((_) => dispose());
  }

  void _clearForm() {
    final oldIngredients = _ingredients;
    final oldSteps = _steps;
    setState(() {
      _formKey = GlobalKey<FormState>(); // a new key rebuilds empty fields
      _autovalidate = AutovalidateMode.disabled;
      _title.clear();
      _prepTime.clear();
      _servings.clear();
      _category = null;
      _difficulty = null;
      _ingredients = [_IngredientFields()];
      _steps = [TextEditingController()];
    });
    for (final i in oldIngredients) {
      _disposeLater(i.dispose);
    }
    for (final s in oldSteps) {
      _disposeLater(s.dispose);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create recipe')),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            DropdownButtonFormField<RecipeCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: RecipeCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(categoryLabel(c)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
              validator: (value) => value == null ? 'Choose a category' : null,
            ),
            DropdownButtonFormField<Difficulty>(
              initialValue: _difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: Difficulty.values
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(difficultyLabel(d)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _difficulty = value),
              validator: (value) =>
                  value == null ? 'Choose a difficulty' : null,
            ),
            TextFormField(
              controller: _prepTime,
              decoration: const InputDecoration(
                labelText: 'Prep time (minutes)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value?.trim() ?? '') == null
                  ? 'Enter a whole number'
                  : _positiveNumber(value),
            ),
            TextFormField(
              controller: _servings,
              decoration: const InputDecoration(labelText: 'Servings'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value?.trim() ?? '') == null
                  ? 'Enter a whole number'
                  : _positiveNumber(value),
            ),
            const SizedBox(height: 24),
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            for (final ingredient in _ingredients)
              Row(
                key: ObjectKey(ingredient),
                // Top-aligned so the fields stay level when an error shows.
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ingredient.quantity,
                      // Up to three lines so the error is not cut off in
                      // this narrow field.
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        errorMaxLines: 3,
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveNumber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: ingredient.unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: ingredient.name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: _required,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _ingredients.remove(ingredient));
                      _disposeLater(ingredient.dispose);
                    },
                  ),
                ],
              ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add ingredient'),
              onPressed: () =>
                  setState(() => _ingredients.add(_IngredientFields())),
            ),
            const SizedBox(height: 24),
            Text('Steps', style: Theme.of(context).textTheme.titleMedium),
            for (var i = 0; i < _steps.length; i++)
              Row(
                key: ObjectKey(_steps[i]),
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _steps[i],
                      decoration: InputDecoration(labelText: 'Step ${i + 1}'),
                      validator: _required,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      final step = _steps[i];
                      setState(() => _steps.removeAt(i));
                      _disposeLater(step.dispose);
                    },
                  ),
                ],
              ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add step'),
              onPressed: () =>
                  setState(() => _steps.add(TextEditingController())),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _publish,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }
}
