# Sufrah (سفرة)

A bilingual community recipe application for Arabic-speaking home cooks, built with Flutter for SWE 463 (Group 4). Users sign in, browse and search recipes shared by others, open a recipe to cook from it, and publish their own recipes.

This is the Phase 3 working prototype. The submitted version is tagged `phase-3`.

## Setup and run

Requirements: Flutter 3.47 (Dart 3.13) or newer.

```bash
flutter pub get
flutter run
```

The project includes the Android, iOS and web platforms (for example `flutter run -d chrome`).

Test account: `test@sufrah.app` / `test1234` (or create a new account on the sign-up form).

## Phase 3 features

| # | Feature | Screens | Status |
|---|---------|---------|--------|
| F1 | Account and profile (sign in, sign up, profile, sign out) | S1, S6 | Implemented |
| F2 | Discover feed and search | S2, S3 | Implemented |
| F3 | Recipe details with servings scaling | S4 | Implemented |
| F4 | Create and publish a recipe | S5 | Implemented |
| F5 | Save and like | S2, S4, S6 | Not started (Phase 4) |
| F6 | Arabic and English interface | All | Not started (Phase 4) |

End-to-end flow: Create tab → fill in the recipe form → Publish → the new recipe appears at the top of the Discover feed, opens in Recipe details and can be found in Search.

## How to test

1. **Sign in (S1).** Tap Sign in with empty fields to see the errors under each field. Try `abc` / `123` to see the email and password rules; each error clears as soon as the field is fixed. Try the test account with a wrong password to see "Wrong email or password." Use the eye icon to show or hide the password. Then sign in with `test@sufrah.app` / `test1234`.
2. **Discover feed (S2).** The feed shows a loading spinner, then two recipes. Pull down to refresh. Tap a card to open it.
3. **Recipe details (S4).** Chicken Kabsa is written for 4 servings. Press + once: 1.5 kg chicken becomes 1.9 kg and 3 cups rice becomes 3.8 cups. The − button stops at 1. The back arrow returns to the previous screen.
4. **Search (S3).** Type part of a title (`luq`) or an ingredient (`rice`). Pick a category chip to filter; tap it again to clear it. Type `zzz` to see "No results".
5. **Create recipe (S5), the end-to-end flow.** Tap Publish on the empty form to see the validation errors. Fill in a title, category, difficulty, prep time, servings, one ingredient and one step, then tap Publish. A "Recipe published" message appears and the new recipe is at the top of the feed. Open it and change its servings, then find it in Search.
6. **Profile (S6).** Shows your initial, name and email. Sign out returns to S1, and Back does not return to the app.
7. **Sign up.** On S1 tap "No account? Sign up", create an account, and check that Profile shows the new name. Signing up again with the same email shows an error.
8. **Error state.** Set `simulateError = true` in `lib/services/recipe_service.dart` and restart the app. The feed and Search show "Could not load recipes. Check your connection." with a Try again button.

### Automated tests

```bash
flutter analyze
flutter test
```

`test/app_flow_test.dart` starts the real app (router, providers and in-memory services) and goes through F1 to F4 like a user, covering every step above: validation, the password eye icon, the redirect for signed-out users, the feed, empty and error states, servings scaling, search by title, ingredient and category, publishing a recipe, and sign out / sign up.

## Project structure

```text
lib/
  main.dart        App start: providers and the router
  models/          AppUser, Recipe, Ingredient, RecipeStep
  services/        Temporary in-memory AuthService and RecipeService
  providers/       AuthProvider and RecipeProvider (shared state)
  router/          go_router routes, bottom navigation shell, sign-in redirect
  screens/         S1 to S6
  widgets/         MainShell (bottom navigation) and RecipeCard
test/
  app_flow_test.dart
```

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

Both services wait one second before answering, like a network call, so the loading states are visible. Screens never call the services directly. They go through the providers in `lib/providers/`. In Phase 4 the service method bodies will be replaced with Firebase Authentication and Cloud Firestore, without changing the screens or providers. No API keys or other secrets are stored in the repository.

## Known issues

- Data is kept in memory only, so new accounts and recipes are lost when the app restarts.
- Firebase is not connected yet (planned for Phase 4).
- The Arabic interface (F6) and save/like (F5) are not done yet.
- Some screens are simpler than the Phase 2 design: S5 is a single-page form (no step bar, preview or photos), S3 searches titles and ingredients and filters by category but has no prep time or difficulty filters, S6 has no Published/Saved tabs or settings yet, and recipe cards show an icon instead of a photo.

## Team and contributions

| Member | Phase 3 work | Branch and pull request |
|--------|--------------|-------------------------|
| Abdulmalik Alsafadi (team lead) | Services and providers, F4 create recipe form (S5), README | `foundation` (#2), `abdulmalik/create-recipe` (#4) |
| Faris Alshahrany | F2 Discover feed (S2), search (S3), RecipeCard widget | `faris/feed-search` (#5) |
| Abdullah Baleid | F3 recipe details with servings stepper (S4), merging and testing the branches, end-to-end tests, fixes after the merge | `baleid/recipe-details` (#3), commits on `main` |
| Abdullah Binsheheween | F1 sign in / sign up (S1), profile (S6), sign-in redirect | `binsheheween/auth` (#6) |

## AI-use disclosure

As allowed by the course, we used Claude Code (Anthropic) as a helper. Each member reviewed, tested and can explain the code they submitted.

- Phase 2 starter project (routing, placeholder screens): generated with Claude Code.
- Abdulmalik Alsafadi: used Claude Code to help write the services, providers, create recipe form, and README.
- Faris Alshahrany: used Claude Code to help build the Discover feed, search filters, and recipe cards.
- Abdullah Baleid: used Claude Code to help write the S4 recipe details screen with the servings stepper, to merge and test the Phase 3 branches, to write the end-to-end tests, and for small fixes after the merge (shared category and difficulty labels, the search error state, extra spaces and ingredient names in search, the empty-feed button, the password eye icon, the sign out button, and form errors that now stay on the right field and clear once fixed).
- Abdullah Binsheheween: used Claude Code to help build the sign-in and sign-up form, profile screen, and sign-in redirects.
