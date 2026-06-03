import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../home/domain/meal_models.dart';
import '../domain/user_recipe.dart';

final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  if (firebaseReady) {
    return FirebaseUserDataRepository(
      FirebaseFirestore.instance,
      FirebaseStorage.instance,
    );
  }
  return MemoryUserDataRepository();
});

abstract class UserDataRepository {
  Stream<List<FavoriteRecipe>> watchFavorites(String userId);
  Future<bool> isFavorite(String userId, String mealId);
  Future<void> toggleFavorite(String userId, MealSummary meal);
  Stream<List<UserRecipe>> watchRecipes(String userId);
  Future<void> addRecipe(String userId, UserRecipeDraft draft, XFile? photo);
  Future<void> updateRecipe(String userId, UserRecipe recipe);
  Future<void> deleteRecipe(String userId, String recipeId);
}

class FirebaseUserDataRepository implements UserDataRepository {
  FirebaseUserDataRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _favorites(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  CollectionReference<Map<String, dynamic>> _recipes(String userId) {
    return _firestore.collection('users').doc(userId).collection('recipes');
  }

  @override
  Stream<List<FavoriteRecipe>> watchFavorites(String userId) {
    return _favorites(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FavoriteRecipe.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<bool> isFavorite(String userId, String mealId) async {
    final doc = await _favorites(userId).doc(mealId).get();
    return doc.exists;
  }

  @override
  Future<void> toggleFavorite(String userId, MealSummary meal) async {
    final doc = _favorites(userId).doc(meal.id);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
      return;
    }
    await doc.set(FavoriteRecipe.fromMeal(meal).toJson());
  }

  @override
  Stream<List<UserRecipe>> watchRecipes(String userId) {
    return _recipes(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserRecipe.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> addRecipe(
    String userId,
    UserRecipeDraft draft,
    XFile? photo,
  ) async {
    String? photoUrl;
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final ref = _storage.ref().child(
        'users/$userId/recipes/${DateTime.now().millisecondsSinceEpoch}_${photo.name}',
      );
      final upload = await ref.putData(
        bytes,
        SettableMetadata(contentType: photo.mimeType ?? 'image/jpeg'),
      );
      photoUrl = await upload.ref.getDownloadURL();
    }

    await _recipes(userId).add(
      UserRecipe(
        id: '',
        title: draft.title,
        category: draft.category,
        ingredients: draft.ingredients,
        steps: draft.steps,
        servings: draft.servings,
        notes: draft.notes,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      ).toJson(),
    );
  }

  @override
  Future<void> updateRecipe(String userId, UserRecipe recipe) {
    return _recipes(userId).doc(recipe.id).update(recipe.toJson());
  }

  @override
  Future<void> deleteRecipe(String userId, String recipeId) {
    return _recipes(userId).doc(recipeId).delete();
  }
}

class MemoryUserDataRepository implements UserDataRepository {
  final Map<String, List<FavoriteRecipe>> _favorites = {};
  final Map<String, List<UserRecipe>> _recipes = {};
  final _favoritesController =
      StreamController<Map<String, List<FavoriteRecipe>>>.broadcast();
  final _recipesController =
      StreamController<Map<String, List<UserRecipe>>>.broadcast();

  @override
  Stream<List<FavoriteRecipe>> watchFavorites(String userId) async* {
    yield _favorites[userId] ?? [];
    yield* _favoritesController.stream.map((items) => items[userId] ?? []);
  }

  @override
  Future<bool> isFavorite(String userId, String mealId) async {
    return (_favorites[userId] ?? []).any((item) => item.id == mealId);
  }

  @override
  Future<void> toggleFavorite(String userId, MealSummary meal) async {
    final items = [...?_favorites[userId]];
    final index = items.indexWhere((item) => item.id == meal.id);
    if (index >= 0) {
      items.removeAt(index);
    } else {
      items.insert(0, FavoriteRecipe.fromMeal(meal));
    }
    _favorites[userId] = items;
    _favoritesController.add(Map.unmodifiable(_favorites));
  }

  @override
  Stream<List<UserRecipe>> watchRecipes(String userId) async* {
    yield _recipes[userId] ?? [];
    yield* _recipesController.stream.map((items) => items[userId] ?? []);
  }

  @override
  Future<void> addRecipe(
    String userId,
    UserRecipeDraft draft,
    XFile? photo,
  ) async {
    final recipe = UserRecipe(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: draft.title,
      category: draft.category,
      ingredients: draft.ingredients,
      steps: draft.steps,
      servings: draft.servings,
      notes: draft.notes,
      photoUrl: null,
      createdAt: DateTime.now(),
    );
    _recipes[userId] = [recipe, ...?_recipes[userId]];
    _recipesController.add(Map.unmodifiable(_recipes));
  }

  @override
  Future<void> updateRecipe(String userId, UserRecipe recipe) async {
    _recipes[userId] = (_recipes[userId] ?? []).map((item) {
      return item.id == recipe.id ? recipe : item;
    }).toList();
    _recipesController.add(Map.unmodifiable(_recipes));
  }

  @override
  Future<void> deleteRecipe(String userId, String recipeId) async {
    _recipes[userId] = (_recipes[userId] ?? [])
        .where((item) => item.id != recipeId)
        .toList();
    _recipesController.add(Map.unmodifiable(_recipes));
  }
}
