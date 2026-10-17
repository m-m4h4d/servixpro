import 'package:flutter_test/flutter_test.dart';
import 'package:servixpro/features/auth/models/user.dart';
import 'package:servixpro/features/bookings/models/booking_model.dart';
import 'package:servixpro/features/services/models/service_model.dart';

void main() {
  test('UserModel reads a profiles row', () {
    final user = UserModel.fromMap({
      'id': 'u1',
      'full_name': 'Ada Lovelace',
      'email': 'ada@example.com',
      'phone': '123',
      'role': 'Provider',
      'profile_image': null,
    });

    expect(user.fullName, 'Ada Lovelace');
    expect(user.role, 'Provider');
    expect(user.copyWith(profileImage: 'https://x/y.png').profileImage, 'https://x/y.png');
  });

  test('ServiceModel reads a services row with integer numerics', () {
    final service = ServiceModel.fromMap({
      'id': 's1',
      'title': 'Fix sink',
      'description': 'Leaky tap repair',
      'category': 'Plumbing',
      'provider_id': 'u1',
      'price': 40,
      'image_url': null,
      'rating': 0,
      'availability': true,
      'created_at': '2026-10-17T12:00:00+00:00',
    });

    expect(service.price, 40.0);
    expect(service.rating, 0.0);
    expect(service.availability, isTrue);
  });

  test('BookingModel reads a bookings row', () {
    final booking = BookingModel.fromMap({
      'id': 'b1',
      'service_id': 's1',
      'customer_id': 'u2',
      'booking_date': '2026-10-20',
      'booking_status': 'Pending',
      'notes': null,
      'services': {'provider_id': 'u1'},
    });

    expect(booking.serviceId, 's1');
    expect(booking.bookingStatus, 'Pending');
  });
}
