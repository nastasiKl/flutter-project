import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider = NotifierProvider<AuthController, AuthFormState>(
  AuthController.new,
);

class AuthFormState {
  const AuthFormState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;
}

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<bool> signIn(String email, String password) async {
    return _run(() {
      return ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
    });
  }

  Future<bool> signUp(String name, String email, String password) async {
    return _run(() {
      return ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password);
    });
  }

  Future<bool> resetPassword(String email) async {
    return _run(() {
      return ref.read(authRepositoryProvider).sendPasswordReset(email);
    });
  }

  Future<void> signOut() {
    return ref.read(authRepositoryProvider).signOut();
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = const AuthFormState(isLoading: true);
    try {
      await action();
      state = const AuthFormState();
      return true;
    } on AuthFailure catch (error) {
      state = AuthFormState(error: error.message);
      return false;
    } on Object catch (error) {
      state = AuthFormState(error: error.toString());
      return false;
    }
  }
}
