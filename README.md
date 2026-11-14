# Sufrah (سفرة)

A bilingual community recipe application for Arabic-speaking home cooks, built with Flutter for SWE 463 (Group 4). Users sign in, browse and search recipes shared by others, open a recipe to cook from it, and publish their own recipes.

This is the Phase 3 working prototype.

## Setup and run

```bash
flutter pub get
flutter run
```

Test account: `test@sufrah.app` / `test1234` (or create a new account on the sign-up form).

## Phase 3 features

| # | Feature | Status |
|---|---------|--------|
| F1 | Account and profile (sign in, sign up, profile, sign out) | Implemented |
| F2 | Discover feed and search | Implemented |
| F3 | Recipe details with servings scaling | Implemented |
| F4 | Create and publish a recipe | Implemented |
| F5 | Save and like | Not started |
| F6 | Arabic and English interface | Not started |

End-to-end flow: Create tab → fill in the recipe form → Publish → the new recipe appears at the top of the Discover feed.

## Packages

| Package | Version | Purpose | Licence |
|---------|---------|---------|---------|
| `go_router` | ^18.0.2 | Routing and the bottom navigation shell | BSD-3-Clause |
| `provider` | ^6.1.5+1 | Shared app state (AuthProvider, RecipeProvider) | MIT |
| `firebase_core` | ^5.0.0 | Firebase setup, for the Phase 4 backend | BSD-3-Clause |
| `cloud_firestore` | ^7.0.0 | Firestore types used by the data models | BSD-3-Clause |
| `cupertino_icons` | ^1.0.8 | iOS-style icon font (Flutter template default) | MIT |
| `flutter_lints` (dev) | ^6.0.0 | Static analysis rules | BSD-3-Clause |

## Data source

Phase 3 uses a temporary in-memory data layer in `lib/services/`:

- `AuthService`: sign in, sign up and sign out.
- `RecipeService`: loads the recipe list (two sample recipes) and saves new recipes.

Screens never call the services directly. They go through the providers in `lib/providers/`. In Phase 4 the service method bodies will be replaced with Firebase Authentication and Cloud Firestore, without changing the screens or providers.

## Known issues

- Data is kept in memory only, so new accounts and recipes are lost when the app restarts.
- Firebase is not connected yet (planned for Phase 4).
- The Arabic interface (F6) and save/like (F5) are not done yet.

## AI-use disclosure

As allowed by the course, we used Claude Code (Anthropic) as a helper. Each member reviewed, tested and can explain the code they submitted.

- Phase 2 starter project (routing, placeholder screens): generated with Claude Code.
- Abdulmalik Alsafadi: used Claude Code to help write the foundation (services and providers), the S5 create recipe form and this README.
- Faris Alshahrany: used Claude Code to help write the S2 Discover feed (loading, empty and error states), the S3 search with category chips and the RecipeCard widget.
- Abdullah Baleid: used Claude Code to help write the S4 recipe details screen with the servings stepper, to merge and test the Phase 3 branches, and to share the category and difficulty labels across screens.
- Abdullah Binsheheween: used Claude Code to help write the S1 sign in / sign up form, the S6 profile screen with sign out and the sign-in redirect in the router.
