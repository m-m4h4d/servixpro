class ServiceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String providerId;
  final double price;
  final String? imageUrl;
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
    this.imageUrl,
    this.rating = 0.0,
    this.availability = true,
    required this.createdAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      providerId: map['provider_id'],
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'],
      rating: (map['rating'] as num? ?? 0).toDouble(),
      availability: map['availability'] ?? true,
      createdAt: map['created_at'],
    );
  }
}
