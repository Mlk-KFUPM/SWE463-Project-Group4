import 'package:go_router/go_router.dart';

import '../screens/create_recipe_screen.dart';
import '../screens/discover_feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/recipe_details_screen.dart';
import '../screens/search_screen.dart';
import '../screens/sign_in_screen.dart';
import '../widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/sign-in',
  routes: [
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/recipe',
      builder: (context, state) => const RecipeDetailsScreen(),
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
