import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/storage_helper.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/user.dart';

class AuthRepository {
  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Returns true if the user is signed in straight away, false if they must
  /// confirm their email first.
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    // The profile row is created by the on_auth_user_created trigger from this metadata.
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone, 'role': role},
    );
    return response.session != null;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<UserModel?> getUserById(String id) async {
    final map = await supabase.from('profiles').select().eq('id', id).maybeSingle();
    return map == null ? null : UserModel.fromMap(map);
  }

  Future<String> updateProfileImage(String id, Uint8List bytes, String? extension) async {
    final url = await StorageHelper.uploadImage(bytes, name: 'avatar', extension: extension);
    await supabase.from('profiles').update({'profile_image': url}).eq('id', id);
    return url;
  }
}
