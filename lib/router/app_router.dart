import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/create_recipe_screen.dart';
import '../screens/discover_feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/recipe_details_screen.dart';
import '../screens/search_screen.dart';
import '../screens/sign_in_screen.dart';
import '../widgets/main_shell.dart';

GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/sign-in',
    // Run redirect again every time AuthProvider calls notifyListeners().
    refreshListenable: auth,
    redirect: (context, state) {
      final onSignIn = state.matchedLocation == '/sign-in';
      if (!auth.isSignedIn && !onSignIn) return '/sign-in';
      if (auth.isSignedIn && onSignIn) return '/feed';
      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) =>
            RecipeDetailsScreen(recipeId: state.pathParameters['id']!),
      ),
      // The four tabs that share the bottom navigation bar.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const DiscoverFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const CreateRecipeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
