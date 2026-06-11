import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../services/providers/service_provider.dart';

final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return [];

  final repository = ref.watch(bookingRepositoryProvider);

  if (user.role == 'Customer') {
    return repository.getBookingsForCustomer(user.id);
  } else {
    // For Provider: get their services first, then get bookings for those services
    final services = await ref.watch(providerServicesProvider.future);
    final serviceIds = services.map((e) => e.id).toList();
    return repository.getBookingsForProviderServices(serviceIds);
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

  Future<void> createBooking(BookingModel booking) async {
    state = true;
    try {
      await _repository.createBooking(booking);
      ref.invalidate(myBookingsProvider);
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
