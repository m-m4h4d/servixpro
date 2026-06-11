import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DBHelper {
  static const String _dbName = 'servixpro.db';
  static const int _dbVersion = 2;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    if (kIsWeb) {
      return await databaseFactoryFfiWeb.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
        ),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN profileImage TEXT');
    }
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        profileImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE services(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        providerId TEXT NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        rating REAL DEFAULT 0.0,
        availability INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings(
        id TEXT PRIMARY KEY,
        serviceId TEXT NOT NULL,
        customerId TEXT NOT NULL,
        bookingDate TEXT NOT NULL,
        bookingStatus TEXT NOT NULL,
        notes TEXT
      )
    ''');
  }
}
