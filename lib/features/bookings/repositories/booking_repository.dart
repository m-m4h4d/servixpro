import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_config.dart';
import '../models/booking_model.dart';

final bookingRepositoryProvider = Provider((ref) => BookingRepository());

class BookingRepository {
  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    String? notes,
  }) async {
    // customer_id and booking_status default to the caller and 'Pending'.
    final map = await supabase
        .from('bookings')
        .insert({
          'service_id': serviceId,
          'booking_date': bookingDate.toIso8601String().split('T').first,
          'notes': notes,
        })
        .select()
        .single();
    return BookingModel.fromMap(map);
  }

  Future<List<BookingModel>> getBookingsForCustomer(String customerId) async {
    final maps = await supabase
        .from('bookings')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return maps.map(BookingModel.fromMap).toList();
  }

  Future<List<BookingModel>> getBookingsForProvider(String providerId) async {
    final maps = await supabase
        .from('bookings')
        .select('*, services!inner(provider_id)')
        .eq('services.provider_id', providerId)
        .order('created_at', ascending: false);
    return maps.map(BookingModel.fromMap).toList();
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await supabase.from('bookings').update({'booking_status': newStatus}).eq('id', bookingId);
  }
}
