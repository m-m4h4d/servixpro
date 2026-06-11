import 'package:sqflite/sqflite.dart';
import '../../../core/local_db/db_helper.dart';
import '../models/user.dart';

class AuthRepository {
  Future<UserModel?> login(String email, String password) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<void> signUp(UserModel user) async {
    final db = await DBHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateProfileImage(String id, String imagePath) async {
    final db = await DBHelper.database;
    await db.update(
      'users',
      {'profileImage': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
