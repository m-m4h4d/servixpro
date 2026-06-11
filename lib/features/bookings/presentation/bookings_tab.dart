import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final isProvider = user?.role == 'Provider';
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isProvider ? 'Booking Requests' : 'My Bookings'),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Service ID: ${booking.serviceId}'),
                  subtitle: Text('Status: ${booking.bookingStatus}\nDate: ${booking.bookingDate}'),
                  trailing: isProvider && booking.bookingStatus == 'Pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () {
                                ref.read(bookingControllerProvider.notifier).updateBookingStatus(booking.id, 'Accepted');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                ref.read(bookingControllerProvider.notifier).updateBookingStatus(booking.id, 'Rejected');
                              },
                            ),
                          ],
                        )
                      : Text(booking.bookingStatus, style: TextStyle(
                          color: booking.bookingStatus == 'Accepted' ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        )),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
