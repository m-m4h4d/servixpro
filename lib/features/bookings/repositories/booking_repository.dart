import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/local_db/db_helper.dart';
import '../models/booking_model.dart';

final bookingRepositoryProvider = Provider((ref) => BookingRepository());

class BookingRepository {
  Future<void> createBooking(BookingModel booking) async {
    final db = await DBHelper.database;
    await db.insert(
      'bookings',
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BookingModel>> getBookingsForCustomer(String customerId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
    return maps.map((e) => BookingModel.fromMap(e)).toList();
  }

  Future<List<BookingModel>> getBookingsForProviderServices(List<String> serviceIds) async {
    if (serviceIds.isEmpty) return [];
    
    final db = await DBHelper.database;
    final placeholders = List.filled(serviceIds.length, '?').join(',');
    
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'serviceId IN ($placeholders)',
      whereArgs: serviceIds,
    );
    return maps.map((e) => BookingModel.fromMap(e)).toList();
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    final db = await DBHelper.database;
    await db.update(
      'bookings',
      {'bookingStatus': newStatus},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }
}
