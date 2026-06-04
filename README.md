# FoodHub

FoodHub is a Flutter recipe discovery app for searching meals with [TheMealDB](https://www.themealdb.com/api.php), saving favorites, adding personal recipes with photos, and managing language/theme preferences.

## Screenshots
<img width="335" height="838" alt="image" src="https://github.com/user-attachments/assets/19d699f2-4609-417d-a878-efb7d3bc4f75" />

<img width="324" height="838" alt="image" src="https://github.com/user-attachments/assets/2444e9a5-6fd5-4bbf-b6f8-8baee170eaf0" />


## Implemented Requirements

| Requirement | Implementation |
| --- | --- |
| Material Design 3 UI | Light/dark themes, responsive grids, custom recipe/category widgets |
| Navigation | GoRouter with protected routes and 6 main screens: Home, Category list, Details, Favorites, Add recipe, Profile |
| Dynamic lists | GridView/SliverGrid and ListView builders, pull-to-refresh, search and filtering |
| Forms and validation | Auth/reset forms and custom recipe form with text, number, dropdown, multiline fields, real-time validation |
| Public API | TheMealDB repository with GET endpoints and error/loading states; optional public POST feedback call |
| Local storage | SharedPreferences for theme, language, and cached recently viewed recipes |
| State management | Riverpod Notifier/AsyncNotifier providers for auth, settings, home/search, repositories |
| Animations | AnimatedContainer category tiles, Hero recipe images, FadeTransition search results |
| Localization | Ukrainian, English, Polish with language switcher and persisted selection |
| Camera/Gallery | image_picker camera/gallery selection and preview; Firebase Storage upload when configured |
| Firebase | Auth, Firestore favorites/custom recipes, Storage upload; demo fallback works without Firebase config |
| Tests | 7 unit tests and 3 widget tests, all passing |

## Tech Stack

- Flutter 3.44.1 / Dart 3.12.1
- Riverpod 3
- GoRouter
- Firebase Auth, Cloud Firestore, Firebase Storage
- SharedPreferences
- image_picker
- TheMealDB API

## Run Locally

```powershell
.\flutter\bin\flutter.bat pub get
.\flutter\bin\flutter.bat run
```

For Android, open an emulator or connect a device before `flutter run`.

## Firebase Setup

The app runs in demo mode until real Firebase options are added. To enable real Auth, Firestore, and Storage:

1. Create a Firebase project on the Spark plan.
2. Enable Email/Password Authentication.
3. Create Firestore and Firebase Storage.
4. Install FlutterFire CLI and configure the project:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

5. Replace `lib/firebase_options.dart` with the generated file.
6. Add Android/iOS Firebase files if FlutterFire asks for them.

Suggested Firestore shape:

```text
users/{userId}/favorites/{mealId}
users/{userId}/recipes/{recipeId}
```

Suggested Storage path:

```text
users/{userId}/recipes/{timestamp}_{filename}
```

## Tests

```powershell
.\flutter\bin\flutter.bat analyze
.\flutter\bin\flutter.bat test
```

Current verification:

- `flutter analyze`: no issues found
- `flutter test`: 10 tests passed

## Project Structure

```text
lib/
  core/
    constants/
    firebase/
    l10n/
    router/
    theme/
    utils/
  features/
    auth/
    details/
    favorites/
    home/
    profile/
    settings/
    user_recipes/
test/
  unit/
  widget/
```
