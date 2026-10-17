import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';
import '../../auth/providers/auth_provider.dart';

final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];

  final repository = ref.watch(bookingRepositoryProvider);

  if (user.role == 'Customer') {
    return repository.getBookingsForCustomer(user.id);
  } else {
    return repository.getBookingsForProvider(user.id);
  }
});

final bookingControllerProvider = NotifierProvider<BookingController, bool>(() {
  return BookingController();
});

class BookingController extends Notifier<bool> {
  late final BookingRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(bookingRepositoryProvider);
    return false;
  }

  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    String? notes,
  }) async {
    state = true;
    try {
      final booking = await _repository.createBooking(
        serviceId: serviceId,
        bookingDate: bookingDate,
        notes: notes,
      );
      ref.invalidate(myBookingsProvider);
      return booking;
    } finally {
      state = false;
    }
  }

  Future<void> updateBookingStatus(String id, String status) async {
    state = true;
    try {
      await _repository.updateBookingStatus(id, status);
      ref.invalidate(myBookingsProvider);
    } finally {
      state = false;
    }
  }
}
