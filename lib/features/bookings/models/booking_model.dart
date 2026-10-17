class BookingModel {
  final String id;
  final String serviceId;
  final String customerId;
  final String bookingDate;
  final String bookingStatus; // 'Pending', 'Accepted', 'Rejected', 'Cancelled', 'Completed'
  final String? notes;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.customerId,
    required this.bookingDate,
    required this.bookingStatus,
    this.notes,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      serviceId: map['service_id'],
      customerId: map['customer_id'],
      bookingDate: map['booking_date'],
      bookingStatus: map['booking_status'],
      notes: map['notes'],
    );
  }
}
