import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseReady = ref.watch(firebaseReadyProvider);
  if (firebaseReady) {
    return FirebaseAuthRepository(firebase_auth.FirebaseAuth.instance);
  }
  return MemoryAuthRepository();
});

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final firebase_auth.FirebaseAuth _auth;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      return user == null ? null : AppUser.fromFirebase(user);
    });
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AppUser.fromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthFailure(error.message ?? error.code);
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return AppUser.fromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthFailure(error.message ?? error.code);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class MemoryAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (password.length < 6) {
      throw AuthFailure('Password must contain at least 6 characters.');
    }
    _currentUser = AppUser(id: email.hashCode.toString(), email: email);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (password.length < 6) {
      throw AuthFailure('Password must contain at least 6 characters.');
    }
    _currentUser = AppUser(
      id: email.hashCode.toString(),
      email: email,
      displayName: name,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
