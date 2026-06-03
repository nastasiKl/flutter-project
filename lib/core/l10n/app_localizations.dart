import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('uk'), Locale('en'), Locale('pl')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String t(String key) {
    return _strings[locale.languageCode]?[key] ?? _strings['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const _strings = {
  'uk': {
    'appName': 'FoodHub',
    'welcome': 'Смачна навігація світом рецептів',
    'email': 'Email',
    'password': 'Пароль',
    'name': 'Імʼя',
    'login': 'Увійти',
    'register': 'Реєстрація',
    'createAccount': 'Створити акаунт',
    'forgotPassword': 'Забули пароль?',
    'sendReset': 'Надіслати лист',
    'logout': 'Вийти',
    'home': 'Головна',
    'favorites': 'Улюблені',
    'addRecipe': 'Мій рецепт',
    'profile': 'Профіль',
    'settings': 'Налаштування',
    'categories': 'Категорії',
    'recipeOfDay': 'Рецепт дня',
    'searchHint': 'Шукайте рецепт або інгредієнт',
    'search': 'Пошук',
    'byName': 'Назва',
    'byIngredient': 'Інгредієнт',
    'emptySearch': 'Почніть із запиту або відкрийте категорію',
    'noResults': 'Нічого не знайдено',
    'ingredients': 'Інгредієнти',
    'instructions': 'Інструкція',
    'video': 'Відео',
    'addToFavorites': 'Додати в улюблені',
    'removeFromFavorites': 'Прибрати з улюблених',
    'pullToRefresh': 'Оновіть список',
    'title': 'Назва',
    'category': 'Категорія',
    'servings': 'Порції',
    'steps': 'Кроки приготування',
    'notes': 'Нотатки',
    'pickGallery': 'Галерея',
    'pickCamera': 'Камера',
    'saveRecipe': 'Зберегти рецепт',
    'requiredField': 'Заповніть поле',
    'invalidEmail': 'Введіть коректний email',
    'shortPassword': 'Мінімум 6 символів',
    'positiveNumber': 'Введіть число більше 0',
    'theme': 'Тема',
    'language': 'Мова',
    'darkMode': 'Темна тема',
    'recentMeals': 'Останні переглянуті',
    'myRecipes': 'Мої рецепти',
    'firebaseDemo':
        'Demo mode: додайте Firebase config для реальних Auth, Firestore і Storage.',
    'saved': 'Збережено',
    'error': 'Помилка',
    'retry': 'Повторити',
    'protectedInfo': 'Цей розділ доступний після входу.',
    'alreadyAccount': 'Вже маєте акаунт?',
    'needAccount': 'Потрібен акаунт?',
    'resetInfo': 'Ми надішлемо посилання для відновлення пароля.',
  },
  'en': {
    'appName': 'FoodHub',
    'welcome': 'A smart way to explore recipes',
    'email': 'Email',
    'password': 'Password',
    'name': 'Name',
    'login': 'Sign in',
    'register': 'Register',
    'createAccount': 'Create account',
    'forgotPassword': 'Forgot password?',
    'sendReset': 'Send reset email',
    'logout': 'Sign out',
    'home': 'Home',
    'favorites': 'Favorites',
    'addRecipe': 'My recipe',
    'profile': 'Profile',
    'settings': 'Settings',
    'categories': 'Categories',
    'recipeOfDay': 'Recipe of the day',
    'searchHint': 'Search recipe or ingredient',
    'search': 'Search',
    'byName': 'Name',
    'byIngredient': 'Ingredient',
    'emptySearch': 'Start with a query or open a category',
    'noResults': 'No results found',
    'ingredients': 'Ingredients',
    'instructions': 'Instructions',
    'video': 'Video',
    'addToFavorites': 'Add to favorites',
    'removeFromFavorites': 'Remove favorite',
    'pullToRefresh': 'Refresh the list',
    'title': 'Title',
    'category': 'Category',
    'servings': 'Servings',
    'steps': 'Cooking steps',
    'notes': 'Notes',
    'pickGallery': 'Gallery',
    'pickCamera': 'Camera',
    'saveRecipe': 'Save recipe',
    'requiredField': 'This field is required',
    'invalidEmail': 'Enter a valid email',
    'shortPassword': 'Use at least 6 characters',
    'positiveNumber': 'Enter a number above 0',
    'theme': 'Theme',
    'language': 'Language',
    'darkMode': 'Dark theme',
    'recentMeals': 'Recently viewed',
    'myRecipes': 'My recipes',
    'firebaseDemo':
        'Demo mode: add Firebase config for real Auth, Firestore, and Storage.',
    'saved': 'Saved',
    'error': 'Error',
    'retry': 'Retry',
    'protectedInfo': 'This section is available after sign in.',
    'alreadyAccount': 'Already have an account?',
    'needAccount': 'Need an account?',
    'resetInfo': 'We will send a password reset link.',
  },
  'pl': {
    'appName': 'FoodHub',
    'welcome': 'Wygodny sposób na odkrywanie przepisów',
    'email': 'Email',
    'password': 'Hasło',
    'name': 'Imię',
    'login': 'Zaloguj',
    'register': 'Rejestracja',
    'createAccount': 'Utwórz konto',
    'forgotPassword': 'Nie pamiętasz hasła?',
    'sendReset': 'Wyślij link',
    'logout': 'Wyloguj',
    'home': 'Start',
    'favorites': 'Ulubione',
    'addRecipe': 'Mój przepis',
    'profile': 'Profil',
    'settings': 'Ustawienia',
    'categories': 'Kategorie',
    'recipeOfDay': 'Przepis dnia',
    'searchHint': 'Szukaj przepisu lub składnika',
    'search': 'Szukaj',
    'byName': 'Nazwa',
    'byIngredient': 'Składnik',
    'emptySearch': 'Wpisz zapytanie albo otwórz kategorię',
    'noResults': 'Brak wyników',
    'ingredients': 'Składniki',
    'instructions': 'Instrukcja',
    'video': 'Wideo',
    'addToFavorites': 'Dodaj do ulubionych',
    'removeFromFavorites': 'Usuń z ulubionych',
    'pullToRefresh': 'Odśwież listę',
    'title': 'Tytuł',
    'category': 'Kategoria',
    'servings': 'Porcje',
    'steps': 'Kroki gotowania',
    'notes': 'Notatki',
    'pickGallery': 'Galeria',
    'pickCamera': 'Kamera',
    'saveRecipe': 'Zapisz przepis',
    'requiredField': 'To pole jest wymagane',
    'invalidEmail': 'Wpisz poprawny email',
    'shortPassword': 'Minimum 6 znaków',
    'positiveNumber': 'Wpisz liczbę większą od 0',
    'theme': 'Motyw',
    'language': 'Język',
    'darkMode': 'Ciemny motyw',
    'recentMeals': 'Ostatnio oglądane',
    'myRecipes': 'Moje przepisy',
    'firebaseDemo':
        'Tryb demo: dodaj Firebase config dla Auth, Firestore i Storage.',
    'saved': 'Zapisano',
    'error': 'Błąd',
    'retry': 'Ponów',
    'protectedInfo': 'Ta sekcja jest dostępna po zalogowaniu.',
    'alreadyAccount': 'Masz już konto?',
    'needAccount': 'Potrzebujesz konta?',
    'resetInfo': 'Wyślemy link resetowania hasła.',
  },
};
