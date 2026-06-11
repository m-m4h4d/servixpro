class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String providerId;
  final double price;
  final String? imagePath;
  final double rating;
  final bool availability;
  final String createdAt;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.providerId,
    required this.price,
    this.imagePath,
    this.rating = 0.0,
    this.availability = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'providerId': providerId,
      'price': price,
      'imagePath': imagePath,
      'rating': rating,
      'availability': availability ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      providerId: map['providerId'],
      price: map['price'],
      imagePath: map['imagePath'],
      rating: map['rating'],
      availability: map['availability'] == 1,
      createdAt: map['createdAt'],
    );
  }
}
