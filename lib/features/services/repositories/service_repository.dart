import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/local_db/db_helper.dart';
import '../models/service_model.dart';

final serviceRepositoryProvider = Provider((ref) => ServiceRepository());

class ServiceRepository {
  Future<void> createService(ServiceModel service) async {
    final db = await DBHelper.database;
    await db.insert(
      'services',
      service.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ServiceModel>> getAllServices() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('services');
    return maps.map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<List<ServiceModel>> getServicesByProvider(String providerId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'providerId = ?',
      whereArgs: [providerId],
    );
    return maps.map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<void> updateService(ServiceModel service) async {
    final db = await DBHelper.database;
    await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<void> deleteService(String id) async {
    final db = await DBHelper.database;
    await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
