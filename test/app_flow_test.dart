// End-to-end widget tests for the Phase 3 prototype.
// They run the real app (router, providers and in-memory services)
// and walk through features F1 to F4 like a user would.
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:sufrah/main.dart';
import 'package:sufrah/models/recipe.dart';
import 'package:sufrah/providers/auth_provider.dart';
import 'package:sufrah/providers/recipe_provider.dart';
import 'package:sufrah/router/app_router.dart';
import 'package:sufrah/screens/search_screen.dart';
import 'package:sufrah/widgets/recipe_card.dart';

/// Builds the app the same way main() does.
Future<AuthProvider> startApp(WidgetTester tester) async {
  // A tall screen so the whole create form fits without scrolling.
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final auth = AuthProvider();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => RecipeProvider()..loadRecipes()),
      ],
      child: SufrahApp(router: createRouter(auth)),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

Finder field(String label) => find.widgetWithText(TextFormField, label);
Finder tab(String label) => find.widgetWithText(NavigationDestination, label);

Future<void> signIn(WidgetTester tester, String email, String password) async {
  await tester.enterText(field('Email'), email);
  await tester.enterText(field('Password'), password);
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
}

/// Lets any open SnackBar time out so no timers are left running.
Future<void> waitForSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F1 sign in: validation, wrong password and redirect', (
    tester,
  ) async {
    final auth = await startApp(tester);
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.enterText(field('Password'), '123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // The eye icon shows and hides the password.
    bool passwordHidden() => tester
        .widget<TextField>(
          find.descendant(
            of: field('Password'),
            matching: find.byType(TextField),
          ),
        )
        .obscureText;
    expect(passwordHidden(), isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(passwordHidden(), isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pumpAndSettle();
    expect(passwordHidden(), isTrue);

    await signIn(tester, 'test@sufrah.app', 'wrongpass');
    expect(find.text('Wrong email or password.'), findsOneWidget);
    expect(auth.isSignedIn, isFalse);
    await waitForSnackBars(tester);

    // Signed-out users are sent back to sign in.
    final context = tester.element(find.byType(Scaffold).first);
    context.go('/feed');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
    context.go('/recipe/r1');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);

    await signIn(tester, 'test@sufrah.app', 'test1234');
    expect(auth.isSignedIn, isTrue);
    expect(find.widgetWithText(AppBar, 'Discover'), findsOneWidget);
  });

  testWidgets('F2 + F3: feed opens recipe details and servings scale', (
    tester,
  ) async {
    await startApp(tester);
    await signIn(tester, 'test@sufrah.app', 'test1234');

    expect(find.byType(RecipeCard), findsNWidgets(2));
    await tester.tap(find.text('Chicken Kabsa'));
    await tester.pumpAndSettle();

    expect(find.text('By Test User'), findsOneWidget);
    expect(find.text('Main dish'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('• 1.5 kg Chicken'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('• 1.9 kg Chicken'), findsOneWidget);
    expect(find.text('• 3.8 cups Basmati rice'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
    }
    expect(find.text('• 0.4 kg Chicken'), findsOneWidget);
    final minus = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove),
    );
    expect(minus.onPressed, isNull, reason: 'servings cannot go below 1');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Discover'), findsOneWidget);

    // An unknown id shows a message instead of crashing.
    tester.element(find.byType(Scaffold).first).push('/recipe/missing');
    await tester.pumpAndSettle();
    expect(find.text('Recipe not found'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // An empty feed offers a button that opens the Create tab.
    final provider = tester
        .element(find.byType(RecipeCard).first)
        .read<RecipeProvider>();
    provider.recipes = [];
    provider.status = LoadStatus.empty;
    provider.notifyListeners();
    await tester.pump();
    expect(find.text('No recipes yet'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Create recipe'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Create recipe'), findsOneWidget);
  });

  testWidgets('F2 search: title, category chips, spaces and load error', (
    tester,
  ) async {
    await startApp(tester);
    await signIn(tester, 'test@sufrah.app', 'test1234');
    await tester.tap(tab('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'LUQ');
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.text('Luqaimat'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  kabsa  ');
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.text('Chicken Kabsa'), findsOneWidget);

    // Ingredient names are searched too: Basmati rice is in the Kabsa.
    await tester.enterText(find.byType(TextField), 'rice');
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.text('Chicken Kabsa'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dessert'));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.text('Luqaimat'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'kabsa');
    await tester.pumpAndSettle();
    expect(find.text('No results'), findsOneWidget);

    // Tapping the selected chip again clears the category filter.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dessert'));
    await tester.pumpAndSettle();
    expect(find.text('Chicken Kabsa'), findsOneWidget);

    // When loading fails, search shows the error and a retry button.
    final provider = tester
        .element(find.byType(SearchScreen))
        .read<RecipeProvider>();
    provider.status = LoadStatus.error;
    provider.error =
        'Exception: Could not load recipes. Check your connection.';
    provider.notifyListeners();
    await tester.pump();
    expect(
      find.text('Could not load recipes. Check your connection.'),
      findsOneWidget,
    );
    expect(find.text('No results'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Chicken Kabsa'), findsOneWidget);
  });

  testWidgets('F4 create: validation, publish, then find it everywhere', (
    tester,
  ) async {
    await startApp(tester);
    await signIn(tester, 'test@sufrah.app', 'test1234');
    await tester.tap(tab('Create'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Publish'));
    await tester.pumpAndSettle();
    expect(find.text('Title must be at least 3 characters'), findsOneWidget);
    expect(find.text('Choose a category'), findsOneWidget);
    expect(find.text('Choose a difficulty'), findsOneWidget);

    await tester.enterText(field('Title'), 'Mint Tea');
    await tester.tap(find.byType(DropdownButtonFormField<RecipeCategory>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drink').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<Difficulty>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Easy').last);
    await tester.pumpAndSettle();
    await tester.enterText(field('Prep time (minutes)'), '10');
    await tester.enterText(field('Servings'), '2');
    await tester.enterText(field('Qty'), '3');
    await tester.enterText(field('Unit'), 'cups');
    await tester.enterText(field('Name'), 'Water');
    await tester.enterText(field('Step 1'), 'Boil water with mint.');
    await tester.tap(find.widgetWithText(FilledButton, 'Publish'));
    await tester.pumpAndSettle();

    // Back on the feed with the new recipe first.
    expect(find.text('Recipe published'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Discover'), findsOneWidget);
    final cards = tester.widgetList<RecipeCard>(find.byType(RecipeCard));
    expect(cards.length, 3);
    expect(cards.first.recipe.title, 'Mint Tea');
    expect(cards.first.recipe.authorName, 'Test User');
    await waitForSnackBars(tester);

    await tester.tap(find.text('Mint Tea'));
    await tester.pumpAndSettle();
    expect(find.text('• 3 cups Water'), findsOneWidget);
    expect(find.text('Boil water with mint.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('• 4.5 cups Water'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(tab('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Drink'));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsOneWidget);
    expect(find.text('Mint Tea'), findsOneWidget);

    // The form is empty again for the next recipe.
    await tester.tap(tab('Create'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(field('Title')).controller!.text,
      isEmpty,
    );
  });

  testWidgets('F1 profile: sign out, sign up and duplicate email', (
    tester,
  ) async {
    await startApp(tester);
    await signIn(tester, 'test@sufrah.app', 'test1234');

    await tester.tap(tab('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@sufrah.app'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);

    await tester.tap(find.text('No account? Sign up'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(field('Name'), 'sara');
    await tester.enterText(field('Email'), 'sara@example.com');
    await tester.enterText(field('Password'), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Discover'), findsOneWidget);

    await tester.tap(tab('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('sara'), findsOneWidget);
    expect(find.text('sara@example.com'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No account? Sign up'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Name'), 'sara');
    await tester.enterText(field('Email'), 'sara@example.com');
    await tester.enterText(field('Password'), 'secret1');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();
    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
    await waitForSnackBars(tester);

    // The new account can sign back in.
    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();
    await signIn(tester, 'sara@example.com', 'secret1');
    expect(find.widgetWithText(AppBar, 'Discover'), findsOneWidget);
  });
}
