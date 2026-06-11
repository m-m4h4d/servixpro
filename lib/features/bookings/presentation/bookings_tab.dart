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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(booking.bookingStatus, style: TextStyle(
                          color: booking.bookingStatus == 'Accepted' ? Colors.green : (booking.bookingStatus == 'Cancelled' || booking.bookingStatus == 'Rejected' ? Colors.red : Colors.grey),
                          fontWeight: FontWeight.bold,
                      )),
                      if (isProvider && booking.bookingStatus == 'Pending') ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Accept Booking',
                          onPressed: () {
                            ref.read(bookingControllerProvider.notifier).updateBookingStatus(booking.id, 'Accepted');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Reject Booking',
                          onPressed: () {
                            ref.read(bookingControllerProvider.notifier).updateBookingStatus(booking.id, 'Rejected');
                          },
                        ),
                      ],
                      if (!isProvider && (booking.bookingStatus == 'Pending' || booking.bookingStatus == 'Accepted')) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'Cancel Booking',
                          onPressed: () {
                            ref.read(bookingControllerProvider.notifier).updateBookingStatus(booking.id, 'Cancelled');
                          },
                        ),
                      ]
                    ],
                  ),
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
