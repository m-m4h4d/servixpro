import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  late final AuthRepository _repository;

  @override
  UserModel? build() {
    _repository = ref.watch(authRepositoryProvider);

    // Keep the profile in sync with the Supabase session (restored sessions,
    // token refreshes, sign-outs from elsewhere).
    final subscription = _repository.authStateChanges.listen((data) {
      final user = data.session?.user;
      if (user == null) {
        state = null;
      } else if (state?.id != user.id) {
        _loadProfile(user.id);
      }
    });
    ref.onDispose(subscription.cancel);

    return null;
  }

  Future<void> _loadProfile(String userId) async {
    try {
      state = await _repository.getUserById(userId);
    } catch (_) {
      // Leave the state as is; screens will show the signed-out view.
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _repository.login(email, password);
      await _loadProfile(_repository.currentUser!.id);
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Login failed. Check your connection and try again.';
    }
  }

  /// Returns null on success, or a message to show the user. [needsConfirmation]
  /// is set when the project requires email confirmation before signing in.
  Future<({String? error, bool needsConfirmation})> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    try {
      final signedIn = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );
      if (!signedIn) return (error: null, needsConfirmation: true);
      await _loadProfile(_repository.currentUser!.id);
      return (error: null, needsConfirmation: false);
    } on AuthException catch (e) {
      return (error: e.message, needsConfirmation: false);
    } catch (e) {
      return (error: 'Sign up failed. Check your connection and try again.', needsConfirmation: false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }

  Future<void> updateProfileImage(Uint8List bytes, String? extension) async {
    final currentUser = state;
    if (currentUser != null) {
      final url = await _repository.updateProfileImage(currentUser.id, bytes, extension);
      state = currentUser.copyWith(profileImage: url);
    }
  }
}
