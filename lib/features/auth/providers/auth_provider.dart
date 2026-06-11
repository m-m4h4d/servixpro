import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/shared_prefs/shared_prefs_helper.dart';
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
    _loadSession();
    return null;
  }

  Future<void> _loadSession() async {
    final userId = SharedPrefsHelper.loggedInUserId;
    if (userId != null) {
      final user = await _repository.getUserById(userId);
      state = user;
    }
  }

  Future<String?> login(String email, String password) async {
    final user = await _repository.login(email, password);
    if (user != null) {
      await SharedPrefsHelper.setLoggedInUserId(user.id);
      state = user;
      return null; // Success
    }
    return 'Invalid email or password';
  }

  Future<String?> signUp(UserModel user) async {
    final exists = await _repository.checkEmailExists(user.email);
    if (exists) {
      return 'Email already exists';
    }
    try {
      await _repository.signUp(user);
      await SharedPrefsHelper.setLoggedInUserId(user.id);
      state = user;
      return null; // Success
    } catch (e) {
      return 'Sign up failed';
    }
  }

  Future<void> logout() async {
    await SharedPrefsHelper.clearSession();
    state = null;
  }
}
