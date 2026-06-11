class BookingModel {
  final String id;
  final String serviceId;
  final String customerId;
  final String bookingDate;
  final String bookingStatus; // 'Pending', 'Accepted', 'Rejected', 'Completed'
  final String? notes;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.customerId,
    required this.bookingDate,
    required this.bookingStatus,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'customerId': customerId,
      'bookingDate': bookingDate,
      'bookingStatus': bookingStatus,
      'notes': notes,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'],
      serviceId: map['serviceId'],
      customerId: map['customerId'],
      bookingDate: map['bookingDate'],
      bookingStatus: map['bookingStatus'],
      notes: map['notes'],
    );
  }
}
